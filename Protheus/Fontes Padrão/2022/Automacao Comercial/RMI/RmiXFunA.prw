#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "RMIXFUNA.CH"

Static cRetF3Fil := ""      //Filiais selecionadas utilizado nas funções RmiXF3Fil e RmiXF3FilR

//--------------------------------------------------------
/*/{Protheus.doc} RmiGrvLog
Grava Log da Integração RMI para posterior análise no Monitor

@param 		cStatus    -> Status que sera gravado no registro da tebela de vendas
@param 		cAlias     -> Alias da tabela de vendas
@param 		nRecno     -> Recno do registro que sera atualizado o status
@param 		cCodMen    -> Codigo da mensagem
@param 		cErro      -> Erro que foi encontrado na verificacao
@param 		lRegNew    -> Parametro que identifica se inclui um novo registro ou
                        atualiza o registro ja existente na tabela
@param 		cFilStatus -> Campo que sera atualizado o status na tabela
@param 		lUpdStatus -> Identifica se faz atualização de status 
@param 		nIndice    -> Numero do índice da tabela origem para busca
@param 		cChave     -> Chave da tabela origem para busca
@param 		cProcesso  -> Processo de Origem do Erro
@param 		cAssinante -> Assinante do processo de origem do erro
@param 		cUIDOrigem -> UUID do Processo de Origem do Erro.
@author  	Varejo
@version 	1.0
@since    03/09/2019
@return	  Nao ha
/*/
//--------------------------------------------------------
Function RmiGrvLog( cStatus     , cAlias     , nRecno    , cCodMen    ,;
                    cErro       , lRegNew    , lTxt      , cFilStatus ,;
                    lUpdStatus  , nIndice    , cChave    , cProcesso  ,;
                    cAssinante  , cUIDOrigem )
   
    Local aArea         := GetArea()                            //Guarda a area
    Local nSeq          := 0                                    //Sequencia dos registros
    Local lGrvIndice    := MHL->(ColumnPos("MHL_INDICE")) > 0   //Valida se grava Indice para busca
    Local lGrvChave     := MHL->(ColumnPos("MHL_CHAVE" )) > 0   //Valida se grava Chave para busca
    Local lGrvProce     := MHL->(ColumnPos("MHL_CPROCE")) > 0 
    Local lGrvAssin     := MHL->(ColumnPos("MHL_CASSIN")) > 0 
    Local lUIDORI       := MHL->(ColumnPos("MHL_UIDORI")) > 0
    Local nRecnoMHL     := 0
   
    Default lRegNew     := .F.
    Default lTxt        := .F.
    Default cStatus     := ""
    Default cAlias      := ""
    Default nRecno      := 0
    Default cCodMen     := ""
    Default cErro       := ""
    Default cFilStatus  := "L1_SITUA"
    Default lUpdStatus  := .T.
    Default nIndice     := 0
    Default cChave      := ""
    Default cProcesso   := ""
    Default cAssinante  := ""
    DEFAULT cUIDOrigem  := ""

    LjGrvLog("RMIXFUNA","Inicio da função RmiGrvLog")
    
    DbSelectArea("MHL")
    MHL->( DbSetOrder(1) )  //MHL_FILIAL+MHL_ALIAS+STR(MHL_RECNO,12,0)+MHL_SEQ

    //Se já existe o registro de log, o sistema pode apenas alterar o registro que ja
    //existe, como pode incluir um novo registro, tudo vai depender de como vai vir o 
    //parametro lRegNew
    If MHL->( DbSeek(xFilial("MHL") + cAlias + Str(nRecno, 12, 0)) )

        nRecnoMHL := MHL->( Recno() )

        //Loop para buscar a sequencia do ultimo registro e acrescentar mais um
        While MHL->(!Eof()) .AND. AllTrim(MHL->MHL_FILIAL+MHL->MHL_ALIAS+Str(MHL->MHL_RECNO, 12, 0)) == AllTrim(xFilial("MHL") + cAlias + Str(nRecno, 12, 0))
            nSeq      := MHL->MHL_SEQ
            nRecnoMHL := MHL->( Recno() )

            MHL->( DbSkip() )
        End
        nSeq++

        MHL->( DbGoTo(nRecnoMHL) )

    //Se não existe o registro de log incluo as informações            
    Else

        lRegNew := .T.
        nSeq    := 1
    EndIf

    Begin Transaction
        
        LjGrvLog("RMIXFUNA",IIf(lRegNew,"Incluindo","Alterando") + " dado na tabela MHL")
        RecLock("MHL", lRegNew)
            MHL->MHL_FILIAL := xFilial("MHL")
            MHL->MHL_STATUS := cStatus
            MHL->MHL_DATA   := Date()
            MHL->MHL_HORA   := Time()
            MHL->MHL_ALIAS  := cAlias
            MHL->MHL_RECNO  := nRecno
            MHL->MHL_CODMEN := cCodMen
            MHL->MHL_ERROR  := cErro
            MHL->MHL_SEQ 	:= nSeq

            IIF(lGrvIndice, MHL->MHL_INDICE  := nIndice,)
            IIF(lGrvChave , MHL->MHL_CHAVE   := cChave,)
            IIF(lGrvProce , MHL->MHL_CPROCE  := cProcesso,)
            IIF(lGrvAssin , MHL->MHL_CASSIN  := cAssinante,)
            IIF(lUIDORI   , MHL->MHL_UIDORI  := cUIDOrigem,)
        MHL->( MsUnLock() )
        LjGrvLog("RMIXFUNA","Inclusão/Alteração da MHL finalizada")

        If Alltrim(cAlias) $ "MHQ|MHR"
            cStatus := '3'
        EndIf

        //Atualiza o status conforme o registro que foi passado no parametro nRecno
        If lUpdStatus .And. !Empty(cStatus)
            LjGrvLog("RMIXFUNA","Vai Atualizar Status - Campo {Nome,Conteudo}", {cFilStatus,cStatus})
            DbSelectArea(cAlias)
            (cAlias)->( DbGoTo(nRecno) )

            If !(cAlias)->( Eof() )
                RecLock(cAlias, .F.)
                    &(cAlias + "->" + cFilStatus) := cStatus
                (cAlias)->( MsUnLock() )
                LjGrvLog("RMIXFUNA","Campo [" + cFilStatus + "] atualizado")
            EndIf
            LjGrvLog("RMIXFUNA","Final da atualização do campo Status")
        EndIf

        LjGrvLog("RMIXFUNA","Final da transação na função RmiGrvLog")
    End Transaction

    RestArea(aArea)

    LjGrvLog("RMIXFUNA","Final da função RmiGrvLog")

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} RmiPsqDePa
O objetivo desta funcao eh pesquisar o conteudo gravado 

