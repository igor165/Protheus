#INCLUDE 'JURA026.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

#define SW_HIDE             0 //  Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada

/*
Requisitos:
Instalar a ferramenta Interwoven e ter um usuário criado para acessar;
Salvar a DLL "SIGAGEDW.dll" na mesma pasta que o executável "TotvsSmartClient.exe";
Parâmetros "MV_JGEDDLL" como "SIGAGEDW.dll" e "MV_JGEDSER" configurado com nome do servidor GED.
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA026
Funcionalidades da tela de anexar documentos jurídicos

@author Juliana Iwayama Velho
@since 01/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} JURANEXDOC
Monta a query para exibir os documentos anexados do registro da entidade passada.

Uso Geral.

@param 	cEntidade  			Nome da entidade (em caso de modelo 3, nome da entidade master)
@param 	cModel 	   			Nome do model (em caso de modelo 3, nome do model master)
@param 	cCampoAssJur		Nome do campo que faz relação com o assunto jurídico
@param 	cCampoCodigo  		Nome do campo da PK (em caso de modelo 3, nome da PK master)
@param 	cDetailEntidade 	Nome da entidade detail (só em caso de modelo 3)
@param 	cDetailModel     	Nome do model detail (só em caso de modelo 3)
@param 	cDetailCampo     	Nome do campo da PK detail (só em caso de modelo 3)
@param 	lBrowse				.T. para identificar que a chamada vem fora do modelo
@param  lOpenFluig          Abre fluig
@param  lIntPFS             Integra com PFS
@param  cFilOrig            Filial de origem

@Return NIL

@sample

Modelo 1: Quando o cadastro depende de Assunto Juridico devido a pesquisa de cliente/caso
oView:AddUserButton( "Anexar", "CLIPS", {| oView | JURANEXDOC("NUN","NUNMASTER","NUN_CAJURI","NUN_COD") } )

Modelo 2: Quando o cadastro não depende de Assunto Juridico
oView:AddUserButton( "Anexar", "CLIPS", {| oView | JURANEXDOC("NUN","NUNMASTER",,"NUN_COD") } )

Modelo 3: Quando o cadastro depende de Assunto Juridico devido a pesquisa de cliente/caso
oView:AddUserButton( "Anexar", "CLIPS", {| oView | JURANEXDOC("NUN","NUNMASTER","NUN_CAJURI","NUN_COD","NUP","NUPDETAIL","NUP_COD") } )

@author Raphael Zei
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURANEXDOC(cEntiMain, cModelMain, cAssJur, cCodMain, cEntiDet, cModelDet, cCodDetail, cClienteLoja, cCaso, cOrdem, xCompl, lBrowse, lOpenFluig, lIntPFS, cFilOrig)
Local cRecno         := &((cEntiMain) +"->(RECNO())")
Local aArea          := GetArea()
Local cQuery         := " "
Local cQryValida     := GetNextAlias()
Local cCodAssJur     := " "
Local cCodigo        := " "
Local cCodigoRelacao := " "
Local cEntiRelac     := " "
Local cCliLoja       := ""
Local cCasoCliente   := ""
Local cTableName     := cEntiMain
Local cParam         := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))
Local aCliLoja       := {}
Local cTipoAsj       := ""
Local nOperacao      := 3
Local nOperaBC       := 0
Local nCpo           := 0
Local oModel         := Nil
Local lCharCompl     := .T.
Local xTemp          := {}

cEntiMain := PrefixoCpo(cEntiMain)

ParamType 0 Var cEntiMain      	As Character
ParamType 1 Var cModelMain     	As Character optional default " "
ParamType 2 Var cAssJur		   	As Character optional default " "
ParamType 3 Var cCodMain		As Character
ParamType 4 Var cEntiDet		As Character optional default " "
ParamType 5 Var cModelDet    	As Character optional default " "
ParamType 6 Var cCodDetail    	As Character optional default " "
ParamType 7 Var cClienteLoja	As Character optional default ""
ParamType 8 Var cCaso			As Character optional default ""
ParamType 9 Var cOrdem			As Character optional default ""

Default lBrowse    := .F. //Variável que controla se a chamada esta sendo feita de um browse ou não
Default lOpenFluig := .F. //Variável para somente abrir a tela de anexos do Fluig.
Default lIntPFS    := .F.
Default cFilOrig   := xFilial(cEntiMain)
Default xCompl     := ""

lCharCompl := ValType(xCompl) == "C"

IF !lBrowse

	oModel := FWModelActive()

	If !Empty(cAssJur)
		cCodAssJur  := oModel:GetValue( cModelMain, cAssJur )
	EndIf

	cCodigo := oModel:GetValue( cModelMain, cCodMain )
	nOperacao            := oModel:GetOperation()

	If cEntiDet == "" .OR. cModelDet == " "
		cCodigoRelacao	:= oModel:GetValue( cModelMain, cCodMain )
		cEntiRelac 		:= cTableName
	Else
		cCodigoRelacao	:= oModel:GetValue( cModelDet, cCodDetail )
		cEntiRelac			:= cEntiDet
		cRecno				:= oModel:GetModel(cModelDet):GetDataID() //Pega o correto recno quando é GRID - Detail
	Endif

	Do Case
		Case cOrdem == '1'
	   		cCodigoRelacao := cCodigoRelacao + cCodAssJur
		Case cOrdem == '2'
   			cCodigoRelacao := cCodAssJur + cCodigoRelacao
		Case cOrdem == '3'
			If lCharCompl
				If !Empty(xCompl)
    				xCompl := oModel:GetValue(cModelMain, xCompl)
				EndIf
			Else
				xTemp  := aClone(xCompl)
				xCompl := ""
				For nCpo := 1 To Len(xTemp)
					xCompl += oModel:GetValue(cModelMain, xTemp[nCpo])
				Next nCpo
			EndIf
    		cCodigoRelacao := cCodigoRelacao + xCompl
	End Case

	If !JurHasClas()
	cQuery += "SELECT " + cCodMain
	cQuery += "  FROM " + RetSqlName( cTableName ) + " " + cTableName
	cQuery += " WHERE " + cEntiMain + "_FILIAL = '" + xFilial( cTableName ) + "' "
	cQuery += "   AND " + cCodMain + " = '" + cCodigo + "' "
	cQuery += "   AND " + cTableName + ".D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cQryValida, .T., .F. )
	EndIf
Else
	cCodigo			:= cCodMain

	// Ordem 2 = Garantia
	If cOrdem == '2'
		cCodigoRelacao := cAssJur + cCodMain
	ElseIf cOrdem == '3'
		cCodigoRelacao := cCodMain + cAssJur
	Else
		cCodigoRelacao	:= cCodMain + cCodDetail
	EndIf

	cEntiRelac  	:= cTableName
	cCodAssJur		:= cAssJur
	nOperacao		:= 4

Endif

If !JurHasClas()
	If lBrowse .Or. (!lBrowse .And. !(cQryValida)->( EOF() )) //se foi chamado de um browse ou se for do modelo e o registro já foi salvo

	cQuery := " "
	cQuery += "SELECT NUM_COD, NUM_DESC, NUM_EXTEN, NUM_DOC, NUM_CENTID, NUM_ENTIDA "
	cQuery += "  FROM " + RetSqlName( 'NUM' ) + ' NUM  '
	cQuery += " WHERE NUM_FILIAL = '" + xFilial( 'NUM' ) + "' "
	cQuery += "   AND NUM_ENTIDA = '" + cEntiRelac + "' "
	cQuery += "   AND NUM_CENTID = '" + PadR( cCodigoRelacao, TamSX3('NUM_CENTID')[1]) + "' "
	cQuery += "   AND NUM.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )

	If cParam == '1'
		If !IsPlugin()
			JurMsgErro(STR0083) // "A funcionalidade de anexos com Worksite foi descontinuada para a versão 12.1.17 do Protheus. Para utiliza-la, favor realizar a atualização para a versão mais recente."
		EndIf
	ElseIf cParam == '2'
		If IsPesquisa() // Se for a opção Anexar da tela de pesquisa, é necessário posicionar na tabela
			cRecno := JA026Recno(cEntiMain, cCodAssJur, cCodigoRelacao)
		EndIf

		//Apresenta nova tela de base de conhecimento
		DbSelectArea("NUM")
		If ColumnPos("NUM_MARK") > 0
			J026aBaCon(cEntiRelac, nOperacao, cRecno, cCodAssJur, cCodigoRelacao, cFilOrig)
		Else
			If nOperacao == 5
				nOperaBC := 1
			Else
				nOperaBC := nOperacao
			EndIf
			MsDocument(cEntiRelac, cRecno, nOperaBC)
		EndIf
	ElseIf cParam == '3'

		If Empty(cClienteLoja) .And. Empty(cCaso)
			aCliLoja     := JurGetDados("NSZ",1,xFilial("NSZ")+cCodAssJur, {"NSZ_CCLIEN","NSZ_LCLIEN","NSZ_NUMCAS", "NSZ_TIPOAS"})
			cCliLoja     := aCliLoja[1] + aCliLoja[2]
			cCasoCliente := aCliLoja[3]
			cTipoAsj     := aCliLoja[4]
		Else
			cCliLoja     := cClienteLoja
			cCasoCliente := cCaso
		EndIf

		If !Empty(cCliLoja) .And. ColumnPos(cEntiMain+"_NUMCAS") > 0
			cCasoCliente := &(cEntiMain+"->("+cEntiMain+"_NUMCAS)")
		EndIf

		If lOpenFluig
			ApMsgInfo(STR0072) //Será aberto o fluig
			JF26Abrir( cClienteLoja, cCaso)
		Else
			JF026Tela(cTipoAsj, cEntiRelac, cCodAssJur, nOperacao, cCliLoja, cCasoCliente, cCodigoRelacao)
		EndIf
	Else
		JurMsgErro( STR0035 ) //"Verificar o conteudo do parametro MV_JDOCUME"
	EndIf

	cRecno := ""
	Else

	JurMsgErro( STR0001 ) // "Para anexar um documento é preciso salvar o registro antes!"

	EndIf

	If !lBrowse
		(cQryValida)->( dbCloseArea() )
	Endif

Else
	JurAnexos(cEntiRelac, cCodigoRelacao, , , lIntPFS)
EndIf


RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JGExcluir( cCodigo, lConf )
Excluir Documento no SIGAJURI

@Param cCodigo - Código do Anexo (NUM_COD)
@Param lConf - Verifica se irá conferir antes de excluir

@author SIGAJURI
@since
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGExcluir( cCodigo, lConf )
Local aArea    := GetArea()
Local aAreaNUM := NUM->( GetArea() )
Local lRet     := .F.
Local cMsgDes  := ''
Local lIntPFS  := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local lFSinc   := SuperGetMV("MV_JFSINC", .F., '2') == "1" // Indica se utiliza a integração com o Legal Desk (SIGAPFS)
Local oModel   := Nil
Local cAlias   := ""
Local cChave   := ""

Default lConf := .T.

If !Empty(cCodigo)

	If lConf
		lRet := ApMsgYesNo(STR0020)
	Else
		lRet := .T.
	EndIf

	If lRet

		NUM->( dbSetOrder( 1 ) )

		If NUM->( dbSeek( xFilial('NUM') + cCodigo ) )
			cDirArq := AllTrim(NUM->NUM_DESC) + AllTrim(NUM->NUM_EXTEN)
			Reclock( 'NUM', .F. )
			dbDelete()
			MsUnlock()
			If Deleted()
				J26aGrBaCo(5, /*cCodNum*/, /*cCodObj*/, "SE2"/*cEntidade*/, /*cCodEnt*/, cDirArq, /*cDirVir*/, /*@cOrigem*/, 2/*nACBIndex*/)
			EndIf

			If Deleted() .AND. lConf

				cMsgDes :=  STR0013 + CRLF + CRLF + STR0079

				ApMsgInfo(cMsgDes) // "Documento desvinculado com sucesso!"

				If lIntPFS .And. lFSinc
					oModel := FWModelActive()
					If oModel:GetOperation() == 1 // Visualiza
						Do Case
						Case oModel:GetId() == "JURA241"
							cAlias := "OHB"
							cChave := oModel:GetValue("OHBMASTER", "OHB_CODIGO")
						Case "JURA235" $ oModel:GetId()
							cAlias := "NZQ"
							cChave := oModel:GetValue("NZQMASTER", "NZQ_COD")
						Case oModel:GetId() == "JURA246"
							cAlias := "OHF"
							cChave := oModel:GetValue("OHFDETAIL", "OHF_IDDOC") + oModel:GetValue("OHFDETAIL", "OHF_CITEM")
						Case oModel:GetId() == "JURA247"
							cAlias := "OHG"
							cChave := oModel:GetValue("OHGDETAIL", "OHG_IDDOC") + oModel:GetValue("OHGDETAIL", "OHG_CITEM")
						EndCase
						J170GRAVA(cAlias, xFilial(cAlias) + cChave, "5")
					Endif
				Endif
			EndIf
		EndIf

	EndIf

