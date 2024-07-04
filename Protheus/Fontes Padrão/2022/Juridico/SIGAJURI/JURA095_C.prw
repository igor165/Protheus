#INCLUDE "JURA095_C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA095_C
Consultas de processos 

@author Wellington Coelho
@since 25//11/14
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA095_C()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef Consultas de processos

@author Wellington Coelho
@since 25//11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Consultas de processos

@author Wellington Coelho
@since 25//11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Consultas de processos

@author Wellington Coelho
@since 25//11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J095NW8()
Fun��o utilizada para pegar o nome dos campos dos valores atualizados.
Uso Geral.

@param 	cTabela   Tabela que deve ser utilizada no filtro.

@Return 	Array com os campos da NW8
@author Andr� Spirigoni Pinto
@since 20/08/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095NW8(cTabela)
	Local cQuery  := ""
	Local cAlias  := GetNextAlias()
	Local aArea   := GetArea()
	Local aCampos := {}

	cQuery := "SELECT NW8_CCAMPO, NW8_CDATA , NW8_CAMPH , NW8_CFORMA, NW8_CCORRM, NW8_CJUROS, NW8_MULATU, NW8_CCMPAT  FROM "+RetSqlName("NW8")+" NW8 "+ CRLF
	cQuery += " WHERE NW8_CTABEL = '" + cTabela + "'" + CRLF
	cQuery += " AND NW8_FILIAL = '"+xFilial("NW8")+"' AND NW8.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )

		aAdd(aCampos,{AllTrim( (cAlias)->NW8_CCAMPO ),AllTrim( (cAlias)->NW8_CDATA ),AllTrim( (cAlias)->NW8_CAMPH ),AllTrim( (cAlias)->NW8_CFORMA ),AllTrim( (cAlias)->NW8_CCORRM ),AllTrim( (cAlias)->NW8_CJUROS ),AllTrim( (cAlias)->NW8_MULATU ),AllTrim( (cAlias)->NW8_CCMPAT )})
		(cAlias)->( dbSkip() )

	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} J95TitCpo
Fun��o que retorna o t�tulo do campo que esta na NUZ e caso n�o exista
t�tulo definido, ele pega o t�tulo do SX3.

@param 	cCampo Nome do campo completo
@param 	cTipoAJ C�digo do tipo de assunto jur�dico

@return cTitulo Retorna o t�tulo do campo
 
@author Andr� Spirigoni Pinto
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95TitCpo (cCampo, cTipoAJ)
	Local cTitulo := ''

//Busca na NUZ o t�tulo do campo
	cTitulo := JurGetDados('NUZ', 1, xFilial('NUZ') + cTipoAJ + cCampo + Replicate(" ",10-len(cCampo)), 'NUZ_DESCPO')

//Caso n�o tenha t�tulo, usar o do dicion�rio.
	If Empty(cTitulo)
		cTitulo := JA160X3Des(cCampo)
	Endif
	
Return cTitulo

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA095TabAj            
Retorna as tabelas que s�o usadas para o assunto jur�dico.

Uso Geral. 
		   	    				    
@return cTabelas	    Tabelas

@author Jorge Luis Branco Martins Junior 
@since 28/10/13
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA095TabAj(cAssJur)
	Local cTabelas  := ""
	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT NYC_TABELA
		FROM %table:NYC% NYC
		WHERE NYC.NYC_CTPASJ = %Exp:cAssJur%
		AND NYC.NYC_FILIAL = %xFilial:NYC%
		AND NYC.%notDel%
	EndSql

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbgoTop())
	
	While !(cAliasQry)->( EOF())

		cTabelas += "|"+(cAliasQry)->NYC_TABELA
		
		(cAliasQry)->( dbSkip() )

	EndDo

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)

Return cTabelas

//-------------------------------------------------------------------