@param 		cSisOri     -> Nome do sistema que enviou a informacao para o Protheus
@param 		cAlias      -> Tabela padrao no Protheus
@param 		cCampo      -> Campo da tabela padrao do Protheus
@param 		cContOri    -> Conteudo do campo que veio do sistema de origem
@param 		nIndex      -> Indece para realizar a pesquisa antes de pesquisar na tabela De/Para
@param 		cChave      -> Chave de pesquisa que sera utilizado antes de pesquisar na tabela De/Para
@author  	Varejo
@version 	1.0
@since      24/09/2019
@return	    cRet        -> Retorno do conteudo pesquisado na tabela padrao ou na tabela De/Para
/*/
//--------------------------------------------------------
Function RmiPsqDePa(cSisOri, cAlias, cCampo, cContOri, nIndex, cChave)

    Local uRet  := "" 			//Variavel de retorno
    Local aArea := GetArea() 	//Guarda a area
    Local aCod  := {}           //Variavel que ira receber duas posições Filial|Codigo

    Default cSisOri     := ""
    Default cAlias      := ""
    Default cCampo      := ""
    Default cContOri    := ""
    Default nIndex      := 0
    Default cChave      := ""
    
    If !Empty(cSisOri) .AND. !Empty(cAlias) .AND. !Empty(cCampo) .AND.;
       !Empty(cContOri) .AND. nIndex > 0 .AND. !Empty(cChave)

        If cAlias == "SX5"
            uRet := FWGetSX5 ("24",cContOri)
            If ValType(uRet) == "A" .AND. Len(uRet) >= 1
                uRet := uRet[1][3]
            Else
                uRet := ""
            EndIf
        EndIf

        If !(cAlias $ "SX5|SB1")
            dbSelectArea(cAlias)
            (cAlias)->(DbSetOrder(nIndex))
        EndIf

        If !(cAlias $ "SX5|SB1") .AND. (cAlias)->(dbSeek(cChave))
            If !(cAlias $ "SA1|SAE")
                uRet := &(cAlias + "->" + cCampo)
            ElseIf cAlias == "SA1"
                uRet := {}
                Aadd(uRet,SA1->A1_COD)
                Aadd(uRet,SA1->A1_LOJA)
            ElseIf cAlias == "SAE"
                uRet := AllTrim(SAE->AE_COD) + "-" + AllTrim(SAE->AE_DESC)
            EndIf
        Else
            
            If (cAlias == "SX5" .AND. Empty(uRet)) .OR. cAlias <> "SX5"

                cSisOri := PadR(cSisOri,TamSx3('MHM_SISORI')[1])
                cAlias  := PadR(cAlias,TamSx3('MHM_TABELA')[1])
                cCampo  := PadR(cCampo,TamSx3('MHM_CAMPO')[1])
                cContOri:= PadR(cContOri,TamSx3('MHM_VLORIG')[1])

                dbSelectArea("MHM")
                MHM->(dbSetOrder(1)) //MHM_FILIAL+MHM_SISORI+MHM_TABELA+MHM_CAMPO+MHM_VLORIG+MHM_FILINT+MHM_VLINT
                If MHM->(dbSeek(xFilial("MHM")+cSisOri+cAlias+cCampo+cContOri+xFilial(cAlias)))
                    If cAlias <> "SA1"
                        LjGrvLog("RmiPsqDePa","cAlias",cAlias)
                        LjGrvLog("RmiPsqDePa","dbSeek na MHM - Filtro",xFilial("MHM")+cSisOri+cAlias+cCampo+cContOri+xFilial(cAlias))
                        LjGrvLog("RmiPsqDePa","Conteudo do campo MHM_VLINT",MHM->MHM_VLINT)

                        //Incluimos esse tratamento com "At" pois em alguns casos o código do produto estava gravando com pipe na SL2, exemplo: L2_PRODUTO = |42587
                        //Quando executava o GravaBatch, estava gerando erro dizendo que o produto não existia na base
                        If At("|",MHM->MHM_VLINT) > 0
                            aCod := Separa(MHM->MHM_VLINT, "|")   
                            LjGrvLog("RmiPsqDePa","Conteudo do array aCod",aCod)
                            If Len(aCod) > 1
                                uRet := aCod[2]
                                LjGrvLog("RmiPsqDePa","Conteudo da variavel uRet",uRet)
                            Else
                                LjGrvLog("RmiPsqDePa","Variavel aCod nao tem mais de uma posicao.",aCod)
                                uRet := ""
                                LjGrvLog("RmiPsqDePa","Conteudo da variavel uRet",uRet)
                            EndIf
                        Else
                            uRet := MHM->MHM_VLINT
                            LjGrvLog("RmiPsqDePa","Conteudo da variavel uRet",uRet)
                        EndIf

                    Else
                        uRet := {}
                        uRet := Separa(MHM->MHM_VLINT, "|")
                    EndIf
                Else
                    If cAlias <> "SA1"
                        uRet := ""
                    Else
                        uRet := {}
                        Aadd(uRet,"")
                        Aadd(uRet,"")
                    EndIf
                EndIf

            EndIf

            //Pesquisa primeiro pelo codigo de barras
            If cAlias == "SB1" .AND. Empty(uRet)

                dbSelectArea("SLK")
                SB1->(DbSetOrder(1)) //LK_FILIAL+LK_CODBAR

                cContOri := PadR(cContOri,TamSx3('LK_CODBAR')[1])            

                If SLK->(dbSeek(xFilial('SLK')+cContOri))
                    uRet := SLK->LK_CODIGO
                Else
                    dbSelectArea("SB1")
                    SB1->(DbSetOrder(5)) //B1_FILIAL+B1_CODBAR

                    cContOri := PadR(cContOri,TamSx3('B1_CODBAR')[1])            

                    If SB1->(dbSeek(xFilial('SB1')+cContOri))
                        uRet := SB1->B1_COD
                    Else
                        dbSelectArea("SB1")
                        (cAlias)->(DbSetOrder(nIndex))

                        If (cAlias)->(dbSeek(cChave))
                            uRet := &(cAlias + "->" + cCampo)
                        EndIf

                    EndIf
                EndIf
            EndIf

        EndIf
        LjGrvLog("RmiPsqDePa","Final da funcao - Variavel cAlias",cAlias)
        LjGrvLog("RmiPsqDePa","Final da funcao - Variavel uRet",uRet)
    EndIf


    RestArea(aArea)

Return uRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiXSql
Função utilizada para rodar uma query e trazer o result em um array.

@Param aReplace - Array com os replaces para serem feitos após o changeQuery
				  [1] - Primeira parte do Replace
				  [2] - Segunda parte do Replace

@author  Rafael Tenorio da Costa
@since 	 31/10/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiXSql(cSQL, xCamposRet, lCommit, aReplace)

    Local aValor  := {}
    Local aArea   := GetArea()
    Local cQry	  := ""
    Local cTmp    := ""
    Local cAux    := ""
    Local nI      := 1
    Local nY      := 1
    Local aFldPos := {}
    Local aStru   := {}
    Local cType   := ""
    Local nJ      := 0

    Default cSQL       := ""
    Default xCamposRet := {}
    Default lCommit    := .T.
    Default aReplace   := {}

	If !Empty(cSQL) .And. !Empty(xCamposRet)

		If lCommit
			DbCommitAll() //Para efetivar a alteraï¿½ï¿½o no banco de dados (nï¿½o impacta no rollback da transaï¿½ï¿½o)
		EndIf

		cQry  := ChangeQuery(cSQL)

		If Len(aReplace) > 0
			For nJ := 1 to Len(aReplace)
				cQry := StrTran(cQry, aReplace[nJ][1], aReplace[nJ][2])
			Next
		EndIf
        LjGrvLog("RmiXSql","Query a ser executada ->",cQry)
		cTmp  := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), cTmp, .T., .F. )

		cType := ValType(xCamposRet)

		If cType == "A" .And. LEN(xCamposRet) == 1 .And. xCamposRet[1] == "*" // Tratamento para aceitar tanto "*" como {"*"}
			xCamposRet := "*"
			cType      := "C"
		EndIf

		If cType == "C"
			If xCamposRet == "*"
				xCamposRet := {}
				aStru := (cTmp)->(dbStruct())
				For nI := 1 to Len(aStru)
					aAdd(xCamposRet, aStru[nI][DBS_NAME])
				Next
			else
				cAux := xCamposRet
				xCamposRet := {}
				aAdd(xCamposRet, cAux)
			EndIf
		EndIF
		aFldPos := Array(Len(xCamposRet))

		While !(cTmp)->(EOF())

			aAdd(aValor, {})
			For nI := 1 to Len(xCamposRet)
				If aFldPos[nI] == Nil
					aFldPos[nI] := (cTmp)->(FieldPos(xCamposRet[nI]))
				EndIf
				aAdd(aValor[nY], (cTmp)->(FieldGet(aFldPos[nI])))
			Next
			nY += 1
			(cTmp)->(dbSkip())

		EndDo

		(cTmp)->( dbCloseArea() )

	EndIf

	RestArea( aArea )

Return aValor

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiXSelFil
Apresenta um tela com as filiais da empresa logada para seleção.

@author  Rafael Tenorio da Costa
@since 	 28/01/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiXSelFil()

    Local aSelFilial := {}
    Local cSelFilial := ""    
    Local nCont      := 0

    //Campos da SM0 retornados no array: { 'FLAG', 'SM0_CODFIL', 'SM0_NOMRED', 'SM0_CGC', 'SM0_INSC', 'SM0_INSCM' }
    aSelFilial := FwListBranches( .F./*lCheckUser*/, .F./*lAllEmp*/, /*lOnlySelect*/ , /*aRetInfo*/);
    
    If Len(aSelFilial) > 0 

        For nCont:=1 To Len(aSelFilial)
            cSelFilial += aSelFilial[nCont][2] + ";"
        Next nCont

        //cSelFilial := SubStr(cSelFilial, 1, Len(cSelFilial) - 1)
    EndIf

    Asize(aSelFilial, 0)