Else
	JurMsgErro( STR0022 )
EndIf

RestArea( aAreaNUM )
RestArea( aArea )
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurExcAnex
Função genérica para excluir os documentos anexados ao excluir o
registro-pai
Uso Geral.

@param cEntidade Nome da Entidade (range da tabela)
@param cCodEntid Campo de código da entidade
@param cComposto Campo de código para entidade composta
@param cOrdem    Ordem que definirá qual chave será utilizada para o dbseek

@Return lRet	 		.T./.F. O vinculo do documento anexo é válido ou não
@sample
If nOpc == 5
	lRet := JurExcAnex ('NT4',oModel:GetValue("NT4MASTER","NT4_COD"))
EndIf

@author Juliana Iwayama Velho
@since 17/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurExcAnex(cEntidade, cCodEntid, cComposto, cOrdem)

Local aArea    := GetArea()
Local aAreaAC9 := AC9->( GetArea() )
Local lRet     := .T.
Local cCod     := ''
Local cParam   := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))

	ParamType 2 Var cComposto As Character optional default ""
	ParamType 3 Var cOrdem    As Character optional default ""

	If cParam =='1'

		lRet := DeleteNUM(cEntidade, cCodEntid, cComposto, cOrdem)

	Else

		If !Select("AC9") > 0
			DBSelectArea("AC9")
		EndIf
		AC9->( dbSetOrder( 2 ) ) // AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
		
		Do Case
			Case cOrdem == '1'
				AC9->( dbSeek( XFILIAL('AC9') + cEntidade + XFILIAL(''+cEntidade+'') + cCodEntid + cComposto ))
				cCod := XFILIAL('AC9') + cEntidade + XFILIAL(''+cEntidade+'') + cCodEntid + cComposto
			Case cOrdem == '2'
				AC9->( dbSeek( XFILIAL('AC9') + cEntidade + XFILIAL(''+cEntidade+'') + cComposto + cCodEntid ))
				cCod := XFILIAL('AC9') + cEntidade + XFILIAL(''+cEntidade+'') + cComposto + cCodEntid
			Case cOrdem == '3'
				AC9->( dbSeek( XFILIAL('AC9') + cEntidade + XFILIAL(''+cEntidade+'') + cCodEntid + cComposto ))
				cCod := XFILIAL('AC9') + cEntidade + XFILIAL(''+cEntidade+'') + cCodEntid + cComposto
			Otherwise
				If AC9->( dbSeek( xFilial("AC9")  + cEntidade + XFILIAL(''+cEntidade+'') + cCodEntid ))
					cCod := xFilial("AC9") + cEntidade + XFILIAL(''+cEntidade+'') + cCodEntid
				ElseIf AC9->( dbSeek( xFilial("AC9")  + cEntidade + XFILIAL(''+cEntidade+'') +  XFILIAL(''+cEntidade+'') + cCodEntid ))
					cCod := xFilial("AC9") + cEntidade + XFILIAL(''+cEntidade+'') + XFILIAL(''+cEntidade+'') + cCodEntid
				EndIf
		End Case

		While !AC9->( EOF() ) .AND.;
			( RTrim(AC9->(AC9_FILIAL + AC9_ENTIDA + AC9_FILENT + PadR(AC9_CODENT,50))) == cCod;
			.OR. RTrim(AC9->(AC9_FILIAL + AC9_ENTIDA + AC9_FILENT + AC9_FILENT + PadR(AC9_CODENT,50))) == cCod )

			AC9->( Reclock( 'AC9', .F. ) )
			AC9->( dbDelete() )
			AC9->( MsUnlock() )

			lRet := AC9->( DELETED())
			If !lRet
				JurMsgErro(STR0023) //"Erro ao desvincular documento(s) anexo(s)"
				Exit
			else
				lRet := DeleteNUM(cEntidade, cCodEntid, cComposto, cOrdem)
			EndIf

			AC9->( dbSkip() )
		End
		
		AC9->( DbCloseArea() )
		
	EndIf

	RestArea( aAreaAC9 )
	RestArea( aArea )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteNUM
Função auxiliar para excluir os documentos na tabela NUM anexados ao excluir o
registro-pai
Uso Geral.

@param cEntidade Nome da Entidade (range da tabela)
@param cCodEntid Campo de código da entidade
@param cComposto Campo de código para entidade composta
@param cOrdem    Ordem que definirá qual chave será utilizada para o dbseek

@Return lRet .T./.F. A exclusão do documento foi feita ou não

@since 06/08/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function DeleteNUM(cEntidade, cCodEntid, cComposto, cOrdem)

Local aArea    := GetArea()
Local aAreaNUM  := NUM->( GetArea() )
Local lRet      := .T.

	If !Select("NUM") > 0
		DBSelectArea("NUM")
	EndIf

	NUM->( dbSetOrder( 3 ) ) // NUM_FILIAL+NUM_ENTIDA+NUM_CENTID
	Do Case
		Case cOrdem == '1'
			NUM->( dbSeek( XFILIAL(cEntidade) + cEntidade + cCodEntid + cComposto ) )
			cCod := XFILIAL(cEntidade) + cEntidade + cCodEntid + cComposto
		Case cOrdem == '2'
			NUM->( dbSeek( XFILIAL(cEntidade) + cEntidade + cComposto + cCodEntid ) )
			cCod := XFILIAL(cEntidade) + cEntidade + cComposto + cCodEntid
		Otherwise
			If NUM->( dbSeek( XFILIAL(cEntidade) + cEntidade + cCodEntid ) )
				cCod := XFILIAL(cEntidade) + cEntidade + cCodEntid
			ElseIf NUM->( dbSeek( cFilAnt + cEntidade + cFilAnt + cCodEntid ) )
				cCod := cFilAnt + cEntidade + cFilAnt + cCodEntid
			EndIf
	End Case

	While !NUM->( EOF() ) .AND.;
			RTrim(NUM->(NUM_FILIAL + NUM_ENTIDA + PadR(NUM_CENTID,50))) == cCod

		NUM->( Reclock( 'NUM', .F. ) )
		NUM->( dbDelete() )
		NUM->( MsUnlock() )

		lRet := NUM->(DELETED())
		If !lRet
			JurMsgErro(STR0023)  //"Erro ao desvincular documento(s) anexo(s)"
			Exit
		EndIf

		NUM->( dbSkip() )
	End
	
	NUM->( DbCloseArea() )

	RestArea( aAreaNUM )
	RestArea( aArea )
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLegAnex
Função genérica para excluir os documentos anexados ao excluir o
registro-pai
Uso Geral.

@param 	cEntidade 	Nome da Entidade
@param 	cChave1 		Chave para anexos do Worksite
@param 	cChave2 		Chave para anexos da Base de conhecimento