/*/{Protheus.doc} J095RetSig
Retorna a Sigla para que seja feita a rotina de anexos

@author Jorge Luis Branco Martins Junior
@since 23/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095RetSig()
	Local cQuery    := ""
	Local aArea    	:= GetArea()
	Local cResQRY  	:= GetNextAlias()
	Local cRet

	cQuery := "SELECT RD0_CODIGO COD FROM " + RetSqlName("RD0") + CRLF
	cQuery += "WHERE RD0_USER = '" + __cUserID + "'" + CRLF

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cResQRY,.T.,.T.)

	cRet := (cResQRY)->COD

	dbSelectArea(cResQRY)
	(cResQRY)->( dbcloseArea() )

	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LstSituac
Caso seja um processo tipo Contrato, o combo de situa��o aparece
com a situa��o 'Vigente' no lugar de 'Em Andamento'

@Return cRet  					Retorno..

@param 	TipoPesq  			Identifica��o do codigo de Assunto Juridico.
@param 	nOrigemChamada  Identifica de origem da fun��o (01= Dicionario,  02= Ao carregar os campos na tela de pesquisa e 03= Ao carregar os processos no grid da tela de pesquisa)


@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o
@author Jorge Luis Branco Martins Junior
@since 05/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function LstSituac(cRet, TipoPesq, nOrigem, lTelaPes)
	Local aArea 		 := GetArea()
	Local nCont 		 :=0
	Local aLstPesq :={}
	Local cLstPesq :=""

	Default cRet					:="C"
	Default TipoPesq		:= ""
	Default nOrigem			:= 1
	Default lTelaPes  	:= .F.

	If !isInCallStack("JURA099")
		lTelaPes := IsPesquisa()
	EndIF


	If (TipoPesq == '' ) .Or. ValType(TipoPesq) == "A" // Se o parametro vier do tipo array
		TipoPesq = AtoC(TipoPesq,',') // A variavel TipoPesq receber� uma string com todo o conteudo do array, separado por ','
	EndIF

	If lTelaPes
		If Empty(TipoPesq)
			TipoPesq:= JA162Assun()
		EndIf
	Else
		TipoPesq:= NSZ->NSZ_TIPOAS
	Endif

  // Verifica qual � o item para ser adicionado na op��es de escolha da Situa��o.
  // Se o tipo de assunto juridico for igual a Contratos (TipoPesq == "06"), dever� retornar "1=Vigente" como o primeiro elemento para o array.
  // Se houver mais de um tipo e nele conter Contratos (TipoPesq == "06"), dever� retornar "1=Andam./Vigente" como o primeiro elemento para o array.
  // Se houver um, ou mais, tipos de assuntos e forem diferentes de Contratos (TipoPesq != "06"), dever� retornar "1=Em Andamento".
	If "006" $ TipoPesq
		If (TipoPesq == "006")
			If !lTelaPes .Or. nOrigem != 02
				aAdd(aLstPesq,STR0001) //1=Vigente
			Else
				aAdd(aLstPesq,STR0002) //'1=Andam./Vigente'
			EndIf
		ElseIf (nOrigem == 02) .Or.(nOrigem == 01 .And. lTelaPes)
			aAdd(aLstPesq,STR0002) //'1=Andam./Vigente'
		Else
			aAdd(aLstPesq,STR0003) //1=Em Andamento
		EndIf
	Else
		aAdd(aLstPesq,STR0003) //1=Em Andamento
	EndIf

	aAdd(aLstPesq,STR0004)//2=Encerrado

	For nCont:=1 To Len(aLstPesq)
		cLstPesq+=aLstPesq[nCont]+";"
	Next
	cLstPesq:=Substr(cLstPesq,1,Len(cLstPesq)-1)

	if Empty(cLstPesq)
		cLstPesq = "1=ERRO na montagem;2=Verificar conteudo"
	EndIF

	RestArea(aArea)

Return Iif(Upper(cRet)=="C",cLstPesq,aLstPesq)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095Qtde
Fun��o para contabilizar a quantidade de incidentes e processos
vinculados
@Return cQtde		Quantidade de processo

@param cAssJur 		- C�digo do assunto jur�dico
@param cTela 		- 1 - Incidentes 2 - Vinculo
@author Juliana Iwayama Velho
@since 01/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095Qtde(cAssJur, cTela)
	Local aArea      := GetArea()
	Local cQuery     := ''
	Local cAlias     := GetNextAlias()
	Local cQtde      := '0'

	If cTela == '1' //Verifica��o do tipo de tela para montagem da query
		cQuery += "SELECT COUNT(*) QTDE "
		cQuery += "FROM "+RetSqlName("NSZ")+" NSZ,"+RetSqlName("NUQ")+" NUQ "
		cQuery += "WHERE NSZ.NSZ_COD    = NUQ.NUQ_CAJURI "
		cQuery += "AND NUQ.NUQ_FILIAL = '"+xFilial("NUQ")+"' "
		cQuery += "AND NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' "
		cQuery += "AND NUQ.D_E_L_E_T_ = ' ' "
		cQuery += "AND NSZ.D_E_L_E_T_ = ' ' "
		cQuery += "AND NSZ.NSZ_CPRORI = '"+cAssJur+"' "
		cQuery += "AND NUQ.NUQ_INSATU = '1' "
	ElseIf cTela == '2'
		cQuery += "SELECT COUNT(NVO.NVO_CAJUR1) QTDE "
		cQuery += "FROM "+RetSqlName("NVO")+" NVO "
		cQuery += "WHERE (NVO.NVO_CAJUR1 = '"+cAssJur+"') "
		cQuery += "AND NVO.NVO_FILIAL  = '"+xFilial("NVO")+"' "
		cQuery += "AND NVO.D_E_L_E_T_  = ' ' "
	ElseIf cTela == '3'
		cQuery += "SELECT COUNT(NXX.NXX_CAJURO) QTDE "
		cQuery +=  "FROM "+RetSqlName("NXX")+" NXX "
		cQuery += "WHERE (NXX.NXX_CAJURO = '"+cAssJur+"') "
		cQuery +=   "AND NXX.NXX_FILIAL  = '"+xFilial("NXX")+"' "
		cQuery +=   "AND NXX.D_E_L_E_T_  = ' ' "
	Endif

	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If !(cAlias)->( EOF() )
		cQtde := AllTrim(Str((cAlias)->QTDE))
	EndIf

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return cQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetTitulo
Fun��o para trazer o titulo do caso

@param 	cCod 	     	Campo de c�digo a ser verificado
@param 	cCod2           Campo de c�digo2 a ser verificado
@return cResultPad	 	Descri��o do c�digo

IIF(!INCLUI,JurGetDados('NQM',1,xFilial('NQM')+NTA->NTA_CPREPO,'NQM_DESC'), JurGatilho('NTA_CPREPO','NQM','NQM_DESC' ))

@author Cl�vis Eduardo Teixeira
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetTitulo()
	Local aArea  := GetArea()
	Local cRPad1 := ''
	Local cRPad2 := ''
	Local cRPad3 := ''
	Local cResultPad := ''
	Local oModel := FWModelActive()
	Local oM     := ''

	If IsInCallStack( 'JURA162' ) .AND. !INCLUI
		cResultPad := JA095CASO()
	Else
		oM:=oModel:GetModel('NSZMASTER')

		If INCLUI
			cRPad1 := oM:GetValue('NSZ_CCLIEN')
			cRPad2 := oM:GetValue('NSZ_LCLIEN')
			cRPad3 := oM:GetValue('NSZ_NUMCAS')
	
			If !Empty(cRPad1) .AND. !Empty(cRPad2) .AND. !Empty(cRPad3)
				cResultPad := JurGetDados('NVE', 1, xFilial('NVE') + cRPad1 + cRPad2 + cRPad3, 'NVE_TITULO')
			EndIf
		EndIf

	EndIf

	RestArea( aArea )

Return cResultPad

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetCliente
Fun��o para trazer a descri��o do campo de nome do cliente

@return cResultPad	 	Descri��o do c�digo

IIF(!INCLUI,JurGetDados('NQM',1,xFilial('NQM')+NTA->NTA_CPREPO,'NQM_DESC'), JurGatilho('NTA_CPREPO','NQM','NQM_DESC' ))
@author Cl�vis Eduardo Teixeira
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetCliente()
	Local aArea       := GetArea()
	Local cClient	  := ''
	Local cLoja 	  := ''
	Local cResult     := ''

	If INCLUI
		cClient := M->NSZ_CCLIEN
		cLoja	:= M->NSZ_LCLIEN

		If !Empty(cClient) .AND. !Empty(cLoja)
			cResult := JurGetDados('SA1', 1 , xFilial('SA1') + cClient + cLoja , 'A1_NOME')
		EndIf
	EndIf

	RestArea( aArea )

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095TCaso()
Fun��o respons�vel pela composi��o do titulo do Caso
Uso no cadastro de Processos.
@return cTitulo Titulo do Caso
@author Cl�vis Eduardo Teixeira
@since 24/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095TCaso(oModel)
Local aArea         := GetArea()
Local cTitulo       := ''
Local cAliasMaster  := ''
Local cAliasQry     := GetNextAlias()
Local cTipoAj       := oModel:GetValue("NSZMASTER","NSZ_TIPOAS")
Local cAreaJur      := oModel:GetValue("NSZMASTER","NSZ_CAREAJ")
Local cPicture      := ""
Local cNumeroP      := ""
Local cNatureza     := IIF(c162TipoAs $ '001/002/003/004/009',oModel:GetValue("NUQDETAIL","NUQ_CNATUR"),'')
Local aReservado    := {'\','/','|','<','>','*',':','�','"','?',"�","'",'@',',','=','!','#','%'}
Local nI            := 0

	BeginSql Alias cAliasQry

		SELECT NRQ_CAMPO, NRQ_ABREV, NRQ_QTDCAR, NRQ_SEPARA	
		FROM %table:NRQ% NRQ
		WHERE NRQ_CTIPAS = %Exp:cTipoAj%
		AND NRQ_CAREA  = %Exp:cAreaJur%
		AND NRQ_FILIAL = %xFilial:NRQ%
		AND NRQ.%NotDel%
		ORDER BY NRQ_POSICA

	EndSql

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())

	If (cAliasQry)->(EOF())

    /*Valida se alguma das abas n�o esta dispon�vel para o usu�rio, para usar outro
	padr�o de t�tulo de caso. Geralmente ocorre com o tipo de assunto Consultivo*/
		If (JA105Aut(oModel) == '' .And. JA105Reu(oModel) == '' .And. JA183NPro(oModel) == '')
			cTitulo  := rTrim(SubStr(JurGetDados('NYB', 1 , xFilial('NYB') + c162TipoAs, 'NYB_DESC'),1,20))+' - '+ rTrim(SubStr((oModel:GetValue('NSZMASTER','NSZ_DAREAJ')),1,40))+' - '+ rTrim(oModel:GetValue('NSZMASTER','NSZ_COD'))
		Else
			cNumeroP := rTrim(SubStr(JA183NPro(oModel),1,30))
		
			If (JGetParTpa(cTipoAj, "MV_JNUMCNJ", "2") == "1")
		
				If !Empty(cNatureza)
					DbSelectArea("NQ1")
					NQ1->(DbSetOrder(1))
			
					If NQ1->(dbSeek(xFilial('NQ1')+cNatureza)) .And. ((NQ1->NQ1_VALCNJ == '1') .Or. (Empty(NQ1->NQ1_VALCNJ)))
						cPicture := '@R XXXXXXX-XX.XXXX.X.XX.XXXX'
						cNumeroP := replace(cNumeroP,".","")
						cNumeroP := replace(cNumeroP,"-","")
						cNumeroP := TRANSFORM(cNumeroP, cPicture)
					EndIf
				EndIf
			EndIf
			cTitulo  := rTrim(SubStr(JA105Aut(oModel),1,80))+' - '+ rTrim(SubStr(JA105Reu(oModel),1,80))+' - '+ cNumeroP
		Endif

	Else
		While !(cAliasQry)->( EOF())
			Do case
			Case SubStr((cAliasQry)->NRQ_CAMPO,1,3) == 'NSZ'
				cAliasMaster := "NSZMASTER"
			Case SubStr((cAliasQry)->NRQ_CAMPO,1,3) == 'NT9'
				cAliasMaster := "NT9DETAIL"
			Case SubStr((cAliasQry)->NRQ_CAMPO,1,3) == 'NUQ'
				cAliasMaster := "NUQDETAIL"
			End Case

			If (cAliasQry)->NRQ_QTDCAR == 'S'
				cTitulo += rTrim(SubStr(oModel:GetValue(cAliasMaster,(cAliasQry)->NRQ_CAMPO),1,(cAliasQry)->NRQ_QTDCAR))
			Else
				cTitulo += rTrim(oModel:GetValue(cAliasMaster,(cAliasQry)->NRQ_CAMPO))
			Endif

			If !Empty((cAliasQry)->NRQ_SEPARA)
				cTitulo += (cAliasQry)->NRQ_SEPARA
			Endif
			(cAliasQry)->(dbSkip())
		End
	Endif

    //Adiciona o c�digo do Workflow pada os casos que vieram do Fluig.
    If(!Empty(oModel:GetValue("NSZMASTER","NSZ_CODWF")))
        cTitulo := cTitulo + " - WF_" + oModel:GetValue("NSZMASTER","NSZ_CODWF")
    EndIf

    For nI :=1 to Len(aReservado)
        cTitulo := StrTran( cTitulo, aReservado[nI], '')
    Next

    cTitulo := StrTran( cTitulo, '&', 'E')
    cTitulo := StrTran( cTitulo, '$', 'S')

	(cAliasQry)->( dbCloseArea() )

	RestArea (aArea)