Return cSelFilial

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiXF3Fil
Utilizado em consultas padrões F3 para selecionar multiplas filiais.
 
@author  Rafael Tenorio da Costa
@since 	 29/01/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiXF3Fil()
    cRetF3Fil := RmiXSelFil()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiXF3FilR
Utilizado em consultas padrões F3 para retornar as filiais selecionadas.

@author  Rafael Tenorio da Costa
@since 	 29/01/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiXF3FilR()
Return cRetF3Fil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiXGetTag
Retonar o conteudo de uma tag do xml

@param cXml		- Xml de resposta do WebService
@param cTagIni	- Tag que tera o conteudo retornado
@param lTag		- Indica se deve retornar a tag tb

@author  Rafael Tenorio da Costa
@since 	 17/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiXGetTag(cXml, cTagIni, lTag)

	Local cRet 	  := ""
	Local cTagFim := ""
	Local nAtIni  := 0
	Local nAtFim  := 0
	Local nTamTag := 0

	Default lTag  := .T.

	cTagFim := StrTran(cTagIni, "<", "</")

	//Localização das tags na string do XML
	nAtIni := At( Lower(cTagIni), Lower(cXml) )
	nAtFim := At( Lower(cTagFim), Lower(cXml) )

	//Pega o valor entre a tag inicial e final
	If nAtIni > 0 .And. nAtFim > 0
		nTamTag := Len(cTagIni)
		cRet	:= SubStr(cXml, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag)
	Endif

	//Retorna a tag com o conteudo
	If !Empty(cRet) .And. lTag
		cRet := cTagIni + cRet + cTagFim
	EndIf