@author Jorge Luis Branco Martins	Junior
@since 23/02/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLegAnex(cEntidade, cChave1, cChave2)

	Local cParam     := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))
	Local lRet       := .F.
	Local cQuery     := ''
	Local aArea      := GetArea()
	Local cResQRY    := GetNextAlias()
	Local lJurHasCls := JurHasClas()
	Local cChave     := ""
	Local nIndice    := ""

	If cParam == '1' // Worksite

		If lJurHasCls
			nIndice := 5  // NUM_FILIAL + NUM_ENTIDA + NUM_FILENT + NUM_CENTID
			cChave  := xFilial('NUM') + cEntidade + xFilial(cEntidade) + &(cChave1)
		Else
			nIndice := 3 // NUM_FILIAL + NUM_ENTIDA + NUM_CENTID
			cChave  := xFilial('NUM') + cEntidade + &(cChave1)
		EndIf

		lRet := !Empty( AllTrim(POSICIONE('NUM', nIndice, cChave,'NUM_DOC')) )

	Else
		If cEntidade <> 'NUN'
			lRet := !Empty(Posicione('NUM', IIF(JurHasClas(), 5, 3), xFilial('NUM') + cEntidade + &(cChave2), 'NUM_COD'))
		Else
			cQuery += "  SELECT NUN_CAJURI, NUN_COD, NUP_COD " + CRLF
			cQuery += "    FROM " + RetSqlName( "NUN" ) + " NUN " + CRLF
			cQuery += "    		INNER JOIN " + RetSqlName( "NUP" ) + " NUP " + CRLF
			cQuery += "       	ON(NUP_FILIAL = NUN_FILIAL" + CRLF
			cQuery += "      	 AND NUP_CPEDRH = NUN_COD)" + CRLF
			cQuery += "    		INNER JOIN " + RetSqlName( "AC9" ) + " AC9 " + CRLF
			cQuery += "       	ON(AC9_FILIAL = NUP_FILIAL" + CRLF
			cQuery += "      	 AND AC9_CODENT = NUP_FILIAL+NUP_CPEDRH+NUP_COD+NUP_CTPDOC)" + CRLF
			cQuery += "   WHERE NUN_COD  = '" + &(cChave1) + "' " + CRLF
			cQuery += "   	AND NUN.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "   	AND NUP.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "   	AND AC9.D_E_L_E_T_ = ' ' " + CRLF

			cQuery := ChangeQuery( cQuery )
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery ),cResQRY,.T.,.F.)

			If !((cResQRY)->(EOF()))
				dbSelectArea(cResQRY)
	 			(cResQRY)->( dbcloseArea() )
				RestArea( aArea )
				Return .T.
			EndIf

			dbSelectArea(cResQRY)
 			(cResQRY)->( dbcloseArea() )
			RestArea( aArea )
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
// Pesquisar Documento no Fluig e Anexar
//-------------------------------------------------------------------
Static Function JFAnexar(cClienteLoja, cCaso, cEntidFili, cEntidade, cCodigo, aCoord, cCodigoRelacao, cAssJur)

Local aArea     := GetArea()
Local cUsuario	:= AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenha	:= AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local nEmpresa  := AllTrim(SuperGetMV('MV_ECMEMP' ,,0))
Local cColId	:= JColId(cUsuario,cSenha,nEmpresa,UsrRetMail ( __CUSERID ))
Local cPstFil	:= ""
Local ni		:= 0
Local nj		:= 0
Local cErro		:= ""
Local cAviso	:= ""
Local cPathCab  := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCHILDRENRESPONSE:_DOCUMENT:_ITEM"
Local nDoc
Local nVersao
Local nTipo 	:= "0"
Local cFile		:= ""
Local aDocs		:= {}
Local aPastas	:= {}
Local oDlgTree, oTree
Local cDocto		:= ""
Local cVersao		:= ""
Local oBtnSair
Local oBtnCanc
Local oTela
Local oPnlTree
Local oPnlRoda
Local aNodes	    := {}
Local aCriaPst      := hasFolderF(cClienteLoja, cCaso)//1 - lRet / 2 - cDocto / 3 - cVersao
Local lOk           := .F.
Local lMsg          := .T.

Default cAssJur := ""

	If aCriaPst[1] // Existe a pasta criada no fluig

		cDocto  := aCriaPst[2]
		cVersao := aCriaPst[3]

		cPstFil	:= JGetChild(cDocto,cUsuario,cSenha,nEmpresa,cColid)

		oXmlgetChildren := XmlParser( cPstFil, "_", @cErro, @cAviso )

		If oXmlgetChildren <> Nil
			If "item" $ cPstFil

				If ValType(&("oXmlgetChildren" + cPathCab)) == "A"
					For ni:=1 to Len(&("oXmlgetChildren" + cPathCab))

						If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTID") <> Nil
							nDoc 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTID:TEXT")
							If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTTYPE") <> Nil
								nTipo 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTTYPE:TEXT")
							EndIf
							If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_VERSION") <> Nil
								nVersao 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_VERSION:TEXT")
							EndIf

							If nTipo == "1"
								If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
									cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
								EndIf

								aAdd(aPastas,{cFile,nDoc,nVersao,'01'})

							ElseIf nTipo == "2"
								If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
									cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
								EndIf

								aAdd(aDocs,{cFile,nDoc,nVersao,'01',0})

							EndIf
						EndIf
					Next
				Else
					If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTID") <> Nil
						nDoc 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTID:TEXT")
						If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTTYPE") <> Nil
							nTipo 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTTYPE:TEXT")
						EndIf
						If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_VERSION") <> Nil
							nVersao 	:= &("oXmlgetChildren" + cPathCab + ":_VERSION:TEXT")
						EndIf

						If nTipo == "1"
							If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
								cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
							EndIf

							aAdd(aPastas,{cFile,nDoc,nVersao,'01'})

						ElseIf nTipo == "2"
							If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
								cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
							EndIf

							aAdd(aDocs,{cFile,nDoc,nVersao,'01',0})

						EndIf
					EndIf
				EndIf

				//Nivel 2
				For ni:=1 to Len(aPastas)
					cPstFil	:= JGetChild(aPastas[ni][2],cUsuario,cSenha,nEmpresa,cColid)

					oXmlgetChildren := XmlParser( cPstFil, "_", @cErro, @cAviso )

					If oXmlgetChildren <> Nil .AND. "item" $ cPstFil

						If ValType(&("oXmlgetChildren" + cPathCab)) == "A"

							For nj:=1 to Len(&("oXmlgetChildren" + cPathCab))

								If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTID") <> Nil
									nDoc 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTID:TEXT")
									If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTTYPE") <> Nil
										nTipo 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTTYPE:TEXT")
									EndIf
									If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_VERSION") <> Nil
										nVersao 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_VERSION:TEXT")
									EndIf

									If nTipo == "2"
										If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
											cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
										EndIf

										aAdd(aDocs,{cFile,nDoc,nVersao,'02',ni})

									EndIf
								EndIf
							Next
						Else
							If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTID") <> Nil
								nDoc 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTID:TEXT")
								If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTTYPE") <> Nil
									nTipo 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTTYPE:TEXT")
								EndIf
								If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_VERSION") <> Nil
									nVersao 	:= &("oXmlgetChildren" + cPathCab + ":_VERSION:TEXT")
								EndIf

								If nTipo == "2"
									If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
										cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
									EndIf

									aAdd(aDocs,{cFile,nDoc,nVersao,'02',ni})

								EndIf
							EndIf
						EndIf
					EndIf
				Next

				nSeq:=1
				aadd(aNodes,{'00',StrZero(nSeq,4),"",STR0038,"FOLDER5","FOLDER6"}) //"Raiz"
				For ni:=1 to Len(aPastas)
					nSeq++
					aadd(aNodes,{aPastas[ni][4],StrZero(nSeq,4),"",aPastas[ni][1],"FOLDER5","FOLDER6"})
					For nj:=1 to Len(aDocs)
						If aDocs[nj][5] == ni
							nSeq++
							aadd(aNodes,{aDocs[nj][4],StrZero(nSeq,4),"",aDocs[nj][2]+";"+aDocs[nj][3]+" - "+aDocs[nj][1],"",""})
						EndIf
					Next
				Next

				For nj:=1 to Len(aDocs)
					If aDocs[nj][5] == 0
						nSeq++
						aadd(aNodes,{aDocs[nj][4],StrZero(nSeq,4),"",aDocs[nj][2]+";"+aDocs[nj][3]+" - "+aDocs[nj][1],"",""})
					EndIf
				Next

				DEFINE MSDIALOG oDlgTree TITLE STR0039 FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Pixel style DS_MODALFRAME //"Diretórios Fluig"

				oTela     := FWFormContainer():New( oDlgTree )
				cIdTree   := oTela:CreateHorizontalBox( 84 )
				cIdRodape := oTela:CreateHorizontalBox( 16 )
				oTela:Activate( oDlgTree, .F. )
				oPnlTree  := oTela:GeTPanel( cIdTree   )
				oPnlRoda  := oTela:GeTPanel( cIdRodape )

				@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 221 Button oBtnCanc	   Prompt STR0040		Size 25 , 12 Of oPnlRoda Pixel Action ( oDlgTree:End() ) //"Cancelar"
				@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 273 Button oBtnSair     Prompt STR0041		Size 25 , 12 Of oPnlRoda Pixel Action ( VincFluig(cClienteLoja, cCaso, cEntidFili, cEntidade, cCodigo, oTree, cCodigoRelacao), oDlgTree:End() ) //"Ok"

				oTree := DbTree():New( 0, 0, 0, 0, oPnlTree,,, .T. )
				oTree:Align 	 := CONTROL_ALIGN_ALLCLIENT
				oTree:BCHANGE 	 := {|| }
				oTree:BLDBLCLICK := {|| VincFluig(cClienteLoja, cCaso, cEntidFili, cEntidade, cCodigo, oTree, cCodigoRelacao, cAssJur), lOk:=.T.,oDlgTree:End()}
				oTree:BLCLICKED  := {|| }

				oTree:PTSendTree( aNodes )

				Activate MsDialog oDlgTree Centered
			Else
				cErro := STR0080 + AllTrim(cErro) //"A pasta do caso está vazia. Não existem documentos a serem anexados."
				lMsg  := .F.
			EndIf

			If !Empty(cErro)
				If !lMsg
					cErro := AllTrim(cErro)
				Else
					cErro := STR0057 + AllTrim(cErro) //"Não foi possível efetuar o anexo(s) do(s) documento(s) no Fluig: "
				EndIf

				JurMsgErro(cErro)
			Else
				If lOk
					ApMsgInfo(STR0010) //"Documento(s) anexado(s) com sucesso!"
				EndIf
			EndIf
		Else
			//³Retorna falha no parser do XML³
			cErro := STR0042 //"Objeto XML nao criado, verificar a estrutura do XML"
		EndIf
	Else
		ApMsgInfo(STR0047)//"A pasta do caso não foi criada no Fluig"
	EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
