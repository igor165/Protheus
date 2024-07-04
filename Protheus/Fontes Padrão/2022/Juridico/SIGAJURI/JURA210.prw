#Include "JURA210.CH"
#Include "PROTHEUS.CH"

Static aJColId	  := {}		//Contem o ID dos usuários no Fluig

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA210
Schedule para processamento das pastas no Fluig a partir dos dados juridicos..

@param aParJob		aParJob

@author Andre Lago
@sample JURA210(aParJob)

@return Sem retorno
@since 07/04/2015
@version 1.0
@obs
/*/
//-------------------------------------------------------------------
Main Function JURA210(aParJob)

Local 	lSegue		:= .T.
Local   aSay     	:= {}
Local   aButton  	:= {}
Local   nOpc     	:= 0
Local   Titulo   	:= STR0001 //'INTEGRAÇÃO COM FLUIG'
Local   cDesc1   	:= STR0002 //'Esta rotina fara a integração com o fluig criando os'
Local   cDesc2   	:= STR0003 //'grupos de usuarios, pastas de assunto e caso.'
Local   cDesc3   	:= ''
Local   lOk      	:= .T.
Local   lDocPai  	:= .T.
Local 	lEnd		:= .F.

Private lJob		:= GetRemoteType() == -1

//Iniciando ambiente
If lJob

	lSegue := LockByName("JJURA210_JOB",.f.,.f.,.t.)

	If lSegue
		RpcSetEnv(aParJob[1],aParJob[2])

		IF SuperGetMV('MV_JDOCUME',,"2") == "3"

			JGrpAss()  	//"Processando Grupos de Assuntos Juridicos..."
			JPstAss()  	//"Processando pastas de Assuntos Juridicos..."
			JPstCaso() 	//"Processando pastas de Casos..."
			JSecPst()	//"Processando segurança das pastas..."

		EndIf
		//Fechando ambiente
		RpcClearEnv()
		aParJob := nil
		UnLockByName("JJURA210_JOB",.f.,.f.,.t.)
	Else
		Conout(STR0004) //"Execução job JURA210 bloqueada, ja esta em execução"
	EndIf
Else
	IF SuperGetMV('MV_JDOCUME',,"2") == "3"

		aAdd( aSay, cDesc1 )
		aAdd( aSay, cDesc2 )
		aAdd( aSay, cDesc3 )

		aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
		aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

		FormBatch( Titulo, aSay, aButton )

		If nOpc == 1
			Processa( {|lEnd| lOk := JGrpAss(@lEnd)}, STR0005, , .T.) //"Processando Grupos de Assuntos Juridicos..."
			If lOk
				ApMsgInfo( STR0006, STR0007 ) //'Processando Grupos de Assuntos Juridicos terminado com sucesso.'##'ATENÇÃO'

				Processa( {|lEnd| lOk := JPstAss(@lEnd, @lDocPai)}, STR0009, , .T.) //"Processando pastas de Assuntos Juridicos..."
				If lOk
					ApMsgInfo( STR0010, STR0007 ) //'Processando pastas de Assuntos Juridicos terminado com sucesso.'##'ATENÇÃO'

					Processa( {|lEnd| lOk := JPstCaso(@lEnd)}, STR0012, , .T.) //"Processando pastas de Casos..."
					If lOk
						ApMsgInfo( STR0013, STR0007 ) //'Processando pastas de Casos terminado com sucesso.'##'ATENÇÃO'

						Processa( {|lEnd| lOk := JSecPst(@lEnd)}, STR0015, , .T.) //"Processando segurança das pastas..."
						If lOk
							ApMsgInfo( STR0016, STR0007 ) //'Processando segurança das pastas terminado com sucesso.'##'ATENÇÃO'
						Else
							ApMsgStop( STR0017, STR0007 ) //'Processando segurança das pastas realizado com problemas.'##'ATENÇÃO'
						EndIf

					Else
						ApMsgStop( STR0014, STR0007 ) //'Processando pastas de Casos realizado com problemas.'##'ATENÇÃO'
					EndIf

				Else
					If lDocPai //'Caso o erro indicado não seja o do parâmetro MV_JDOCPAI vazio'
						ApMsgStop( STR0011, STR0007 ) //'Processando pastas de Assuntos Juridicos realizado com problemas.'##'ATENÇÃO'
					EndIf
				EndIf

			Else
				ApMsgStop( STR0008, STR0007 ) //'Processando Grupos de Assuntos Juridicos realizado com problemas.'##'ATENÇÃO'
			EndIf

		EndIf
	Endif
Endif

Return

/*/{Protheus.doc} JGrpAss
Processamento dos grupos para os assuntos juridicos

@param
@author Andre Lago
@sample JGrpAss()
@since 08/04/2015
@version 1.0
@return Sem retorno
@obs
/*/
Function JGrpAss(lEnd)

Local cAliasNYB		:= GetNextAlias()
Local cAliasNVK		:= GetNextAlias()
Local cQuery		:= ""
Local cQueryNVK		:= ""
Local xRet
Local nIdGrp		:= 0
Local cErro			:= ""
Local cAviso		:= ""
Local cPathCab		:= ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATEGROUPRESPONSE"	// Informa o caminho para acessar o cabecalho da msg XML
Local cPathCab1		:= ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATECOLLEAGUEGROUPRESPONSE"
Local cIdGrp		:= ""
Local cGrpRest   	:= ""

Default lEnd		:= .F.

dbSelectArea("NYB")

If !lJob
	ProcRegua(NYB->(RecCount()))
EndIf

//carregando o saldo dos produtos a processar.
cQuery := "SELECT NYB.R_E_C_N_O_ AS RECNONYB "
cQuery += "FROM " + RetSqlName("NYB") + " NYB "
cQuery += "WHERE NYB.D_E_L_E_T_ = ' ' "
cQuery += "	AND NYB.NYB_IDGRP = '' "
cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNYB,.T.,.T.)

While !(cAliasNYB)->(eof()) .and. !KillApp()

	//Verifica se foi pressionado o botao cancela
	If lEnd
		Exit
	EndIf

	If !lJob
		Incproc(STR0018) //"Efetuando a criação dos Grupos de Assuntos Juridicos..."
	EndIf

	NYB->(dbSetOrder(1))
	NYB->(dbGoto((cAliasNYB)->RECNONYB))

	xRet := JMkGrp("JUR_" + AllTrim(NYB->NYB_COD) + "_" + AllTrim(FwNoAccent(NYB->NYB_DESC)),AllTrim(NYB->NYB_COD))

	If "RESULTXML" $ Upper(xRet)
		//Localizo o id da pasta craida
		oXmlJMkGrp := XmlParser( xRet, "_", @cErro, @cAviso )

		If oXmlJMkGrp <> Nil
			If XmlChildEx(&("oXmlJMkGrp" + cPathCab),"_RESULTXML") <> Nil
				If &("oXmlJMkGrp" + cPathCab + ":_RESULTXML:TEXT") <> "ok"
					cErro := STR0019+AllTrim(FwNoAccent(NYB->NYB_DESC))+STR0020 //"Grupo "##" nao criado"
				Else
					cIdGrp := "JUR_" + AllTrim(NYB->NYB_COD) + "_" +  AllTrim(FwNoAccent(NYB->NYB_DESC))
				EndIf
			EndIf
		Else
			//³Retorna falha no parser do XML³
			cErro := STR0021 //"Objeto XML nao criado, verificar a estrutura do XML"
		EndIf

		RecLock("NYB",.f.)
			NYB->NYB_IDGRP := cIdGrp
		MsUnLock()

		//Verifica e cria os usuario do grupo.

		cQuery1 := "SELECT NVK.R_E_C_N_O_ AS RECNONVK,  NVJ.NVJ_CASJUR "
		cQuery1 += "FROM " + RetSqlName("NVK") + " NVK "
		cQuery1 += "JOIN " + RetSqlName("NVJ") + " NVJ ON NVK.NVK_CPESQ = NVJ.NVJ_CPESQ "
		cQuery1 += "WHERE NVK.D_E_L_E_T_ = ' ' "
		cQuery1 += "AND NVJ.D_E_L_E_T_ = ' ' "
		cQuery1 += "AND NVJ.NVJ_CASJUR = '" + AllTrim(NYB->NYB_COD) + "' "
		cQuery1 := ChangeQuery( cQuery1 )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cAliasNVK,.T.,.T.)

		While !(cAliasNVK)->(eof()) .and. !KillApp()

			//Verifica se foi pressionado o botao cancela
			If lEnd
				Exit
			EndIf

			If !lJob
				Incproc(STR0022) //"Efetuando a inclusão dos usuarios do Grupo de Assuntos Juridicos..."
			EndIf

			NVK->(dbSetOrder(1))
			NVK->(dbGoto((cAliasNVK)->RECNONVK))

			cGrpRest := JurGrpRest(NVK->NVK_CUSER)

			If !('CORRESPONDENTES' $ cGrpRest .Or. 'CLIENTES' $ cGrpRest )

				xRet := JMkCGrp( UsrRetMail ( NVK->NVK_CUSER ),"JUR_" + AllTrim(NYB->NYB_COD) + "_" + AllTrim(FwNoAccent(NYB->NYB_DESC)),AllTrim(NYB->NYB_COD))

				If "RESULTXML" $ Upper(xRet)
					//Localizo o id da pasta craida
					oXmlJMkCGrp := XmlParser( xRet, "_", @cErro, @cAviso )

					If oXmlJMkCGrp <> Nil
						If XmlChildEx(&("oXmlJMkCGrp" + cPathCab1),"_RESULTXML") <> Nil
							If &("oXmlJMkCGrp" + cPathCab1 + ":_RESULTXML:TEXT") <> "ok"
								cErro := STR0023+AllTrim(UsrRetMail ( NVK->NVK_CUSER ))+STR0020 //"Usuario "##" nao criado"
							EndIf
						EndIf
					Else
						//³Retorna falha no parser do XML³
						cErro := STR0021 //"Objeto XML nao criado, verificar a estrutura do XML"
					EndIf

				EndIf

			EndIf
			(cAliasNVK)->(dbSkip())

		EndDo
		(cAliasNVK)->(dbCloseArea())

	EndIf

	(cAliasNYB)->(dbSkip())

EndDo

(cAliasNYB)->(dbCloseArea())

Return !lEnd

/*/{Protheus.doc} JPstAss
Processamento das pastas para os assuntos juridicos