Return cRet
//--------------------------------------------------------
/*/{Protheus.doc} PagMovCx
Função para buscar o movimento do caixa de Sangria

@param 		aMoviPag  -> Array com os dados do movimento
@author  	Varejo
@version 	1.0
@since      08/07/2020
@return	    xRet       -> Retorna o VALORCONFERIDO
/*/
//--------------------------------------------------------
function PagMovCx(xMoviPag)
Local xRet  := ""
Local nX    := 0  
//Caso tenha apenas um registo gera um Objeto no Xml
If Valtype(xMoviPag) == "O"
    If Alltrim(xMoviPag:_FORMAPAGAMENTO:TEXT) = "DINHEIRO"
        xRet:= xMoviPag:_VALORCONFERIDO:TEXT
    EndIf    
Else
    For nX := 1 To Len(xMoviPag)
        If Alltrim(xMoviPag[nX]:_FORMAPAGAMENTO:TEXT) = "DINHEIRO"
            xRet:= xMoviPag[nX]:_VALORCONFERIDO:TEXT
            exit
        EndIf
    Next
EndIf

Return xRet  
//--------------------------------------------------------
/*/{Protheus.doc} RmiVldVend
Busca se a venda já existe na tabela SL1

@param 		aExecAuto -> Array com os dados encontrados SL1
@param 		cUUID     -> Codigo UUID da tabela MHQ
@author  	Varejo
@version 	1.0
@since      23/09/2021
@return	    xRet       -> Retorna o VALORCONFERIDO
/*/
//--------------------------------------------------------
Function RmiVldVend(cUUID,aExecAuto)
Local aArea     := GetArea()
Local aAreaSL1  := SL1->(GetArea())
Local lRet      := .T.
Local cErro     := ""
Local cFilSL1   := ""
Local cSerie    := ""
Local cDoc      := ""
Local cSitua    := ""
Local nPos      := 0