// Pesquisar Documento no Fluig e Anexar
//-------------------------------------------------------------------
Static Function VincFluig(cClienteLoja, cCaso, cEntidFili, cEntidade, cCodigo, oTree, cAssJur)

	Local nDoc		:= SubStr(oTree:GetPrompt(.T.),1,at(";",oTree:GetPrompt(.T.))-1)
	Local nVersao	:= SubStr(oTree:GetPrompt(.T.),at(";",oTree:GetPrompt(.T.))+1,4)
	Local cFile		:= SubStr(oTree:GetPrompt(.T.),at("-",oTree:GetPrompt(.T.))+2)

	If at(";",oTree:GetPrompt(.T.)) <> 0
		VincFlgNUM(cEntidFili, cEntidade, cCodigo, nDoc+";"+nVersao, cFile,, cAssJur)
	Else
		ApMsgInfo(STR0043) //"Não é possivel vincular uma Pasta"
	EndIf

Return

//-------------------------------------------------------------------will
/*/{Protheus.doc} VincFlgNUM
Função responsável por somente vincular o registro na NUM

@Param cEntidFili	-
@Param cEntidade 	-
@Param cCodigo		-
@Param cDoc		- Numero do documento + versão [nDoc+";"+nVersao]
@Param cFile		- Nome do Arquivo

@return bReturn
@author Willian Yoshiaki Kazahaya
@since  02/05/2017
/*/
//-------------------------------------------------------------------
Static Function VincFlgNUM(cEntidFili, cEntidade, cCodigo, cDoc, cFile, bMsgSucess, cAssJur)
	Local cCentId       := cCodigo
	Local aArea         := GetArea()
	Local aAreaNUM      := NUM->( GetArea() )
	Local cNumCod       := ""
	Local lRet          := .T.

	If !JurHasClas()
		cCentId := xFilial(cEntidade) + AllTrim(cCentId)
	EndIf

	Default bMsgSucess := .T.

	cCentId := StrTran(cCentId, "+","")

	NUM->( dbSetOrder( 4 ) )	//NUM_FILIAL+NUM_DOC+NUM_ENTIDA+NUM_CENTID
	If !NUM->( dbSeek( xFilial( 'NUM' ) + PadR( cDoc, TamSX3('NUM_DOC')[1]) + cEntidade + cCentId) )

		cNumCod := GetSXENum("NUM","NUM_COD")
		lRet := RecLock( 'NUM', .T. )  // Trava registro

		NUM->NUM_FILIAL := xFilial( 'NUM' )
		NUM->NUM_COD    := cNumCod
		NUM->NUM_FILENT := cEntidFili
		NUM->NUM_ENTIDA := cEntidade
		NUM->NUM_CENTID := cCentId
		NUM->NUM_DOC    := cDoc
		NUM->NUM_NUMERO := ''
		NUM->NUM_DESC   := cFile
		NUM->NUM_EXTEN  := ''

		MsUnlock()     // Destrava registro
		ConfirmSX8()

		If bMsgSucess
			ApMsgInfo(STR0010) // "Documento anexado com sucesso!"
		EndIf
	Else
		If bMsgSucess
			ApMsgInfo(STR0025) // "Documento já vinculado!"
		EndIf
	EndIf

	RestArea(aAreaNUM)
	RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
// Importar Documento no Fluig
//-------------------------------------------------------------------
Static Function JFImport(cClienteLoja, cCaso)

Local aArea    := GetArea()
Local nEmpresa := AllTrim(SuperGetMV('MV_ECMEMP2',,""))
Local cUrl     := StrTran(AllTrim(JFlgUrl()), '/webdesk/', '')
Local aCriaPst := hasFolderF(cClienteLoja, cCaso)//1 - lRet / 2 - cDocto / 3 - cVersao

If Empty(nEmpresa)
	nEmpresa := AllTrim(SuperGetMV('MV_ECMEMP' ,,0))
EndIf

If aCriaPst[1]
	ShellExecute("open", cUrl + "/portal/p/" + nEmpresa + "/ecmnavigation?app_ecm_navigation_doc=" + aCriaPst[2] + "&app_ecm_navigation_docVersion=" + aCriaPst[3],"","",SW_SHOW)
Else
	ApMsgInfo(STR0047)//"A pasta do caso não foi criada no Fluig"
EndIf

RestArea(aArea)

Return NIL


//-------------------------------------------------------------------
// Abrir Documento no Fluig
//-------------------------------------------------------------------
Static Function JFAbrir(cClienteLoja, cCaso, cDoc)

Local aArea    := GetArea()
Local nEmpresa := AllTrim(SuperGetMV('MV_ECMEMP2',,""))
Local cUrl     := StrTran(StrTran(AllTrim(JFlgUrl()), '/webdesk', ''), '//','/',2)
Local cDocto   := ""
Local cVersao  := ""
Local aCriaPst := {}

Default cDoc := ""

If Empty(nEmpresa)
	nEmpresa := AllTrim(SuperGetMV('MV_ECMEMP' ,,0))
EndIf

If Empty(cDoc) //Se for abrir a pasta do caso
	aCriaPst := hasFolderF(cClienteLoja, cCaso)//1 - lRet / 2 - cDocto / 3 - cVersao
	If aCriaPst[1]
		cDocto  := aCriaPst[2]
		cVersao := aCriaPst[3]
	EndIf
Else
	//se for abrir um doc específico
	cDocto	:= SubStr(cDoc,1,at(";",cDoc)-1)
	cVersao	:= SubStr(cDoc,at(";",cDoc)+1,4)

	If Empty(cDocto)//Se não encontrar o doc, chama a função para buscar ou criar a pasta no fluig
		aCriaPst := hasFolderF(cClienteLoja, cCaso)//1 - lRet / 2 - cDocto / 3 - cVersao
		If aCriaPst[1]
			cDocto  := aCriaPst[2]
			cVersao := aCriaPst[3]
		EndIf
	EndIf
Endif

If !Empty(cDocto)
	cUrl := StrTran((cUrl+"/portal/p/"+nEmpresa+"/ecmnavigation?app_ecm_navigation_doc="+cDocto+"&app_ecm_navigation_docVersion="+cVersao),'//','/',2)
	ShellExecute("open", cUrl ,"","",SW_SHOW)
Else
	ApMsgInfo(STR0046)//"A pasta do assunto jurídico não esta configurada"
EndIf

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
// Pesquisar Documento no Fluig
//-------------------------------------------------------------------
Static Function JFPesqDoc(cClienteLoja, cCaso)

Local aArea     := GetArea()
Local cUsuario  := AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenha    := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local nEmpresa  := AllTrim(SuperGetMV('MV_ECMEMP' ,,0))
Local cColId    := JColId(cUsuario,cSenha,nEmpresa,UsrRetMail ( __CUSERID ))
Local cPstFil   := ""
Local ni        := 0
Local nj        := 0
Local cErro     := ""
Local cAviso    := ""
Local cPathCab  := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCHILDRENRESPONSE:_DOCUMENT:_ITEM"
Local nDoc      := 0
Local nVersao   := 0
Local nTipo     := "0"
Local cFile     := ""
Local aDocs     := {}
Local aPastas   := {}
Local cDocto    := ""
Local cVersao   := ""

NZ7->(dbsetorder(1))
NZ7->( DBSeek(XFILIAL('NZ7') + cClienteLoja + cCaso) )
cDocto	:= SubStr(NZ7->NZ7_LINK,1,at(";",NZ7->NZ7_LINK)-1)
cVersao	:= SubStr(NZ7->NZ7_LINK,at(";",NZ7->NZ7_LINK)+1,4)

cPstFil	:= JGetChild(cDocto,cUsuario,cSenha,nEmpresa,cColid)

oXmlgetChildren := XmlParser( cPstFil, "_", @cErro, @cAviso )