Return cTitulo

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTpAsPesq
Fun��o que verifica os tipo de assuntos jur�dicos que o usu�rio esta
habilitado para filtrar os registros e o tipo que esta sendo utilizado no momento da pesquisa
 dos cadastros filhos, como Andamento,Follow-up, Garantias, Despesas.

@Param cUser      C�digo do usu�rio
@param cAssJurExc C�digo assunto juridico que deseja fazer exce��o no retorno

@Return cTipoAj C�digo(s) do(s) tipo(s) de assunto jur�dico

@author Juliana Iwayama Velho
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTpAsPesq(cUser, cAssJurExc)
Local aArea        := GetArea()
Local cAliasQry    := GetNextAlias()
Local aVetor       := {}
Local cTipoAj      := ""
Local nI           := 0
Local cSQL         := ""
Default cAssJurExc := ""

cSQL := " SELECT NVJ.NVJ_CASJUR CASJUR " 
cSQL += " FROM "+ RetSqlName("NVJ") + " NVJ , "
cSQL +=           RetSqlName("NVK")+" NVK " 
cSQL += " WHERE NVJ.NVJ_FILIAL = " + ValToSQL(xFilial("NVJ"))
cSQL +=   " AND NVK.NVK_FILIAL = " + ValToSQL(xFilial("NZY"))
cSQL +=   " AND NVK.NVK_CPESQ = NVJ.NVJ_CPESQ"
cSQL +=   " AND NVK.NVK_CUSER = " + ValToSQL(cUser)
cSQL +=   " AND NVK.D_E_L_E_T_ = ' ' "
cSQL +=   " AND NVJ.D_E_L_E_T_ = ' ' "
cSQL +=" UNION SELECT NVJ.NVJ_CASJUR CASJUR"
cSQL +=" FROM" + RetSqlName("NVJ")+ " NVJ ,"
cSQL +=          RetSqlName("NVK") + " NVK,"
cSQL +=          RetSqlName("NZY") + " NZY " 
cSQL += " WHERE NVJ.NVJ_FILIAL = " + ValToSQL(xFilial("NVJ"))
cSQL +=   " AND NVK.NVK_FILIAL = " + ValToSQL(xFilial("NVK"))
cSQL +=   " AND NZY.NZY_FILIAL = " + ValToSQL(xFilial("NZY"))
cSQL +=   " AND NVK.NVK_CPESQ = NVJ.NVJ_CPESQ "
cSQL +=   " AND NVK.NVK_CGRUP = NZY_CGRUP "
cSQL +=   " AND NZY.NZY_CUSER = "+ ValToSQL(cUser)
cSQL +=   " AND NVK.D_E_L_E_T_ = ' '" 
cSQL +=   " AND NVJ.D_E_L_E_T_ = ' '"  
cSQL +=   " AND NZY.D_E_L_E_T_ = ' '" 

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasQry,.T.,.T.)