LjGrvLog("RmiVldVend","Processando a função RmiVldVend para validar se a venda já existe na tabela SL1 ")

DbSelectArea('SL1')
DbSetOrder(2) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV

nPos := Ascan(aExecAuto, {|x| x[1] == "L1_FILIAL"})
cFilSL1 := PadR(aExecAuto[nPos][2],TamSx3('L1_FILIAL')[1])

nPos := Ascan(aExecAuto, {|x| x[1] == "L1_SERIE"})
cSerie := PadR(aExecAuto[nPos][2],TamSx3('L1_SERIE')[1])

nPos := Ascan(aExecAuto, {|x| x[1] == "L1_DOC"})
cDoc := PadR(aExecAuto[nPos][2],TamSx3('L1_DOC')[1])


If SL1->(DbSeek(cFilSL1 + cSerie +cDoc))
    lRet := .F.
    Do Case
         Case SL1->L1_SITUA == "IP"
            cSitua := "(INTEGRAÇÃO PENDENTE)"   
         Case SL1->L1_SITUA == "IR"
            cSitua := "(INTEGRAÇÃO COM ERRO)"
         Case SL1->L1_SITUA == "ER"
            cSitua := "(VENDA COM ERRO)"
         Case SL1->L1_SITUA == "RX"
            cSitua := "(VENDA EM PROCESSAMENTO)"
         Case SL1->L1_SITUA == "OK"
            cSitua := "(VENDA COM SUCESSO)"
         OtherWise
    End Case
    
    cErro := STR0001+ "L1_NUM: "+SL1->L1_NUM + ", L1_FILIAL: "+SL1->L1_FILIAL+ ", L1_DOC: "+SL1->L1_DOC+", L1_SERIE: "+SL1->L1_SERIE+ ", L1_SITUA: "+SL1->L1_SITUA+" = "+cSitua+", UUID: "+ cUUID //"A venda que esta tentando processar já foi gravada na tabela SL1 no Registro do Codigo :"
   
    LjGrvLog("RmiVldVend","Retorno do Erro  ",{cErro})
    LjGrvLog("RmiVldVend","UUID QUE ESTA TENTANDO GRAVAR A NOVA VENDA  ",cUUID)
    LjGrvLog("RmiVldVend","UUID QUE GRAVOU A VENDA ANTERIOR ",SL1->L1_UMOV)