@param
@author Andre Lago
@sample JPstAss()
@since 07/04/2015
@version 1.0
@return Sem retorno
@obs
/*/
Function JPstAss(lEnd, lDocPai)

Local cAliasNYB
Local xRet
Local cQuery    := ""
Local cPstPai   := AllTrim(SuperGetMV('MV_JDOCPAI' ,,'0'))
Local nPasta    := ""
Local cIdPst    := ""
Local cErro     := ""
Local cAviso    := ""
Local cPathCab  := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATESIMPLEFOLDERRESPONSE:_RESULT:_ITEM"	// Informa o caminho para acessar o cabecalho da msg XML
Local cPathCab3 := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_UPDATEFOLDERRESPONSE:_RESULT:_ITEM"
Local cUsuario  := AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenha    := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local cEmpresa  := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))

Default lEnd    := .F.
Default lDocPai := .F.

If Empty(AllTrim(cPstPai)) .Or. AllTrim(cPstPai) == '0'
	ApMsgStop("Não foi informado o ID do documento do FLUIG referente a pasta raiz onde a estrutura de documentos será criada. Verifique o parâmetro MV_JDOCPAI.")
	lEnd := .T.
	lDocPai := .F.
Else

	dbSelectArea("NYB")

	If !lJob
		ProcRegua(NYB->(RecCount()))
	EndIf

	//carregando o saldo dos produtos a processar.
	cQuery := "SELECT NYB.R_E_C_N_O_ AS RECNONYB "
	cQuery += "FROM " + RetSqlName("NYB") + " NYB "
	cQuery += "WHERE NYB.D_E_L_E_T_ = ' ' "
	cQuery += "	AND NYB.NYB_IDGED = '' "
	cQuery := ChangeQuery( cQuery )

	cAliasNYB := GetNextAlias()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNYB,.T.,.T.)

	While !(cAliasNYB)->(eof()) .and. !KillApp()

		//Verifica se foi pressionado o botao cancela
		If lEnd
			Exit
		EndIf

		If !lJob
			Incproc(STR0024) //"Efetuando a criação das Pastas de Assuntos Juridicos..."
		EndIf

		NYB->(dbSetOrder(1))
		NYB->(dbGoto((cAliasNYB)->RECNONYB))

		xRet := JMkPst(cPstPai,AllTrim(NYB->NYB_COD)+'-'+AllTrim(NYB->NYB_DESC),cUsuario,cSenha,cEmpresa)

		If "WEBSERVICEMESSAGE" $ Upper(xRet)
			//Localizo o id da pasta craida
			oXmlJPstAss := XmlParser( xRet, "_", @cErro, @cAviso )

			If oXmlJPstAss <> Nil
				If XmlChildEx(&("oXmlJPstAss" + cPathCab),"_WEBSERVICEMESSAGE") <> Nil
					If &("oXmlJPstAss" + cPathCab + ":_WEBSERVICEMESSAGE:TEXT") <> "ok"
						cErro := &("oXmlJPstAss" + cPathCab + ":_WEBSERVICEMESSAGE:TEXT")
					Else
						cIdPst := AllTrim(&("oXmlJPstAss" + cPathCab + ":_DOCUMENTID:TEXT"))
						cIdPst += ";"
						cIdPst += AllTrim(&("oXmlJPstAss" + cPathCab + ":_VERSION:TEXT"))
					EndIf
				EndIf
			Else
				//³Retorna falha no parser do XML³
				cErro := STR0021 //"Objeto XML nao criado, verificar a estrutura do XML"
			EndIf

			RecLock("NYB",.f.)
				NYB->NYB_IDGED := cIdPst
			MsUnLock()

			nPasta := SubStr(NYB->NYB_IDGED,1,at(";",NYB->NYB_IDGED)-1)

			xRet := JUpPst(nPasta,cUsuario,cSenha,cEmpresa,"2",AllTrim(NYB->NYB_IDGRP),.T.)

			If "WEBSERVICEMESSAGE" $ Upper(xRet)
				//Localizo o id da pasta craida
				oXmlJUpPst := XmlParser( xRet, "_", @cErro, @cAviso )

				If oXmlJUpPst <> Nil
					If XmlChildEx(&("oXmlJUpPst" + cPathCab3),"_WEBSERVICEMESSAGE") <> Nil
						If &("oXmlJUpPst" + cPathCab3 + ":_WEBSERVICEMESSAGE:TEXT") <> "ok"
							cErro := STR0023+AllTrim(UsrRetMail ( NVK->NVK_CUSER ))+STR0020 //"Usuario "##" nao criado"
						EndIf
					EndIf
				Else
					//³Retorna falha no parser do XML³
					cErro := STR0021 //"Objeto XML nao criado, verificar a estrutura do XML"
				EndIf
			EndIf
		EndIf

		(cAliasNYB)->(dbSkip())

	EndDo

	(cAliasNYB)->(dbCloseArea())

EndIf

Return !lEnd

/*/{Protheus.doc} JPstCaso
Processamento das pastas para os casos