While !(cAliasQry)->( EOF())
	If !Empty(cAssJurExc) 
		if cAssJurExc != (cAliasQry)->CASJUR 
			aAdd(aVetor, (cAliasQry)->CASJUR )
		EndIf
	Else
		aAdd(aVetor, (cAliasQry)->CASJUR )
	EndIf
	(cAliasQry)->(DbSkip())
EndDo

If Len(aVetor) == 0
	cTipoAj := '000'
Else
	For nI := 1 to LEN(aVetor)
		cTipoAj += ", '"+aVetor[nI]+"'"
	Next
	cTipoAj := AllTrim( SubStr(cTipoAj, 2, Len(cTipoAj) - 1) )
Endif

(cAliasQry)->( DbCloseArea() )

ASize(aVetor, 0)
RestArea(aArea)

Return cTipoAj

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095TIPOP
Preenchimento automatico do tipo de processo (principal ou incidente)
Uso no cadastro de Processos.

@return 	cRet   Descri��o do tipo do processo

@author Juliana Iwayama Velho
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095TIPOP()
	Local cRet := ''
	If !Empty( FwFldGet('NSZ_CPRORI') )
		cRet := STR0005
	Else
		cRet := STR0006
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095CASO
Verifica o t�tulo do caso do processo
Uso Geral. Campos de inicializa��o padr�o