EndIf

RestArea(aAreaSL1)
RestArea(aArea)
Return {lRet,cErro}

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiErroBlock
Funçaõ para ser utilizada em parceria com o Begin Sequence, para capturar error log e não parar o processamento.
Deve fazer os tratamentos necessarios para conseguir setar erro.

@type    Function
@param   oErro, Objeto, Objeto de erro capturado pelo ErrorBlock
@param   lErrorBlock, Lógico, Define que teve algum erro no processamento, parâmetro por referencia
@param   cErrorBlock, Caractere, Numero do pagamento, parâmetro por referencia

@author  Rafael Tenorio da Costa
@version 12.1.27
@since   06/01/22
/*/
//-------------------------------------------------------------------
Function RmiErroBlock(oErro, lErrorBlock, cErrorBlock)

    //Seta erro na execauto
    If Type("lMsErroAuto") == "L"
        lMsErroAuto := .T.
    EndIf

	//Volta a transacao em caso de algum erro
	If InTransact()
		DisarmTransaction()
	EndIf    

    //Carrega erro
    lErrorBlock := .T.
    cErrorBlock := AllTrim(oErro:ErrorStack)

    Conout(cErrorBlock)
    
    //Necessario para continuar o begin sequence
    Break

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} RsGrvCli
Função responsavel em verificar se o cliente já existe ou não,
chama as funções para retornar o endereço ou incluir o cliente.

@author Bruno Almeida
@since  22/03/2022
@return aRet - Retorna um array com os dados do cliente
@uso    RetailSales.prw
/*/
//--------------------------------------------------------
Function RsGrvCli(cJson)

Local oJson     := JsonObject():New() //Recebe o Json de origem
Local aRet      := {.T.,"","","",""} //Variavel de retorno

oJson:FromJson(cJson)

SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC
If !SA1->(DbSeek(xFilial("SA1") + PadR(oJson["Cliente"]["CpfCnpj"],TamSx3("A1_CGC")[1])))
    aRet := RsAutCli(oJson)
Else
    aRet := RsEndCli(oJson, SA1->A1_CGC, SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME)
EndIf

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} RsEndCli
Funcao Responsavel por Verificar e Avaliar o Cadastro
do Cliente Utilizando o Endereço Principal. Caso o endereço
já exista, retorna o código do cliente e loja referente ao 
endereço, caso contrario inclui um novo cliente com novo
endereço alterando apenas o código da loja.