@param
@author Andre Lago
@sample JPstCaso()
@since 10/04/2015
@version 1.0
@return Sem retorno
@obs
/*/
Function JPstCaso(lEnd)

Local cAliasNZ7		:= GetNextAlias()
Local cQuery		:= ""
Local cPstPai  		:= "0"
Local xRet
Local cIdPst		:= ""
Local cErro			:= ""
Local cAviso		:= ""
Local cPathCab		:= ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATESIMPLEFOLDERRESPONSE:_RESULT:_ITEM"	// Informa o caminho para acessar o cabecalho da msg XML
Local cPathCab3 	:= ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_UPDATEFOLDERRESPONSE:_RESULT:_ITEM"
Local cStatus
Local cUsuario		:= AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenha		:= AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local cEmpresa  	:= AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
Local aPstFil		:= StrtoKArr(AllTrim(SuperGetMV('MV_JFLSUBP' ,,"")),";/\,")
Local ni

Default lEnd		:= .F.

dbSelectArea("NZ7")

If !lJob
	ProcRegua(NZ7->(RecCount()))
EndIf

cQuery := "SELECT NZ7.R_E_C_N_O_ AS RECNONZ7 "
cQuery += "FROM " + RetSqlName("NZ7") + " NZ7 "
cQuery += "WHERE NZ7.D_E_L_E_T_ = ' ' "
cQuery += "	AND NZ7.NZ7_STATUS = '1' "
cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNZ7,.T.,.T.)

While !(cAliasNZ7)->(eof()) .and. !KillApp()

	//Verifica se foi pressionado o botao cancela
	If lEnd
		Exit
	EndIf

	If !lJob
		Incproc(STR0025) //"Efetuando a criação das Pastas de Casos..."
	EndIf

	NZ7->(dbSetOrder(1))
	NZ7->(dbGoto((cAliasNZ7)->RECNONZ7))

	NSZ->(dbSetOrder(2))// NSZ_FILIAL+NSZ_CCLIEN+NSZ_LCLIEN+NSZ_NUMCAS
	NSZ->(dbSeek(xFilial("NSZ")+NZ7->NZ7_CCLIEN+NZ7->NZ7_LCLIEN+NZ7->NZ7_NUMCAS))

	NYB->(dbSetOrder(1))
	NYB->(dbSeek(xFilial("NYB")+NSZ->NSZ_TIPOAS))

	cPstPai := SubStr(NYB->NYB_IDGED,1,at(";",NYB->NYB_IDGED)-1)

	xRet := JMkPst(cPstPai,NZ7->NZ7_CCLIEN+"-"+NZ7->NZ7_LCLIEN+"-"+NZ7->NZ7_NUMCAS+"-"+AllTrim(NZ7->NZ7_TITULO),cUsuario,cSenha,cEmpresa)

	If "WEBSERVICEMESSAGE" $ Upper(xRet)
		//Localizo o id da pasta criada
		oXmlJMkPst := XmlParser( xRet, "_", @cErro, @cAviso )

		If oXmlJMkPst <> Nil
			If XmlChildEx(&("oXmlJMkPst" + cPathCab),"_WEBSERVICEMESSAGE") <> Nil
				If &("oXmlJMkPst" + cPathCab + ":_WEBSERVICEMESSAGE:TEXT") <> "ok"
					cErro := &("oXmlJMkPst" + cPathCab + ":_WEBSERVICEMESSAGE:TEXT")
				Else
					cIdPst := AllTrim(&("oXmlJMkPst" + cPathCab + ":_DOCUMENTID:TEXT"))
					cIdPst += ";"
					cIdPst += AllTrim(&("oXmlJMkPst" + cPathCab + ":_VERSION:TEXT"))
					cStatus := "2"
				EndIf
			EndIf
		Else
			//³Retorna falha no parser do XML³
			cErro := STR0021 //"Objeto XML nao criado, verificar a estrutura do XML"
		EndIf

		If cStatus == "2"
			RecLock("NZ7",.f.)
				NZ7->NZ7_STATUS 	:= cStatus
				NZ7->NZ7_LINK 		:= cIdPst
			MsUnLock()

			cPstPai := SubStr(cIdPst,1,at(";",cIdPst)-1)

			xRet := JUpPst(cPstPai,cUsuario,cSenha,cEmpresa,"2",AllTrim(NYB->NYB_IDGRP),.T.)

			If "WEBSERVICEMESSAGE" $ Upper(xRet)
				//Localizo o id da pasta craida
				oXmlJUpPst := XmlParser( xRet, "_", @cErro, @cAviso )

				If oXmlJUpPst <> Nil
					If XmlChildEx(&("oXmlJUpPst" + cPathCab3),"_WEBSERVICEMESSAGE") <> Nil
						If &("oXmlJUpPst" + cPathCab3 + ":_WEBSERVICEMESSAGE:TEXT") <> "ok"
							cErro := STR0023+AllTrim(UsrRetMail ( NVK->NVK_CUSER ))+STR0020 //"Usuario "##" nao criado"
						EndIf
					EndIf
				Else
					//³Retorna falha no parser do XML³
					cErro := STR0021 //"Objeto XML nao criado, verificar a estrutura do XML"
				EndIf
			EndIf

			For ni:=1 to Len(aPstfil)

				//Verifica se foi pressionado o botao cancela
				If lEnd
					Exit
				EndIf

				xRet := JMkPst(cPstPai,AllTrim(aPstFil[ni]),cUsuario,cSenha,cEmpresa)
			Next

		EndIf
	EndIf

	(cAliasNZ7)->(dbSkip())

EndDo

(cAliasNZ7)->(dbCloseArea())

Return !lEnd

/*/{Protheus.doc} JSecPst
Processamento da segurança das pastas das pastas

@param
@author Andre Lago
@sample JSecPst()
@since 27/04/2015
@version 1.0
@return Sem retorno
@obs
/*/
Function JSecPst(lEnd)

Local aArea		:= GetArea()
Local cAliasNVK	:= GetNextAlias()
Local cQuery	:= ""
Local cRestUsu  := ""
Local cCampos	:= "NSZ_CCLIEN, NSZ_LCLIEN, NSZ_NUMCAS, NSZ_TIPOAS"
Local cAliasQry	:= GetNextAlias()
Local aCasos	:= {}
Local cErro		:= ""
Local cAviso	:= ""
Local cPathCab	:= ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCOLLEAGUEGROUPSBYCOLLEAGUEIDRESPONSE:_RESULT:_ITEM"	// Informa o caminho para acessar o cabecalho da msg XML
Local cPathCab1	:= ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_DELETECOLLEAGUEGROUPRESPONSE"	// Informa o caminho para acessar o cabecalho da msg XML
Local cPathCab2 := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATECOLLEAGUEGROUPRESPONSE"
Local cPathCab3 := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_UPDATEFOLDERRESPONSE:_RESULT:_ITEM"
Local cPathCab5 := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETSUBFOLDERSRESPONSE:_DOCUMENT:_ITEM"
Local cUsuario	:= AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenha	:= AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local cEmpresa  := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
Local cColId	:= ""
Local ni
Local aUsuarios := {}
Local lJob		:= GetRemoteType() == -1

Default lEnd 	:= .F.

DbSelectArea("NVK")
If !lJob
	ProcRegua(NVK->(RecCount()))
EndIf

//carregando o saldo dos produtos a processar.
cQuery := "SELECT NVK.R_E_C_N_O_ AS RECNONVK "
cQuery += "FROM " + RetSqlName("NVK") + " NVK "
cQuery += "WHERE NVK.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNVK,.T.,.T.)

While !(cAliasNVK)->(eof()) .and. !KillApp()

	//Verifica se foi pressionado o botao cancela
	If lEnd
		Exit
	EndIf

	If !lJob
		Incproc(STR0026) //"Efetuando a configuração de segurança das Pastas de Assuntos Juridicos..."
	EndIf

	NVK->(dbSetOrder(1))
	NVK->(dbGoto((cAliasNVK)->RECNONVK))

	//Carrega os usuarios dos grupos
	If !Empty(NVK->NVK_CGRUP)
		aUsuarios := JA163GrUsu(NVK->NVK_CGRUP)

	//Carrega usuario
	Else
		Aadd(aUsuarios, {NVK->NVK_CUSER})
	EndIf

	//Faz as devidas alterações no Fluig referente as permissões
	J163PFluig(aUsuarios)

	(cAliasNVK)->(dbSkip())
EndDo

(cAliasNVK)->(dbCloseArea())

RestArea( aArea )

Return !lEnd

//-------------------------------------------------------------------
/*/{Protheus.doc} JGSQLPesq
Retorna a SQL de pesquisa

@param cCampos    - Campos para montar o select da query
@param cCodPart   - Código do participante
@param cPesq      - Código da pesquisa
@param cCodAssJur - Código do assunto jurídico

@since 09/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGSQLPesq(cCampos,cCodPart,cPesq, cCodAssJur)
Local aSQLRest   := {}
Local cSQL       := ""
Local cTpAJ      := ""
Local NSZName    := Alltrim(RetSqlName("NSZ"))
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local lWSTLegal  := .F.
Local lNVKNvCmp  := .F.

Default cCodAssJur := ''

	//Verifica se o campo NVK_CASJUR existe no dicionário
	If Select("NVK") > 0
		lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	lWSTLegal := lNVKNvCmp .And. JModRst()

	aSQLRest := JA162RstUs(cCodPart,cPesq, , lWSTLegal)

	cSQL := " SELECT "+cCampos+ ", NSZ001.R_E_C_N_O_ RECNSZ " + CRLF
	cSQL += " FROM "+NSZName+" NSZ001 JOIN "+ RetSqlName("NZ7") + " NZ7"
	cSQL += " ON (NSZ001.NSZ_CCLIEN = NZ7.NZ7_CCLIEN AND NSZ001.NSZ_LCLIEN = NZ7.NZ7_LCLIEN AND NSZ001.NSZ_NUMCAS = NZ7.NZ7_NUMCAS AND NZ7.NZ7_FILIAL = '" + xFilial("NZ7") + "' AND NZ7.NZ7_STATUS='2')" + CRLF

	cTpAJ := AllTrim( JurSetTAS(.F.,,cPesq) )

	//Tratamento de aspas simples para a query
	cTpAJ := IIf(  Left(cTpAJ,1) == "'", "", "'" ) + cTpAJ
	cTpAJ += IIf( Right(cTpAJ,1) == "'", "", "'" )

	If lWSTLegal
		If !Empty(cTpAJ)
			cTpAJ += ",'" + AllTrim( cCodAssJur ) + "'"
		Else
			cTpAJ := "'" + AllTrim( cCodAssJur ) + "'"
		EndIf
	EndIf

	If ( VerSenha(114) .or. VerSenha(115) )
		cSQL += " WHERE NSZ001.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2]) +  CRLF
	Else
		cSQL += " WHERE NSZ001.NSZ_FILIAL = '"+xFilial("NSZ")+"'"+ CRLF
	Endif

	cSQL += "   AND NSZ001.D_E_L_E_T_ = ' ' "+ CRLF
	cSQL += "   AND NZ7.D_E_L_E_T_ = ' ' "+ CRLF
	cSQL += "   AND NSZ001.NSZ_TIPOAS IN (" + cTpAJ + ")" + CRLF

	cSQL += VerRestricao(cCodPart,cPesq)  //Restricao de Escritorio e Area

	If !Empty(aSQLRest)
		cSQL += " AND ("+JA162SQLRt(aSQLRest, , , , , , , , , ,cCodPart,cPesq)+")"
	EndIf

	cSQL += " ORDER BY NSZ001.NSZ_NUMCAS DESC"
	