@Return cRet	   T�tulo do Caso

@author Juliana Iwayama Velho
@since 30/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095CASO(cClien,cLoja,cNumCas)
	Local aArea := GetArea()
	Local cRet := ""

	Default cClien := NSZ->NSZ_CCLIEN
	Default cLoja := NSZ->NSZ_LCLIEN
	Default cNumCas := NSZ->NSZ_NUMCAS
 
	cRet := JurGetDados('NVE',1,XFILIAL('NVE')+cClien+cLoja+cNumCas,'NVE_TITULO')
	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095TICAS
Verifica o t�tulo do caso do processo
Uso Geral.

@Param cAssJur     C�digo do Assunto Jur�dico
@Param cCliente    C�digo do Cliente
@Param cLoja       C�digo da Loja
@Param cNumCaso    C�digo do N�mero do Caso

@Return cRet	   T�tulo do Caso

@author Juliana Iwayama Velho
@since 30/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095TICAS(cAssJur,cCliente,cLoja,cNumCaso)
Local cRet      := ""
Local cCliProc  := ""
Local cLojaProc := ""
Local cNCasProc := ""
Local cCajuri   := M->&(cAssJur)
	
	If !Empty(cCajuri)
		cCliProc  := JurGetDados('NSZ',1,xFilial('NSZ') + cCajuri, 'NSZ_CCLIEN')
		cLojaProc := JurGetDados('NSZ',1,xFilial('NSZ') + cCajuri, 'NSZ_LCLIEN')
		cNCasProc := JurGetDados('NSZ',1,xFilial('NSZ') + cCajuri, 'NSZ_NUMCAS')

		cRet := JurGetDados('NVE',1,xFilial('NVE') + cCliProc + cLojaProc + cNCasProc, 'NVE_TITULO')
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95SPRO
Sugere o progn�stico conforme o objeto
Uso no Gatilho de Processo, com configura��o de par�metro 'MV_JSUGPRO'.