@author Bruno Almeida
@since  23/03/2022
@return aRet - Retorna um array com os dados do cliente
@uso    RetailSales.prw
/*/
//--------------------------------------------------------
Function RsEndCli(oJson, cCgcCpf, cCodCli, cCodLoja, cNome)

    Local aRet      := {.F.,"","","",""}    //Variavel de retorno
    Local nOpCli    := 3

    //Verifica se encontra o endereço do cliente
    SA1->( DbSetOrder(3) )      //A1_FILIAL+A1_CGC
    If SA1->( DbSeek(xFilial("SA1") + cCgcCpf) )

        While !SA1->( Eof() ) .And. AllTrim(SA1->A1_CGC) == AllTrim(cCgcCpf)
            
            If  AllTrim(oJson["Cliente"]["Cep"])                                == AllTrim(SA1->A1_CEP)                      .And.;
                NOACENTO(UPPER(AllTrim(oJson["Cliente"]["EnderecoEntrega"])))   == NOACENTO(UPPER(AllTrim(SA1->A1_END)))     .And.;
                NOACENTO(UPPER(AllTrim(oJson["Cliente"]["Complemento"])))       == NOACENTO(UPPER(AllTrim(SA1->A1_COMPLEM))) .And.;
                NOACENTO(UPPER(AllTrim(oJson["Cliente"]["Bairro"])))            == NOACENTO(UPPER(AllTrim(SA1->A1_BAIRRO)))  .And.;
                NOACENTO(UPPER(oJson["Cliente"]["Cidade"]))                     == AllTrim(SA1->A1_MUN)        

                nOpCli  := 4

                aRet[1] := .T.
                aRet[2] := SA1->A1_COD
                aRet[3] := SA1->A1_LOJA
                aRet[4] := SA1->A1_NOME
                aRet[5] := "Cliente já cadastrado na base"            

                Exit
            EndIf

            SA1->( DbSkip() )
        EndDo
    EndIf

    //Não contrando o endereço do cliente, pega um código de loja livre
    If !aRet[1]
        cCodLoja := I030LjCli(cCodCli, cCodLoja)[2]
    EndIf

    //Atualiza cliente
    aRet := RsAutCli(oJson, cCodCli, cCodLoja, nOpCli)

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} RsAutCli
Faz a chamada da rotina automatica do cliente CRMA980

@author Bruno Almeida
@since  23/03/2022
@return aRet - Retorna um array com os dados do cliente
@uso    RetailSales.prw
/*/
//--------------------------------------------------------
Function RsAutCli(oJson, cCodCli, cCodLoja, nOpCli)

Local aCliente  := {}                                   //Dados do cliente
Local aErroAuto := {}                                   //Guarda no array o retorno do ExecAuto
Local nX        := 0                                    //Variavel de loop
Local cErro     := ""                                   //Guarda o erro do ExecAuto
Local aRet      := {.T.,"","","",""}                    //Variavel de retorno
Local cIniPad   := GetSx3Cache("A1_COD","X3_RELACAO")   //Inicializador padrao do cliente
Local cQuery    := ""                                   //Armazena a query para consulta do cliente
Local cAlias    := ""                                   //Proximo alias
Local cNome     := AllTrim( oJson["Cliente"]["Nome"] )
Local cInscEst  := ""

Default cCodCli     := ""
Default cCodLoja    := "01"
Default nOpCli      := 3

Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile 	:= .T. //força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário

If !Empty(cCodCli)
    Aadd(aCliente,{"A1_COD",cCodCli, Nil})
ElseIf Empty(cIniPad)
    Aadd(aCliente,{"A1_COD",MATI030Num(), Nil})
EndIf