Return cSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} JColId(cUsuario, cSenha, cEmpresa, cMail, cErro, lMostraMsg)
Retorna o ColleagueId do usuario solicitado

@param cUsuario   - Usuário para conexão com Fluig.
@param cSenha     - Senha para conexão com Fluig.
@param cEmpresa   - Empresa para conexão com Fluig.
@param cMail      - E-mail para conexão com Fluig.
@param cErro      - Funções que chamam JCOLID(), podem obter o cErro por meio
					deste parâmetro.
@param lMostraMsg - Define se apresenta na tela a mensagem de erro, .T. ou .F.

@since 09/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JColId(cUsuario, cSenha, cEmpresa, cMail, cErro, lMostraMsg)
Local xRet
Local cAviso   := ""
Local cPathCab := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCOLLEAGUESMAILRESPONSE:_RESULT:_ITEM"	// Informa o caminho para acessar o cabecalho da msg XML
Local cRet     := ""
Local nPos     := 0

Default cUsuario   := AllTrim(SuperGetMV('MV_ECMUSER',,""))
Default cSenha     := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Default cEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
Default lMostraMsg := .T.
Default cErro      := ""

//Verifica se ja tem o ID do usuario no Fluig
nPos := aScan( aJColId, {|x| AllTrim(x[1]) == AllTrim(cMail)} )
If nPos > 0
	cRet := aJColId[nPos][2]
EndIf

//Carrega ID do Fluig, do usuario administrador
If Empty(cRet) .And. cUsuario == cMail
	cRet := AllTrim( SuperGetMV("MV_JCOLID", , "") )
EndIf

If Empty(cRet)

	xRet := JColMail(cUsuario,cSenha,cEmpresa,cMail)

	If "ACTIVE" $ Upper(xRet)

		oXmlJColId := XmlParser( xRet, "_", @cErro, @cAviso )
		If oXmlJColId <> Nil
			If XmlChildEx(&("oXmlJColId" + cPathCab),"_ACTIVE") <> Nil
				If &("oXmlJColId" + cPathCab + ":_ACTIVE:TEXT") <> "true"
					cErro := I18n(STR0038, {cMail, &("oXmlJColId" + cPathCab + ":_COLLEAGUENAME:TEXT")}) //"Usuário #1 não está ativo no Fluig: #2"
				Else
					cRet := AllTrim( &("oXmlJColId" + cPathCab + ":_COLLEAGUEID:TEXT") )
				EndIf
			EndIf
		Else
			cErro := STR0021 //"Objeto XML nao criado, verificar a estrutura do XML"
		EndIf
	Else
		cErro := I18n(STR0038, {cMail, xRet}) //"Usuário #1 não está ativo no Fluig: #2"
	EndIf

	If !Empty(cErro) .And. !JurAuto() .And. lMostraMsg
		JurMsgErro('JColId: ' + cErro)
	EndIf
EndIf

//Popula o array static para reutilizar as informações
If !Empty(cRet) .And. nPos == 0
	Aadd(aJColId, {cMail, cRet})
EndIf

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JMkPst()
Função para criar um diretorio no Fluig

@Param	cPstPai		Código do diretorio pai, numerico. (Pode ser NYB_IDGED ou NXX_IDGED)
@Param	cDescrPst	Nome da Pasta a ser criada.
@Param	cIdPublic	Matrícula do usuário publicador.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JMkPst(cPstPai,cDescrPst,cUsuario,cSenha,cEmpresa)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMFolderService?wsdl","//E","/E") //URL do Web Service
	Local aSimple	:= {}
   	Local cColId	:= JColId(cUsuario,cSenha,cEmpresa,cUsuario)

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif

  	// Define a operação
  	xRet := oWsdl:SetOperation( "createSimpleFolder" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMFolderService","//E","/E")

	aSimple := oWsdl:SimpleInput()

  	// Define o valor de cada parâmeto necessário
  	// Parâmetros:
  	// username: login do usuário.
  	// password: senha do usuário.
  	// companyId: código da empresa.
  	// parentDocumentId: número do documento pai.
  	// publisherId: matrícula do usuário publicador.
  	// documentDescription: descrição da pasta. 

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "parentDocumentId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cPstPai )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "publisherId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cColId )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "documentDescription" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cDescrPst) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif
   
 	xRet := oWsdl:GetSoapMsg()

  	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>", '')
	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()
	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpPst()
Função para alterar permissões de um diretorio, no Fluig.