@Return cRet	 	C�digo do Progn�stico

@author Juliana Iwayama Velho
@since 29/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95SPRO()
	Local cRet := FwFldGet('NSZ_CPROGN')
	Local cProg:= ""
	Local aArea := GetArea()

	If !Empty(FwFldGet('NSZ_COBJET'))
		cProg := JurGetDados('NQ4', 1 , xFilial('NQ4') + FwFldGet('NSZ_COBJET') , 'NQ4_CPROG')
		If !Empty(cProg)
			cRet := cProg
		EndIf
	EndIf

	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA095SIT
Preenchimento automatico da descricao da situacao do processo (NSZ_DSITUA)

@param 	cSituacao  	Situa��o do processo
@Return cRet	 	Descri��o da situa��o do processo

@author Romeu Calmon Braga Mendon�a
@since 17/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA095SIT(cSituacao)
	Local cAssJuri := IIF(Empty(NSZ->NSZ_TIPOAS),'',NSZ->NSZ_TIPOAS)

	If cSituacao == '1'
		If cAssJuri == '006'
			cRet := SubStr( alltrim(STR0001),3, len(alltrim(STR0001)) ) //"Vigente"
		Else
			cRet := STR0007 //"Em andamento"
		EndIF
	Else
		cRet := STR0008 //Encerrado
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR095CPO
Campos a serem exibidos