If oXmlgetChildren <> Nil .AND. "item" $ cPstFil

	If ValType(&("oXmlgetChildren" + cPathCab)) == "A"
		For ni:=1 to Len(&("oXmlgetChildren" + cPathCab))

			If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTID") <> Nil
				nDoc 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTID:TEXT")
				If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTTYPE") <> Nil
					nTipo 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTTYPE:TEXT")
				EndIf
				If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_VERSION") <> Nil
					nVersao 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_VERSION:TEXT")
				EndIf

				If nTipo == "1"
					If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
						cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
					EndIf

					aAdd(aPastas,{cFile,nDoc,nVersao,'01'})

				ElseIf nTipo == "2"
					If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
						cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
					EndIf

					aAdd(aDocs,{cFile,nDoc,nVersao,'01',0})

				EndIf
			EndIf
		Next
	Else
		If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTID") <> Nil
			nDoc 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTID:TEXT")
			If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTTYPE") <> Nil
				nTipo 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTTYPE:TEXT")
			EndIf
			If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_VERSION") <> Nil
				nVersao 	:= &("oXmlgetChildren" + cPathCab + ":_VERSION:TEXT")
			EndIf

			If nTipo == "1"
				If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
					cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
				EndIf

				aAdd(aPastas,{cFile,nDoc,nVersao,'01'})

			ElseIf nTipo == "2"
				If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
					cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
				EndIf

				aAdd(aDocs,{cFile,nDoc,nVersao,'01',0})

			EndIf
		EndIf
	EndIf

	//Nivel 2
	For ni:=1 to Len(aPastas)
		cPstFil	:= JGetChild(aPastas[ni][2],cUsuario,cSenha,nEmpresa,cColid)

		oXmlgetChildren := XmlParser( cPstFil, "_", @cErro, @cAviso )

		If oXmlgetChildren <> Nil .AND. "item" $ cPstFil

			If ValType(&("oXmlgetChildren" + cPathCab)) == "A"

				For nj:=1 to Len(&("oXmlgetChildren" + cPathCab))

					If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTID") <> Nil
						nDoc 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTID:TEXT")
						If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTTYPE") <> Nil
							nTipo 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTTYPE:TEXT")
						EndIf
						If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_VERSION") <> Nil
							nVersao 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_VERSION:TEXT")
						EndIf

						If nTipo == "2"
							If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
								cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
							EndIf

							aAdd(aDocs,{cFile,nDoc,nVersao,'02',ni})

						EndIf
					EndIf
				Next
			Else
				If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTID") <> Nil
					nDoc 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTID:TEXT")
					If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTTYPE") <> Nil
						nTipo 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTTYPE:TEXT")
					EndIf
					If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_VERSION") <> Nil
						nVersao 	:= &("oXmlgetChildren" + cPathCab + ":_VERSION:TEXT")
					EndIf

					If nTipo == "2"
						If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
							cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
						EndIf

						aAdd(aDocs,{cFile,nDoc,nVersao,'02',ni})

					EndIf
				EndIf
			EndIf
		EndIf
	Next

Else
	//³Retorna falha no parser do XML³
	cErro := STR0042 //"Objeto XML nao criado, verificar a estrutura do XML"
EndIf

RestArea(aArea)

Return aDocs

//-------------------------------------------------------------------
/*/{Protheus.doc} JA026Recno
Retorna o RECNO do registro atual.

Usado quando a opção Anexos é chamada pela tela de pesquisa

@param	cEntidade 	- Nome da entidade
@param	cCampoAssuntoJuridico 	- Assunto Jurídico
@param	cCampoCodigo 	- Código do registro

@return nRecno 		- RECNO
@author Jorge Luis Branco Martins Junior
@since  20/01/17
/*/
//-------------------------------------------------------------------
Static Function JA026Recno(cEntidade, cCampoAssuntoJuridico, cCampoCodigo)
Local aArea   := GetArea()
Local nRecno  := 0

	If cEntidade $ 'NSZ|NTA|NT4'
		DbSelectArea(cEntidade)
		(cEntidade)->( dbSetOrder( 1 ) )
		If (cEntidade)->( dbSeek( xFilial(cEntidade) + cCampoCodigo ) )
			nRecno := (cEntidade)->(RECNO())
		EndIf
	Else
		DbSelectArea(cEntidade)
		(cEntidade)->( dbSetOrder( 1 ) )
		If (cEntidade)->( dbSeek( xFilial(cEntidade) + cCampoAssuntoJuridico + cCampoCodigo ) )
			nRecno := (cEntidade)->(RECNO())
		Endif
	EndIf

RestArea( aArea )

Return nRecno

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpFluig
Importar do Fluig. O método tem um Browser para que seja importado um arquivo
e ele será automaticamente vinculado ao processo

@Param cClienteLoja
@Param cCaso
@Param cDoc