@Param	nPasta		Código do diretorio, numerico. (Pode ser NYB_IDGED ou NXX_IDGED)
@Param	cDescrPst	Nome da Pasta a ser criada.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUpPst(nPasta,cUsuario,cSenha,cEmpresa,cTipo,cColIdUsr,lInclui,cSecHeran)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMFolderService?wsdl","//E","/E") //URL do Web Service
	Local aSimple	:= {}
	Local aComplex	:= {}
  	Local cColId	:= JColId(cUsuario,cSenha,cEmpresa,cUsuario)
	Local cXMLPst	:= JGetPst(nPasta,cColId,cUsuario,cSenha,cEmpresa)
	Local cXMLSec	:= JGetSec(nPasta,cUsuario,cSenha,cEmpresa)
	Local aTmp		:= {}
	Local aChildren := {}
	Local aChilSec	:= {}
	Local cErro		:= ""
	Local cAviso	:= ""
	Local cPathCab	:= ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETFOLDERRESPONSE:_DOCUMENT:_ITEM"
	Local cPathCab1	:= ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETSECURITYRESPONSE:_SECURITY:_ITEM"
	Local ni
	Local nj
	Local nk
	Local cComplex := ""
	Local nSec     := 1

	Default cSecHeran := "false"

	if aT("alha de login",cXMLPst) > 0 .Or. aT("alha de login",cXMLSec) > 0
		return "Falha de login"
	Endif

	if lInclui .And. At(cColIdUsr,cXMLSec) > 0
		Return "ok"
	Endif

	oXmlOri := XmlParser( cXMLPst, "_", @cErro, @cAviso )

	// Inicia a cópia dos dados do Arquivo.
	If oXmlOri <> Nil .And. Type("oXmlOri" + cPathCab) != "U"

		// Se encontrou as informações do Arquivo, copia elas para o aTmp
		If ValType(&("oXmlOri" + cPathCab )) == "A"
			For ni:=1 to Len(&("oXmlOri" + cPathCab ))
				aSize(aTmp,0)
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_ACCESSCOUNT")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_ACCESSCOUNT:REALNAME"),;
							   &("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_ACCESSCOUNT:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_activeVersion")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_activeVersion:REALNAME"),;
							   &("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_activeVersion:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_additionalComments")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_additionalComments:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_additionalComments:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_allowMuiltiCardsPerUser")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_allowMuiltiCardsPerUser:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_allowMuiltiCardsPerUser:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_approved")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_approved:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_approved:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_approvedDate")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_approvedDate:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_approvedDate:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_cardDescription")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_cardDescription:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_cardDescription:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_colleagueId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_colleagueId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_colleagueId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_companyId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_companyId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_companyId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_crc")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_crc:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_crc:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_createDate")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_createDate:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_createDate:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_createDateInMilliseconds")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_createDateInMilliseconds:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_createDateInMilliseconds:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_datasetName")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_datasetName:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_datasetName:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_deleted")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_deleted:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_deleted:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_documentId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_documentDescription")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentDescription:REALNAME"),;
									JurEncUTF8(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentDescription:TEXT"))})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_documentPropertyNumber")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentPropertyNumber:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentPropertyNumber:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_documentPropertyVersion")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentPropertyVersion:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentPropertyVersion:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_documentType")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentType:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentType:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_documentTypeId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentTypeId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_documentTypeId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_downloadEnabled")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_downloadEnabled:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_downloadEnabled:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_draft")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_draft:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_draft:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_expirationDate")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_expirationDate:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_expirationDate:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_expires")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_expires:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_expires:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_externalDocumentId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_externalDocumentId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_externalDocumentId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_forAproval")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_forAproval:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_forAproval:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_iconId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_iconId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_iconId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_imutable")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_imutable:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_imutable:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_indexed")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_indexed:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_indexed:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_inheritSecurity")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_inheritSecurity:REALNAME"),;
									"true"})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_isEncrypted")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_isEncrypted:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_isEncrypted:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_keyWord")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_keyWord:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_keyWord:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_languageId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_languageId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_languageId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_lastModifiedDate")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_lastModifiedDate:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_lastModifiedDate:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_metaListId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_metaListId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_metaListId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_metaListRecordId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_metaListRecordId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_metaListRecordId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_onCheckout")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_onCheckout:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_onCheckout:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_parentDocumentId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_parentDocumentId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_parentDocumentId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_permissionType")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_permissionType:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_permissionType:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_phisicalFile")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_phisicalFile:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_phisicalFile:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_phisicalFileSize")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_phisicalFileSize:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_phisicalFileSize:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_privateColleagueId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_privateColleagueId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_privateColleagueId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_privateDocument")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_privateDocument:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_privateDocument:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_protectedCopy")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_protectedCopy:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_protectedCopy:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_publisherId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_publisherId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_publisherId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_restrictionType")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_restrictionType:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_restrictionType:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_rowId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_rowId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_rowId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_securityLevel")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_securityLevel:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_securityLevel:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_siteCode")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_siteCode:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_siteCode:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_topicId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_topicId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_topicId:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_translated")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_translated:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_translated:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_UUID")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_UUID:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_UUID:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_updateIsoProperties")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_updateIsoProperties:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_updateIsoProperties:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_userNotify")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_userNotify:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_userNotify:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_validationStartDate")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_validationStartDate:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_validationStartDate:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_version")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_version:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_version:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_versionDescription")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_versionDescription:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_versionDescription:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]"),Upper("_volumeId")) <> Nil
					aAdd(aTmp,{&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_volumeId:REALNAME"),;
									&("oXmlOri" + cPathCab + "[" + StrZero(ni,3) + "]:_volumeId:TEXT")})
				EndIf
				aAdd(aChildren,aClone(aTmp))
			Next
		Else
			aSize(aTmp,0)
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_ACCESSCOUNT")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_ACCESSCOUNT:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_ACCESSCOUNT:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_activeVersion")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_activeVersion:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_activeVersion:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_additionalComments")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_additionalComments:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_additionalComments:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_allowMuiltiCardsPerUser")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_allowMuiltiCardsPerUser:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_allowMuiltiCardsPerUser:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_approved")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_approved:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_approved:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_approvedDate")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_approvedDate:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_approvedDate:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_cardDescription")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_cardDescription:REALNAME"),;
								JurEncUTF8(&("oXmlOri" + cPathCab + ":_cardDescription:TEXT"))})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_colleagueId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_colleagueId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_colleagueId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_companyId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_companyId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_companyId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_crc")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_crc:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_crc:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_createDate")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_createDate:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_createDate:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_createDateInMilliseconds")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_createDateInMilliseconds:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_createDateInMilliseconds:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_datasetName")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_datasetName:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_datasetName:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_deleted")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_deleted:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_deleted:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_documentId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_documentId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_documentId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_documentDescription")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_documentDescription:REALNAME"),;
								JurEncUTF8(&("oXmlOri" + cPathCab + ":_documentDescription:TEXT"))})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_documentPropertyNumber")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_documentPropertyNumber:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_documentPropertyNumber:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_documentPropertyVersion")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_documentPropertyVersion:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_documentPropertyVersion:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_documentType")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_documentType:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_documentType:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_documentTypeId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_documentTypeId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_documentTypeId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_downloadEnabled")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_downloadEnabled:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_downloadEnabled:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_draft")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_draft:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_draft:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_expirationDate")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_expirationDate:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_expirationDate:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_expires")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_expires:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_expires:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_externalDocumentId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_externalDocumentId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_externalDocumentId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_forAproval")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_forAproval:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_forAproval:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_iconId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_iconId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_iconId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_imutable")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_imutable:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_imutable:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_indexed")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_indexed:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_indexed:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_inheritSecurity")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_inheritSecurity:REALNAME"),;
								"true"})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_isEncrypted")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_isEncrypted:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_isEncrypted:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_keyWord")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_keyWord:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_keyWord:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_languageId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_languageId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_languageId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_lastModifiedDate")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_lastModifiedDate:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_lastModifiedDate:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_metaListId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_metaListId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_metaListId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_metaListRecordId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_metaListRecordId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_metaListRecordId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_onCheckout")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_onCheckout:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_onCheckout:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_parentDocumentId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_parentDocumentId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_parentDocumentId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_permissionType")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_permissionType:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_permissionType:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_phisicalFile")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_phisicalFile:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_phisicalFile:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_phisicalFileSize")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_phisicalFileSize:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_phisicalFileSize:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_privateColleagueId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_privateColleagueId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_privateColleagueId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_privateDocument")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_privateDocument:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_privateDocument:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_protectedCopy")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_protectedCopy:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_protectedCopy:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_publisherId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_publisherId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_publisherId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_restrictionType") )<> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_restrictionType:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_restrictionType:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_rowId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_rowId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_rowId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_securityLevel")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_securityLevel:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_securityLevel:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_siteCode") )<> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_siteCode:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_siteCode:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_topicId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_topicId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_topicId:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_translated")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_translated:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_translated:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_UUID")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_UUID:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_UUID:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_updateIsoProperties")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_updateIsoProperties:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_updateIsoProperties:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_userNotify")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_userNotify:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_userNotify:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_validationStartDate")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_validationStartDate:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_validationStartDate:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_version")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_version:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_version:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_versionDescription")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_versionDescription:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_versionDescription:TEXT")})
			EndIf
			If XmlChildEx(&("oXmlOri" + cPathCab),Upper("_volumeId")) <> Nil
				aAdd(aTmp,{&("oXmlOri" + cPathCab + ":_volumeId:REALNAME"),;
								&("oXmlOri" + cPathCab + ":_volumeId:TEXT")})
			EndIf
			aAdd(aChildren,aClone(aTmp))
		EndIf

		FwFreeObj(oXmlOri)
		oXmlOri := Nil
	EndIf

	oXmlSec := XmlParser( cXMLSec, "_", @cErro, @cAviso )

	// Inicia a parte de Security
	If oXmlSec <> Nil .And. Type("oXmlSec" + cPathCab1) != "U"
		// Verifica se encontrou os dados de Segurança
		If ValType(&("oXmlSec" + cPathCab1 )) == "A"
			For ni:=1 to Len(&("oXmlSec" + cPathCab1 ))
				// Verifica se a linha é o usuário que foi passado. Se for, não copia ele
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_ATTRIBUTIONVALUE") <> Nil .and. &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_ATTRIBUTIONVALUE:TEXT") <> cColIdUsr
					aSize(aTmp,0)
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_ATTRIBUTIONTYPE") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_ATTRIBUTIONTYPE:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_ATTRIBUTIONTYPE:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_ATTRIBUTIONVALUE") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_ATTRIBUTIONVALUE:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_ATTRIBUTIONVALUE:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_COMPANYID") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_COMPANYID:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_COMPANYID:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_DOCUMENTID") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_DOCUMENTID:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_DOCUMENTID:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_INHERITSECURITY") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_INHERITSECURITY:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_INHERITSECURITY:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_PERMISSION") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_PERMISSION:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_PERMISSION:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_SECURITYLEVEL") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_SECURITYLEVEL:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_SECURITYLEVEL:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_SECURITYVERSION") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_SECURITYVERSION:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_SECURITYVERSION:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_SEQUENCE") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_SEQUENCE:REALNAME"),;
									StrZero(nSec,3)})
						nSec := nSec + 1
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_SHOWCONTENT") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_SHOWCONTENT:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_SHOWCONTENT:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_VERSION") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_VERSION:REALNAME"),;
									&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_VERSION:TEXT")})
					EndIf
					If XmlChildEx(&("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]"),"_DOWNLOADENABLED") <> Nil
						aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[" + StrZero(ni,3) + "]:_DOWNLOADENABLED:REALNAME"),;
									"true"})
					EndIf
					aAdd(aChilSec,aClone(aTmp))
				EndIf
			Next

			// Se estiver ativo, irá inserir os dados do usuário passado por parâmetro.
			// Essa operação serve tanto para Incluir quanto manter o usuário na configuração
			If lInclui
				aSize(aTmp,0)
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_ATTRIBUTIONTYPE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_ATTRIBUTIONTYPE:REALNAME"),cTipo})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]"),"_ATTRIBUTIONVALUE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_ATTRIBUTIONVALUE:REALNAME"),cColIdUsr})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_COMPANYID") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_COMPANYID:REALNAME"),cEmpresa})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_DOCUMENTID") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_DOCUMENTID:REALNAME"),nPasta})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_INHERITSECURITY") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_INHERITSECURITY:REALNAME"),cSecHeran})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_PERMISSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_PERMISSION:REALNAME"),"true"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_SECURITYLEVEL") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_SECURITYLEVEL:REALNAME"),"3"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_SECURITYVERSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_SECURITYVERSION:REALNAME"),"true"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_SEQUENCE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_SEQUENCE:REALNAME"),StrZero(nSec,3)})
					nSec := nSec + 1
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_SHOWCONTENT") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_SHOWCONTENT:REALNAME"),"true"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_VERSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_VERSION:REALNAME"),"1000"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 + "[001]" ),"_DOWNLOADENABLED") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + "[001]" + ":_DOWNLOADENABLED:REALNAME"),"true"})
				EndIf
				aAdd(aChilSec,aClone(aTmp))
			EndIf
		Else
			If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_ATTRIBUTIONVALUE") <> Nil .and. &("oXmlSec" + cPathCab1 + ":_ATTRIBUTIONVALUE:TEXT") <> cColIdUsr

				aSize(aTmp,0)
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_ATTRIBUTIONTYPE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_ATTRIBUTIONTYPE:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_ATTRIBUTIONTYPE:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_ATTRIBUTIONVALUE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_ATTRIBUTIONVALUE:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_ATTRIBUTIONVALUE:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_COMPANYID") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_COMPANYID:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_COMPANYID:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_DOCUMENTID") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_DOCUMENTID:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_DOCUMENTID:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_INHERITSECURITY") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_INHERITSECURITY:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_INHERITSECURITY:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_PERMISSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_PERMISSION:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_PERMISSION:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_SECURITYLEVEL") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_SECURITYLEVEL:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_SECURITYLEVEL:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_SECURITYVERSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_SECURITYVERSION:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_SECURITYVERSION:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_SEQUENCE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_SEQUENCE:REALNAME"),;
								StrZero(nSec,3)})
					nSec := nSec + 1
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_SHOWCONTENT") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_SHOWCONTENT:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_SHOWCONTENT:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_VERSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_VERSION:REALNAME"),;
								&("oXmlSec" + cPathCab1 + ":_VERSION:TEXT")})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_DOWNLOADENABLED") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_DOWNLOADENABLED:REALNAME"),;
								"true"})
				EndIf
				aAdd(aChilSec,aClone(aTmp))
			EndIf

			If lInclui
				aSize(aTmp,0)
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_ATTRIBUTIONTYPE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_ATTRIBUTIONTYPE:REALNAME"),cTipo})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_ATTRIBUTIONVALUE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_ATTRIBUTIONVALUE:REALNAME"),cColIdUsr})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_COMPANYID") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_COMPANYID:REALNAME"),cEmpresa})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_DOCUMENTID") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_DOCUMENTID:REALNAME"),nPasta})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_PERMISSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_PERMISSION:REALNAME"),"true"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_INHERITSECURITY") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_INHERITSECURITY:REALNAME"),cSecHeran})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_SECURITYLEVEL") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_SECURITYLEVEL:REALNAME"),"3"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_SECURITYVERSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_SECURITYVERSION:REALNAME"),"true"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_SEQUENCE") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_SEQUENCE:REALNAME"),StrZero(nSec,3)})
					nSec := nSec + 1
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_SHOWCONTENT") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_SHOWCONTENT:REALNAME"),"true"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_VERSION") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_VERSION:REALNAME"),"1000"})
				EndIf
				If XmlChildEx(&("oXmlSec" + cPathCab1 ),"_DOWNLOADENABLED") <> Nil
					aAdd(aTmp,{ &("oXmlSec" + cPathCab1 + ":_DOWNLOADENABLED:REALNAME"),"true"})
				EndIf
				aAdd(aChilSec,aClone(aTmp))
			EndIf
		EndIf
		FwFreeObj(oXmlSec)
	Else
		aSize(aTmp,0)
		aAdd(aTmp,{ "attributionType",cTipo})
		aAdd(aTmp,{ "attributionValue",cColIdUsr})
		aAdd(aTmp,{ "companyId",cEmpresa})
		aAdd(aTmp,{ "documentId",nPasta})
		aAdd(aTmp,{ "inheritSecurity",cSecHeran})
		aAdd(aTmp,{ "permission","true"})
		aAdd(aTmp,{ "securityLevel","3"})
		aAdd(aTmp,{ "securityVersion","true"})
		aAdd(aTmp,{ "sequence",StrZero(nSec,3)})
		aAdd(aTmp,{ "showContent","true"})
		aAdd(aTmp,{ "version","1000"})
		aAdd(aTmp,{ "downloadEnabled","true"})

		nSec := nSec + 1
		aAdd(aChilSec,aClone(aTmp))
	EndIf

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
		Return(xRet)
	Endif

	// Define a operação
	xRet := oWsdl:SetOperation( "updateFolder" )
	If xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	EndIf
 
  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMFolderService","//E","/E")

	// Lista os tipos complexos da mensagem de input envolvida na operação
	aComplex := oWsdl:NextComplex()
	While ValType( aComplex ) == "A"
		if ( aComplex[2] == "item" ) .And. ( aComplex[5] == "Document#1" )
			nOccurs := Len(aChildren)
		Elseif ( aComplex[2] == "item" ) .And. ( aComplex[5] == "security#1" )
			nOccurs := Len(aChilSec)
		Else
			nOccurs := 0
		EndIf

		xRet := oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
		If xRet == .F.
			xRet := STR0030 + aComplex[2] + STR0031 + cValToChar( aComplex[1] ) + STR0032 + cValToChar( nOccurs ) + STR0033 //"Erro ao definir elemento "##", ID "##", com "##" ocorrencias"
			return
		EndIf
		aComplex := oWsdl:NextComplex()
	EndDo
	  
	aSimple := oWsdl:SimpleInput()

	// Define o valor de cada parâmeto necessário
	// Parâmetros:
	//     <username>?</username>
	//     <password>?</password>
	//     <companyId>?</companyId>
	//     <Document></Document>
	//     <security>
	//     <Approvers/>
	nPos := aScan( aSimple, {|x| x[2] == "username" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
	if xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	EndIf

	nPos := aScan( aSimple, {|x| x[2] == "password" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
	If xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	EndIf

	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )

	If xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	EndIf

	// Atribui dados da pasta
	For nk:=1 to Len(aChildren)
		cComplex := "Document#1.item#"+AllTrim(Str(nk))
		For nj:=4 to Len(aSimple)
			If aSimple[nj][5] == cComplex
				nPos := aScan( aChildren[nk], {|x| aSimple[nj][2] == x[1] } )
				If nPos > 0
					If !Empty(aChildren[nk][nPos][2])
						xRet := oWsdl:SetValue( aSimple[nj][1], aChildren[nk][nPos][2] )
						if xRet == .F.
							xRet := STR0029 + oWsdl:cError
				 			Return(xRet)
						endif
					EndIf
				EndIf
			Else
				Exit
			EndIf
		Next
	Next

	//Atribui dados de segurança
	For nk:=1 to Len(aChilSec)
		cComplex := "security#1.item#"+AllTrim(Str(nk))
		For nj:=nj to Len(aSimple)
			If aSimple[nj][5] == cComplex
				nPos := aScan( aChilSec[nk], {|x| aSimple[nj][2] == x[1] } )
				If nPos > 0
					If !Empty(aChilSec[nk][nPos][2])
						xRet := oWsdl:SetValue( aSimple[nj][1], aChilSec[nk][nPos][2] )
						if xRet == .F.
							xRet := STR0029 + oWsdl:cError
							Return(xRet)
						EndIf
					EndIf
				EndIf
			Else
				Exit
			EndIf
		Next
	Next

	// Pega a mensagem SOAP que será enviada ao servidor
	xRet := oWsdl:GetSoapMsg()

	If !Empty(xRet)
		//Retirado o elemento da tag devido o obj nao suportar
		cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
		cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

		// Log do XML de Envio
		JConLogXML(cMsg, "E")

		// Envia a mensagem SOAP ao servidor
		xRet := oWsdl:SendSoapMsg(cMsg)

		// Pega a mensagem de resposta
		xRet := oWsdl:GetSoapResponse()

		// Log do XML de Recebimento
		JConLogXML(xRet, "R")
	Else
		xRet := oWsdl:cError
	Endif

	aSize(aChildren,0)
	aSize(aChilSec,0)
	aSize(aTmp,0)
	cMsg := ""

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpSPst()
Função para alterar um diretorio, no Fluig

@Param	nPasta		Código do diretorio, numerico. (Pode ser NYB_IDGED ou NXX_IDGED)
@Param	cDescrPst	Nome da Pasta a ser criada.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUpSPst(nPasta,cDescrPst,cUsuario,cSenha,cEmpresa)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMFolderService?wsdl","//E","/E") //URL do Web Service
	Local aSimple	:= {}
	Local aComplex	:= {}
   	Local cColId	:= JColId(cUsuario,cSenha,cEmpresa,cUsuario)
 	Local cXMLPst	:= JGetPst(nPasta,cColId,cUsuario,cSenha,cEmpresa)
 	Local lLoop 	:= .T., lRet1 := .F., lRet2 := .F.
  	Local aChildren := {}
  	Local ni
  	Local nj

  	oXmlOri := TXmlManager():New()

 	xRet := oXmlOri:Parse( cXMLPst )
  	If !xRet
    	xRet := STR0029 + oXmlOri:Error()	//"Erro: "
    	Conout(xRet)
	   	Return(xRet)
  	EndIf

  	While lLoop

	    If oXmlOri:CNAME == "item"
			aChildren := oXmlOri:DOMGetChildArray()
			lLoop	  := .F.
    	EndIf

    	If oXmlOri:DOMHasChildNode()
      		oXmlOri:DOMChildNode()
    	Elseif oXmlOri:DOMHasNextNode()
      		oXmlOri:DOMNextNode()
    	Else
			lLoop := .F.
    	EndIf
    EndDo

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif
   
  	// Define a operação
  	xRet := oWsdl:SetOperation( "updateSimpleFolder" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif
 
  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMFolderService","//E","/E")

	// Lista os tipos complexos da mensagem de input envolvida na operação
  	aComplex := oWsdl:NextComplex()

    xRet := oWsdl:SetComplexOccurs(aComplex[1], 1 )
    If !xRet
    	xRet := STR0030 + STR0031 + cValToChar(aComplex[1]) + STR0034	//"Erro ao definir elemento "	//", ID "	//", com 1 (uma) ocorrência"
    	Conout(xRet)
    	Return(xRet)
    EndIf

	aSimple := oWsdl:SimpleInput()
  
  	// Define o valor de cada parâmetro necessário
  	// Parâmetros:
    //     <username>?</username>
    //     <password>?</password>
    //     <companyId>?</companyId>
    //     <Document></Document>

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	ni:=1
	For nj:=4 to Len(aSimple)
		If ni <= Len(aChildren)
			nPos := aScan( aSimple, {|x| x[2] == aChildren[ni][1] .AND. x[5] == "Document#1.item#1" } )
			If nPos > 0
				If nPos == nj
					If aChildren[ni][1] == "documentDescription"
						xRet := oWsdl:SetValue( aSimple[nPos][1], If(Empty(aChildren[ni][2])," ",JurEncUTF8(cDescrPst)) )
					Else
						xRet := oWsdl:SetValue( aSimple[nPos][1], If(Empty(aChildren[ni][2])," ",aChildren[ni][2]) )
		  			EndIf
					if xRet == .F.
   						xRet := STR0029 + oWsdl:cError
   				 		Return(xRet)
  					endif
					ni := ni + 1
				Else
					If "Date" $ aSimple[nj][2]
						xRet := oWsdl:SetValue( aSimple[nj][1], SubStr(Dtos(dDataBase),1,4)+"-"+SubStr(Dtos(dDataBase),5,2)+"-"+SubStr(Dtos(dDataBase),7,2) )
					Else
						xRet := oWsdl:SetValue( aSimple[nj][1], "0" )
					Endif
		  			if xRet == .F.
				 		xRet := STR0029 + oWsdl:cError
				 		Return(xRet)
					Endif
				EndIf
			EndIf
		Else
			xRet := oWsdl:SetValue( aSimple[nj][1], " " )
  			if xRet == .F.
		 		xRet := STR0029 + oWsdl:cError
		 		Return(xRet)
			endif
		EndIf
	Next

	// Pega a mensagem SOAP que será enviada ao servidor
 	xRet := oWsdl:GetSoapMsg()

  	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()
	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetPst()
Função para trazer informações de um diretorio no Fluig

@Param	nPasta		Código do diretorio, numerico. (Pode ser NYB_IDGED ou NXX_IDGED)
@Param	cIdPublic	Matrícula do usuário publicador.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetPst(nPasta,cIdPublic,cUsuario,cSenha,cEmpresa)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMFolderService?wsdl","//E","/E") //URL do Web Service
	Local aSimple	:= {}

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif
   
  	// Define a operação
  	xRet := oWsdl:SetOperation( "getFolder" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMFolderService","//E","/E")
   
  	// Define o valor de cada parâmeto necessário
  	// Parâmetros:
    //      <username>juridicodemo@totvs.com.br</username>
    //     <password>Totvs@123</password>
    //     <companyId>1</companyId>
    //     <documentId>441</documentId>
    //     <colleagueId>adm</colleagueId>
 	aSimple := oWsdl:SimpleInput()

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

   	nPos := aScan( aSimple, {|x| x[2] == "documentId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], nPasta )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "colleagueId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cIdPublic )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif
  
  	// Pega a mensagem SOAP que será enviada ao servidor
 	// DocumentDto[].
	xRet := oWsdl:GetSoapMsg()

	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetSPst()
Função para trazer informações de um diretorio, no Fluig

@Param	nPasta		Código do diretorio, numerico. (Pode ser NYB_IDGED ou NXX_IDGED)
@Param	cIdPublic	Matrícula do usuário publicador.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetSPst(nPasta,cUsuario,cSenha,cEmpresa,cColId)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMFolderService?wsdl","//E","/E") //URL do Web Service
	Local aSimple	:= {}

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif
   
  	// Define a operação
  	xRet := oWsdl:SetOperation( "getSubFolders" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMFolderService","//E","/E")
   
  	// Define o valor de cada parâmeto necessário
  	// Parâmetros:
    //      <username>juridicodemo@totvs.com.br</username>
    //     <password>Totvs@123</password>
    //     <companyId>1</companyId>
    //     <documentId>441</documentId>
    //     <colleagueId>adm</colleagueId>
 	aSimple := oWsdl:SimpleInput()

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

   	nPos := aScan( aSimple, {|x| x[2] == "documentId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], nPasta )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "colleagueId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cColId )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif
  
  	// Pega a mensagem SOAP que será enviada ao servidor
 	// DocumentDto[].
	xRet := oWsdl:GetSoapMsg()

	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} JGetSec()
Função para trazer informações de Segurança de um diretorio no Fluig

@Param	nPasta		Código do diretorio, numerico. (Pode ser NYB_IDGED ou NXX_IDGED)

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetSec(nPasta,cUsuario,cSenha,cEmpresa)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMFolderService?wsdl","//E","/E") //URL do Web Service
   
	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif
   
  	// Define a operação
  	xRet := oWsdl:SetOperation( "getSecurity" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif
   
  	// Define o valor de cada parâmetro necessário
  	// Parâmetros:
    //     <username>juridicodemo@totvs.com.br</username>
    //     <password>Totvs@123</password>
    //     <companyId>1</companyId>
    //     <documentId>441</documentId>
  
	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
 	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMFolderService","//E","/E")

 	aSimple := oWsdl:SimpleInput()

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

   	nPos := aScan( aSimple, {|x| x[2] == "documentId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], nPasta )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

   	// Pega a mensagem SOAP que será enviada ao servidor
 	// DocumentDto[].
	xRet := oWsdl:GetSoapMsg()

	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')
	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JMkGrp()
Função para criar um grupo no Fluig

@Param	cDescrGrp	Nome do Grupo a ser criado.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 08/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JMkGrp(cDescrGrp,cIdGrp)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMGroupService?wsdl","//E","/E") //URL do Web Service
	Local cUsuario	:= AllTrim(SuperGetMV('MV_ECMUSER',,""))
	Local cSenha	:= AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
	Local cEmpresa  := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
	Local aSimple	:= {}
   
	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif
   
  	// Define a operação
  	xRet := oWsdl:SetOperation( "createGroup" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMGroupService","//E","/E")
	// Lista os tipos complexos da mensagem de input envolvida na operação
  	aComplex := oWsdl:NextComplex()

    xRet := oWsdl:SetComplexOccurs(aComplex[1], 1 )
    if xRet == .F.
      conout( STR0030+STR0031 + cValToChar( aComplex[1] ) + STR0034 )
      return
    endif

	aSimple := oWsdl:SimpleInput()

  	// Define o valor de cada parâmetro necessário
  	// Parâmetros:
  	// username: login do usuário.
  	// password: senha do usuário.
  	// companyId: código da empresa.
  	// Grupos:
  	// publisherId: matrícula do usuário publicador.
  	// documentDescription: descrição da pasta. 

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" .AND. x[5] == "companyId"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "companyId" .AND. x[5] == "groups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "foo" .AND. x[5] == "groups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cIdGrp )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "groupDescription" .AND. x[5] == "groups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], STR0035+cDescrGrp ) //"Membros_"
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "groupId" .AND. x[5] == "groups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cDescrGrp )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

 	xRet := oWsdl:GetSoapMsg()

  	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')
	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()
	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JColMail()
Função para retornar o colleague do usuario no Fluig

@Param	cDescrGrp	Nome do Grupo a ser criado.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 08/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JColMail(cUsuario,cSenha,cEmpresa,cMail)

	Local oWsdl
	Local xRet
	Local cUrl 	   := StrTran(AllTrim(JFlgUrl())+"/ECMColleagueService?wsdl","//E","/E") //URL do Web Service
	Local aSimple	   := {}

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif

	// Define a operação
	xRet := oWsdl:SetOperation( "getColleaguesMail" )
	if xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	endif

	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMColleagueService","//E","/E")

	aSimple := oWsdl:SimpleInput()

	// Define o valor de cada parâmeto necessário
	// Parâmetros:
	//     <username>juridicodemo@totvs.com.br</username>
	//     <password>Totvs@123</password>
	//     <companyId>1</companyId>
	//     <mail>juridicodemo@totvs.com.br</mail>

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )

	If xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	EndIf

	nPos := aScan( aSimple, {|x| x[2] == "password" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )

	If xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	EndIf

	nPos := aScan( aSimple, {|x| x[2] == "companyId"  } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )

	If xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	EndIf

	nPos := aScan( aSimple, {|x| x[2] == "mail" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(cMail) )

	if xRet == .F.
		xRet := STR0029 + oWsdl:cError
		Return(xRet)
	EndIf

 	xRet := oWsdl:GetSoapMsg()

	//Retirado o elemento da tag devido o obj nao suportar
	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
	xRet := oWsdl:SendSoapMsg(cMsg)

	// Pega a mensagem de resposta
	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JMkCGrp()
Função para criar um usuario no grupo, no Fluig.

@Param	cUsuario	Email do Usuario a ser adicionado ao grupocriado.
@Param	cDescrGrp	Nome do Grupo a ser criado.
@Param	cIdGrp		Codigo do Grupo a ser criado.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 08/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JMkCGrp(cMail,cDescrGrp,cIdGrp)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMColleagueGroupService?wsdl","//E","/E") //URL do Web Service
	Local cUsuario	:= AllTrim(SuperGetMV('MV_ECMUSER',,""))
	Local cSenha	:= AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
	Local cEmpresa  := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
   	Local cColId	:= JColId(cUsuario,cSenha,cEmpresa,cMail)
	Local aSimple	:= {}
	Local aComplex 	:= {}
   
	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif

  	// Define a operação
  	xRet := oWsdl:SetOperation( "createColleagueGroup" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMColleagueGroupService","//E","/E")

	// Lista os tipos complexos da mensagem de input envolvida na operação
  	aComplex := oWsdl:NextComplex()

	xRet := oWsdl:SetComplexOccurs(aComplex[1], 1 )
	if xRet == .F.
		conout( STR0030+STR0031 + cValToChar( aComplex[1] ) + STR0034 )
		return
	endif

	aSimple := oWsdl:SimpleInput()

  	// Define o valor de cada parâmeto necessário
  	// Parâmetros:
    //       <item>
    //           <colleagueId>lago</colleagueId>
    //           <companyId>1</companyId>
    //           <foo>001</foo>
    //           <groupId>JUR_001_CONTENCIOSO</groupId>
    //           <writeAllowed>true</writeAllowed>
    //        </item>

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" .AND. x[5] == "companyId"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "colleagueId" .AND. x[5] == "ColleagueGroups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cColId )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "companyId" .AND. x[5] == "ColleagueGroups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "foo" .AND. x[5] == "ColleagueGroups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cIdGrp )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "groupId" .AND. x[5] == "ColleagueGroups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cDescrGrp )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

 	nPos := aScan( aSimple, {|x| x[2] == "writeAllowed" .AND. x[5] == "ColleagueGroups#1.item#1"} )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], "true" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif


 	xRet := oWsdl:GetSoapMsg()

  	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} JDelCGrp()
Função para deletar um usuario no grupo no Fluig

@Param	cUsuario	Email do Usuario a ser adicionado ao grupocriado.
@Param	cIdGrp		Codigo do Grupo a ser criado.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 22/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JDelCGrp(cMail,cIdGrp)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMColleagueGroupService?wsdl","//E","/E") //URL do Web Service
	Local cUsuario	:= AllTrim(SuperGetMV('MV_ECMUSER',,""))
	Local cSenha	:= AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
	Local cEmpresa  := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
   	Local cColId	:= JColId(cUsuario,cSenha,cEmpresa,cMail)
	Local aSimple	:= {}
   
	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif

  	// Define a operação
  	xRet := oWsdl:SetOperation( "deleteColleagueGroup" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMColleagueGroupService","//E","/E")

	aSimple := oWsdl:SimpleInput()

  	// Define o valor de cada parâmeto necessário
  	// Parâmetros:

    //     <username>juridicodemo@totvs.com.br</username>
    //     <password>Totvs@123</password>
    //     <companyId>1</companyId>
    //     <GroupId>JUR_001_CONTENCIOSO</GroupId>
    //     <ColleagueId>adm</ColleagueId>

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "GroupId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cIdGrp )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "ColleagueId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cColId )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

 	xRet := oWsdl:GetSoapMsg()

  	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Resposta
	JConLogXML(xRet, "R")


Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtCGrp()
Função que retorna os grupos em que o usuário pertence, no Fluig.

@Param	cUsuario	Email do Usuario a ser adicionado ao grupocriado.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 08/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGtCGrp(cMail)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMColleagueGroupService?wsdl","//E","/E") //URL do Web Service
	Local cUsuario	:= AllTrim(SuperGetMV('MV_ECMUSER',,""))
	Local cSenha	:= AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
	Local cEmpresa  := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
   	Local cColId	:= JColId(cUsuario,cSenha,cEmpresa,cMail)
	Local aSimple	:= {}
   
 	If Empty(cColId)
   	 	xRet := STR0036 //"Erro: Verificar e-mail do usuario, id nao encontrado"
    	Return(xRet)
	EndIf

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif
   
  	// Define a operação
  	xRet := oWsdl:SetOperation( "getColleagueGroupsByColleagueId" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMColleagueGroupService","//E","/E")

	aSimple := oWsdl:SimpleInput()

  	// Define o valor de cada parâmeto necessário
  	// Parâmetros:

    //  <ws:getColleagueGroupsByColleagueId>
    //     <username>juridicodemo@totvs.com.br</username>
    //     <password>Totvs@123</password>
    //     <companyId>1</companyId>
    //     <colleagueId>lago</colleagueId>
    //  </ws:getColleagueGroupsByColleagueId>

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

	nPos := aScan( aSimple, {|x| x[2] == "colleagueId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cColId )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

 	xRet := oWsdl:GetSoapMsg()

  	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetChild()
Função para trazer os filhos de um diretorio no Fluig

@Param	nPasta		Código do diretorio, numerico. (Pode ser NYB_IDGED ou NXX_IDGED)
@Param	cIdPublic	Matrícula do usuário publicador.

@Return xRet		Mensagem Web Sevice ou erro

@author Andre Lago
@since 09/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGetChild(nPasta,cUsuario,cSenha,cEmpresa,cColId)
  
	Local oWsdl
 	Local xRet
    Local cUrl 		:= StrTran(AllTrim(JFlgUrl())+"/ECMFolderService?wsdl","//E","/E") //URL do Web Service
	Local aSimple	:= {}

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
	   	Return(xRet)
	Endif
   
  	// Define a operação
  	xRet := oWsdl:SetOperation( "getChildren" )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
 	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMFolderService","//E","/E")
  
  	// Define o valor de cada parâmeto necessário
  	// Parâmetros:
    //     <username>juridicodemo@totvs.com.br</username>
    //     <password>Totvs@123</password>
    //     <companyId>1</companyId>
    //     <documentId>441</documentId>
    //     <colleagueId>adm</colleagueId>
 	aSimple := oWsdl:SimpleInput()

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "password" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha) )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

   	nPos := aScan( aSimple, {|x| x[2] == "documentId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], nPasta )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif

  	nPos := aScan( aSimple, {|x| x[2] == "colleagueId" } )
  	xRet := oWsdl:SetValue( aSimple[nPos][1], cColId )
  	if xRet == .F.
    	xRet := STR0029 + oWsdl:cError
    	Return(xRet)
  	endif
  
  	// Pega a mensagem SOAP que será enviada ao servidor
 	// DocumentDto[].
	xRet := oWsdl:GetSoapMsg()

	//Retirado o elemento da tag devido o obj nao suportar
  	cMsg := StrTran(xRet, ' xmlns="http://ws.dm.ecm.technology.totvs.com/"', '')
  	cMsg := StrTran(cMsg, ' xmlns="http://ws.foundation.ecm.technology.totvs.com/"', '')

	// Log do XML de Envio
	JConLogXML(cMsg, "E")

	// Envia a mensagem SOAP ao servidor
  	xRet := oWsdl:SendSoapMsg(cMsg)

  	// Pega a mensagem de resposta
  	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Recebimento
	JConLogXML(cMsg, "R")

Return(xRet)