@param 	cTabela  	Tabela a ser verificada
@Return aArray	 	Array de campos

@author Romeu Calmon Braga Mendon�a
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR095CPO(cCampo, cFil, cAssJur)
	Local lRet       	:= .F.
	Local aArea      	:= GetArea()
	Local aAreaNUZ  		:= NUZ->( GetArea() )
	Local cTipoAjCPO	:= ''
	Local cTipoOri 		:= ''


	If IsInCallStack( 'JURA162' ) .AND. INCLUI
		cTipoAjCPO := cTipoAj
	Elseif NSZ->(dbSeek(xFilial('NSZ') + cAssJur))
		cTipoAjCPO := NSZ->NSZ_TIPOAS
	Endif

	If x3Obrigat( PadR( cCampo, 10 ) )

		lRet := .T.
		Return lRet

	Else

		If cTipoAjCPO > '050'
			cTipoOri := JurGetDados("NYB",1,XFILIAL("NYB")+cTipoAjCPO, "NYB_CORIG")
		EndIf

		NYD->( dbSetOrder( 1 ) )
	
		If !(cTipoAjCPO > '050' .AND. (NYD->( dbSeek( xFilial( 'NYD' ) + cTipoAjCPO + PadR( cCampo, 10 ) ) ) ) )
			NUZ->( dbSetOrder( 1 ) )
			If cTipoAjCPO > '050' .AND. NUZ->( dbSeek( xFilial( 'NUZ' ) + cTipoOri + PadR( cCampo, 10 ) ) )
				lRet := .T.
				Return lRet
			EndIf
	
			If NUZ->( dbSeek( xFilial( 'NUZ' ) + cTipoAjCPO + PadR( cCampo, 10 ) ) )
	
				lRet := .T.
				Return lRet
			EndIf
		EndIf
	EndIf

	RestArea( aAreaNUZ )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetListaCod(oLstPesq)
Fun��o utilizada para pegar o c�digo(NSZ_COD) do registro.
Uso Geral.
@author Cl�vis Eduardo Teixeira
@param oLstPesq - Objeto ListBox
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GetListaCod(oLstPesq, cCampo)
	Local nPos := 1
	Local nX

	Default cCampo := 'NSZ_COD'

	For nX := 1 To LEN(oLstPesq:aHeader)
		if AllTrim(oLstPesq:aHeader[nX][2]) == cCampo
			nPos := nX
			Exit
		Endif
	Next

Return IIF( LEN(oLstPesq:aCols)>0, oLstPesq:aCols[oLstPesq:NAT][nPos], )