Aadd(aCliente,{"A1_LOJA"    , cCodLoja                                  , Nil})
Aadd(aCliente,{"A1_NOME"    , cNome                                     , Nil})
Aadd(aCliente,{"A1_NREDUZ"  , SubStr(cNome, 1, Tamsx3("A1_NREDUZ")[1])  , Nil})
Aadd(aCliente,{"A1_CGC"     , oJson["Cliente"]["CpfCnpj"]               , Nil})
Aadd(aCliente,{"A1_DDD"     , oJson["Cliente"]["Ddd"]                   , Nil})
Aadd(aCliente,{"A1_TEL"     , oJson["Cliente"]["Fone"]                  , Nil})
Aadd(aCliente,{"A1_TIPO"    , "F"                                       , Nil})
Aadd(aCliente,{"A1_PESSOA"  , oJson["Cliente"]["TipoCliente"]           , Nil})
Aadd(aCliente,{"A1_END"     , oJson["Cliente"]["EnderecoEntrega"]       , Nil})
Aadd(aCliente,{"A1_COMPLEM" , oJson["Cliente"]["Complemento"]           , Nil})
Aadd(aCliente,{"A1_MUN"     , NOACENTO(UPPER(oJson["Cliente"]["Cidade"])), Nil})
Aadd(aCliente,{"A1_BAIRRO"  , oJson["Cliente"]["Bairro"]                , Nil})
Aadd(aCliente,{"A1_EST"     , oJson["Cliente"]["Estado"]                , Nil})
Aadd(aCliente,{"A1_CEP"     , oJson["Cliente"]["Cep"]                   , Nil})
Aadd(aCliente,{"A1_COD_MUN" , SubStr(oJson["Cliente"]["Ibge"],3,Len(oJson["Cliente"]["Ibge"]) ), Nil})

If oJson["Cliente"]:HasProperty("InscricaoEstadual")
    cInscEst := oJson["Cliente"]["InscricaoEstadual"]
EndIf

If Empty(cInscEst) .And. oJson["Cliente"]["TipoCliente"] == "F"
    cInscEst := "ISENTO"
EndIF

Aadd(aCliente,{"A1_INSCR", cInscEst, Nil})

If oJson["Cliente"]:HasProperty("Email")
    Aadd(aCliente,{"A1_EMAIL", oJson["Cliente"]["Email"], Nil})
EndIf

MsExecAuto( {|a,b| CRMA980(a,b)}, aCliente, nOpCli)

If lMsErroAuto

    RollBackSX8()
    aErroAuto := GetAutoGrLog()

    For nX := 1 To Len(aErroAuto)
        cErro += aErroAuto[nX] + Chr(10)
    Next nX

    aRet[1] := .F.
    aRet[2] := ""
    aRet[3] := ""
    aRet[4] := ""
    aRet[5] := STR0004 + " " + cErro //"Erro ao cadastrar o cliente:"
Else

    ConfirmSX8()
    cAlias := GetNextAlias()

    cQuery := "SELECT A1_COD"
    cQuery += "     , A1_LOJA"
    cQuery += "	    , A1_NOME"
    cQuery += "  FROM " + RetSQLName( "SA1" )
    cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
    cQuery += "   AND A1_CGC = '" + AllTrim(oJson["Cliente"]["CpfCnpj"]) + "'"
    cQuery += "   AND D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY A1_LOJA DESC"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    If !(cAlias)->(Eof())

        aRet[2] := (cAlias)->(A1_COD)
        aRet[3] := (cAlias)->(A1_LOJA)
        aRet[4] := (cAlias)->(A1_NOME)
        aRet[5] := STR0003 //"Cliente cadastrado com sucesso"
    EndIf

    (cAlias)->(DbCloseArea())
EndIf

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} RsSaldoPrd
Consulta o saldo em estoque do produto para informar na
mensagem de erro

@author Bruno Almeida
@since  24/03/2022
@return nSaldo - Saldo do produto
@uso    RetailSales.prw
/*/
//--------------------------------------------------------
Function RsSaldoPrd(cProd)

Local nSaldo    := 0 //Retorna o saldo
Local aArea     := SB2->(GetArea()) //Guarda area da SB2

cProd := PadR(AllTrim(cProd),TamSx3("B2_COD")[1])

SB2->(dbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
SB2->(dbSeek(xFilial("SB2") + cProd))

While !SB2->(Eof()) .And. SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2") + cProd
    nSaldo := SaldoSB2()
    SB2->( dbSkip() )
EndDo

RestArea(aArea)

Return nSaldo