@return bReturn
@author Willian Yoshiaki Kazahaya
@since  02/05/2017
/*/
//-------------------------------------------------------------------
Static Function JImpFluig(cClienteLoja, cCaso, cDoc, cCajuri, cEntidFili, cEntidade, cCodigoRelacao, oTree )
Local cExtens   := "Arquivos | *.*"
Local cCamArq   := "C:\"
Local aCamArq   := {}
Local cMsgErro  := ""
Local nI        := 0
Local lRet      := .F.
Local bReturn   := .F.
Local cDocto    := ""
Local cCodFluig := ""
Local nQtd      := 0
Local cCargo    := ""
Local aCriaPst  := {}
Local cDestino  := MsDocPath()
Local cCodObj   := ""

Default cDoc  := ""
Default oTree := Nil

 	If !Empty(oTree) .AND. ValType(oTree) == "O"
 		cCargo := AllTrim(oTree:GetCargo())
 	EndIf

 	// Verificação da pasta em que o usuário está posicionado
 	If (cEntidade == cCargo) .OR. (cEntidade == "NSZ") .OR. IsInCallStack("J026Anexar")
 		lRet := .T.
 	EndIf

 	If lRet
		// Busca o ID da pasta do Caso no Fluig
		aCriaPst  := hasFolderF(cClienteLoja, cCaso)//1 - lRet / 2 - cDocto / 3 - cVersao
		If aCriaPst[1]
			cDocto	:= aCriaPst[2]
			// Caminho do Arquivo a ser importado
			If JURAUTO() .or. !Empty(cDoc)
				cCamArq:= cDoc
				cCodFluig := JDocFluig(cCamArq,cDocto)

				If (cCodFluig != "0" .and. !Empty(cCodFluig))
					VincFlgNUM(cEntidFili, cEntidade, cCodigoRelacao, cCodFluig + ";1000", SubStr(cCamArq,Rat("\",cCamArq)+1), .F., cCajuri)
					bReturn := .T.
					If cEntidade $ "NT3|NT2" .AND. SuperGetMV('MV_JINTVAL',, '2') == '1' //caso a entidade seja a NT3 e tenha integração com o financeiro
						//obtemos as informações do contas a pagar (SE2)
						cCodEntSE2 := SubStr(cCodigoRelacao, At(cCajuri, cCodigoRelacao)+10,10)
						aDadosSE2 := JurQryAlc(cEntidade, cCajuri, cCodEntSE2, IIF(cEntidade == 'NT2','2','3'), .T.)
						If Len(aDadosSE2) > 0
							cSE2Chave := PadR((AllTrim(aDadosSE2[5])),GetSx3Cache("E2_PREFIXO","X3_TAMANHO"))
							cSE2Chave += PadR((AllTrim(aDadosSE2[4])),GetSx3Cache("E2_NUM",    "X3_TAMANHO"))
							cSE2Chave += PadR((AllTrim(aDadosSE2[6])),GetSx3Cache("E2_PARCELA","X3_TAMANHO"))
							cSE2Chave += PadR((AllTrim(aDadosSE2[7])),GetSx3Cache("E2_TIPO",   "X3_TAMANHO"))
							cSE2Chave += PadR((AllTrim(aDadosSE2[8])),GetSx3Cache("E2_FORNECE","X3_TAMANHO"))
							cSE2Chave += PadR((AllTrim(aDadosSE2[9])),GetSx3Cache("E2_LOJA",   "X3_TAMANHO"))

							//gravamos o mesmo anexo na AC9 e ACB para o titulo gerado
							If __CopyFile(cCamArq, cDestino + "\" + SubStr(cCamArq, Rat("\", cCamArq)+1))
								//Cria codigo de base de conhecimento
								cCodObj	 := CriaVar("ACB_CODOBJ", .T.)
								J26aGrBaCo(3, /*cCodNum*/, cCodObj, "SE2", cSE2Chave, cCamArq, "")
							EndIf
						EndIf
					EndIf
				Else
					cMsgErro := cMsgErro + CRLF + SubStr(cCamArq,Rat("\",cCamArq)+1)
					bReturn := .F.
				EndIf


			Else
				cCamArq := cGetFile(cExtens,STR0015,,'C:\',.F.,nOr(GETF_LOCALHARD,GETF_NETWORKDRIVE,GETF_MULTISELECT),.F.)

				//Se for informado um arquivo para ser importado
				If !Empty(cCamArq)
					aCamArq := StrTokArr( cCamArq, "|" )
					nQtd := Len(aCamArq)
					ProcRegua(nQtd) // 4

					If (ApMsgYesNo(STR0054 + CRLF + Replace(cCamArq,"|", CRLF) + CRLF + STR0055))

						for nI := 1 to Len(aCamArq)
							cCamArq := AllTrim(aCamArq[nI])
							IncProc( I18N(STR0049, {cValToChar(nI), cValToChar(nQtd)}) ) //"Importando arquivo #1 de #2"
							cCodFluig = JDocFluig(cCamArq,cDocto)

							If (cCodFluig != "0" .and. !Empty(cCodFluig))
								VincFlgNUM(cEntidFili, cEntidade, cCodigoRelacao, cCodFluig + ";1000", SubStr(cCamArq,Rat("\",cCamArq)+1), .F., cCajuri)
								If cEntidade $ "NT3|NT2" .AND. SuperGetMV('MV_JINTVAL',, '2') == '1' //caso a entidade seja a NT3 e tenha integração com o financeiro
									//obtemos as informações do contas a pagar (SE2)
									cCodEntSE2 := SubStr(cCodigoRelacao, At(cCajuri, cCodigoRelacao)+10,10)
									aDadosSE2 := JurQryAlc(cEntidade, cCajuri, cCodEntSE2, IIF(cEntidade == 'NT2','2','3'), .T.)
									If Len(aDadosSE2) > 0
										cSE2Chave := PadR((AllTrim(aDadosSE2[5])),GetSx3Cache("E2_PREFIXO","X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[4])),GetSx3Cache("E2_NUM",    "X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[6])),GetSx3Cache("E2_PARCELA","X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[7])),GetSx3Cache("E2_TIPO",   "X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[8])),GetSx3Cache("E2_FORNECE","X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[9])),GetSx3Cache("E2_LOJA",   "X3_TAMANHO"))

										//gravamos o mesmo anexo na AC9 e ACB para o titulo gerado
										If __CopyFile(cCamArq, cDestino + "\" + SubStr(cCamArq, Rat("\", cCamArq)+1))
											//Cria codigo de base de conhecimento
											cCodObj	 := CriaVar("ACB_CODOBJ", .T.)
											J26aGrBaCo(3, /*cCodNum*/, cCodObj, "SE2", cSE2Chave, cCamArq, "")
										EndIf
									EndIf
								EndIf
							Else
								cMsgErro := cMsgErro + CRLF + SubStr(aCamArq[nI],Rat("\",aCamArq[nI])+1)
							EndIf
						Next

						if !Empty(cMsgErro)
							JurMsgErro(STR0056,,STR0057 + cMsgErro,)
							bReturn := .F.
						Else
							ApMsgInfo(STR0010)
							bReturn := .T.
						EndIf
					Else
						JurMsgErro(STR0045,,,)
					Endif
				EndIf
			EndIf
		Else
			ApMsgInfo(STR0046)//"A pasta do assunto jurídico não esta configurada"
		EndIf
	Else
		JurMsgErro( I18n(STR0073, {JurX2Nome( SubStr(cEntidade, 1, 3) )}) )	//"Para importar arquivos para esta entidade utilize a rotina de #1"
		bReturn := .F.
	EndIf

Return bReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} J026Anexar
Função para anexar um arquivo fisico a uma entidade juridica.
@Param cEntidade Nome da entidade
@Param cFilEnt   Filial da entidade
@Param cCodEnt   Código da entidade
@Param cCajuri   Código do assunto jurídico
@Param cArquivo  Caminho do arquivo
@Param lIntPFS   Integração com PFS ativada?
@Param cSubpasta Nome da Subpasta

@return {lRetorno, cMsg} - Lógico e Mensagem

@author Rafael Tenorio da Costa
@since  08/05/2017
/*/
//-------------------------------------------------------------------
Function J026Anexar(cEntidade, cFilEnt, cCodEnt, cCajuri, cArquivo, lIntPFS, cSubpasta)
Local cTipDocs    := AllTrim( SuperGetMv('MV_JDOCUME', ,'1') )
Local cMsg        := ''
Local lRetorno    := .F.
Local aProcesso   := {}
Local cCliente    := ''
Local cLoja       := ''
Local cCaso       := ''
Local cCodObj     := ''
Local cDestino    := ''
Local cCentId     := ''
Local oAnexo      := Nil

Default lIntPFS   := .F.

	//Busca dados do cliente do processo
	If !lIntPFS
		aProcesso := JurGetDados("NSZ", 1, xFilial("NSZ") + cCajuri, {"NSZ_CCLIEN", "NSZ_LCLIEN", "NSZ_NUMCAS"})
		cCliente  := aProcesso[1]
		cLoja     := aProcesso[2]
		cCaso     := aProcesso[3]
	EndIf

	If JurHasClas()
		Do Case
			Case cTipDocs == '1'
				oAnexo := TJurAnxWork():New(STR0081, cEntidade, cFilEnt, cCodEnt, /* cIndice */, .F., lIntPFS) // "Worksite"
			Case cTipDocs == '2' .Or. cSubpasta == 'NSZ_Logomarca'
				oAnexo := TJurAnxBase():New(STR0082, cEntidade, cFilEnt, cCodEnt, /* cIndice */, /* cCajuri */ , .F., lIntPFS) // "Base de Conhecimento"
			Case cTipDocs == '3'
				oAnexo := TJurAnxFluig():New(STR0059, cEntidade, cFilEnt, cCodEnt, /* cIndice */, .F.) // "Documentos em destaque - Fluig"
		EndCase

		// Adicionar o arquivo e realizar a importação
		oAnexo:addArquivo(cArquivo)
		oAnexo:cSubpasta := cSubpasta
		lRetorno := oAnexo:Importar()
		cMsg := oAnexo:cErro
	Else
		Do Case
			Case cTipDocs = '1'
				JurMsgErro(STR0083) // "A funcionalidade de anexos com Worksite foi descontinuada para a versão 12.1.17 do Protheus. Para utiliza-la, favor realizar a atualização para a versão mais recente."
			//Base de conhecimento
			Case cTipDocs == '2'
				cDestino := MsDocPath() //DIRDOC

				//Verifica se o arquivo já existe
				If !J26aExiNum(cEntidade, cFilEnt, cCentId, cArquivo)

					If ( lRetorno := GrvBaseCon(3, /*cCodNum*/, @cCodObj, cEntidade, cFilEnt + cCodEnt, cArquivo, "") )
						lRetorno := __CopyFile(cArquivo, cDestino + "\" + cCodObj)
						// Caso a cópia ocorra, remove o arquivo original para deixar o arquivo com nome alterado.
						If lRetorno .And. !lIntPFS
							FErase(cArquivo)
						EndIf
					EndIf

					If !lRetorno
						cMsg:= I18n(STR0075, {STR0077 + cValToChar(FError())})	//"Erro ao anexar arquivo #1"	//"a Base de Conhecimento: "
		 			EndIf
	 			EndIf
			//Fluig
			Case cTipDocs == '3'
				lRetorno:= JImpFluig(cCliente + cLoja, cCaso, cArquivo, cCodEnt, cFilEnt, cEntidade, cCodEnt)
				If !lRetorno
					cMsg:= I18n(STR0075, {STR0078})	//"Erro ao anexar arquivo #1"	//"ao Fluig"
	 			EndIf
		EndCase
	EndIf
	
Return {lRetorno, cMsg, cCodObj}

//-------------------------------------------------------------------
/*/{Protheus.doc} JF026Tela
Tela de anexos do Fluig B
@param cTipoAsj - Tipo do assunto jurídico
@param cEntida - Entidade de origem da chamada
@param cAssJur - Código do assunto juridico
@param cQuery - Query da pesquisa
@param nOp - Operação realizada
@param cClienteLoja - Cliente do caso
@param cCaso - Código do caso
@param cCodOri - Código de referencia da Entidade

@return
@author Willian Yoshiaki Kazahaya
@since  09/10/2017
/*/
//-------------------------------------------------------------------
Function JF026Tela(cTipoAsj, cEntida, cAssJur, nOp, cClienteLoja, cCaso, cCodOri)
	//Formatação do campo de busca (oGetSearch)
	#DEFINE CSSEdit "QLineEdit {" +;
	  "border-width: 2px;" +;
	  "border: 1px solid #C0C0C0;" +;
	  "border-radius: 3px;" +;
	  "border-color: #C0C0C0;" +;
	  "font: bold 12px Arial;" +;
	  "}"

	//Formatação dos botão Pesquisar
	#DEFINE CSSButton "QPushButton {" +;
	      "cursor: pointer; color: rgb(79, 84, 94);" +;
	      "border: 1px solid rgb(216, 216, 216);" +;
	      "border-radius: 3px;" +;
	      "background-color: rgb(245, 245, 245);"+;
	      "}" +;
	      "QPushButton:hover:!pressed {background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(255, 255, 255), stop: 1 rgb(230, 230, 230));}"+;
	      "QPushButton:hover:pressed {background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(230, 230, 230), stop: 1 rgb(255, 255, 255));}"

	Local aArea       := GetArea()
	Local aAreaEnt    := {}
	Local oModal      := Nil
	Local oPanel      := Nil
	Local oLayer      := Nil
	Local oTree       := Nil
	Local oFont       := TFont():New( "Arial"/*cName*/, /*uPar2*/, 15/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/)
	Local oEntidades  := Nil
	Local oPesquisa   := Nil
	Local oDocumentos := Nil
	Local oBtnSearch  := Nil
	Local oGetSearch  := Nil
	Local oSelect     := Nil
	Local aCampos     := {}
	Local aColunas    := {}
	Local cMarca      := GetMark()
	Local cPesquisa   := Space( TamSx3("NUM_DOC")[1] )
	Local nI          := 0
	Local cUrlEcm     := AllTrim(JFlgUrl())
	Local oUrl        := Nil
	Local aCoord      := { 0, 0, 600, 800 }
	Local oModel      := ''
	Local nOperacao   := ''

	Default cEntida	:= "NSZ"
	Default nOp     := 2		//Visualizar

	If IsPesquisa()
    	nOperacao   := IIf(SuperGetMv('MV_JALTPRO',,'2') == '1', 4, 1)
	Else
		oModel      := FWModelActive()
		nOperacao   := oModel:GetOperation()
	EndIf


	oModal := FWDialogModal():New()
	oModal:SetFreeArea(500, 230)
	oModal:SetEscClose(.T.)				//Permite fechar a tela com o ESC
	oModal:SetBackground(.T.)			//Escurece o fundo da janela
	oModal:SetTitle(STR0059)			//"Base de Conhecimento"
	oModal:EnableFormBar(.T.)
	oModal:CreateDialog()
	oModal:CreateFormBar()				//Cria barra de botoes

	//Inclui botoões
	If JA162AcRst('03')
		//"Ver Todos"
		oModal:AddButton( STR0074, {|| JF26Abrir( cClienteLoja, cCaso)	}, STR0074, , .T., .F., .T., )

		//"Abrir"
		oModal:AddButton( STR0014, {|| JF26Abrir( cClienteLoja, cCaso , cMarca, oSelect)	}, STR0014, , .T., .F., .T., )
	EndIf

	If JA162AcRst('03',2)
		//"ImportarFluig"
		oModal:AddButton( STR0015, {|| Processa({ || JImpFluig(cClienteLoja, cCaso, , cAssJur, xFilial(cEntida), cEntida, cCodOri, oTree )}, STR0050 /*"Aguarde"*/, STR0051 /*"Anexando..."*/, .F. ), oSelect:DeActivate(.T.), oSelect:Activate()} , STR0015, , .T., .F., .T. )

		//"Anexar"
		oModal:AddButton( STR0016, {|| JFAnexar(cClienteLoja, cCaso, xFilial(cEntida), cEntida, cCodOri, aCoord, cAssJur), oSelect:DeActivate(.T.), oSelect:Activate()}, STR0036, , .T., .F., .T. )
	EndIf

	If JA162AcRst('03',5)
		//"Excluir"
		oModal:AddButton( STR0062, {|| JF26Desvin(cMarca), oSelect:DeActivate(.T.), oSelect:Activate()}, STR0017, , .T., .F., .T., ) //"Excluir"
	EndIf

	//"Fechar"
	oModal:AddCloseButton()

	//==========================
	// Criação dos painéis
	//==========================
	oPanel := oModal:GetPanelMain()

	oLayer := FwLayer():New()
	oLayer:Init(oPanel, .F.)

	// Coluna esquerda
	oLayer:AddCollumn("COLUNA1", 30, .F., 	)
	oLayer:AddWindow("COLUNA1", "WINDOW1", STR0039, 85, .F., .F., {|| .T.},  , {|| .T.})	//"Entidades"
	oLayer:AddWindow("COLUNA1", "WINDOW4", "URL", 15, .F., .F., {|| .T.},  , {|| .T.})	//"Entidades"

	oEntidades := oLayer:getWinPanel("COLUNA1", "WINDOW1", )
	oUrlWindow := oLayer:getWinPanel("COLUNA1", "WINDOW4", )

	oUrl := TSay():Create(oUrlWindow)
	oUrl:setText(cUrlEcm)
	oUrl:nLeft := 0
	oUrl:nTop  := 0
	oUrl:nHeight := 32
	oUrl:nWidth  := 300

	//Cria Arvore
	oTree := DbTree():New(0 , 0, oEntidades:nBottom, oEntidades:nRight, oEntidades, {|| JF26AtGrid(oTree, oSelect, cMarca,, cEntida,cAssJur,cCodOri), cPesquisa:= Space(TamSx3("NUM_DOC")[1]), oTree:SetFocus()}	, /*bRClick*/, .T., /*lDisable*/, oFont, /*cHeaders*/)

	If cEntida == "NSZ"
		    //AddItem( cPrompt			, cCargo			, cRes1	   	, cRes2	  	, cFile1	, cFile2	, nTipo)
		//oTree:AddItem( PadR(STR0063, 50), PadR("RAIZ", 50)	, "FOLDER10", "FOLDER11", /*cFile1*/, /*cFile2*/, 1)	//"Raiz"
		oTree:AddItem( STR0064			, "NSZ"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Assunto Jurídico"

		//Adiciona pastas filhas da NSZ
		JF26FldNsz(oTree)

		oTree:AddItem( STR0065			, "NT4"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Andamentos"
		oTree:AddItem( STR0066			, "NTA"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Follow-ups"
		oTree:AddItem( STR0067			, "NT2"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Garantias"
		oTree:AddItem( STR0068			, "NT3"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Despesas"
		//oTree:AddItem( STR0069			, "NUQ"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Instâncias"
		oTree:AddItem( STR0070			, "NSY"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Objetos"

	Else
		oTree:AddItem( JurX2Nome(cEntida)	, cEntida 		, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)
	EndIf

	//Pesquisa
	oLayer:AddCollumn("COLUNA2", 70, .F.,)
	oLayer:AddWindow("COLUNA2", "WINDOW2", STR0060, 20, .F., .F., {|| .T.},  , {|| .T.})	//"Pesquisa"

	oPesquisa := oLayer:getWinPanel("COLUNA2", "WINDOW2", )

	//Cria campo de pesquisa
	AddCSSRule("TGet", CSSEdit)
	oGetSearch := TGet():Create(oPesquisa)
	oGetSearch:cName 	:= "oGetSearch"
	oGetSearch:bSetGet  := {|u| If( pCount() > 0, cPesquisa := u, cPesquisa)}
	oGetSearch:nTop 	:= 5
 	oGetSearch:nLeft 	:= 5
	oGetSearch:nHeight 	:= 32
 	oGetSearch:nWidth 	:= oPesquisa:nRight - 120
	oGetSearch:SetFocus()

	//Cria botão de pesquisa
	AddCSSRule("TButton", CSSButton)
	oBtnSearch := TButton():Create(oPesquisa)
	oBtnSearch:cName 	 := "oBtnSearch"
	oBtnSearch:cCaption  := "Pesquisar" //"Pesquisar"
	oBtnSearch:blClicked := {|| JF26AtGrid(oTree, oSelect, cMarca, cPesquisa, cEntida,cAssJur,cCodOri) }
	oBtnSearch:nTop 	 := 5
	oBtnSearch:nLeft 	 := oGetSearch:nWidth + 10
	oBtnSearch:nHeight 	 := 32
	oBtnSearch:nWidth 	 := 90

	//Documentos
	oLayer:AddWindow("COLUNA2", "WINDOW3", "Documentos", 80, .F., .F., {|| .T.},  , {|| .T.})	//"Documentos"

	oDocumentos := oLayer:getWinPanel("COLUNA2", "WINDOW3", )

	//Cria grid
	Aadd(aCampos, {"NUM_DESC"   , JA160X3Des("NUM_DESC")    , "C", 50    })
	Aadd(aCampos, {"NUM_DOC" 	, JA160X3Des("NUM_DOC")		, "C", 15 	/*"@!S80"*/			})

	For nI := 1 To Len( aCampos )
	    AAdd( aColunas, FWBrwColumn():New() )

	    aColunas[nI]:SetData( &( "{|| " + aCampos[nI][1] + " }" ) )
	    aColunas[nI]:SetTitle( aCampos[nI][2] )
	    aColunas[nI]:SetType(aCampos[nI][3] )
	    aColunas[nI]:SetSize( aCampos[nI][4] )
	    aColunas[nI]:SetAutoSize(.T.)
	Next nI

	oSelect := TJurBrowse():New(oDocumentos)
	oSelect:SetDataTable()
	oSelect:SetAlias("NUM")
	oSelect:AddMarkColumns( {|| IIF(!Empty(NUM->NUM_MARK), "LBOK", "LBNO")}, {|| JF26SelM(oSelect, cMarca)}, {|| MarcaTudo(oSelect, cMarca)})
	oSelect:SetColumns( aColunas )
	oSelect:SetDoubleClick( {|| } )	//Abre documento

	//Atualiza dados do grid
	JF26AtGrid(oTree, oSelect, cMarca, /*cPesquisa*/, cEntida,cAssJur,cCodOri)

	oSelect:Activate(.F.)

	oModal:Activate()

	//Limpa registros selecionados quando fechar tela
 	JF26LmpSel(cMarca)

	ASize(aCampos	, 0)
	ASize(aColunas	, 0)

	If Len(aAreaEnt) > 0
		RestArea(aAreaEnt)
	EndIf
	RestArea(aArea)
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JF26AtGrid
Atualização do Grid da nova tela de Anexos para o Fluig

@param oTree - Arvore das classes
@param oSelect - Objeto do Grid
@param cMarca - Código da marca da sessão
@param cPesquisa - String de pesquisa
@param cEntiTela - Entidade origem da tela

@return {lRetorno,cMsg} - Lógico e Mensagem
@author Willian Yoshiaki Kazahaya
@since  09/10/2017
/*/
//-------------------------------------------------------------------
Function JF26AtGrid(oTree, oSelect, cMarca, cPesquisa, cEntiTela,cNszCod,cCodOri)
	Local cCargo  := AllTrim( oTree:GetCargo() )
 	Local cFiltro := "NUM->NUM_FILIAL == '" + xFilial("NUM") + "' .And. !Empty(NUM->NUM_DOC)"
 	Local aRegCod := {}
 	Local nIndex  := 0
 	Local cQueryWhere := ""

 	Default cPesquisa := ""
 	Default cNszCod := AllTrim(JF26RtCdEn("NSZ"))
 	Default cCodOri := ""

 	If !cCargo == "RAIZ"
	 	cFiltro += " .And. NUM->NUM_ENTIDA == '" + cCargo + "'
	EndIf

	If cEntiTela == cCargo .OR. (cCargo == "RAIZ" .AND. cEntiTela == "NSZ")
		//Inclui filtro do registro posicionado
		cFiltro += " .And. ALLTRIM((NUM->NUM_CENTID)) == ALLTRIM('" + xFilial(cEntiTela) + cCodOri + "')"
 	Else
 		aRegCod := JNumCentId(cNszCod,cCargo)

 		For nIndex := 1 to Len(aRegCod)
 			cQueryWhere += " ALLTRIM((NUM->NUM_CENTID)) == ALLTRIM('" + aRegCod[nIndex][1] + "')"
		 	//Inclui filtro do registro posicionado
		 	If nIndex < Len(aRegCod)
		 		cQueryWhere += " .OR. "
		 	EndIf
		Next

		If Len(aRegCod) > 0
			cFiltro += " .And. (" + cQueryWhere + ")"
		Else
			cFiltro += " .AND. 1 = 2"
		EndIf
 	EndIf

 	//Inclui filtro
 	If !Empty(cPesquisa)
		//Prepara pesquisa
		cPesquisa := AllTrim( Lower( JurLmpCpo(cPesquisa) ) )

		//Carrega filtro que será aplicado ao grid
		cPesquisa := " .And. '" + cPesquisa + "' $ Lower( JurLmpCpo(NUM->NUM_DESC) )"

 		cFiltro += cPesquisa
 	EndIf

 	//Limpa registros selecionados
 	JF26LmpSel(cMarca)

 	//Executa filtro
 	oSelect:SetFilterDefault(cFiltro)
 	oSelect:UpdateBrowse()
	oSelect:Enable()
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodEnt
Retorna o codigo da entidade a partir do registro que esta posicionado.

@param	cEntidade 	- Nome da entidade
@return cCodEnt 	- Código da entidade
@author Willian Yoshiaki Kazahaya
@since  11/10/2017
/*/
//-------------------------------------------------------------------
Static Function JF26RtCdEn(cEntidade)

	Local cField   	:= ""
	Local cCodEnt	:= ""

	cField := JNumIndex(cEntidade)

	cCodEnt	:= &(cEntidade + "->(" + cField + ")")		//cCodEnt  := &(cUnico)


Return RTrim(cCodEnt)

//-------------------------------------------------------------------
/*/{Protheus.doc} JF26LmpSel
Tira seleção dos documentos.

@param 	cMarca	 - Código que define que o registro foi selecionado.
@return	lRetorno - Retorna se o update foi executado corretamente.
@author  Willian Yoshiaki Kazahaya
@since 11/10/2017
/*/
//-------------------------------------------------------------------
Static Function JF26LmpSel(cMarca)

	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local cUpdate 	:= ""

	cUpdate := " UPDATE " + RetSqlName("NUM")
	cUpdate	+= " SET NUM_MARK = '  '"
	cUpdate	+= " WHERE D_E_L_E_T_ = ' '"
	cUpdate	+= 	" AND NUM_FILIAL = '" + xFilial("NUM") + "'"
	cUpdate	+= 	" AND NUM_MARK = '" + cMarca + "'"

	If TcSqlExec(cUpdate) < 0
		lRetorno := .F.
	  	JurMsgErro( I18n(STR0047, {TcSqlError()}) )	//"Erro ao desvicular o arquivo: #1"
	EndIf

	RestArea(aArea)

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} JF26SelM
Faz o controle da marcação ou não do campo NUM_MARK.

@param	oSelect - Grid da tela
@param 	cMarca	- Código que define que o registro foi selecionado.
@author Willian Yoshiaki Kazahaya
@since 11/10/2017
/*/
//-------------------------------------------------------------------
Static Function JF26SelM(oSelect, cMarca)

	RecLock("NUM", .F.)

		If Empty(NUM->NUM_MARK)
			NUM->NUM_MARK := cMarca
		Else
			NUM->NUM_MARK := ""
		Endif

	NUM->( MsUnLock() )

	oSelect:Refresh(.T.)
	oSelect:GoTop()
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} JF26Abrir
Abertura da pasta do Fluig. No primeiro caso é com a abertura direta do arquivo.
No segundo caso é somente a abertura da pasta

@param cCliCaso - Cliente do caso
@param cCaso - Caso
@param cMarca - Código da marca da sessão
@param oSelect - Objeto do Grid para posicionamento

@return
@author Willian Yoshiaki Kazahaya
@since 11/10/2017
/*/
//-------------------------------------------------------------------
Static Function JF26Abrir(cCliCaso, cCaso, cMarca, oSelect)
	Local aReg := {}
	Local nLinha

	Default cMarca := ""
	Default oSelect := ""

	If !Empty(cMarca) .AND. !Empty(oSelect)
		aReg := JF26RegSel(cMarca, oSelect:nAt)
	EndIf

	If Len(aReg) == 0
		JFAbrir( cCliCaso, cCaso)
	Else
		For nLinha := 1 to Len(aReg)
			JFAbrir( cCliCaso, cCaso, aReg[nLinha][4])
		Next nLinha
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetRegsSel
Retorna os documentos jurídicos que foram selecionados.

@param 	cMarca		- Código que define que o registro foi selecionado.
@param  cRecNo      - Registro em que está posicionado o objeto

@return	aRegistros	- Registros da NUM selecionados
@author Willian Yoshiaki Kazahaya
@since 11/10/2017
/*/
//-------------------------------------------------------------------
Static Function JF26RegSel(cMarca, cRecNo, lRec)

	Local aArea		 := GetArea()
	Local aRegistros := {}
	Local cQuery	 := ""

	Default cMarca := ""
	Default cRecno := 0
	Default lRec   := .F.

	cQuery := " SELECT NUM_FILIAL, NUM_COD, NUM_NUMERO, NUM_DOC, NUM_EXTEN"
	cQuery += " FROM " + RetSqlName("NUM")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND NUM_FILIAL = '" + xFilial("NUM") + "'"

	If !Empty(cMarca)
		cQuery += " AND NUM_MARK = '" + cMarca + "'"
	Else
		cQuery += " AND R_E_C_N_O_ = " + cValToChar(cRecno)
	EndIf

	aRegistros := JurSQL(cQuery, {"NUM_FILIAL", "NUM_COD", "NUM_NUMERO", "NUM_DOC", "NUM_EXTEN"})

	If (Len(aRegistros) == 0) .AND. !lRec
		aRegistros := JF26RegSel(,cRecno, .T.)
	EndIf

	RestArea(aArea)

Return aRegistros

//-------------------------------------------------------------------
/*/{Protheus.doc} JF26Desvin
Exclusão dos registros da NUM

@param 	cMarca		- Código que define que o registro foi selecionado.
@return
@author Willian Yoshiaki Kazahaya
@since 11/10/2017
/*/
//-------------------------------------------------------------------
Static Function JF26Desvin(cMarca)
	Local aReg   := JF26RegSel(cMarca)
	Local cMsgDes:= ''
	Local nCont  := 0

	If Len(aReg) > 0
		For nCont:=1 To Len(aReg)
			JGExcluir(aReg[nCont][2], .F.)
		Next nCont

		cMsgDes := STR0013 + CRLF + CRLF + STR0079

		ApMsgInfo(cMsgDes)
	Else
		JurMsgErro(STR0071)// Não há registros marcados para serem desvinculados
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PastasNsz
Carrega as pastas na arvore que são filhas da NSZ.Cópia do método da JURA026A

@param oTree - Árvore da tela
@author Willian Yoshiaki Kazahaya
@since 11/10/2017
/*/
//-------------------------------------------------------------------
Static Function JF26FldNsz(oTree)

	Local aRegistros := JurSubPasta(/*cPasta*/)
	Local nCont      := 0

	If oTree:TreeSeek("NSZ")

		For nCont:=1 To Len(aRegistros)

			cPasta := SubStr(aRegistros[nCont][1], 5)
			cCargo := AllTrim(aRegistros[nCont][1])

			oTree:AddItem( cPasta, cCargo, "FOLDER5", "FOLDER6", /*cFile1*/, /*cFile2*/, 2)
		Next nCont

		//Volta para pasta raiz
		oTree:TreeSeek("RAIZ")

		oTree:Refresh()
	EndIf

	ASize(aRegistros, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JNumCentId
Consulta do código da entidade

@param cNszCod - Código Cajuri
@param cEntiPasta - Entidade da Pasta (oTree posicionado)
@author Willian Yoshiaki Kazahaya
@since 18/10/2017
/*/
//-------------------------------------------------------------------
Function JNumCentId(cNszCod, cEntiPasta)
	Local aRegistros := {}
	Local aArea      := GetArea()
	Local cQuery     := ""
	Local cIndex     := JNumIndex(cEntiPasta)

	cQuery := " SELECT " + cIndex + " CODIGO"
	cQuery += " FROM " + RetSqlName(cEntiPasta) + " " + cEntiPasta + " INNER JOIN " + RetSqlName("NUM") + " NUM ON (NUM.NUM_CENTID = " + cIndex + ")"
	cQuery += " WHERE " + cEntiPasta + ".D_E_L_E_T_ = '' "
	cQuery +=   " AND " + cEntiPasta + "_CAJURI = '" + cNszCod + "'"

	aRegistros := JurSQL(cQuery, {"CODIGO"})

	RestArea(aArea)
Return aRegistros

//-------------------------------------------------------------------
/*/{Protheus.doc} JNumIndex
Consulta do Index da tabela. Remove o campo da filial

@param cEntiPasta - Entidade da Pasta (oTree posicionado)
@author Willian Yoshiaki Kazahaya
@since 18/10/2017
/*/
//-------------------------------------------------------------------
Function JNumIndex(cEntiPasta)
	Local cReturn := ""
	Local cBanco  := Upper(TcGetDb())

	cReturn := FWX2Unico(cEntiPasta)

	If cBanco == "POSTGRES"
		cReturn := StrTran("RTRIM(CONCAT(" + cReturn + "))","+","||")
	EndIf
Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SelectMark
Faz o controle da marcação ou não do campo NUM_MARK.

@param	oSelect - Grid da tela
@param 	cMarca	- Código que define que o registro foi selecionado.
@author Rafael Tenorio da Costa
@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function MarcaTudo(oSelect, cMarca)

	oSelect:GoTop(.T.)

	While !NUM->( Eof() )

		RecLock("NUM", .F.)

			If Empty(NUM->NUM_MARK)
				NUM->NUM_MARK := cMarca
			Else
				NUM->NUM_MARK := ""
			Endif

		NUM->( MsUnLock() )

		NUM->( DbSkip() )
	EndDo

	oSelect:Refresh(.T.)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} hasFolderF
Verifica se existe pasta para o caso, se não, chama a função para a criação

@param	cClienteLoja - Codigo do cliente e loja do processo
@param 	cCaso	- Código do caso do processo
@Return Array com lRet - Retorna .T. se encontrar a pasta ou se criou com sucesso/ cDocto - diretorio no Fluig (Pasta do caso) / cVersao - Versão do documento
@since 16/05/2019
/*/
//-------------------------------------------------------------------
Static Function hasFolderF(cClienteLoja, cCaso)
Local lRet       := .T.
Local cDocto     := ""
Local cVersao    := ""
Local cCriaPasta := ""
Local aArea      := GetArea()

NZ7->(dbsetorder(1))
If NZ7->( DBSeek(XFILIAL('NZ7') + cClienteLoja + cCaso) )
	cDocto  := SubStr(NZ7->NZ7_LINK,1,at(";",NZ7->NZ7_LINK)-1)
	cVersao := SubStr(NZ7->NZ7_LINK,at(";",NZ7->NZ7_LINK)+1,4)
EndIf

If Empty(cDocto)
	cCriaPasta := J070PFluig(cClienteLoja + cCaso, "", )
	If cCriaPasta == "2"
		If NZ7->( DBSeek(XFILIAL('NZ7') + cClienteLoja + cCaso) )
			cDocto := SubStr(NZ7->NZ7_LINK,1,at(";",NZ7->NZ7_LINK)-1)
			cVersao := SubStr(NZ7->NZ7_LINK,at(";",NZ7->NZ7_LINK)+1,4)
			If Empty(cDocto)
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return {lRet,cDocto,cVersao}
