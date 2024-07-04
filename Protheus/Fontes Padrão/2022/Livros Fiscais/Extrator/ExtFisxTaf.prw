#Include 'Protheus.ch' 
#Include 'RwMake.ch'
#Include 'TopConn.ch'
#Include 'Totvs.ch'  
#Include 'FileIo.ch' 
#Include 'SpedXDef.ch' 
#Include 'FisaExtWiz.ch'
 
#Define cST1TAB 'TAFST1'	// Nome DEFINIDO da tabela compartilhada no dominio do ERP
#Define cST2TAB 'TAFST2'	// Nome DEFINIDO da tabela compartilhada no dominio do TAF
#Define cTAFXERP 'TAFXERP'	// Nome DEFINIDO da tabela de controle de integrações ( TICKET )
#Define NAO_GRAVAR '#NAOGRAVAR#'

Static cTCGetDB		:= Upper( AllTrim( TCGetDB() ) )
Static cRelease		:= GetRPORelease()
Static cBarraUnix	:= IIf(IsSrvUnix(),"/","\")
Static oAuxiliar	:= Nil
Static oFisaExtSx	:= Nil
Static lJob 		:= IsBlind() .or. IsInCallStack('TAFXGSP')
Static lConectado 	:= .F.
Static lAliasCLO 	:= AliasInDic("CLO")
Static lFKGCALCUL	:=  FKG->(ColumnPos("FKG_CALCUL")) > 0
Static lCCF_TRIB	:=  CCF->(ColumnPos("CCF_TRIB")) > 0
Static MV_PAR61 	:= '1'
Static aSPDSX2		:= SpedLoadX2()
Static aSPDSX3		:= SpedLoadX3()
Static aSPDSX6		:= SpedLoadX6()
Static aSPDFil		:= fGetSpdFil()

/*/{Protheus.doc} ExtTafFExc
	(Função para executar a thread de integração do TAF)

	@type Function
	@author Vitor Ribeiro
	@since 06/12/2017

	@Return lExecuta, logico, se executa ou não a thread. 
	/*/
Function ExtTafFExc()
	
	Local lExecuta := .F.
	
	Local cFilialSFT := ""
	Local cMsgjobTaf := ""
	
	// Pega a filial do SFT para verIficar se essa filial está sEndo executado.
	cFilialSFT := xFilial("SFT")
	
	// Monta a mensagem do thread do taf.
	cMsgjobTaf := "EXTTAFFJOB_" + AllTrim(FWGrpCompany())
	
	If !Empty(cFilialSFT)
		cMsgjobTaf += "_" + AllTrim(cFilialSFT) 
	EndIf
	
	cMsgjobTaf += ": "
	
	// Verifica se já tem uma thread sendo executada.
	lExecuta := VerThread(cMsgjobTaf)
	
	If lExecuta
		// Executa o Job
		StartJob("ExtTafFJob",GetEnvServer(),.F.,cMsgjobTaf,FWGrpCompany(),FWCodFil())
	EndIf
	
Return lExecuta

/*/{Protheus.doc} VerThread
	(Função para verIficar se a thread já está em execução.)

	@type Static Function
	@author Vitor Ribeiro
	@since  06/12/2017

	@param cMsgjobTaf, caracter, mensagem para thread do job

	@return lExecuta, logico, se executou ou não.
	/*/
Static Function VerThread(cMsgjobTaf)
	
	Local aUserInfo := {}
	
	Local lExecuta := .F.
	
	Default cMsgjobTaf := ""
	
	// Retorna um array multidimensional com as informações de cada um do processos em execução
	aUserInfo := GetUserInfoArray()
	
	// verIfica se não tem uma thread sEndo executada da função EXTTAFFJOB para empresa conectada e a filial do SFT caso não seja compartilhado.  
	lExecuta := (Ascan(aUserInfo,{|x| Upper(x[5]) == "EXTTAFFJOB" .And. cMsgjobTaf $ Upper(x[11]) }) < 1)
	
Return lExecuta

/*/{Protheus.doc} ExtTafFJob
	(Função para ser chamado via StartJob. Essa função irá verIficar todos os registros que não tiveram sua integração com o TAF e executará o mesmo.)

	@type Function
	@author Vitor Ribeiro
	@since  06/12/2017

	@param cMsgjobTaf, caracter, mensagem para thread do job
	@param cEmpThread, caracter, codigo da empresa
	@param cFilThread, caracter, codigo da filial

	@Return null, não existe retorno.
	/*/
Function ExtTafFJob(cMsgjobTaf,cEmpThread,cFilThread)

	Local dInIntTaf := CtoD("")
	
	Local aDadosQry := {}
	
	Local nCount := 0
	
	Private cTafJobMsg := ""
	
	Default cMsgjobTaf := ""
	Default cEmpThread := ""
	Default cFilThread := ""
	
	cTafJobMsg := cMsgjobTaf
		
	// Seta job para nao consumir licensas
	RpcSetType(3)
	
	// Seta job para empresa filial desejadas
	RPCSetEnv(cEmpThread,cFilThread)
	
	// Função para saber a data da primeira nota integrada pelo MV_INTTAF.
	dInIntTaf := fIniIntTaf()
	
	// VerIfica se existe registros para integração sem verIficar se existe notas que não foram integradas com o por algum motivo.
	aDadosQry := fQryTafKey(dInIntTaf,.F.)
	
	//21-01-2022 - Função ExtTafFJob não está mais sendo utilizada no ERP, foi removido o While para não ficar em loop nos testCases, pois o campo FT_TAFKEY sempre ficará em branco
	// Enquanto existir registros, executa o FisaExtExc
	iF !Empty(aDadosQry)
		For nCount := 1 To Len(aDadosQry)
			// Executa o extrator do TAF
			FisaExtExc(aDadosQry[nCount])
		Next
		
		// Executa novamente a query para verIfica se existe mais registros para integração, porém dessa vez excluindo as notas que não foram integradas por algum motivo.
		aDadosQry := fQryTafKey(dInIntTaf,.T.)
	Endif
	
Return

/*/{Protheus.doc} fIniIntTaf
	(Função para saber a data da primeira nota integrada pelo MV_INTTAF.)

	@type Static Function
	@author Vitor Ribeiro
	@since  03/01/2017

	@Return data, contém os documentos para integração.
	/*/
Static Function fIniIntTaf()
	
	Local dInIntTaf := dDataBase
	
	Local cAliasQry := ""
	
	cAliasQry := GetNextAlias()
	
	BeginSql Alias cAliasQry
		Column FT_ENTRADA As Date
		
		SELECT 
			MIN(FT_ENTRADA) FT_ENTRADA
		FROM %Table:SFT% SFT

		WHERE
			SFT.%NotDel%
			AND SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_TAFKEY<> ''
	EndSql
	
	If (cAliasQry)->(!Eof())
		dInIntTaf := (cAliasQry)->FT_ENTRADA
	EndIf
	
	(cAliasQry)->(DbCloseArea())
	
Return dInIntTaf

/*/{Protheus.doc} fQryTafKey
	(Função para executar query de verIficação dos registros que precisam ser integrados com o TAF.)

	@type Static Function
	@author Vitor Ribeiro
	@since  06/12/2017

	@param d_InIntTaf, data, data da primeira nota realizada pelo MV_INTTAF
	@param l_VerErro, logico, se deve verIficar se houve erro na integração

	@Return array, contém os documentos para integração.

	@obs Com o parametro l_VerErro igual a .T., a função irá verIficar a tabela TAFXERP para ignorar os registros que ocorram erros na integração.
	/*/
Static Function fQryTafKey(d_InIntTaf,l_VerErro)
	
	Local cAliasQry := ""
	Local cCampXERP := ""
	Local cJoinXErp := ""
	
	Local aDadosQry := {}
	
	Default d_InIntTaf := dDataBase
	
	Default l_VerErro := .F.
	
	cAliasQry := GetNextAlias()
	
	// Se verIfica se ocorreu erro na integração
	If l_VerErro
		cCampXERP := "," + xFunExpSql("COALESCE") + "(XERP.TAFKEY,'') TAFKEY"
		
		cJoinXErp := " LEFT OUTER JOIN ( "
		cJoinXErp += "	 SELECT DISTINCT "
		cJoinXErp += "		XERP.TAFKEY "
		cJoinXErp += "	 FROM " + cTAFXERP + " XERP "
		
		cJoinXErp += "	 WHERE "
		cJoinXErp += "		XERP.D_E_L_E_T_ = ' ' "
		cJoinXErp += "		AND XERP.TAFDATA = '" + DtoS(Date()) + "' "
		cJoinXErp += "		AND XERP.TAFHORA = '00:00:00' "
		cJoinXErp += "		AND XERP.TAFSTATUS = '9' "
		cJoinXErp += "	) XERP ON "
		cJoinXErp += "	XERP.TAFKEY = (SFT.FT_FILIAL + SFT.FT_TIPOMOV + SFT.FT_SERIE + SFT.FT_NFISCAL + SFT.FT_CLIEFOR + SFT.FT_LOJA) "
	Else
		cCampXERP := ",'' TAFKEY"
	EndIf
	
	cCampXERP := "%" + cCampXERP + "%"
	cJoinXErp := "%" + cJoinXErp + "%"
	
	/* 
		Segura 10 segundos antes de executar a query.
		Isso para que caso esteja sEndo gerado mais notas nesse momento 
	*/
	Sleep(10000)
	
	BeginSql Alias cAliasQry
		Column ENTRADA As Date
		
		SELECT DISTINCT
			TAF.NFISCAL
			,TAF.SERIE
			,TAF.CLIEFOR
			,TAF.LOJA
			,TAF.TIPOMOV
			,TAF.ENTRADA
		FROM (
			SELECT DISTINCT
				SFT.FT_NFISCAL NFISCAL
				,SFT.FT_SERIE SERIE
				,SFT.FT_CLIEFOR CLIEFOR
				,SFT.FT_LOJA LOJA
				,SFT.FT_TIPOMOV TIPOMOV
				,SFT.FT_ENTRADA ENTRADA
				%Exp:cCampXERP%
			FROM %Table:SFT% SFT
			
			%Exp:cJoinXErp%
			
			WHERE
				SFT.%NotDel%
				AND SFT.FT_FILIAL = %xFilial:SFT%
				AND SFT.FT_ENTRADA >= %Exp:DtoS(d_InIntTaf)%
				AND SFT.FT_TAFKEY = ''
		) TAF
		
		WHERE
			TAF.TAFKEY = ''
		
		ORDER BY
			TAF.NFISCAL
			,TAF.SERIE
			,TAF.CLIEFOR
			,TAF.LOJA
			,TAF.TIPOMOV
			,TAF.ENTRADA
	EndSql
	
	While (cAliasQry)->(!Eof())
		(cAliasQry)->(Aadd(aDadosQry,{NFISCAL,SERIE,CLIEFOR,LOJA,TIPOMOV,ENTRADA}))
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())
	
Return aDadosQry

/*/{Protheus.doc} DocFisxTAF
Rotina acionada pela funcao MaFisAtuSF3() do MATXFIS atravez de
StartJob para proporcionar a integracao NATIVA entre 
ERP PROTHEUS x TAF quando o parametro MV_INTTAF estiver acionado.
A funcao recebe como parametro o array a_DocSFT contEndo o documento
fiscal que esta sEndo incluido no momento para gerar-lo na TAFST1.

@author Alexandre Inacio Lemes
@since  26/02/2016

@param c_EmpresaT, caracter, contem a empresa para thread
@param c_FilialT, caracter, contem a filial para thread
@param a_DocSFT, array, contem as informações do documento informado
@param l_LmTafKey, logico, se deve limpar o campo FT_TAFKEY

@return nulo, não tem retorno

@obs Função refeita - Vitor Ribeiro - 02/01/2018
/*/
Function DocFisxTAF(c_EmpresaT,c_FilialT,a_DocSFT,l_LmTafKey)

	Default c_EmpresaT := ""
	Default c_FilialT := ""
	
	Default a_DocSFT := {}
	
	Default l_LmTafKey := .F.
	
	// Seta job para nao consumir licensas
	RpcSetType(3)
	
	// Seta job para empresa filial desejadas
	RPCSetEnv(c_EmpresaT,c_FilialT)
	
	// Se deve limpar o campo FT_TAFKEY
	If l_LmTafKey
		fLmTafKey(a_DocSFT)
	EndIf
	
	// Executa o extrator do TAF para o documento informado
	FisaExtExc(a_DocSFT)

Return

/*/{Protheus.doc} fLmTafKey
Função para limpar o campos FT_TAFKEY.

@author Vitor Ribeiro
@since  02/01/2018

@param a_DocSFT, array, contem as informações do documento informado

@return nulo, não tem retorno
/*/
Static Function fLmTafKey(a_DocSFT)
	
	Local cChaveSFT := ""
	
	Default a_DocSFT := {}
	
	DbSelectArea("SFT")		// LIVRO FISCAL POR ITEM DE NF
	SFT->(dbSetOrder(1))	// FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
	
	/*
		Dados do array a_DocSFT
		a_DocSFT[1]	- Numero da nota fiscal - SFT->FT_NFISCAL
		a_DocSFT[2]	- Serie da nota fiscal - SFT->FT_SERIE
		a_DocSFT[3]	- Codigo do cliente ou fornecedor - SFT->FT_CLIEFOR
		a_DocSFT[4]	- Loja do cliente ou fornecedor - SFT->FT_LOJA
		a_DocSFT[5]	- Tipo de movimentação (Entrada/Saída) - SFT->FT_TIPOMOV
		a_DocSFT[6]	- Data da entrada da nota - SFT->FT_ENTRADA
	*/
	If !Empty(a_DocSFT) .And. Len(a_DocSFT) >= 5
		// Chave para busca na SFT.
		cChaveSFT := xFilial("SFT") + a_DocSFT[5] + a_DocSFT[2] + a_DocSFT[1] + a_DocSFT[3] + a_DocSFT[4]
		
		If SFT->(DbSeek(cChaveSFT))
			Do While SFT->(!Eof()) .And. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)  == cChaveSFT
				
				// Se o tafkey estiver preenchido.
				If !Empty(SFT->FT_TAFKEY)
					RecLock("SFT",.F.)
						SFT->FT_TAFKEY := ""
					SFT->(MsUnLock())
					SFT->(FkCommit())
				EndIf
				
				SFT->(DbSkip())
			EndDo
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} ExtFisxTaf
	(Essa rotina irá chamar a tela da wizard ou executar o extrator quase seja chamado via job.)

	@type Function
	@author Vitor Ribeiro
	@since 20/03/2013

	@return Nil, nulo, não tem retorno
	/*/
Function ExtFisxTaf()

	// Se for Job
	If lJob
		// Executa o extrator
		FisaExtExc()
	Else
		// Monta a wizard
		FisaExtWiz()
	EndIf

Return Nil

/*/{Protheus.doc} FisaExtExc
	(Esta rotina tem como Objetivo Extrair os dados do Protheus para importacao no TAF)

	@type Function
	@author Rodrigo Aguilar
	@since 20/03/2013

	@param a_DocSFT, array, contem os dados do documento da SFT

	@return Nil, nulo, não tem retorno
	/*/
Function FisaExtExc(a_DocSFT, cTblTemp)

	Local lTAFGST2		:= .F.
	Local lExtGia		:= FwIsInCallStack('TAFXGSP') //Se esta extraindo a partir da geração da GIA-SP
	Local lJob 			:= IsBlind() .or. lExtGia
	Private cInc 		:= ""
	Private cHorIni 	:= ""
	Private cTafKeyOld 	:= ""
	Private cEntSaiSFT 	:= ""
	Private cFiltInt	:= ""

	Private lBuild := .F.
	Private lDocSFT := .F.
	Private lIntTAF := .F.
	Private lConcFil := .F.	// Variavel private para sobrepor a mesma variavel no sped.
	Private lFFinExtOK := .F.
	Private lGeraST2TAF := .F.
	Private lExtTAFContr := .T. //Indica que será executada a extração de registros mauro 
	Private lFiltReinf := .F.

	Private oHashCache := Nil

	Private aRegExtTaf := {}  //Array contEndo os registros gerados no SPED Contribuíçoes  mauro

	// Se a variavel não existir, inicializa a mesma.
	If Type("cTafJobMsg") <> "C"
		Private cTafJobMsg := ""
	EndIf

	If Type("lTemC1E") <> "L"
		Private lTemC1E := .f.
	EndIf

	If Type("oWizard") <> "O"
		Private oWizard := FisaExtWiz_Class():New()
	EndIf

	Default a_DocSFT := {}
	Default cTblTemp := ''

	lFiltReinf 	:= (oWizard:GetFiltraReinf() == "1")


	cFiltInt	:= oWizard:GetFiltraInteg()

	// Função para instanciar objeto FisaExtSx contEndo as informações dos SX's.
	oFisaExtSx := FisaExtX02()

	cInc := "000001"

	lBuild := GetBuild() >= "7.00.131227A"

	lDocSFT := !Empty(a_DocSFT)

	cEntSaiSFT := IIf(!Empty(a_DocSFT),a_DocSFT[5],"")

	// Verifica Integracao NATIVA Protheus x TAF
	lIntTAF := .F. // FindFunction("TAFExstInt") .And. TAFExstInt() .And. cRelease <> "R8" -> Parametro MV_INTTAF foi desabilitado por não funcionar corretamente

	// Indica se a chamada é da integração online
	lGeraST2TAF := lDocSFT .And. lIntTAF .And. lJob .And. AllTrim(Upper(ProcName(1))) $ "DOCFISXTAF|EXTTAFFJOB"

	lTemC1E := lTAFGST2 := oFisaExtSx:_MV_TAFGST2

	PutGlbValue("FISAEXTEXC_TKTEXT",TAFGTicket())
	PutGlbValue("FISAEXTEXC_DATAEXT",DtoS(Date()))
	PutGlbValue("FISAEXTEXC_HORAEXT",Time()) 
	PutGlbValue("FISAEXTEXC_LTEMC1E",cValToChar(lTemC1E)) 

	// Se a função FFinExtOk existir
	If FindFunction('FFinExtOK')
		lFFinExtOK := FFinExtOK()

		// Se for a release 11.80 ou igual e superior a 12.1.17
		If !lFFinExtOK .And. (cRelease == 'R8' .Or. cRelease >= '12.1.017')
			If lJob
				TAFConout('Ambiente financeiro desatualizado para o Reinf. As informações do financeiro não serão integradas ao TAF. Necessário atualizar o ambiente!',3,.T.,"EXT")
			Else
				MsgAlert(OemToAnsi('Ambiente financeiro desatualizado para o Reinf. As informações do financeiro não serão integradas ao TAF. Necessário atualizar o ambiente!'))
			EndIf
		EndIf
	EndIf

	// Quando for chamado via JOB, as informacoes do WIZARD serao passadas como pergunte
	If lJob
		If Empty(a_DocSFT)
			// Função para alimentar a Wizard do Schedule
			fParaSched(lExtGia)
		Else
			// Função para alimentar a Wizard do Schedule
			fParaJob(a_DocSFT)
		EndIf
		
		TafConout(cTafJobMsg + "1- Extrator (Execucao Automática) - Emp: " + cEmpAnt + " - Filial: " + cFilAnt)
		
		TAFConout(" #inicio " + DtoS(Date()) + " _ " + Time(),2,.T.,"EXT") 
		MsgJobExt("Início do processamento!")
	EndIf

	MsgJobExt("Processando Extrator...")
	ExtProc(lTAFGST2, cTblTemp )
	MsgJobExt("Fim do processamento...")
	TAFConout(" #fim " + DtoS(Date()) + " _ " + Time(),2,.T.,"EXT")

	
	if !lExtGia
		ClearGlbValue("FISAEXTEXC_TKTEXT")
	endif	
	ClearGlbValue("FISAEXTEXC_DATAEXT")
	ClearGlbValue("FISAEXTEXC_HORAEXT")

Return Nil

/*/{Protheus.doc} fParaSched
	(Função para montar os parametros do Schedule)

	@type Function
	@author Vitor Ribeiro
	@since 09/05/2018

	@Return Nil, nulo, não tem retorno.
	/*/
Static Function fParaSched( lExtGia )

	Local oSX1 := FWSX1Util():New()
	Default lExtGia := .f.

	oSX1:AddGroup("FISAEXTJOB")
	oSX1:SearchGroup()

	TAFConout( "Periodo - Opc: " + cvaltochar( &(oSX1:aGrupo[1, 2, 1]:cX1_Var01) ) + ' - ' + IIF( cvaltochar( MV_PAR01 ) == "1", "Diario", "Mensal" ),2,.F.,"EXT" )

	// Aba Geração 1-Diario ou 2-Mensal
	If MV_PAR01 == 1 .and. MV_PAR02 <> 4
		oWizard:SetDataDe(dDataBase)
		oWizard:SetDataAte(dDataBase)
	Else
		/*
			1 - Considera Data De/Ate
			2 - Primeiro Dia ate Data Corrente
			3 - Mes anterior
		*/
		If MV_PAR02 == 1
			oWizard:SetDataDe(MV_PAR03)
			oWizard:SetDataAte(MV_PAR04)
		ElseIf MV_PAR02 == 2
			oWizard:SetDataDe(FirstDay(dDataBase))
			oWizard:SetDataAte(dDataBase)
		ElseIf MV_PAR02 == 3
			oWizard:SetDataDe(FirstDay(FirstDay(dDataBase)-1))
			oWizard:SetDataAte(LastDay(FirstDay(dDataBase)-1))
		ElseIf MV_PAR02 == 4 // o dia anterior
			oWizard:SetDataDe((dDataBase)-1)
			oWizard:SetDataAte((dDataBase)-1)
		EndIf
	EndIf

	TAFConout( "Data De " + DTOC( oWizard:GetDataDe( ) ) + " Ate " + DTOC( oWizard:GetDataAte( ) ),2,.F.,"EXT" )

	oWizard:SetTipoSaida(AllTrim(cValToChar(MV_PAR05)))
	oWizard:SetDiretorioDestino(MV_PAR06)
	oWizard:SetArquivoDestino(MV_PAR07)

	oWizard:SetFiltraInteg(MV_PAR57)
	oWizard:SetFiltraReinf(MV_PAR58)

	// Aba Movimento
	oWizard:SetTipoMovimento(cValToChar(MV_PAR09))
	oWizard:SetNotaDe(MV_PAR10)
    oWizard:SetNotaAte(MV_PAR11)
    oWizard:SetSerieDe(MV_PAR12)
    oWizard:SetSerieAte(MV_PAR13)
    oWizard:SetEspecie(MV_PAR14)

	// Aba Apuração / SPED
	oWizard:SetApuracaoIPI(cValToChar(MV_PAR15))
	oWizard:SetIncidTribPeriodo(AllTrim(cValToChar(MV_PAR16)))
	oWizard:SetIniObrEscritFiscalCIAP(AllTrim(cValToChar(MV_PAR17)))
	oWizard:SetTipoContribuicao(AllTrim(cValToChar(MV_PAR18)))
	oWizard:SetIndRegimeCumulativo(AllTrim(cValToChar(MV_PAR19)))
	oWizard:SetTipoAtividade(AllTrim(cValToChar(MV_PAR20)))
	oWizard:SetIndNaturezaPJ(MV_PAR21)
	oWizard:SetCentralizarUnicaFilial(AllTrim(cValToChar(MV_PAR22)))
    oWizard:SetServicoCodReceita(MV_PAR23)
    oWizard:SetOutrosCodReceita(MV_PAR24)
    oWizard:SetIndIncidTribut(cValToChar(MV_PAR56))

	// Aba Inventário
    oWizard:SetMotivoInventario(AllTrim(cValToChar(MV_PAR25)))
    oWizard:SetDataFechamentoEstoque(MV_PAR26)
    oWizard:SetReg0210Mov(AllTrim(cValToChar(MV_PAR27)))

	// Aba Financeiro
	oWizard:SetTituReceber(AllTrim(cValToChar(MV_PAR28)))
	oWizard:SetTituPagar(AllTrim(cValToChar(MV_PAR29)))
	oWizard:SetBxReceber(AllTrim(cValToChar(MV_PAR60)))
	oWizard:SetBxPagar(AllTrim(cValToChar(MV_PAR61)))

	// Aba Contribuinte
	oWizard:SetEnviaContribuinte(cValToChar(MV_PAR30))
    oWizard:SetObrigatoriedadeECD(MV_PAR31)
    oWizard:SetClassifTribTabela8(MV_PAR32)
    oWizard:SetAcordoInterIsenMultas(MV_PAR33)
    oWizard:SetNomeContribuinte(MV_PAR34)
    oWizard:SetCpfContribuinte(MV_PAR35)
    oWizard:SetTelContribuinte(MV_PAR36)
    oWizard:SetCelularContribuinte(MV_PAR37)
    oWizard:SetEmailContribuinte(MV_PAR38)
	oWizard:SetEnteFederativo(MV_PAR39)
	oWizard:SetCnpjEnteFederativo(MV_PAR40)
	oWizard:SetIndDesoneracaoCPRB(MV_PAR41)
	oWizard:SetIndSituacaoPj(MV_PAR42)
	oWizard:SetEmail_ContatoReinf(MV_PAR49) 
	oWizard:SetNome_ContatoReinf(MV_PAR50)	
	oWizard:SetCPF_ContatoReinf(MV_PAR51)
	oWizard:SetDDD_ContatoReinf(MV_PAR52)
	oWizard:SetTEL_ContatoReinf(MV_PAR53)
	oWizard:SetDDDCEL_ContatoReinf(MV_PAR54)
	oWizard:SetCEL_ContatoReinf(MV_PAR55)

	// Aba Empresa Software
    oWizard:SetCnpjEmpSoftware(MV_PAR43)	
    oWizard:SetRazaoSocialEmpSoftware(MV_PAR44)
    oWizard:SetContatoEmpSoftware(MV_PAR45)
    oWizard:SetTelEmpSoftware(MV_PAR46)
	oWizard:SetCelEmpSoftware(MV_PAR47)
    oWizard:SetEmailEmpSoftware(MV_PAR48)

	// Seta as filiais para o job
	oWizard:SetJobFiliais()

	// Seta os layouts para o job
	oWizard:SetJobLayouts(MV_PAR01 == 1, cValToChar(MV_PAR59) == '1', lExtGia) 

	// Seta a quantidade de thread's
	oWizard:SetQtdeThread(oFisaExtSx:_MV_EXTQTHR)   

Return Nil

/*/{Protheus.doc} fParaJob
	(Função para montar os parametros do Job)

	@type Function
	@author Vitor Ribeiro
	@since 09/05/2018

	@param a_DocSFT, array, informações do documento na SFT

	@Return Nil, nulo, não tem retorno.
	/*/
Static Function fParaJob(a_DocSFT)

	Default a_DocSFT := {}

	// Aba Geração
	oWizard:SetDataDe(a_DocSFT[6])
	oWizard:SetDataAte(a_DocSFT[6])
	oWizard:SetTipoSaida("2")
	oWizard:SetDiretorioDestino("")
	oWizard:SetArquivoDestino("")
	oWizard:SetFiltraReinf("1")
	oWizard:SetFiltraInteg("3")
	oWizard:SetQtdeThread(0)   // Seta a quantidade de thread's

	// Aba Movimento
	oWizard:SetTipoMovimento("1")
	oWizard:SetNotaDe(a_DocSFT[1])
    oWizard:SetNotaAte(a_DocSFT[1])
    oWizard:SetSerieDe(a_DocSFT[2])
    oWizard:SetSerieAte(a_DocSFT[2])
    oWizard:SetEspecie("")

	// Aba Apuração / SPED
	oWizard:SetApuracaoIPI("0")
	oWizard:SetIncidTribPeriodo("1")
	oWizard:SetIniObrEscritFiscalCIAP("1")
	oWizard:SetTipoContribuicao("")
	oWizard:SetIndRegimeCumulativo("")
	oWizard:SetTipoAtividade("")
	oWizard:SetIndNaturezaPJ("")
	oWizard:SetCentralizarUnicaFilial("1")
    oWizard:SetServicoCodReceita("")
    oWizard:SetOutrosCodReceita("")
    oWizard:SetIndIncidTribut("1")

	// Aba Inventário
    oWizard:SetMotivoInventario("1")
    oWizard:SetDataFechamentoEstoque(dDataBase)
    oWizard:SetReg0210Mov("1")

	// Aba Financeiro
	oWizard:SetTituReceber("1")
	oWizard:SetTituPagar("1")
	oWizard:SetBxReceber("1")
	oWizard:SetBxPagar("1")

	// Aba Contribuinte
    oWizard:SetObrigatoriedadeECD("0")
    oWizard:SetClassifTribTabela8("99")
    oWizard:SetAcordoInterIsenMultas("0")
    oWizard:SetNomeContribuinte("")
    oWizard:SetCpfContribuinte("")
    oWizard:SetTelContribuinte("")
    oWizard:SetCelularContribuinte("")
    oWizard:SetEmailContribuinte("")
	oWizard:SetEnteFederativo("")
	oWizard:SetCnpjEnteFederativo("")
	oWizard:SetIndDesoneracaoCPRB("")
	oWizard:SetIndSituacaoPj("")
	oWizard:SetEmail_ContatoReinf("") 
	oWizard:SetNome_ContatoReinf("")	
	oWizard:SetCPF_ContatoReinf("")
	oWizard:SetDDD_ContatoReinf("")
	oWizard:SetTEL_ContatoReinf("")
	oWizard:SetDDDCEL_ContatoReinf("")
	oWizard:SetCEL_ContatoReinf("")

	// Aba Empresa Software
    oWizard:SetCnpjEmpSoftware("")
    oWizard:SetRazaoSocialEmpSoftware("")
    oWizard:SetContatoEmpSoftware("")
    oWizard:SetTelEmpSoftware("")    
	oWizard:SetCelEmpSoftware("")
	oWizard:SetEmailEmpSoftware("")
	
	// Seta as filiais para o job
	oWizard:SetJobFiliais()

	// Seta os layouts para o job
	oWizard:SetJobLayouts(.T.)

Return Nil

/*/{Protheus.doc} ExtProc
	(Realiza o Processamento da geracao do Arquivo TXT com as informacoes do protheus)

	@Type Static Function
	@author Rodrigo Aguilar
	@since 20/03/2013

	@return Nil, nulo, não tem retorno
	/*/
Static Function ExtProc(lTAFGST2, cTblTemp)
	
Local cFilBkp := ""
Local cFilCent := ""
Local cSemaphore := "EXTRATOR"	// Semaforo das multithreads 
Local cKeyCent	:=	""

Local nCountFil := 0
Local nCountArq := 0
Local nCount := 0
Local nHdlTot := 0
Local nHdlAux := 0
Local nHdlT007 := 0
Local nHdlT003 := 0
Local nQtdThr := 0
Local nCountJob := 0
Local nPosicao := 0
Local aArquivos := {}
Local aParticip := {}
Local aProdutos := {}
Local aRegT022AB := {}
Local aVlrMovST := {}
Local aIcmPago := {}
Local aLanCDA2 := {}
Local aWizFin := {}
Local aWizSped := {}
Local aJobContr := {}	// Array para controle das threads
Local aGerT013J := {}
Local aDirSystem := {}
Local aListT003 := {}
Local oMTProc := Nil	// Objeto de Processamento em MT.
Local cNew	:= "HMNew()"  // é necessário dessa forma pois a Build do Robô não tem a build atualizada

Local lContinua := .T.
Local lMThr := .F. 
Local lMultiThr := .F.
Local lRegXThr := .F.
Local lTabComp := .F. 
Local lGerouT013 := .F.
Local cTabInteg := "|"
Local cTabsTaf := SuperGetMv( "MV_TAFCMPT", .F., "" )
Local lPartComp := At("C1HCCC", cTabsTaf)>0 .Or. At("C1HECC", cTabsTaf)>0 .Or. At("C1HEEC", cTabsTaf)>0
Local lProdComp := At("C1LCCC", cTabsTaf)>0 .Or. At("C1LECC", cTabsTaf)>0 .Or. At("C1LEEC", cTabsTaf)>0
Local cDir := GetSrvProfString("StartPath","\undefined")
Local nWeb := GETREMOTETYPE()

Default lTAFGST2 := oFisaExtSx:_MV_TAFGST2 
Default cTblTemp := ''

// Armazena todos os nomes de arquivos que são gerados durante o processamento do arquivo principal 
Private aArqGer := {}
Private aDadosST1 := {}
 
Private cTpSaida := "3"	// Nativo
Private cST1Alias := ""
Private cST2Alias := ""
Private cXERPAlias := ""
Private cFilProc := ""
Private cDirSystem := ""

Private lGerFilial := .T.
Private lGerFilPar := .F.
Private oHashT003 := nil
Private oHashT007 := nil
Private oTempTab := Nil

Private cExtUser	:= AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" ))   
If Type("lTemC1E") <> "L"
	Private lTemC1E := &(GetGlbValue("FISAEXTEXC_LTEMC1E"))
endif

if lJob
	lFiltReinf 	:= ( cValToChar( oWizard:GetFiltraReinf()) == "1" )
	cFiltInt 	:= ( cValToChar( oWizard:GetFiltraInteg() ) )
endif

If lBuild
    oHashT003 := &cNew
	oHashT007 := &cNew
EndIf

/* 
	Se o parametro tiver sido preenchido apenas com uma tabela e sem o pipe no final,
    insiro o pipe para que a função fTafTabInt( ) funcione corretamente.
*/	
If !Empty( cTabsTaf ) .and. !( "|" $ cTabsTaf )
	cTabsTaf += "|"
EndIf

/*
	Para integracao Nativa que correponde a incluir uma Nota Fiscal no ERP chamando
	via job o Extrator para incluir esta nota na TAFST1. Desligo o MultiThr.
*/
If !lDocSFT 
	// Quantidade de Threads
	nQtdThr := oFisaExtSx:_MV_EXTQTHR
EndIf

// VerIfica se o banco possui alguma exceção
fExceBanco(@nQtdThr)

// VerIfica se é Multi Thread
lMultiThr := IIf(nQtdThr > 1,.T.,.F.)

cTpSaida := oWizard:GetTipoSaida()

// Arquivo TXT
If cTpSaida == "1"
    lContinua := fMakeATxt(@nHdlTot)
ElseIf cTpSaida == "2"  // Banco de dados
    lContinua := fConectBnc(lTAFGST2)
EndIf

// Se conseguiu conectar no banco ou criar o arquivo txt
If lContinua
	// Monta a wizard para as funções do financeiro
	aWizFin := fMakeWFin()

	// Monta a wizard para as funções do sped
	aWizSped := fMakeWSped()

    // Guarada Filial Corrente da Rotina
    cFilBkp := cFilAnt

    cTimeIni := Time()
    TAFConout("***********" + cTimeIni,2,.T.,"EXT")

	If lFiltReinf // Não permito multthread, pois seria necessário tratar de forma diferente os registros de cadastro.
		lMultiThr := .F.
	EndIf

	// Se for multi thread e o registro T013 foi selecionado ou está relacionado
	If lMultiThr .And. oWizard:LayoutSel("T013")
		oMTProc := FWIPCWait():New(cSemaphore,100000)
		oMTProc:SetThreads(nQtdThr*2) // Multiplico por 2 para quebrar entradas e saidas.
		oMTProc:SetEnvironment(FWGrpCompany(),FWCodFil())
		oMTProc:Start("RegT013")
	Else
		lMultiThr := .F.
	EndIf
	cFilCent := cFilAnt  
    //Passo por todas as filiais selecionadas para processamento chamando
    //a execução dos layouts existentes para processamento
    For nCountFil := 1 To Len(oWizard:aFiliais)
		// Se a filial estiver marcado
		If oWizard:aFiliais[nCountFil][1] == _MARK_OK_
			// Variavel para indicar se gerou algum layout para filial. 
			lGerFilial := .T.

			// Variavel para indicar se a filial gerou parcial.
			lGerFilPar := .F.  

			cFilAnt := oWizard:aFiliais[nCountFil][2] 
			cFilProc := oWizard:aFiliais[nCountFil][2] 
			
			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,2,"",0)

			fMsgPrcss("Gerando Arquivo Magnético - Filial " + cFilAnt)

			// Geração via arquivo texto
			If cTpSaida == "1" 
				// Realizando a criacao dos Diretorios na Root Path
				cDirSystem := fMakeDirS()

				// Tratamento para quando ocorre algum erro na criacao dos diretorios no System
				If Empty(cDirSystem)
					Exit
				EndIf
			EndIf

			// Função para executar o layout T001
			fLayT001()
			
			// Se o layout T001AB foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T001AB"))
				// Função para executar o layout T001AB
				fLayT001AB(aWizFin)
			EndIf

			// Se o layout T001AC foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T001AC"))
				// Função para executar o layout T001AC
				fLayT001AC()

				lMThr := .T.
			EndIf

			// Se o layout T001AD foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T001AD"))
				// Função para executar o layout T001AD
				fLayT001AD()

				lMThr := .T.
			EndIf

			// Se o layout T001AE foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T001AE")) 
				// Função para executar o layout T001AE
				fLayT001AE()

				lMThr := .T.
			EndIf

			// Se o layout T001AK foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T001AK"))
				// Função para executar o layout T001AK
				fLayT001AK()

				lMThr := .T.
			EndIf

			// Se o layout T001AL foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T001AL"))
				// Função para executar o layout T001AL
				fLayT001AL()

				lMThr := .T.
			EndIf

			// Se o layout T002 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T002"))
				// Função para executar o layout T002
				fLayT002()
			EndIf

			// Se o layout T003 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T003"))
				
				if !( ( AllTrim( "SA1" + xFilial( "SA1" ) ) ) $ cTabInteg )
					// Função para executar o layout T003
					fLayT003(@nHdlT003,@aParticip,,aWizFin, "SA1", @aListT003 )
					lMThr := .T.
					/*
						As tabelas SA1 e SA2 são integradas a uma única tabela do lado do TAF ( C1H ).
						Se elas estiverem com a mesma configuração de compartilhamento no lado do Protheus ( cfgTabT003() ), 
						valido se a configuração do TAF também é igual ( fTafTabInt ).
						Caso sejam iguais entre TAF e Protheus, foi escolhido a tabela SA1 para controlar a integração das tabelas desse registro T003.
					*/
					If (!Empty( cTabsTaf ) .and. cfgTabT003( ) )
						fTafTabInt( "C1H", "SA1", cTabsTaf, @cTabInteg )
					EndIf
				EndIf
			EndIf

			// Se o layout T005 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T005"))
				
				if !( ( AllTrim( "SAH" + xFilial( "SAH" ) ) ) $ cTabInteg )
					// Função para executar o layout T005
					fLayT005()
					lMThr := .T.

					If !Empty( cTabsTaf )
						fTafTabInt( "C1J", "SAH", cTabsTaf, @cTabInteg )
					EndIf
				EndIf
			EndIf

			// Se o layout T007 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T007"))
				if !( ( AllTrim( "SB1" + xFilial( "SB1" ) ) ) $ cTabInteg )
					// Função para executar o layout T007
					fLayT007(@nHdlT007,@aProdutos,"")
					lMThr := .T.

					If (!Empty( cTabsTaf ))
						fTafTabInt( "C1L", "SB1", cTabsTaf, @cTabInteg )
					EndIf
				EndIf
			EndIf

			// Se o layout T009 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T009"))
				// Função para executar o layout T009
				fLayT009()

				lMThr := .T.
			EndIf

			// Se o layout T010 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T010"))

				if !( ( AllTrim( "CT1" + xFilial( "CT1" ) ) ) $ cTabInteg )
					
					// Função para executar o layout T010
					fLayT010()
					lMThr := .T.

					If !Empty( cTabsTaf )
						fTafTabInt( "C1O", "CT1", cTabsTaf, @cTabInteg )
					EndIf

				EndIf
			EndIf

			// Se o layout T011 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T011"))
				
				if !( ( AllTrim( "CTT" + xFilial( "CTT" ) ) ) $ cTabInteg )

					// Função para executar o layout T011
					fLayT011()
					lMThr := .T.

					If !Empty( cTabsTaf )
						fTafTabInt( "C1P", "CTT", cTabsTaf, @cTabInteg )
					EndIf

				EndIf	

			EndIf

			// Se o layout T013 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T013") .or. lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				// Função para executar o layout T013 
				fLayT013(oMTProc,nQtdThr,lMultiThr,@lRegXThr,lTAFGST2,@aJobContr,@aRegT022AB,@aVlrMovST,@aIcmPago,@aLanCDA2,@aGerT013J,@aParticip,@aProdutos,cTblTemp)

				lMThr := .T.
			Else
				lMultiThr := .F.
			EndIf

			// Se o layout T035 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T035") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				// Função para executar o layout T035
				fLayT035()

				lMThr := .T.
			EndIf

			// Se o layout T045 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T045") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				// Função para executar o layout T045
				fLayT045(@nHdlT003,@nHdlT007,@aProdutos,@aParticip)

				lMThr := .T.
			EndIf

			// Se o layout T065 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T065") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				// Função para executar o layout T065
				fLayT065()

            	lMThr := .T.
        	EndIf

			// Se o layout T072 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T072") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				// Função para executar o layout T072
				fLayT072()

				lMThr := .T.
			EndIf

			// Se o layout T078 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T078") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				// Função para executar o layout T078
				fLayT078()

				lMThr := .T.
			EndIf

			// Se os layouts T082 foram selecionados ou estão relacionados
			If (oWizard:LayoutSel("T082") .Or. lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				// Função para executar o layout T082
				fLayCPRB()

				lMThr := .T.
			EndIf

        
			// Quando o processamento é centralizado apenas executo a apuração para quando a filial seja igual a centralizadora
			If oWizard:GetCentralizarUnicaFilial() == '1' .Or. cFilCent == cFilAnt
				lTabComp := .F.
				lTabCDT  := .F.
				lTabCD0  := .F.
				lIntTMS  := .F.
				lCmpsVld := .F.
				lTabCE5  := .F.
				lTabCD1  := .F.
				cKeyCent := iif(oWizard:GetCentralizarUnicaFilial() == '2',oWizard:aFiliais[nCountFil][4],"" )
				// Funcao de Inicializacao do Ambiente Fiscal/Apuração
				SPEDOpenEnv(@lTabComp,@lTabCDT,@lTabCD0,@lIntTMS,@lCmpsVld,@lTabCE5,@lTabCD1)
				
				// Se os layouts T020|T021|T022 foram selecionados ou estão relacionados				
				If !lFiltReinf .and. (oWizard:LayoutSel("T020") .Or. oWizard:LayoutSel("T021") .Or. oWizard:LayoutSel("T022") ) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
					// Função para executar o layout T082
					fLayApura(aWizSped,@aRegT022AB,aVlrMovST,aIcmPago,aLanCDA2,lTabComp, oWizard,cKeyCent)

					lMThr := .T.
				EndIf

				// Se o layout T066 foi selecionado ou está relacionado
				If (oWizard:LayoutSel("T066") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
					// Função para executar o layout T066
					fLayT066(aWizSped,lTabComp)

					lMThr := .T.
				EndIf

				// Se o layout T067 foi selecionado ou está relacionado
				If (oWizard:LayoutSel("T067") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
					// Função para executar o layout T067
					fLayT067(aWizSped)

					lMThr := .T.
				EndIf

				// Se o layout T079 foi selecionado ou está relacionado
				If (oWizard:LayoutSel("T079") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
					// Função para executar o layout T079
					fLayT079(aWizSped)

					lMThr := .T.
				EndIf
			EndIf

			// Se o layout T080 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T080") .and. !lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				// Função para executar o layout T080
				fLayT080()

				lMThr := .T.
			EndIf

			if lCCF_TRIB .and. lFKGCALCUL
				// Se o layout T154 foi selecionado ou está relacionado
				If (oWizard:LayoutSel("T154")  .or. lFiltReinf) .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
					// Função para executar o layout T154
					fLayT154(aWizFin, @aParticip)
				EndIf
			elseif !lCCF_TRIB .and. !lFKGCALCUL
				TAFConout("Não é possível processar o layout T154 por falta dos campos CCF_TRIB e FKG_CALCUL",3,.T.,"EXT")
			elseif !lCCF_TRIB 
				TAFConout("Não é possível processar o layout T154 por falta dos campo CCF_TRIB",3,.T.,"EXT")
			elseif !lFKGCALCUL 
				TAFConout("Não é possível processar o layout T154 por falta do campo FKG_CALCUL",3,.T.,"EXT")
			endif 

			// Se o layout T157 foi selecionado ou está relacionado
			If (oWizard:LayoutSel("T157"))
				// Função para executar o layout T157
				fLayT157()
			EndIf

			// Consolidação dos arquivos
			If cTpSaida == "1" // "Arquivo texto"
				Aadd(aDirSystem,cDirSystem)
			EndIf

			If !Empty(aGerT013J)
				aGerT013J[Len(aGerT013J)][2] := lGerFilial
				aGerT013J[Len(aGerT013J)][3] := lGerFilPar
			EndIf

			If lGerFilial		// Filial não gerou nenhum layout selecionado
				// Atualiza a tela de processamento
				FisaExtW01(cFilProc,1,"",0)
			ElseIf lGerFilPar	// Filial gerou parcialmente os layouts selecionados
				// Atualiza a tela de processamento
				FisaExtW01(cFilProc,3,"",0)
			Else				// Filial gerou todos os layouts selecionados
				// Atualiza a tela de processamento
				FisaExtW01(cFilProc,4,"",0)
			EndIf
		EndIf

		// Se estiver ok para execução do finaceiro e existir a função
		If lFFinExtOK .And. FindFunction("FFinExtFim")
			/*
				Função para finalizar o alias do financeiro
				Inicializado nas funções FExpT001AB, FExpT003, FExpT154, FExpT157
			*/
			FFinExtFim()
		EndIf
		
		If !lPartComp // gravo no laço nas filiais, pois o compartilhamento da tabela é exclusivo
			// Grava todo os participantes no TXT
			For nCount := 1 to Len(aParticip)
				FConcTxt(aParticip[nCount],nHdlT003)
				
				// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1
				If cTpSaida == "2"
					FConcST1()
				EndIf
			Next			

			//Fecha o Handle do registro T003
			FClose(nHdlT003)
			nHdlT003 := 0
			aParticip := {}
			ASize(aParticip,0)
			If lBuild
				FreeObj(oHashT003)
				oHashT003 := NIL
				oHashT003 := &cNew
			EndIf
		EndIf
		
		If !lProdComp	// gravo no laço nas filiais, pois a tabela está exclusiva

			// Grava todo os produtos no TXT se bloco K não estiver selecionado
			For nCount := 1 to Len(aProdutos)
				FConcTxt(aProdutos[nCount],nHdlT007)
				
				// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
				If cTpSaida == "2"
					FConcST1()
				EndIf
			Next

			//Fecha o Handle do registro T007
			FClose(nHdlT007)
			nHdlT007 := 0
			aProdutos := {}
			ASize(aProdutos,0)
			If lBuild
				FreeObj(oHashT007)
				oHashT007 := NIL
				oHashT007 := &cNew
			EndIf
		EndIf

    Next // Final do laço das filiais

    // Volto para a filial Original da Rotina
    cFilAnt := cFilBkp
	
	If lPartComp // gravo no final do laço nas filiais, pois as tabelas estão compartilhadas.

		// Grava todo os participantes no TXT
		For nCount := 1 to Len(aParticip)
			FConcTxt(aParticip[nCount],nHdlT003)
			
			// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1
			If cTpSaida == "2"
				FConcST1()
			EndIf
		Next			

		//Fecha o Handle do registro T003
		FClose(nHdlT003)
		nHdlT003 := 0
		aParticip := {}
		ASize(aParticip,0)
		If lBuild
			FreeObj(oHashT003)
			oHashT003 := NIL
		EndIf
	EndIf

	If lProdComp // gravo no final do laço nas filiais, pois as tabelas estão compartilhadas.

		// Grava todo os produtos no TXT se bloco K não estiver selecionado
		For nCount := 1 to Len(aProdutos)
			FConcTxt(aProdutos[nCount],nHdlT007)
			
			// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
			If cTpSaida == "2"
				FConcST1()
			EndIf
		Next

		//Fecha o Handle do registro T007
		FClose(nHdlT007)
		nHdlT007 := 0
		aProdutos := {}
		ASize(aProdutos,0)
		If lBuild
			FreeObj(oHashT007)
			oHashT007 := NIL
		EndIf
	EndIf

    // Se for execução em multithread
    If lMultiThr

		// Atualiza a tela de processamento
		FisaExtW01(cFilAnt,0,"T013",2)

		fMsgPrcss("Multi Thread em processamento T013 - Documentos Fiscais...")

		if len(aJobContr) > 0 
			// Enquanto tiver um job executando
			While Ascan(aJobContr,{|x| x[2] == .T. }) > 0 .And. !KillApp()
				For nCountJob := 1 To Len(aJobContr)
					// Se ainda estiver processando
					If aJobContr[nCountJob][2] .and. ( GetGlbValue(aJobContr[nCountJob][1]) $ "4|9" ) // Se terminou o processamento
						TAFConout(Replicate('-',65),2,.T.,"EXT")
						TAFConout("EXTRATOR: JOB FINALIZADO( " + GetGlbValue(aJobContr[nCountJob][1] ) + " ) : " + aJobContr[nCountJob][1] + " -> Thread: " + StrZero(nCountJob,6),2,.T.,"EXT")
						ClearGlbValue(aJobContr[nCountJob][1])
						aJobContr[nCountJob][2] := .F.
					EndIf
				Next
			EndDo
		endif

		For nCountJob := 1 To Len(aGerT013J)
			lGerouT013 := .F.

			if Len(aGerT013J[nCountJob][4]) > 0
				For nCount := 1 To Len(aGerT013J[nCountJob][4])
					If GetGlbValue(aGerT013J[nCountJob][4][nCount]) == "1"
						lGerouT013 := .T.
					EndIf

					ClearGlbValue(aGerT013J[nCountJob][4][nCount])
				Next

				If lGerouT013
					If aGerT013J[Len(aGerT013J)][2] .Or. aGerT013J[Len(aGerT013J)][3]
						// Atualiza a tela de processamento
						FisaExtW01(aGerT013J[nCountJob][1],3,"T013",3)
					Else
						// Atualiza a tela de processamento
						FisaExtW01(aGerT013J[nCountJob][1],4,"T013",3)
					EndIf
				Else
					If aGerT013J[Len(aGerT013J)][2]
						// Atualiza a tela de processamento
						FisaExtW01(aGerT013J[nCountJob][1],1,"T013",1)
					Else
						// Atualiza a tela de processamento
						FisaExtW01(aGerT013J[nCountJob][1],3,"T013",1)
					EndIf
				EndIf
			endif	
		Next

        If lRegXThr	
            TAFConout("Parando as threads" + TIME(),2,.T.,"EXT")
        EndIf
        
        If ValType(oMTProc) == "O"
			fMsgPrcss("Finalizando a Multi Thread...")
			
            oMTProc:Stop()
            FreeObj(oMTProc)
            oMTProc := NIL
        EndIf

        If lRegXThr
            TAFConout("Depois DO STOP" + TIME(),2,.T.,"EXT")
        EndIf
    EndIf

    TAFConout(Replicate("=",30),2,.T.,"EXT")

    If !Empty(cHorIni)
        TAFConout(" TEMPO DO T013 " + ElapTime(cHorIni,Time()),2,.T.,"EXT")
    EndIf

    TAFConout(Replicate("=",30),2,.T.,"EXT")

    If cTpSaida == "2"
        If lTAFGST2 .And. Select(cST2TAB) > 0
            (cST2TAB)->(DbCloseArea())
        ElseIf Select(cST1TAB) > 0
            (cST1TAB)->(DbCloseArea())
        EndIf

		lConectado := .F.
    EndIf

	If !Empty(aDirSystem)
		For nCount := 1 To Len(aDirSystem)
			aArquivos := Directory(aDirSystem[nCount] + "\*.txt")
			aSort(aArquivos,,,{|X, Y| X[1] < Y[1]})

			For nCountArq := 1 to Len(aArquivos)
				fMsgPrcss("Gerando arquivo de final. Processando[" + aArquivos[nCountArq][1] + "].")
				
				If aArquivos[nCountArq][2] > 0						
						nHdlAux := FT_FUse(aDirSystem[nCount] + "\" + aArquivos[nCountArq][1])				
						FT_FGoTop()
						
						While !FT_FEof() .And. nHdlAux <> -1
							cStrTxt := FT_FReadLn()
							cStrTxt += CRLF

							FisaExtX07(nHdlTot,@cStrTxt)
							
							FT_FSkip()
						EndDo
						FisaExtF07(nHdlTot, cStrTxt)
						FT_FUse()
				EndIf
			Next
		Next

        FClose(nHdlTot)
	EndIf

	fMsgPrcss("Encerrando o processamento...")

	if nWeb == 5
		 if CpyS2TW(cDir + AllTrim(oWizard:GetArquivoDestino()) + ".txt", .T.) == 0
		 	FERASE(cDir + AllTrim(oWizard:GetArquivoDestino()) + ".txt")
		 endIf
	endif

    TAFConout("INICIO " + cTimeIni,2,.F.,"EXT")
    TAFConout("FIM " + Time(),2,.F.,"EXT")

    // Controle do cancelamento da rotina
    If lJob
        MsgJobExt( "Processamento Finalizado!" )
    Else
		fMsgPrcss("Processamento finalizado com Sucesso!")
    EndIf
EndIf

// Atualiza a tela
FisaExtW02()

if oWizard:GetTipoSaida() == '2' .and. !lJob .And. lTemC1E .and. MsgYesNo("Deseja abrir a Interface de Processamento do Módulo TAF?") 
	TAFA428()
	
	if lFiltReinf
		//Verifica se todos os parâmetros e configurações estão preenchidos
		If FindFunction('lCfgPainelTAF') .and. lCfgPainelTAF("B")
			if MsgYesNo("Deseja abrir o Painel REINF?")
				TAFA552B() 
			endif
		Endif
	else
		if MsgYesNo("Deseja abrir a central de obrigações do Módulo TAF?") 
			TAFOBRIG()
		endif  
	endif
endif

Return Nil

/*/{Protheus.doc} fMakeATxt
	(Função para criar o arquivo txt)

	@type Static Function
	@author Vitor Ribeiro
	@since 08/05/2018

	@return !Empty(n_Handle), logico, não tem retorno
	/*/
Static Function fMakeATxt(n_Handle)

    Local cFileDest	 := ""
    Local cDirDest	 := ""
	Local cDir := ""
	Local nRemType := GetRemoteType()
	Local cDir := GetSrvProfString("StartPath", "\undefined")
    Default n_Handle := 0

    // Carrego as Variaveis com as Informacoes passadas na Wizard ou do parametro para importacao
    cDirDest :=	AllTrim(oWizard:GetDiretorioDestino())

    // Tratamento para Linux onde a barra eh invertida
    If nRemType == 2
        If !Empty(cDirDest) .And. SubStr(cDirDest,Len(cDirDest),1) <> "/"
            cDirDest +=	"/"
        EndIf
    Else
        If !Empty(cDirDest) .And. SubStr(cDirDest,Len(cDirDest),1) <> "\"
            cDirDest +=	"\"
        EndIf
    EndIf

    // Monto nome do Arquivo que sera gerado
    If !lJob .Or. !Empty(oWizard:GetArquivoDestino())
        cFileDest := cDirDest + AllTrim(oWizard:GetArquivoDestino())
    Else
        If FwMakeDir(cDirDest)
            cFileDest := cDirDest + StrTran(AllTrim(cEmpAnt)," ","") + "_" + StrTran(AllTrim(cFilAnt)," ","") + "_" + DToS(dDataBase) + "_" + StrTran(AllTrim(Time()),":","")
            
            // Tratamento para a extensao do arquivo destino
            If Upper(Right(Alltrim(cFileDest),4)) <> ".TXT"
                cFileDest := (cFileDest + ".TXT")
            EndIf
        Else    // Caso nao seja possivel criar o diretorio sera gravada informacao do erro do Server via ConOut
            MsgJobExt( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
        EndIf
    EndIf

    // Tratamento para a extensao do arquivo destino
    If Upper( Right( Alltrim( cFileDest ), 4 ) ) <> ".TXT"
        cFileDest := ( cFileDest + ".TXT" )
    EndIf

	if !lJob
		if nRemType == 5 
			n_Handle := MsFCreate( cDir + AllTrim(oWizard:GetArquivoDestino()) + ".txt" )
		Else
			n_Handle := MsFCreate( cDirDest + AllTrim(oWizard:GetArquivoDestino()) + ".txt" )
		EndIF
	else //Tratamento P/ JOB
		//cDir := GetSrvProfString("StartPath", "\undefined")
		if cDir <> "\undefined"
			cDir := StrTran( cDir + "\jobextfiscal\" , "\\" , "\" )
			MakeDir(cDir)
			n_Handle   := MsFCreate( cDir + "tmp" + DToS( Date() ) + "_" + StrTran(Time(),":","") + ".txt" )
		endif
	endif

Return !Empty(n_Handle)


/*/{Protheus.doc} fMakeDirS
	(Esta Funcao cria os diretorios na rootPath) 

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return cDiretorio, caracter, diretorio criado
	/*/
Static Function fMakeDirS()

	Local cDiretorio := "\Extrator_TAF"

    Local nRetDir := 0

	If !File(cDiretorio)
		nRetDir := MakeDir(cDiretorio)

		If !Empty(nRetDir)
			cDiretorio := ""
		EndIf
	EndIf

	If !Empty(cDiretorio)
		cDiretorio += "\" + Alltrim(DToS(oWizard:GetDataDe()) ) + "_" + Alltrim(DToS(oWizard:GetDataAte()))

		If !File(cDiretorio)
			nRetDir := MakeDir(cDiretorio)

			If !Empty(nRetDir)
				cDiretorio := ""
			EndIf
		EndIf
	EndIf

	If !Empty(cDiretorio)
		cDiretorio += "\" + StrTran( Alltrim( cFilAnt ), " ", "")
		
		If !File(cDiretorio)
			nRetDir := MakeDir(cDiretorio)

			If !Empty(nRetDir)
				cDiretorio := ""
			EndIf
		EndIf
	EndIf

	If Empty(cDiretorio) ;If lJob ;TAFConout( "EXTFISXTAF.PRW: " + DToS( Date() ) + "-" + Time() + "-" + OemToAnsi("Não foi possível criar o diretório. Erro: " + cValToChar( FError() )),3,.T.,"EXT") ; Else
			Help( ,,"CRIADIR",, "Não foi possível criar o diretório!" + CRLF + CRLF + "Não será possivel a extrair via txt. Erro: " + cValToChar( FError() ) , 1, 0 )
		EndIf
	EndIf

	// Função para limpar arquivos do diretorio para não gerar suzeira em uma nova extração
	fLimpaDir(cDiretorio,"txt","*")

Return cDiretorio

/*/{Protheus.doc} fLimpaDir
	(Função para limpar arquivos do diretorio para não gerar suzeira em uma nova extração)

	@type Static Function
	@author Vitor Ribeiro
	@since 03/07/2018

	@param c_Dir, caracter, diretorio que será limpo, obrigatorio
	@param c_Ext, caracter, extensão a ser excluido, opcionaL, Default extensão TXT
	@param c_Arq, caracter, nome do arquivo a ser excluido, opcional, Default todos os arquivos *

	@return Nil, Nulo, não tem retorno
	/*/
Static Function fLimpaDir(c_Dir,c_Ext,c_Arq)

	Local aArquivos := {}

	Default c_Dir := ""
	Default c_Ext := "txt"
	Default c_Arq := "*"

	// Se foi passado um arquivo
	If !Empty(c_Dir)
		// Ajusta o diretorio
		c_Dir := AllTrim(c_Dir)

		If SubStr(c_Dir,Len(c_Dir),1) <> cBarraUnix
			c_Dir += cBarraUnix
		EndIf

		// Ajusta a extensão
		c_Ext := AllTrim(c_Ext)

		If SubStr(c_Ext,1,1) <> "."
			c_Ext := "." + c_Ext
		EndIf

		// Lista os registros
		aArquivos := Directory(c_Dir + c_Arq + c_Ext)

		// Exclui todos os arquivos
		Aeval(aArquivos,{|x| FErase(c_Dir + x[1]) })
	EndIf
	
return Nil

/*/{Protheus.doc} fConectBnc
	(Função para conectar nas tabelas de extração (TAFST1 e TAFST2))

	@type Static Function
	@author Vitor Ribeiro
	@since 08/05/2018

	@param l_TAFGST2, logico, se gera a TAFST2 no lugar da TAFST1

	@return lContinua, logico, se continua a execução
	/*/
Static Function fConectBnc(l_TAFGST2)

	Local aTABDados := {}
    Local aTabConf := {}
    Local aPar := {}
    Local aErros := {}

    Local cTCBuild := ""
    Local cTopBuild := ""
    Local cAlsST := ""

    Local nHdlTaf := 0

    Local lContinua := .F.

	Default l_TAFGST2 := .F. 

	cAlsST := IIf(l_TAFGST2,"TAFST2","TAFST1")

	If Select(cAlsST) > 0
		lConectado := .T.
	EndIf

	If !lConectado
		// Nome da funcao para verIficao da Build
		cTCBuild := "TCGetBuild"

		DbUseArea(.T.,"TOPCONN",cAlsST,cAlsST,.T.,.F.) //Abre Exclusivo
		
		If Select(cAlsST) > 0
			lContinua := .T.
		Else
			If lJob
				MsgJobExt("Não foi encontrada e/ou não foi possivel a abertura Exclusiva da tabela " + cAlsST + " no mesmo Ambiente de ERP!")
			Else
				MsgAlert("Não foi encontrada e/ou não foi possivel a abertura Exclusiva da tabela " + cAlsST + " no mesmo Ambiente de ERP!")
			EndIf
		EndIf
	
		If lContinua
			lConectado := .T.
		EndIf
	EndIf

Return lContinua

/*/{Protheus.doc} fMsgPrcss
	(Função para mensagem de processo)

	@type Static Function
	@author Vitor Ribeiro
	@since 08/05/2018

	@Param c_Mensagem, caracter, mensagem para o job ou process

	@return Nil, nulo, não tem retorno
	/*/
Static Function fMsgPrcss(c_Mensagem)

	Default c_Mensagem := ""

	If lJob
		MsgJobExt(c_Mensagem)
	Else
		// Incrementa valores na régua de progressão
		IncProc(c_Mensagem)
		
		// Minimiza o efeito de 'congelamento' da aplicação durante a execução de um processo longo forçando o refresh do Smart Client
		ProcessMessages()
	EndIf
	
Return Nil

/*/{Protheus.doc} fMakeWFin
	(Monta a wizard para as funções do financeiro)

	@type Static Function
	@author Vitor Ribeiro
	@since 08/05/2018

	@return aWizFin, array, retorna a Wizard do financeiro
	/*/
Static Function fMakeWFin()

	Local aWizFin := {}

	Local nPosicao := 0

	// Aba 1
	Aadd(aWizFin,{})
	nPosicao := Len(aWizFin)

	Aadd(aWizFin[nPosicao],oWizard:GetTituReceber())
	Aadd(aWizFin[nPosicao],oWizard:GetDataDe())
	Aadd(aWizFin[nPosicao],oWizard:GetDataAte())
	Aadd(aWizFin[nPosicao],oWizard:GetNotaDe())
	Aadd(aWizFin[nPosicao],oWizard:GetNotaAte())

	// Aba 2
	Aadd(aWizFin,{})
	nPosicao := Len(aWizFin)

	Aadd(aWizFin[nPosicao],oWizard:GetTituPagar())
	Aadd(aWizFin[nPosicao],oWizard:GetDataDe())
	Aadd(aWizFin[nPosicao],oWizard:GetDataAte())
	Aadd(aWizFin[nPosicao],oWizard:GetNotaDe())
	Aadd(aWizFin[nPosicao],oWizard:GetNotaAte())

	// Aba 3
	Aadd(aWizFin,{})
	nPosicao := Len(aWizFin)

	Aadd(aWizFin[nPosicao],oWizard:GetBxReceber())
	Aadd(aWizFin[nPosicao],oWizard:GetDataDe())
	Aadd(aWizFin[nPosicao],oWizard:GetDataAte())
	Aadd(aWizFin[nPosicao],oWizard:GetNotaDe())
	Aadd(aWizFin[nPosicao],oWizard:GetNotaAte())

	// Aba 4
	Aadd(aWizFin,{})
	nPosicao := Len(aWizFin)

	Aadd(aWizFin[nPosicao],oWizard:GetBxPagar())
	Aadd(aWizFin[nPosicao],oWizard:GetDataDe())
	Aadd(aWizFin[nPosicao],oWizard:GetDataAte())
	Aadd(aWizFin[nPosicao],oWizard:GetNotaDe())
	Aadd(aWizFin[nPosicao],oWizard:GetNotaAte())	

Return aWizFin

/*/{Protheus.doc} fMakeWSped
	(Monta a wizard para as funções do sped)

	@type Static Function
	@author Vitor Ribeiro
	@since 08/05/2018

	@return aWizSped, array, retorna a Wizard do sped
	/*/
Static Function fMakeWSped()

	Local aWizSped := {}

	Local nPosicao := 0

	/*
		ATENÇÃO
		A Wizard do SPED está montada no modelo antigo da wizard do extrator.
		Isso porque os fontes do SPED já possui alteração para funcionar conforme o modelo do extrator.
		Nao quis mudar isso no momento para não ser muitas alterações de um vez.
		Mas o ideal seria rever esse detalhe.
	*/

	// Aba 1 - Parâmetros para geração
	Aadd(aWizSped,{})
	nPosicao := Len(aWizSped)

	Aadd(aWizSped[nPosicao],oWizard:GetDiretorioDestino())				// 01 - Diretório do Arquivo Destino
	Aadd(aWizSped[nPosicao],oWizard:GetArquivoDestino() + "_SPED.txt")	// 02 - Nome do Arquivo Destino
	Aadd(aWizSped[nPosicao],oWizard:GetDataDe())						// 03 - Data de
	Aadd(aWizSped[nPosicao],oWizard:GetDataAte())						// 04 - Data Ate
	Aadd(aWizSped[nPosicao],"1")										// 05 - Seleciona Filiais
	Aadd(aWizSped[nPosicao],oWizard:GetApuracaoIPI())					// 06 - Periodo da apuração de IPI
	Aadd(aWizSped[nPosicao],oWizard:GetIncidTribPeriodo())				// 07 - Incidencia tributaria no periodo
	Aadd(aWizSped[nPosicao],oWizard:GetIniObrEscritFiscalCIAP())		// 08 - Inicio Obrigação Escrituração Fiscal CIAP
	Aadd(aWizSped[nPosicao],"1")										// 09 - Seleciona Layouts
	Aadd(aWizSped[nPosicao],oWizard:GetTipoSaida())						// 10 - Tipo de saida
	Aadd(aWizSped[nPosicao],oWizard:GetNotaDe())						// 11 - Nota Fiscal de
	Aadd(aWizSped[nPosicao],oWizard:GetNotaAte())						// 12 - Nota Fiscal Ate
	Aadd(aWizSped[nPosicao],oWizard:GetTipoContribuicao())				// 13 - Tipo Contribuição
	Aadd(aWizSped[nPosicao],oWizard:GetIndRegimeCumulativo())			// 14 - Indicador regime cumulativo
	Aadd(aWizSped[nPosicao],oWizard:GetTipoAtividade())					// 15 - Tipo de Atividade
	Aadd(aWizSped[nPosicao],oWizard:GetIndNaturezaPJ())					// 16 - Indicador Natureza PJ
	Aadd(aWizSped[nPosicao],oWizard:GetCentralizarUnicaFilial())		// 17 - Centralizar apurações e totalizadores em uma única filial
	Aadd(aWizSped[nPosicao],oWizard:GetTituReceber())					// 18 - Seleção de titulos a receber
	Aadd(aWizSped[nPosicao],oWizard:GetTituPagar())						// 19 - Seleção de titulos a pagar
	Aadd(aWizSped[nPosicao],oWizard:GetSerieDe())						// 20 - Serie de
	Aadd(aWizSped[nPosicao],oWizard:GetSerieAte())						// 21 - Serie ate
	Aadd(aWizSped[nPosicao],Replicate(' ',TamSX3("FT_ESPECIE")[1]))		// 22 - Especie de
	Aadd(aWizSped[nPosicao],Replicate('Z',TamSX3("FT_ESPECIE")[1]))		// 23 - Especie ate
	Aadd(aWizSped[nPosicao],oWizard:GetTipoMovimento())					// 24 - Tipo de movimento
	Aadd(aWizSped[nPosicao],oWizard:GetBxReceber())						// 25 - Seleção de baixas a receber
	Aadd(aWizSped[nPosicao],oWizard:GetBxPagar())						// 26 - Seleção de baixas a pagar


	// Aba 2 - Informações para processamento do inventario
	Aadd(aWizSped,{})
	nPosicao := Len(aWizSped)

	Aadd(aWizSped[nPosicao],"")											// 01 - Produto Inicial
	Aadd(aWizSped[nPosicao],"")											// 02 - Produto Final
	Aadd(aWizSped[nPosicao],"")											// 03 - Armazem Inicial
	Aadd(aWizSped[nPosicao],"")											// 04 - Armazem Final
	Aadd(aWizSped[nPosicao],"")											// 05 - Considera o saldo de/em poder de terceiros
	Aadd(aWizSped[nPosicao],"")											// 06 - Considera saldo em processo
	Aadd(aWizSped[nPosicao],oWizard:GetMotivoInventario())				// 07 - Motivo do inventário
	Aadd(aWizSped[nPosicao],"")											// 08 - Nome arq. gerado no reg. inv. mod 7
	Aadd(aWizSped[nPosicao],oWizard:GetDataFechamentoEstoque())			// 09 - Data de fechamento do estoque
	Aadd(aWizSped[nPosicao],oWizard:GetReg0210Mov())					// 10 - Reg. T046 por Mov.

	// Aba 3 - Informações do Sped
	Aadd(aWizSped,{})
	nPosicao := Len(aWizSped)

	Aadd(aWizSped[nPosicao],"")											// 01 - Cod da receita paa prestação de serviços
	Aadd(aWizSped[nPosicao],"")											// 02 - Cod da receita para demais operações

	// Aba 4 - Informações do contribuinte
	Aadd(aWizSped,{})
	nPosicao := Len(aWizSped)

	Aadd(aWizSped[nPosicao],oWizard:GetObrigatoriedadeECD())			// 01 - Obrigatoriedade do ECD
	Aadd(aWizSped[nPosicao],oWizard:GetClassifTribTabela8())			// 02 - Classif. Tribut. conforme tabela 8
	Aadd(aWizSped[nPosicao],oWizard:GetAcordoInterIsenMultas())			// 03 - Acordo internacional isenção de multas
	Aadd(aWizSped[nPosicao],oWizard:GetNomeContribuinte())				// 04 - Nome do contribuinte
	Aadd(aWizSped[nPosicao],oWizard:GetCpfContribuinte())				// 05 - CPF do contribuinte
	Aadd(aWizSped[nPosicao],oWizard:GetTelContribuinte())				// 06 - Telefone, com DDD do contribuinte
	Aadd(aWizSped[nPosicao],oWizard:GetCelularContribuinte())			// 07 - Telefone Celular, com DDD do contribuinte
	Aadd(aWizSped[nPosicao],oWizard:GetEmailContribuinte())				// 08 - E-Mail do contribuinte
	Aadd(aWizSped[nPosicao],oWizard:GetCnpjEmpSoftware())				// 09 - Empresa Desenvolvedora do Software CNPJ (somente CNPJ para buscar cadastrofornec.)
	Aadd(aWizSped[nPosicao],oWizard:GetRazaoSocialEmpSoftware())		// 10 - Razão Social da Empresa Desenvolvedora do Software
	Aadd(aWizSped[nPosicao],oWizard:GetContatoEmpSoftware())			// 11 - Contato da Empresa Desenvolvedora do Software
	Aadd(aWizSped[nPosicao],oWizard:GetTelEmpSoftware())				// 12 - Telefone, com DDD da Empresa Desenvolvedora do Software
	Aadd(aWizSped[nPosicao],oWizard:GetEmailEmpSoftware())				// 13 - E-Mail da Empresa Desenvolvedora do Software
	Aadd(aWizSped[nPosicao],oWizard:GetCelEmpSoftware())				// 14 - Telefone Celular, com DDD da Empresa Desenvolvedora do Software
	Aadd(aWizSped[nPosicao],oWizard:GetEnteFederativo())				// 15 - Ente Federativo Responsável
	Aadd(aWizSped[nPosicao],oWizard:GetCnpjEnteFederativo())			// 16 - CNPJ Ente Federativo Responsável
	Aadd(aWizSped[nPosicao],oWizard:GetIndDesoneracaoCPRB())			// 17 - Indicativo de desoneração da folha pela CPRB
	Aadd(aWizSped[nPosicao],oWizard:GetIndSituacaoPJ())					// 18 - Indicativo da Situação da Pessao Jurídica

Return aWizSped

/*/{Protheus.doc} fLayT001
    (Função para executar o layout T001)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT001()

    fMsgPrcss("Gerando Registro T001 - Estabelecimento...")

    // Monta o layout T001
    RegT001()

Return Nil

/*/{Protheus.doc} RegT001
    (Realiza a geracao do registro T001 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 20/03/2013

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT001()

    Local aAreaSM0 := SM0->(GetArea())
    Local aExistBloc := SPDFRetPEs()
    Local aRegT001 := {}

    Local cTxtSys := cDirSystem + "\T001.TXT" 
    Local cNomeFant := ""
    Local cRetPE := ""
    Local cAssDesp := '' 
    Local cPrdRural := '2'
    Local cPertPAA := ''

    Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
    Local nPosicao := 0
    Local aSM0 := FWLoadSM0()
 
    // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
    Aadd(aArqGer,cTxtSys)

	// Se envia o contribuinte
	If oWizard:GetEnviaContribuinte() == "1"
		// Posiciona na SM0
		SM0->(MsSeek(cEmpAnt+cFilAnt,.T.))

		//Alteração realizada para obter o nome fantasia da empresa
		If Len(SM0->M0_CODFIL) > 2
			// Parametro define se as informacoes da empresa virao do XX8
			If aSPDSX6[MV_USAXX8]
				Aeval(aSM0,{|x| cNomeFant := Iif(x[SM0_GRPEMP]==cEmpAnt .And. x[SM0_CODFIL]==cFilAnt .And. x[SM0_USEROK], x[SM0_NOMRED], cNomeFant) })
			Else
				cNomeFant := SM0->M0_FILIAL
			EndIf
		Else
			cNomeFant := SM0->M0_NOME
		EndIf

		If oFisaExtSx:_F0F
			F0F->(DbSetOrder(01))
			If F0F->(DbSeek(xFilial('F0F')+cFilAnt)) 
				//Verifica se o estabelecimento é uma associação desportiva
				cAssDesp := F0F->F0F_ASSDES

				If oFisaExtSx:_F0F_INDPAA
					If F0F->F0F_INDPAA == '2' .Or. Empty(F0F->F0F_INDPAA) 
						cPertPAA := '0'
					Else
						cPertPAA := '1'
					EndIf
				EndIf
			EndIf
		EndIf

		If SM0->M0_PRODRUR == '2'
			cPrdRural := '1'
		Else
			cPrdRural := '0'
		EndIf

		If aExistBloc[25]
			//-- PE usado para alterar campo 02-FANTASIA
			cRetPE := ExecBlock("SPEDFANT",.F.,.F.)
			If  ValType(cRetPE) == "C"
				cNomeFant := cRetPE
			EndIf
		EndIf

		// T001-CADASTRO DE EMPRESAS
		Aadd(aRegT001,{})
		nPosicao := Len(aRegT001)

		Aadd(aRegT001[nPosicao],"T001")									// 01 - REGISTRO
		Aadd(aRegT001[nPosicao],AllTrim(cEmpAnt) + AllTrim(cFilAnt))    // 02 - FILIAL
		Aadd(aRegT001[nPosicao],oWizard:GetEmailContribuinte())			// 03 - EMAIL
		Aadd(aRegT001[nPosicao],"")										// 04 - COD_FEBRABAN
		Aadd(aRegT001[nPosicao],"")										// 05 - CRT
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 06 - MATRIZ
		Aadd(aRegT001[nPosicao],cNomeFant)						        // 07 - DESC_RZ_SOCIAL
		Aadd(aRegT001[nPosicao],"")										// 08 - INSTAL_ANP
		Aadd(aRegT001[nPosicao],"")										// 09 - SEGMENTO
		Aadd(aRegT001[nPosicao],oWizard:GetObrigatoriedadeECD())		// 10 - INDECF
		Aadd(aRegT001[nPosicao],oWizard:GetClassifTribTabela8())		// 11 - CLASSTRIB
		Aadd(aRegT001[nPosicao],oWizard:GetAcordoInterIsenMultas())		// 12 - IND_ACORDO
		Aadd(aRegT001[nPosicao],oWizard:GetNomeContribuinte())			// 13 - NMCTT
		Aadd(aRegT001[nPosicao],oWizard:GetCpfContribuinte())			// 14 - CPFCTT
		Aadd(aRegT001[nPosicao],oWizard:GetTelContribuinte())			// 15 - FONEFIXO
		Aadd(aRegT001[nPosicao],oWizard:GetCelularContribuinte())		// 16 - FONECEL
		Aadd(aRegT001[nPosicao],oWizard:GetEnteFederativo())			// 17 - IDEEFR
		Aadd(aRegT001[nPosicao],oWizard:GetCnpjEnteFederativo())		// 18 - CNPJEFR
		Aadd(aRegT001[nPosicao],oWizard:GetIndDesoneracaoCPRB())		// 19 - IND_DESONERACAO   - Indicativo de desoneração da folha pela CPRB
		Aadd(aRegT001[nPosicao],oWizard:GetIndSituacaoPJ())	            // 20 - IND_SIT_PJ        - Indicativo da Situação da Pessoa Jurídica
		Aadd(aRegT001[nPosicao],"")										// 21 - INI_PER           - Indica a data de início de Vigência das informações prestadas
		Aadd(aRegT001[nPosicao],"")										// 22 - FIM_PER           - Indica a data de término de Vigência das informações prestadas
		Aadd(aRegT001[nPosicao],cAssDesp)								// 23 - IND_ASSOC_DESPORT - Indica se a entidade é uma associação desportiva
		Aadd(aRegT001[nPosicao],cPrdRural)								// 24 - IND_PROD_RURAL    - Indica se a entidade é um produtor rural
		Aadd(aRegT001[nPosicao],cPertPAA)								// 25 - EXECPAA           - Indicativo de Comercialização
		Aadd(aRegT001[nPosicao],oWizard:GetEmail_ContatoReinf())		// 26 - EMAILCONTATOREINF		- Indicativo de email do contato do REINF
		Aadd(aRegT001[nPosicao],oWizard:GetNome_ContatoReinf())			// 27 - NOMECONTATOREINF		- Indicativo de nome do contato do REINF
		Aadd(aRegT001[nPosicao],oWizard:GetCPF_ContatoReinf())			// 28 - CPFCONTATOREINF			- Indicativo de CPF do contato do REINF
		Aadd(aRegT001[nPosicao],oWizard:GetDDD_ContatoReinf())			// 29 - DDDCONTATOREINF			- Indicativo de DDD  do contato do REINF
		Aadd(aRegT001[nPosicao],oWizard:GetTEL_ContatoReinf())			// 30 - TELCONTATOREINF			- Indicativo de TELEFONE  do contato do REINF
		Aadd(aRegT001[nPosicao],oWizard:GetDDDCEL_ContatoReinf())		// 31 - DDDCELULARCONTATOREINF	- Indicativo de DDD DO CELULAR  do contato do REINF
		Aadd(aRegT001[nPosicao],oWizard:GetCEL_ContatoReinf())			// 32 - CELULARCONTATOREINF		- Indicativo de CELULAR  do contato do REINF
	Else 
		// T001-CADASTRO DE EMPRESAS
		Aadd(aRegT001,{})
		nPosicao := Len(aRegT001)

		Aadd(aRegT001[nPosicao],"T001")									// 01 - REGISTRO
		Aadd(aRegT001[nPosicao],AllTrim(cEmpAnt) + AllTrim(cFilAnt))    // 02 - FILIAL
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 03 - EMAIL
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 04 - COD_FEBRABAN
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 05 - CRT
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 06 - MATRIZ
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 07 - DESC_RZ_SOCIAL
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 08 - INSTAL_ANP
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 09 - SEGMENTO
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 10 - INDECF
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 11 - CLASSTRIB
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 12 - IND_ACORDO
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 13 - NMCTT
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 14 - CPFCTT
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 15 - FONEFIXO
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 16 - FONECEL
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 17 - IDEEFR
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 18 - CNPJEFR
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 19 - IND_DESONERACAO   - Indicativo de desoneração da folha pela CPRB
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 20 - IND_SIT_PJ        - Indicativo da Situação da Pessoa Jurídica
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 21 - INI_PER           - Indica a data de início de Vigência das informações prestadas
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 22 - FIM_PER           - Indica a data de término de Vigência das informações prestadas
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 23 - IND_ASSOC_DESPORT - Indica se a entidade é uma associação desportiva
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 24 - IND_PROD_RURAL    - Indica se a entidade é um produtor rural
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 25 - EXECPAA           - Indicativo de Comercialização
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 26 - EMAILCONTATOREINF		- Indicativo de email do contato do REINF
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 27 - NOMECONTATOREINF		- Indicativo de nome do contato do REINF
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 28 - CPFCONTATOREINF			- Indicativo de CPF do contato do REINF
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 29 - DDDCONTATOREINF			- Indicativo de DDD  do contato do REINF
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 30 - TELCONTATOREINF			- Indicativo de TELEFONE  do contato do REINF
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 31 - DDDCELULARCONTATOREINF	- Indicativo de DDD DO CELULAR  do contato do REINF
		Aadd(aRegT001[nPosicao],NAO_GRAVAR)								// 32 - CELULARCONTATOREINF		- Indicativo de CELULAR  do contato do REINF
	EndIf

	// Se o layout T001AN foi selecionado ou está relacionado
	If oWizard:LayoutSel("T001AN")
		if lFiltReinf .And. (cFiltInt $ "1|3" .Or. empty(cFiltInt))
			// Função para executar o layout T001AN		
			fLayT001AN(@aRegT001)
		endif
		lMThr := .T.
	EndIf

    FConcTxt(aRegT001,nHdlTxt)
	
	if !lFiltReinf
    	RegT001AA(nHdlTxt)
	endif

    // Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
    If cTpSaida == "2"
        FConcST1()
    ElseIf cTpSaida == "1"	// Libero Handle do Arquivo
        FClose(nHdlTxt)
    EndIf

    restArea(aAreaSM0)

Return Nil

/*/{Protheus.doc} fLayT001AN
    (Função para executar o layout T001AN)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno.
    /*/
Static Function fLayT001AN(a_RgT001AN)

	Default a_RgT001AN := {}

    fMsgPrcss("Gerando Registro T001AN - Desenvolvedora Software...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T001AN",2)
	
    // Monta o layout T001AN
    If RegT001AN(a_RgT001AN)
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AN",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AN",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT001AN
	(Realiza a geracao do registro T001AN do TAF)

    @type Static Function
	@author flavio.luiz
	@since 01/12/2017

	@param a_RgT001AN, array, contém as informações do layout T001AN.

	@return lGerou, logico, se gerou ou não.
	/*/
Static Function RegT001AN(a_RgT001AN)

	Local nPosicao := 0

	Local lGerou := .T.

	Default a_RgT001AN := {}

	Aadd(a_RgT001AN,{})
	nPosicao := Len(a_RgT001AN)

	Aadd(a_RgT001AN[nPosicao],"T001AN")

		Aadd(a_RgT001AN[nPosicao],oWizard:GetCnpjEmpSoftware())				// 02 - CNPJSOFT
		Aadd(a_RgT001AN[nPosicao],oWizard:GetRazaoSocialEmpSoftware())		// 03 - NM_RAZAO
		Aadd(a_RgT001AN[nPosicao],oWizard:GetContatoEmpSoftware())			// 04 - NM_CONTATO
		Aadd(a_RgT001AN[nPosicao],oWizard:GetTelEmpSoftware())				// 05 - TELEFONE
		Aadd(a_RgT001AN[nPosicao],oWizard:GetEmailEmpSoftware())			// 06 - EMAIL 

Return lGerou

/*/{Protheus.doc} RegT001AA
    (Realiza a geracao do registro T001AA do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 17/04/2013

    @Param n_HdlTxt, numerico, contém o handle do arquivo texto

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT001AA(n_HdlTxt)

    Local aRegT001AA := {}
    Local aUf 		 := UfCodIBGE( "", .F. )
	Local alSubTrib	 := FAllSubTri()
    Local cReg 		 := "T001AA"
    Local nPosI 	 := 0
    Local nPosF 	 := 0
    Local nPosicao 	 := 0
	Local nUfVld 	 := 0
	Local nI		 := 0
	Local nAte		 := 0
    Default n_HdlTxt := 0

	nAte := Len( alSubTrib )

	For nI := 1 To nAte
		nUfVld := Ascan( aUf , {|x| AllTrim(x[1]) $ AllTrim(alSubTrib[nI]) } )
		If nUfVld > 0
			nPosI := At(aUf[nUfVld][1],alSubTrib[nI]) + 2
			nPosF := At("/",SubStr(alSubTrib[nI],nPosI)) - 1
			nPosF := IIf(nPosF<=0,Len(alSubTrib[nI]),nPosF)

			aRegT001AA := {}
			ASize(aRegT001AA,0)
			Aadd(aRegT001AA,{})
			nPosicao := Len(aRegT001AA)

			Aadd(aRegT001AA[nPosicao],cReg)
			Aadd(aRegT001AA[nPosicao],aUf[nUfVld][1])
			Aadd(aRegT001AA[nPosicao],SubStr(alSubTrib[nI],nPosI,nPosF))
			Aadd(aRegT001AA[nPosicao],"")

			FConcTxt(aRegT001AA,n_HdlTxt)
		EndIf
	Next nI

Return Nil

/*/{Protheus.doc} fLayT001AB
    (Função para executar o layout T001AB)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @param a_WizFin, array, contém a wizard do financeiro

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT001AB(a_WizFin)

    Default a_WizFin := {}

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T001AB",2)
	
    fMsgPrcss("Gerando Registro T001AB - Processos Referenciados...")

    // Monta o layout T001AB
    If RegT001AB(a_WizFin)
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AB",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AB",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT001AB
	(Realiza a geracao do registro T001AB do TAF)

	@author Rodrigo Aguilar
	@since 22/04/2013

	@param a_WizFin, array, contém a wizard do financeiro

	@return lGerou, logico, se gerou o registro.

	@obs Alterado por Rodrigo Aguilar (08/09/2016) - Implementada busca dos processos referenciados utilizados
	no registro  E112 do Sped Fiscal
	Buscando os processos utilizados na guia de recolhimento ( E112 )
	/*/
Static Function RegT001AB(a_WizFin)

	Local aRegT001AB := {}

	Local cRegT001AB := ''
	Local cTxtSys := ''
	Local cDataDe := ''
	Local cDataAte := ''
	Local cQuery := ''
	Local cAliasQry := ''
	Local cTpComp := ''
	Local cUf := ''
	Local cCodMun := ''
	Local cIndAut := ''
	Local cDtIni := ''
	Local cDtFin := ''
	Local cNumero := ''
	
	Local nHdlTxt := 0
	Local nPosicao := 0

	Local lGerou	:= .F.
	Local lCarga	:= (!lFiltReinf .and. cFiltInt = '1')

	cRegT001AB := "T001AB"
	cTxtSys  := cDirSystem + "\" + cRegT001AB + ".TXT"

	nHdlTxt := IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )

	cDataDe := DToS(oWizard:GetDataDe())
	cDataAte := DToS(oWizard:GetDataAte())

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)
	
	cQuery := "SELECT DISTINCT "
	cQuery += "	 CCF.CCF_NUMERO "
	cQuery += "	,R_E_C_N_O_ RECCCF "
	cQuery += "FROM " + RetSqlName("CCF") + " CCF "

	if !lCarga

		cQuery += "INNER JOIN ( "
		cQuery += "	SELECT "
		cQuery += "		CDG.CDG_PROCES PROCESSO "
		cQuery += "		,CDG.CDG_TPPROC TIPO_PROC "
		If oFisaExtSx:_CDG_ITPROC
			cQuery += "		,CDG.CDG_ITPROC ITEM_PROC "
		Else
			cQuery += "		,'' ITEM_PROC "
		EndIf
		cQuery += "	FROM " + RetSqlName("CDG") + " CDG "

		cQuery += "	INNER JOIN " + RetSqlName("SFT") + " SFT ON "
		cQuery += "		SFT.D_E_L_E_T_ = ' ' "
		cQuery += "		AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
		cQuery += "		AND SFT.FT_NFISCAL = CDG.CDG_DOC "
		cQuery += "		AND SFT.FT_SERIE = CDG.CDG_SERIE "
		cQuery += "		AND SFT.FT_CLIEFOR = CDG.CDG_CLIfOR "
		cQuery += "		AND SFT.FT_LOJA = CDG.CDG_LOJA "
		If oFisaExtSx:_CDG_ITEM
			cQuery += "		AND SFT.FT_ITEM = CDG.CDG_ITEM "
		EndIf
		cQuery += "		AND SFT.FT_ENTRADA >= '" + cDataDe + "' "
		cQuery += "		AND SFT.FT_ENTRADA <= '" + cDataAte + "' "

		cQuery += "	WHERE "
		cQuery += "		CDG.D_E_L_E_T_ = ' ' "
		cQuery += "		AND CDG.CDG_FILIAL = '" + xFilial("CDG") + "' "
		
		cQuery += "	UNION "

		cQuery += "	SELECT "
		cQuery += "		 SF6.F6_NUMPROC PROCESSO "
		cQuery += "		,SF6.F6_INDPROC TIPO_PROC "
		cQuery += "		,'' ITEM_PROC "
		cQuery += "	FROM " + RetSqlName("SF6") + " SF6 "

		cQuery += "	WHERE "
		cQuery += "		SF6.D_E_L_E_T_ = ' ' "
		cQuery += "		AND SF6.F6_FILIAL = '" + xFilial("SF6") + "' "
		cQuery += "		AND SF6.F6_NUMPROC <> '' "

		//Necessario protecao, pois caso utilize a opção de formulas no parâmetro de periodo do schedule e a tabela SM4 seja exclusiva, 
		//o MV_PARXX relacionado ao periodo nao eh carregado para as demais filiais ocorrendo erro na query.
		cDataDe := Substring(cDataDe,5,2)
		if Empty( cDataDe )
			cDataDe := "''"
		endif
		cDataAte := Left(cDataAte,4)
		if Empty( cDataAte )
			cDataAte := "''"
		endif
		cQuery += "		AND SF6.F6_MESREF = " + cDataDe + " "
		cQuery += "		AND SF6.F6_ANOREF = " + cDataAte + " "
		IF oFisaExtSx:_DHR 
			// reinf
			cQuery += "	UNION "
			cQuery += "	SELECT "
			cQuery += "		DHR.DHR_PSIR PROCESSO "
			cQuery += "		,DHR.DHR_TSIR TIPO_PROC "
			cQuery += "		,'' ITEM_PROC "

			cQuery += "	FROM " + RetSqlName("DHR") + " DHR "

			cQuery += "	INNER JOIN " + RetSqlName("SFT") + " SFT ON "
			cQuery += "		SFT.D_E_L_E_T_ = ' ' "
			cQuery += "		AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
			cQuery += "		AND DHR.DHR_FILIAL = '" + xFilial("DHR") + "' "
			cQuery += "		AND SFT.FT_NFISCAL = DHR.DHR_DOC "
			cQuery += "		AND SFT.FT_SERIE = DHR.DHR_SERIE "
			cQuery += "		AND SFT.FT_CLIEFOR = DHR.DHR_FORNEC "
			cQuery += "		AND SFT.FT_LOJA = DHR.DHR_LOJA "
			cQuery += "		AND SFT.FT_ITEM = DHR.DHR_ITEM "
			cQuery += "		AND SFT.FT_ENTRADA >= '" + cDataDe + "' "
			cQuery += "		AND SFT.FT_ENTRADA <= '" + cDataAte + "' "
			cQuery += "		AND DHR.D_E_L_E_T_ = ' ' "

			cQuery += "	UNION "
			cQuery += "	SELECT "
			cQuery += "		DHR.DHR_PSPIS PROCESSO "
			cQuery += "		,DHR.DHR_TSPIS TIPO_PROC "
			cQuery += "		,'' ITEM_PROC "

			cQuery += "	FROM " + RetSqlName("DHR") + " DHR "

			cQuery += "	INNER JOIN " + RetSqlName("SFT") + " SFT ON "
			cQuery += "		SFT.D_E_L_E_T_ = ' ' "
			cQuery += "		AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
			cQuery += "		AND DHR.DHR_FILIAL = '" + xFilial("DHR") + "' "
			cQuery += "		AND SFT.FT_NFISCAL = DHR.DHR_DOC "
			cQuery += "		AND SFT.FT_SERIE = DHR.DHR_SERIE "
			cQuery += "		AND SFT.FT_CLIEFOR = DHR.DHR_FORNEC "
			cQuery += "		AND SFT.FT_LOJA = DHR.DHR_LOJA "
			cQuery += "		AND SFT.FT_ITEM = DHR.DHR_ITEM "
			cQuery += "		AND SFT.FT_ENTRADA >= '" + cDataDe + "' "
			cQuery += "		AND SFT.FT_ENTRADA <= '" + cDataAte + "' "
			cQuery += "		AND DHR.D_E_L_E_T_ = ' ' "


			cQuery += "	UNION "
			cQuery += "	SELECT "
			cQuery += "		DHR.DHR_PSCOF PROCESSO "
			cQuery += "		,DHR.DHR_TSCOF TIPO_PROC "
			cQuery += "		,'' ITEM_PROC "

			cQuery += "	FROM " + RetSqlName("DHR") + " DHR "

			cQuery += "	INNER JOIN " + RetSqlName("SFT") + " SFT ON "
			cQuery += "		SFT.D_E_L_E_T_ = ' ' "
			cQuery += "		AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
			cQuery += "		AND DHR.DHR_FILIAL = '" + xFilial("DHR") + "' "
			cQuery += "		AND SFT.FT_NFISCAL = DHR.DHR_DOC "
			cQuery += "		AND SFT.FT_SERIE = DHR.DHR_SERIE "
			cQuery += "		AND SFT.FT_CLIEFOR = DHR.DHR_FORNEC "
			cQuery += "		AND SFT.FT_LOJA = DHR.DHR_LOJA "
			cQuery += "		AND SFT.FT_ITEM = DHR.DHR_ITEM "
			cQuery += "		AND SFT.FT_ENTRADA >= '" + cDataDe + "' "
			cQuery += "		AND SFT.FT_ENTRADA <= '" + cDataAte + "' "
			cQuery += "		AND DHR.D_E_L_E_T_ = ' ' "

			cQuery += "	UNION "
			cQuery += "	SELECT "
			cQuery += "		DHR.DHR_PSCSL PROCESSO "
			cQuery += "		,DHR.DHR_TSCSL TIPO_PROC "
			cQuery += "		,'' ITEM_PROC "

			cQuery += "	FROM " + RetSqlName("DHR") + " DHR "

			cQuery += "	INNER JOIN " + RetSqlName("SFT") + " SFT ON "
			cQuery += "		SFT.D_E_L_E_T_ = ' ' "
			cQuery += "		AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' " 
			cQuery += "		AND DHR.DHR_FILIAL = '" + xFilial("DHR") + "' "
			cQuery += "		AND SFT.FT_NFISCAL = DHR.DHR_DOC "
			cQuery += "		AND SFT.FT_SERIE = DHR.DHR_SERIE "
			cQuery += "		AND SFT.FT_CLIEFOR = DHR.DHR_FORNEC "
			cQuery += "		AND SFT.FT_LOJA = DHR.DHR_LOJA "
			cQuery += "		AND SFT.FT_ITEM = DHR.DHR_ITEM "
			cQuery += "		AND SFT.FT_ENTRADA >= '" + cDataDe + "' "
			cQuery += "		AND SFT.FT_ENTRADA <= '" + cDataAte + "' "
			cQuery += "		AND DHR.D_E_L_E_T_ = ' ' "
		Endif

		cQuery += ") MOVI ON "
		cQuery += "	MOVI.PROCESSO = CCF.CCF_NUMERO "
		cQuery += "	AND MOVI.TIPO_PROC = CCF.CCF_TIPO "
		
		
	EndIf

	cQuery += "WHERE "
	cQuery += "	CCF.D_E_L_E_T_ = ' ' "

	cQuery += "	AND CCF.CCF_FILIAL = '" + xFilial("CCF") + "' "

	cQuery := "%" + cQuery + "%"

	cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT *
		FROM (%Exp:cQuery%) CCF 

		ORDER BY 
			CCF.CCF_NUMERO
	EndSql 

	DbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())
		// Posiciona no registro da CCF
		CCF->(DbGoTo((cAliasQry)->RECCCF))
	
		// Se achou o registro
		If CCF->(!Eof())

			lGerou := .T.
			cDtIni := ''
			cDtFin := ''

			// Se exstio campo CCF_INDAUT
			If oFisaExtSx:_CCF_INDAUT
				cTpComp := CCF->CCF_TPCOMP
				cIndAut := CCF->CCF_INDAUT
				cUf := CCF->CCF_UF
				cCodMun := CCF->CCF_CODMUN
			
				If !Empty(CCF->CCF_DTINI)
					if lJob
						cDtIni := Substr(StrTran(DToS(CCF->CCF_DTINI),'/',''),5,2) + Substr(StrTran(DToS(CCF->CCF_DTINI),'/',''),1,4)
					else
						cDtIni := Substr(StrTran(DToC(CCF->CCF_DTINI),'/',''),3)
					endif
					
				EndIf
			
				If !Empty(CCF->CCF_DTFIN)
					if lJob
						cDtFin := Substr(StrTran(DToS(CCF->CCF_DTFIN),'/',''),5,2) + Substr(StrTran(DToS(CCF->CCF_DTFIN),'/',''),1,4)
					else
						cDtFin := Substr(StrTran(DToC(CCF->CCF_DTFIN),'/',''),3)
					endif
				EndIf
			EndIf
		
			// T001AB-PROCESSOS REFERENCIADOS
			aRegT001AB := {}
			Aadd(aRegT001AB,{})
			nPosicao := Len(aRegT001AB)
	
			Aadd(aRegT001AB[nPosicao],cRegT001AB)		// 01 - REGISTRO
			Aadd(aRegT001AB[nPosicao],CCF->CCF_NUMERO)	// 02 - NUM_PROC
			Aadd(aRegT001AB[nPosicao],CCF->CCF_TIPO)	// 03 - IND_PROC
			Aadd(aRegT001AB[nPosicao],'')				// 04 - DESCRI_RESUMIDA
			Aadd(aRegT001AB[nPosicao],CCF->CCF_IDSEJU)	// 05 - ID_SEC_JUD
			Aadd(aRegT001AB[nPosicao],CCF->CCF_IDVARA)	// 06 - ID_VARA
			Aadd(aRegT001AB[nPosicao],'')	            // 07 - IND_NAT_ACAO_JUSTICA
			Aadd(aRegT001AB[nPosicao],'')				// 08 - DESC_DEC_JUD
			Aadd(aRegT001AB[nPosicao],CCF->CCF_DTSENT)	// 09 - DT_SENT_JUD
			Aadd(aRegT001AB[nPosicao],CCF->CCF_NATAC)	// 10 - IND_NAT_ACAO_RECEITA
			Aadd(aRegT001AB[nPosicao],CCF->CCF_DTADM)	// 11 - DT_DEC_ADM
			Aadd(aRegT001AB[nPosicao],cTpComp)			// 12 - IND_PROC_ECF 1 - Judicial 2 - Administrativo
			Aadd(aRegT001AB[nPosicao],cIndAut)			// 13 - INDAUTORIA
			Aadd(aRegT001AB[nPosicao],cUf)				// 14 - UFVARA
			Aadd(aRegT001AB[nPosicao],cCodMun)			// 15 - CODMUNIC
			Aadd(aRegT001AB[nPosicao],cDtIni)			// 16 - INIVALID AAAA-MM
			Aadd(aRegT001AB[nPosicao],cDtFin)			// 17 - FIMVALID AAAA-MM

			FConcTxt(aRegT001AB,nHdlTxt)

			cNumero := CCF->CCF_NUMERO

			// Enquanto for o mesmo numero
			While (cAliasQry)->(!Eof()) .And. (cAliasQry)->CCF_NUMERO == cNumero
				// Posiciona no registro da CCF
				CCF->(DbGoTo((cAliasQry)->RECCCF))

				// Gera o registro T001AO
				RegT001AO(nHdlTxt)

				// Vai para o proximo registro
				(cAliasQry)->(DbSkip())
			EndDo

			//Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
			If cTpSaida == "2"
				FConcST1()
			EndIf
		EndIf
	EndDo

	// Fecha o alias
	(cAliasQry)->(DbCloseArea())

	// Se estiver ok para execução do finaceiro e existir a função
	If lFFinExtOK .And. FindFunction("FExpT001AB")
		// Gera o arquivo T001AB com as regras do financeiro.
		If FExpT001AB(cFilAnt,cTpSaida,nHdlTxt,a_WizFin,, lFiltReinf, cFiltInt) 
			lGerou := .T.
		EndIf
	EndIf

	//Libero Handle do Arquivo
	If cTpSaida == "1"
		FClose(nHdlTxt)
	EndIf
	
Return lGerou

/*/{Protheus.doc} RegT001AO
	(Realiza a geracao do registro T001AO do TAF)

    @type Static Function
	@author flavio.luiz
	@since 05/01/2018

	@param nHdlTxt, numerico, handle de Gravacao do Arquivo

	@return Nil, nulo, não tem retorno
	/*/
Static  Function RegT001AO(nHdlTxt)

	Local nPosicao := 0

	Local cRegT001AO := "T001AO"
	Local cIndSup := ''
	Local cDtDecisao := ''

	Local aRegT001AO := {}

	// Se existir o campo CCF_SUSEXI
	If oFisaExtSx:_CCF_SUSEXI
		cIndSup := CCF->CCF_SUSEXI
	EndIf

	If !Empty(CCF->CCF_DTADM)
		cDtDecisao := CCF->CCF_DTADM
	Else
		cDtDecisao := CCF->CCF_DTSENT
	EndIf

	Aadd(aRegT001AO,{})
	nPosicao := Len(aRegT001AO)

	Aadd(aRegT001AO[nPosicao],cRegT001AO)							// 01 - REGISTRO
	Aadd(aRegT001AO[nPosicao],CCF->CCF_INDSUS)						// 02 - COD_SUSP
	Aadd(aRegT001AO[nPosicao],cIndSup)								// 03 - IND_SUSP
	Aadd(aRegT001AO[nPosicao],cDtDecisao)							// 04 - DT_DECISAO
	Aadd(aRegT001AO[nPosicao],IIf(CCF->CCF_MONINT=='1','S','N'))	// 05 - IND_DEPOSITO

	FConcTxt(aRegT001AO,nHdlTxt)

Return Nil

/*/{Protheus.doc} fLayT001AC
    (Função para executar o layout T001AC)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT001AC()

    fMsgPrcss("Gerando Registro T001AC - Veículos...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T001AC",2)
	
    // Monta o layout T001AC
    If RegT001AC()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AC",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AC",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT001AC
	(Realiza a geracao do registro T001AC do TAF)

	@author Fabio Vessoni
	@since 03/05/2013

	@return lGerou, logico, se o registro foi gerado ou não.
	/*/
Static Function RegT001AC()

	Local cRegT001AC := "T001AC"
	Local cTxtSys := ""
	Local cAliasQry := ""

	Local aRegT001AC := {}

	Local nHdlTxt := 0
	Local nPosicao := 0

	Local lGerou := .F.

	cTxtSys := cDirSystem + "\" + cRegT001AC + ".TXT"
	nHdlTxt	:= IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)

	cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT
			DA3.R_E_C_N_O_ RECDA3
		FROM %Table:DA3% DA3

		WHERE
			DA3.DA3_FILIAL = %xFilial:DA3% 
			AND DA3.%NotDel%
	EndSql

	DbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())
		// Posiciona no registro
		DA3->(DbGoTo((cAliasQry)->RECDA3))
		
		lGerou := .T.

		aRegT001AC := {}
		ASize(aRegT001AC,0)
		Aadd(aRegT001AC,{})
		nPosicao := Len(aRegT001AC)

		Aadd(aRegT001AC[nPosicao],cRegT001AC)
		Aadd(aRegT001AC[nPosicao],DA3->DA3_COD)
		Aadd(aRegT001AC[nPosicao],StrTran(DA3->DA3_PLACA,"-",""))
		Aadd(aRegT001AC[nPosicao],DA3->DA3_ESTPLA)
		Aadd(aRegT001AC[nPosicao],"")
		Aadd(aRegT001AC[nPosicao],DA3->DA3_DESC)
		Aadd(aRegT001AC[nPosicao],AllTrim(DA3->DA3_CHASSI))
		Aadd(aRegT001AC[nPosicao],"")
		Aadd(aRegT001AC[nPosicao],"")
		Aadd(aRegT001AC[nPosicao],"")
		Aadd(aRegT001AC[nPosicao],"")
		Aadd(aRegT001AC[nPosicao],"")

		FConcTxt(aRegT001AC,nHdlTxt)
		
		// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
		If cTpSaida == "2"
			FConcST1()
		EndIf
			
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	// Libero Handle do Arquivo
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf

Return lGerou

/*/{Protheus.doc} fLayT001AD
    (Função para executar o layout T001AD)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT001AD()

    fMsgPrcss("Gerando Registro T001AD - ECF/SAT-CF...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T001AD",2)
	
    // Monta o layout T001AD
    If RegT001AD()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AD",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AD",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT001AD

Realiza a geracao do registro T001AD do TAF

@author Rodrigo Aguilar
@since  23/04/2013

@return lGerou, logico, se gerou ou não.
/*/
Static Function RegT001AD()

	Local aParametro := {}
	Local aRegT001AD := {}

	Local cTxtSys := ""
	
	Local nHdlTxt := 0
	Local nLinha := 0

	Local lGerou := .F.

	// Se existir a tabela
	If oFisaExtSx:_SLG
		DbSelectArea("C0W")		// Cadastro do ECF / SAT-CFe
		C0W->(DbSetOrder(1))	// C0W_FILIAL+C0W_CODIGO+C0W_ECFMOD+C0W_ECFFAB
			
		DbSelectArea("SLG")		// Estacoes
		SLG->(DbSetOrder(1))	// LG_FILIAL+LG_CODIGO
				
		cTxtSys := cDirSystem + "\T001AD.TXT"
		
		nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
					
		// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
		Aadd(aArqGer,cTxtSys)
						
		Aadd(aParametro,DToS(oWizard:GetDataDe()))
		Aadd(aParametro,DToS(oWizard:GetDataAte()))
		Aadd(aParametro,"")
		Aadd(aParametro,"")
										
		SLG->(MsSeek(cFilAnt,.T.))
		While SLG->(!Eof()) .And. SLG->LG_FILIAL == cFilAnt
			aParametro[3] := SLG->LG_PDV
			aParametro[4] := SLG->LG_SERPDV
					
			// Se for SAT ou existir movimento para o ECF no Periodo
			If SpedFFiltro(1,"SFI","",aParametro,,1) .Or. (oFisaExtSx:_LG_SERSAT .And. !Empty(SLG->LG_SERSAT))

				lGerou := .T.

				aRegT001AD := {}
				Aadd(aRegT001AD,{})
				nLinha := Len(aRegT001AD)

				Aadd(aRegT001AD[nLinha],"T001AD")				// 01 - REGISTRO
				Aadd(aRegT001AD[nLinha],SLG->LG_CODIGO)			// 02 - IDENT_ECF
				Aadd(aRegT001AD[nLinha],"2D")					// 03 - ECF_MOD
				Aadd(aRegT001AD[nLinha],SLG->LG_SERPDV)			// 04 - ECF_FAB
				Aadd(aRegT001AD[nLinha],AllTrim(SLG->LG_PDV))	// 05 - ECF_CX
				Aadd(aRegT001AD[nLinha],AllTrim(SLG->LG_NOME))	// 06 - DESCRI
			
				FConcTxt(aRegT001AD,nHdlTxt)
			
				// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
				If cTpSaida == "2"
					FConcST1()
				EndIf

			EndIf
			
			SLG->( DbSkip() )
		EndDo

		// Libero Handle do Arquivo
		If cTpSaida == "1"
			FClose(nHdlTxt)
		EndIf
	EndIf

Return lGerou

/*/{Protheus.doc} fLayT001AE
    (Função para executar o layout T001AE)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT001AE()

    fMsgPrcss("Gerando Registro T001AE - Documento de Arrecadação...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T001AE",2)
	
    // Monta o layout T001AE
    If RegT001AE()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AE",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AE",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT001AE
	(Realiza a geracao do registro T001AE do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 20/03/2013

	@return lGerou, logico, se gerou ou não.
	/*/
Static Function RegT001AE()

	Local aRegT001AE := {}

	Local cSelect := ""
	Local cJoin := ""
	Local cWhere := ""
	Local cCodProd := ""
	Local cMVSubTrib := ""
	Local cReg := "T001AE"
	Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
	Local cAliasQry := GetNextAlias()
	Local cMesRefIni := Substr(DToS(oWizard:GetDataDe()),5,2)
	Local cMesRefFim := Substr(DToS(oWizard:GetDataAte()),5,2)
	Local cAnoRefIni := Substr(DToS(oWizard:GetDataDe()),1,4)
	Local cAnoRefFim := Substr(DToS(oWizard:GetDataAte()),1,4)
	Local cCodPart := ""
	Local cTipoDoc := ""
	Local cSubTrib := ""
	Local cNumBco := ""

	Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
	Local nPosicao := 0

	Local lGerou := .F.

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)

	cSelect := "," + xFunExpSql("COALESCE") + "(SA6.R_E_C_N_O_,0) RECSA6 "
	cSelect += "," + xFunExpSql("COALESCE") + "(SF3.F3_ESPECIE,'') ESPECIE "

	If oWizard:GetTipoMovimento() == '2'		// 2-Entradas	(Notas de Entrada)

		cJoin += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON "
		cJoin += "	SF1.D_E_L_E_T_ = ' ' "
		cJoin += "	AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
		cJoin += " 	AND	SF1.F1_DOC = SF6.F6_DOC "
		cJoin += " 	AND	SF1.F1_SERIE = SF6.F6_SERIE "
		cJoin += " 	AND SF1.F1_FORNECE = SF6.F6_CLIfOR " 
		cJoin += " 	AND SF1.F1_LOJA = SF6.F6_LOJA "

	ElseIf oWizard:GetTipoMovimento() == '3'	// 3-Saidas  	(Notas de Saída)

		cJoin += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON "
		cJoin += "	SF2.D_E_L_E_T_ = ' ' "
		cJoin += "	AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
		cJoin += " 	AND	SF2.F2_DOC = SF6.F6_DOC "
		cJoin += " 	AND	SF2.F2_SERIE = SF6.F6_SERIE "
		cJoin += "	AND SF2.F2_CLIENTE = SF6.F6_CLIfOR "
		cJoin += "	AND SF2.F2_LOJA = SF6.F6_LOJA "

	EndIf

	If !Empty(oWizard:GetNotaAte())
		cWhere  += "AND F6_DOC >='" + oWizard:GetNotaDe() + "' AND F6_DOC <='" + oWizard:GetNotaAte() + "' "
		cWhere  += "AND F6_SERIE	>='" + oWizard:GetSerieDe() + "' AND F6_SERIE	<='" + oWizard:GetSerieAte() + "' "
	EndIf

	cWhere  += " AND F6_MESREF >= " + cMesRefIni + " AND F6_MESREF <= " + cMesRefFim + " "
	cWhere  += " AND F6_ANOREF >= " + cAnoRefIni + " AND F6_ANOREF <= " + cAnoRefFim + " "

	// Definindo Estrutura para Execucao do BeginSql
	cSelect := "%" + cSelect + "%"
	cJoin := "%" + cJoin + "%"
	cWhere := "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT
			DISTINCT SF6.R_E_C_N_O_ RECSF6
			%Exp:cSelect%
		FROM %Table:SF6% SF6

		LEFT OUTER JOIN %Table:SF3% SF3 ON
			SF3.%NotDel%
			AND SF3.F3_FILIAL = %xFilial:SF3%
			AND SF3.F3_CLIEFOR = SF6.F6_CLIfOR
			AND SF3.F3_LOJA = SF6.F6_LOJA
			AND SF3.F3_NFISCAL = SF6.F6_DOC
			AND SF3.F3_SERIE = SF6.F6_SERIE

		LEFT OUTER JOIN %Table:SA6% SA6 ON
			SA6.%NotDel%
			AND SA6.A6_FILIAL = %xFilial:SA6%
			AND SA6.A6_COD = SF6.F6_BANCO
			AND SA6.A6_AGENCIA = SF6.F6_AGENCIA

		%Exp:cJoin%

		WHERE
			SF6.%NotDel%
			AND SF6.F6_FILIAL = %xFilial:SF6%
			%Exp:cWhere%
	EndSql

	cMVSubTrib := IIf(FindFunction("GETSUBTRIB"),GetSubTrib(),oFisaExtSx:_MV_SUBTRIB)

	DbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())
		cNumBco := ""

		// Posiciona no registro da SF6
		SF6->(DbGoTo((cAliasQry)->RECSF6))

		// Se tiver recno da SA6
		If !Empty((cAliasQry)->RECSA6)
			// Posiciona no registro da SA6
			SA6->(DbGoTo((cAliasQry)->RECSA6))

			If SA6->(!Eof())
				cNumBco := SA6->A6_NUMBCO
			EndIf
		EndIf
		
		// Realizado tratamento pois no Protheus o campo referente ao codigo do produto eh numerico
//		cCodProd := IIf(Empty(SF6->F6_CODPROD),Alltrim(Str(SF6->F6_CODPROD)),"")
		cCodProd := AllTrim(Str(SF6->F6_CODPROD))
		If cCodProd == '0'
		 	cCodProd := ''
		EndIf 	
		If !Empty(SF6->F6_CLIfOR)
			If (SF6->F6_OPERNF == "1" .And. !AllTrim(SF6->F6_TIPODOC) $ "BD") .Or. (SF6->F6_OPERNF == "2" .And. AllTrim(SF6->F6_TIPODOC) $ "BD")
				cCodPart := "F"
			Else
				cCodPart := "C"
			EndIf

			cCodPart += SF6->(F6_CLIfOR+F6_LOJA)
		EndIf
		
		// VerIficar se existe inscrição para nao ficar somente com a UF
		cSubTrib := Alltrim(SubStr(SF6->F6_EST,1,2)+SF6->F6_INSC)
		
		If !Empty((cAliasQry)->ESPECIE)
			cTipoDoc := gnreTpDoc(SF6->F6_CODREC,SF6->F6_DOC,cSubTrib$cMVSubTrib,(cAliasQry)->ESPECIE,SF6->F6_EST,SF6->F6_TIPODOC)
		EndIf
		
		lGerou := .T.

		aRegT001AE := {}
		ASize(aRegT001AE,0)
		Aadd(aRegT001AE,{})
		nPosicao := Len(aRegT001AE)

		Aadd(aRegT001AE[nPosicao],cReg)											// 01 - REGISTRO
		Aadd(aRegT001AE[nPosicao],IIf(SF6->F6_TIPOIMP=="0","0","1"))			// 02 - COD_DA
		Aadd(aRegT001AE[nPosicao],SF6->F6_NUMERO)								// 03 - NUM_DA
		Aadd(aRegT001AE[nPosicao],SF6->F6_EST)									// 04 - UF
		Aadd(aRegT001AE[nPosicao],SF6->F6_CODREC)								// 05 - COD_REC
		Aadd(aRegT001AE[nPosicao],cTipoDoc)										// 06 - TIP_DOC_ORIGEM
		Aadd(aRegT001AE[nPosicao],SF6->F6_DOC)									// 07 - DOC_ORIGEM
		Aadd(aRegT001AE[nPosicao],AllTrim(Strzero(SF6->F6_MESREF,2))+AllTrim(Str(SF6->F6_ANOREF)))	// 08 - PERIODO
		Aadd(aRegT001AE[nPosicao],"")											// 09 - NUM_PARC
		Aadd(aRegT001AE[nPosicao],IIf(!Empty(SF6->F6_REF),AllTrim(Str(Val(SF6->F6_REF)-1)),""))	// 10 - REFERENCIA
		Aadd(aRegT001AE[nPosicao],Val2Str(SF6->F6_VALOR,16,2))					// 11 - VALOR_PRINCIPAL
		Aadd(aRegT001AE[nPosicao],Val2Str(SF6->F6_ATMON,16,2))					// 12 - ATU_MONETARIA
		Aadd(aRegT001AE[nPosicao],Val2Str(SF6->F6_JUROS,16,2))					// 13 - JUROS
		Aadd(aRegT001AE[nPosicao],Val2Str(SF6->F6_MULTA,16,2))					// 14 - MULTA
		Aadd(aRegT001AE[nPosicao],Val2Str(SF6->(F6_VALOR+F6_ATMON+F6_JUROS+F6_MULTA),16,2))	// 15 - TOTAL_RECOLHER
		Aadd(aRegT001AE[nPosicao],SF6->F6_AUTENT)								// 16 - COD_AUT
		Aadd(aRegT001AE[nPosicao],SF6->F6_DTVENC)								// 17 - DT_VCTO
		Aadd(aRegT001AE[nPosicao],SF6->F6_DTPAGTO)								// 18 - DT_PGTO
		Aadd(aRegT001AE[nPosicao],"")											// 19 - DET_REC
		Aadd(aRegT001AE[nPosicao],cCodProd)										// 20 - COD_PRODUTO
		Aadd(aRegT001AE[nPosicao],SF6->F6_NUMCONV)								// 21 - CONVENIO
		Aadd(aRegT001AE[nPosicao],cCodPart)										// 22 - COD_PARTICIPANTE
		Aadd(aRegT001AE[nPosicao],Alltrim(SF6->F6_EST) + " / " + Alltrim(SF6->F6_NUMERO))	// 23 - DESCRICAO_DOCUMENTO
		Aadd(aRegT001AE[nPosicao],cNumBco)										// 24 - COD_BANCO
		Aadd(aRegT001AE[nPosicao],SF6->F6_AGENCIA)								// 25 - COD_AGENCIA
		Aadd(aRegT001AE[nPosicao],"")											// 26 - NUM_CC
		Aadd(aRegT001AE[nPosicao],"")											// 27 - VALOR_DEVOLUCAO
		Aadd(aRegT001AE[nPosicao],"")											// 28 - VALOR_RESSARCIMENTO
		Aadd(aRegT001AE[nPosicao],"")											// 29 - DIG_AGE
		Aadd(aRegT001AE[nPosicao],IIf(!SF6->F6_COBREC$"",SF6->F6_COBREC,"000"))	// 30 - COD_OR
		Aadd(aRegT001AE[nPosicao],SF6->F6_NUMPROC)								// 31 - NUM_PROC
		Aadd(aRegT001AE[nPosicao],SF6->F6_INDPROC)								// 32 - IND_PROC
		Aadd(aRegT001AE[nPosicao],"")											// 33 - TIPO_RECOLHE
		Aadd(aRegT001AE[nPosicao],"")											// 34 - TIPO_IMPOSTO
		Aadd(aRegT001AE[nPosicao],0)											// 35 - DESCONTO
		Aadd(aRegT001AE[nPosicao],0)											// 36 - COMPENSADO
		Aadd(aRegT001AE[nPosicao],0)											// 37 - VALOR_PAGO
		Aadd(aRegT001AE[nPosicao],"")											// 38 - STATUS_PAGAMENTO

		RegT001AF(@aRegT001AE)
			
		FConcTxt(aRegT001AE,nHdlTxt)
			
		// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
		If cTpSaida == "2"
			FConcST1()
		EndIf
				
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	// Libero Handle do Arquivo  
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf

Return lGerou

/*/{Protheus.doc} RegT001AF
	(Realiza a geracao do registro T001AF do TAF)

	@type Static Function
	@author Vitor Ribeiro
	@since 08/05/2018

	@Param a_RgT001AF, array, dados do registro T001AF

	@return Nil, nulo, não tem retorno
	/*/
Static Function RegT001AF(a_RgT001AF)

	Local aAreaAtu := GetArea()
	Local aCamposInt := {}

	Local nCount1 := 0
	Local nCount2 := 0

	Local cConteudo	:= ""

	Default a_RgT001AF := {}
	
	DbSelectArea("SF3")		// LIVROS FISCAIS
	SF3->(dbSetOrder(4))	// F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
	
	aCamposInt := xGetCmpGnre(SF6->F6_EST,SF6->F6_CODREC)
	
	For nCount1 := 1 To Len(aCamposInt)
		For nCount2 := 2 To Len(aCamposInt[nCount1])
			cConteudo := xRetInfCmp(aCamposInt[nCount1][nCount2][2])

			// Só devo enviar os campos não vazios ou obrigatórios.
			If !Empty(AllTrim(cConteudo)) .Or. aCamposInt[nCount1][nCount2][4]
				Aadd(a_RgT001AF,{"T001AF",aCamposInt[nCount1][nCount2][1],aCamposInt[nCount1][nCount2][3],cConteudo})	 
			EndIf
		Next
	Next
	
	RestArea(aAreaAtu)

Return Nil

/*/{Protheus.doc} ExtSPEDContr
    (Realiza a extração dos registros gerados na apuração do spedcontribuíções)

    @type Static Function
    @author Mauro A. Gonçalves
    @since 09/08/2016

    @return lGerou, logico, se gerou ou não.
    /*/
Static Function ExtSPEDContr()

    Local cTxtSys := ""
    Local cReg := ""
    Local cFunReg := ""

    Local nHdlTxt := 0
    Local nA := 0
    Local nB := 0
    Local nD := 0

    Local lPriVez := .T.

    Local aRegPROTAF := RegPROTAF()
    Local aPriExeReg := PriExeReg()
    Local aRegTAF := {}

    Local dDataDe := oWizard:GetDataDe()
    Local dDataAte := oWizard:GetDataAte()

    aRegExtTaf := ASort(aRegExtTaf,,,{|x,y| x[1]+x[2]<y[1]+y[2]})

    //Faz o tratamento para colocar no M410/M810 o campo CST_PC do M400/M800
    For nA:=1 to Len(aRegExtTaf)
        If aRegExtTaf[nA][2]$"M410|M810"
            If (nB := Ascan(aRegExtTaf, {|x| x[1]==Left(aRegExtTaf[nA][01],26)})) > 0
                AADD(aRegExtTaf[nA],aRegExtTaf[nB][03])
            EndIf
        EndIf	
    Next

    For nA:=1 to Len(aRegExtTaf)
        If (nD := Ascan(aRegPROTAF, {|x| x[1]==aRegExtTaf[nA][2]})) > 0
            lGera := .T.
            If Left(aRegPROTAF[nD][1],1)=="I"
                lGera := Ascan(aRegExtTaf, {|x| x[1]$"I100|I200|I300"}) > 0		
            EndIf
            If lGera
                cFunReg := "RegBloco"+Left(aRegPROTAF[nD][1],1)
                &(cFunReg)(dDataDe,dDataAte,aRegExtTaf[nA],aRegPROTAF[nD],@aRegTAF)
            EndIf	
        EndIf	
    Next
    AADD(aRegTAF,{{" ", " "}})

    //Gera o arquivo TXT com as informações do array aRegTaf 
    aRegExtTaf := {}
    For nA:=1 to Len(aRegTAF)
        If cReg <> Left(aRegTAF[nA][1][1],4) .Or. len(alltrim(aRegTAF[nA][1][1])) == 4 //verIfico se o registro é PAI
            If Len(aRegExtTaf)>0
                FConcTxt(aRegExtTaf, nHdlTxt)
                //Grava o registro na TABELA TAFST1 e limpa o array aDadosST1	
                If cTpSaida == "2" .And. Len(aDadosST1) > 0
                    FConcST1()
                EndIf
                //Libera Handle do Arquivo 
                If cTpSaida == "1" 
                    FClose(nHdlTxt)
                EndIf	
            EndIf
            aRegExtTaf	:= {}
            cReg		:= Left(aRegTAF[nA][1][1],4)
            If !Empty(cReg)
                //VerIfica se o arquivo TXT para esse registro já foi gerado
                If (nD := Ascan(aPriExeReg, {|x| x[1]==cReg})) > 0
                    lPriVez := aPriExeReg[nD][2]
                EndIf
                //Cria ou atualiza o arquivo TXT do registro		 
                cTxtSys := cDirSystem + "\" + cReg + ".TXT"
                If File(cTxtSys) .And. !lPriVez
                    nHdlTxt := IIf(cTpSaida == "1", FOPEN(cTxtSys, FO_READWRITE + FO_SHARED), 0)
                    If cTpSaida == "1"
                        FSeek(nHdlTxt,0,FS_END)
                    EndIf
                Else
                    nHdlTxt := IIf(cTpSaida == "1", MsFCreate(cTxtSys), 0)
                EndIf
                //Atualiza array para não criar novamente o arquivo TXT do registro e apagar o anterior
                If nD > 0 
                    aPriExeReg[nD][2] := .F.
                EndIf

                // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
                Aadd(aArqGer,cTxtSys)

                //Cria linha no array
                AADD(aRegExtTaf, aRegTAF[nA][1])
            EndIf	
        Else			
            AADD(aRegExtTaf, aRegTAF[nA][1])		
        EndIf
    Next

Return

/*/{Protheus.doc} RegBlocoP
    (Realiza a geracao dos registros no TAF - Bloco P)

    @type Static Function
    @author Mauro A. Gonçalves
    @since 09/08/2016

    @param dDataDe, data, Data Inicial
    @param dDataAte, data, Data Final
    @param aRegPRO, array, Array dos registros gerados pelo Protheus
    @param aTipReg, array, Array contEndo os registros gerados pelo Protheus e os correspondentes no TAF 
    @param aRegTAF, array, Array com os registros gerados no padrão TAF	

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegBlocoP(dDataDe, dDataAte, aRegPRO, aTipReg, aRegTAF)
	
	Local aReg	:= {}

	If aTipReg[1]=='P100'
			Aadd(aReg,;
				 {	aTipReg[2],;		//REGISTRO T082
					aRegPRO[03],;		//DT_INI
					aRegPRO[04],;		//DT_FIN
					aRegPRO[05],;		//VL_REC_TOT_EST
					aRegPRO[06],;		//COD_ATIV_ECON
					aRegPRO[07],;		//VL_REC_ATIV_ESTAB 
					aRegPRO[08],;		//VL_EXC
					aRegPRO[09],;		//VL_BC_CONT
					aRegPRO[10],;		//ALIQ_CONT
					aRegPRO[11],;		//VL_CONT_APU
					aRegPRO[12],;		//COD_CTA 
					aRegPRO[13];		//INFO_COMPL 
				})
	ElseIf aTipReg[1]=='P110'
			Aadd(aReg,;
				 {	aTipReg[2],;		//REGISTRO T082AA
					aRegPRO[03],;		//NUM_CAMPO 
					aRegPRO[04],;		//COD_DET
					aRegPRO[05],;		//DET_VALOR
					aRegPRO[06],;		//INF_COMPL
				})
	ElseIf aTipReg[1]=='P199'
			Aadd(aReg,;
			 	{	aTipReg[2],;		//REGISTRO T082AB
					aRegPRO[03],;		//NUM_PROC
					aRegPRO[04],;		//IND_PROC
				 })	
	ElseIf aTipReg[1]=='P199_1'
			Aadd(aReg,;					
				{	aTipReg[2],;		//REGISDTRO T082AC
					aRegPRO[03],;		//TIPO DO AJUSTE
					aRegPRO[04],;		//CÓDIGO DO AJUSTE
					aRegPRO[05],;		//VALOR DO AJUSTE
					aRegPRO[06],;		//DESCRIÇÃO RESUMIDA DO AJUSTE
					aRegPRO[07],;		//DATA REFERENCIA PERÍODO
				})
	ElseIf aTipReg[1]=='P199_2'
			Aadd(aReg,;					
				{	aTipReg[2],;		//REGISTRO T082AD
					aRegPRO[07],;		//VL_REC_ATIV_ESTAB 
					aRegPRO[08],;		//VL_EXC
					aRegPRO[09],;		//VL_BC_CONT
					aRegPRO[10],;		//ALIQ_CONT
					aRegPRO[11],;		//VL_CONT_APU
					aRegPRO[12],;		//COD_CTA 
					aRegPRO[13];		//CNO
				})
	EndIf

	If Len(aReg)>0
		AADD(aRegTAF,aReg)
	EndIf

Return

/*/{Protheus.doc} RegPROTAF
    (Retorna um array para controle da criação do registro no TAF, fazEndo o de/para entre SIGAFIS e TAF)

    @type Static Function
    @author Mauro A. Gonçalves
    @since 09/08/2016
    
    @Return aTipReg, array, controle de registro no TAF
    /*/
Static Function RegPROTAF()

    Local aTipReg := {}

    // Bloco P
    AADD(aTipReg,{"P100","T082"})
    AADD(aTipReg,{"P110","T082AA"})
    AADD(aTipReg,{"P199","T082AB"})
	AADD(aTipReg,{'P199_1','T082AC'})
	AADD(aTipReg,{'P199_2','T082AD'})

Return aTipReg 	

/*/{Protheus.doc} PriExeReg
	(Retorna um array para controle da criação do arquivo TXT do registro gerado)

	@type Static Function
	@author Mauro A. Gonçalves
	@since 09/08/2016

	@Return aPriExeReg, array, controle da criação do arquivo TXT
	/*/
Static Function PriExeReg()

	Local aPriExeReg := {}

	AADD(aPriExeReg,{"T001",.F.})
	AADD(aPriExeReg,{"T013",.T.})
	AADD(aPriExeReg,{"T015",.T.})
	AADD(aPriExeReg,{"T035",.T.})
	AADD(aPriExeReg,{"T060",.T.})
	AADD(aPriExeReg,{"T062",.T.})
	AADD(aPriExeReg,{"T065",.T.})
	AADD(aPriExeReg,{"T068",.T.})
	AADD(aPriExeReg,{"T071",.T.})
	AADD(aPriExeReg,{"T075",.T.})
	AADD(aPriExeReg,{"T080",.T.})
	AADD(aPriExeReg,{"T082",.T.})
	AADD(aPriExeReg,{"T086",.T.})

Return aPriExeReg

/*/{Protheus.doc} fLayT001AK
    (Função para executar o layout T001AK)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT001AK()

    fMsgPrcss("Gerando Registro T001AK - Informações Complementares...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T001AK",2)
	
    // Monta o layout T001AK
    If RegT001AK()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AK",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AK",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT001AK
	(Realiza a geracao do registro T001AK do TAF)

    @type Static Function
	@author Fabio V Santana
	@since 25/03/2013

	@return lGerou, logico, se gerou ou não.
	/*/
Static Function RegT001AK()

    Local aRegs := {}
    Local cSelect := ""
    Local cWhere := ""
    Local cUnion := ""
    Local cWhere2 := ""
    Local cJoin := ""
    Local cReg := "T001AK"
    Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
    Local cDataDe := DToS(oWizard:GetDataDe())
    Local cDataAte := DToS(oWizard:GetDataAte())
    Local cAliasQry := GetNextAlias()
    Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
    Local lGeraT1AK := .T.
	Local lGerou := .F.

    DbSelectArea("C3Q")    
    C3Q->(DbSetOrder(1))

    // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
    Aadd(aArqGer,cTxtSys)

    // Montando a Estrutura da Query
    cSelect += " CCE_COD, CCE_DESCR "
    cJoin   :=  RetSqlName( "SD2" ) + " SD2	 "
    cJoin 	+=	" JOIN " + RetSqlName('CDT') + " CDT ON (CDT.CDT_FILIAL  = '" + xFilial( "CDT" ) + "' AND SD2.D2_DOC = CDT.CDT_DOC AND SD2.D2_SERIE = CDT.CDT_SERIE AND SD2.D2_CLIENTE = CDT.CDT_CLIfOR AND SD2.D2_LOJA = CDT.CDT_LOJA AND CDT.D_E_L_E_T_= ' ') "
    cJoin 	+=	" JOIN " + RetSqlName('CCE') + " CCE ON (CCE.CCE_FILIAL  = '" + xFilial( "CCE" ) + "' AND CCE.CCE_COD = CDT.CDT_IfCOMP AND CCE.D_E_L_E_T_= ' ') "

    // Movimento de Saida (SD2)
    cWhere := " SD2.D2_EMISSAO >= '" + cDataDe + "' AND SD2.D2_EMISSAO <='" + cDataAte + "' "
    cWhere += " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
    cWhere += " AND SD2.D_E_L_E_T_ = ' ' "

    cUnion := RetSqlName( "SD1" ) + " SD1	 "
    cUnion +=	" JOIN " + RetSqlName('CDT') + " CDT ON (CDT.CDT_FILIAL  = '" + xFilial( "CDT" ) + "' AND SD1.D1_DOC = CDT.CDT_DOC AND SD1.D1_SERIE = CDT.CDT_SERIE AND SD1.D1_FORNECE = CDT.CDT_CLIfOR AND SD1.D1_LOJA = CDT.CDT_LOJA AND CDT.D_E_L_E_T_= ' ') "
    cUnion +=	" JOIN " + RetSqlName('CCE') + " CCE ON (CCE.CCE_FILIAL  = '" + xFilial( "CCE" ) + "' AND CCE.CCE_COD = CDT.CDT_IfCOMP AND CCE.D_E_L_E_T_= ' ') "

    // Movimento de Entrada (SD1)
    cWhere2 := " SD1.D1_DTDIGIT >= '" + cDataDe + "' AND SD1.D1_DTDIGIT <='" + cDataAte + "' "
    cWhere2 += " AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
    cWhere2 += " AND SD1.D_E_L_E_T_ = ' ' "

    // Definindo Estrutura para Execucao do BeginSql
    cSelect   := "%" + cSelect  + "%"
    cJoin     := "%" + cJoin    + "%"
    cWhere    := "%" + cWhere   + "%"
    cUnion    := "%" + cUnion   + "%"
    cWhere2   := "%" + cWhere2  + "%"

    BeginSql Alias cAliasQry
        SELECT
        %Exp:cSelect%
        FROM
        %Exp:cJoin%
        WHERE
        %EXP:cWhere%
        UNION
        SELECT
        %Exp:cSelect%
        FROM
        %Exp:cUnion%
        WHERE
        %Exp:cWhere2%
    EndSql

    DbSelectArea( cAliasQry )
    While (cAliasQry)->(!Eof())
        
        If lGeraT1AK
			lGerou := .T.
            aRegs := {}
            
            (cAliasQry)->( Aadd( aRegs, { cReg,CCE_COD,CCE_DESCR } ) )
            
            FConcTxt(aRegs,nHdlTxt)
            
            // Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
            If cTpSaida == "2"
                FConcST1()
            EndIf
        EndIf
        
        (cAliasQry)->(DbSkip())
    EndDo

    (cAliasQry)->(DbCloseArea())

    // Libero Handle do Arquivo
    If cTpSaida == "1" 
        FClose(nHdlTxt)
    EndIf

Return lGerou

/*/{Protheus.doc} fLayT001AL
    (Função para executar o layout T001AL)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT001AL()

    fMsgPrcss("Gerando Registro T001AL - Observações do Livro Fiscal...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T001AL",2)
	
    // Monta o layout T001AL
    If RegT001AL()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AL",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T001AL",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT001AL
	(Realiza a geracao do registro T001AL do TAF)

	@type Static Function
	@author Fabio V Santana
	@since 25/03/2013

	@return lGerou, logico, se gerou ou não.

	@Obs Função refeita - 04/05/2018 - Vitor Ribeiro
	/*/
Static Function RegT001AL()

	Local aRegT001AL := {}

	Local cJoin := ""
	Local cReg := "T001AL"
	Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
	Local cAliasQry := GetNextAlias()

	Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)

	Local lGerou := .F.

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)

	if lFiltReinf .Or. cFiltInt != '1'
		cJoin := "INNER JOIN ( "
		cJoin += "	SELECT DISTINCT "
		cJoin += "		CDA.CDA_IfCOMP LAN_FISCAL "
		cJoin += "	FROM " + RetSqlName("CDA") + " CDA "

		cJoin += "	INNER JOIN " + RetSqlName("SFT") + " SFT ON "
		cJoin += "		SFT.D_E_L_E_T_ = ' ' "
		cJoin += "		AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
		cJoin += "		AND SFT.FT_TIPOMOV = CDA.CDA_TPMOVI "
		cJoin += "		AND SFT.FT_NFISCAL = CDA.CDA_NUMERO "
		cJoin += "		AND SFT.FT_SERIE = CDA.CDA_SERIE "
		cJoin += "		AND SFT.FT_CLIEFOR = CDA.CDA_CLIfOR "
		cJoin += "		AND SFT.FT_LOJA = CDA.CDA_LOJA "
		cJoin += "		AND SFT.FT_ITEM = CDA.CDA_NUMITE "
		cJoin += "		AND SFT.FT_ENTRADA >= '" + DToS(oWizard:GetDataDe()) + "' "
		cJoin += "		AND SFT.FT_ENTRADA <= '" + DToS(oWizard:GetDataAte()) + "' "

		cJoin += "	WHERE "
		cJoin += "		CDA.D_E_L_E_T_ = ' ' "
		cJoin += "		AND CDA.CDA_FILIAL = '" + xFilial("CDA") + "' "
		cJoin += ") MOVI ON "
		cJoin += "	MOVI.LAN_FISCAL = CCE.CCE_COD "
	EndIf

	// Definindo Estrutura para Execucao do BeginSql
	cJoin := "%" + cJoin + "%"

	BeginSql Alias cAliasQry
		SELECT
			CCE.R_E_C_N_O_ RECCCE
		FROM %Table:CCE% CCE

		%Exp:cJoin%

		WHERE
			CCE.CCE_FILIAL = %xFilial:CCE%
			AND CCE.%NotDel%
	EndSql
		
	DbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())
		CCE->(DbGoTo((cAliasQry)->RECCCE))
		
		lGerou := .T.

		aRegT001AL := {}
		Aadd(aRegT001AL,{})
		nPosicao := Len(aRegT001AL)

		Aadd(aRegT001AL[nPosicao],cReg)				// 01 - REGISTRO
		Aadd(aRegT001AL[nPosicao],CCE->CCE_COD)		// 02 - COD_OBS
		Aadd(aRegT001AL[nPosicao],CCE->CCE_DESCR)	// 03 - TXT_COMPL

		FConcTxt(aRegT001AL,nHdlTxt)

		// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
		If cTpSaida == "2"
			FConcST1()
		EndIf
		
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	// Libero Handle do Arquivo
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf

Return lGerou

/*/{Protheus.doc} fLayT002
    (Função para executar o layout T002)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT002()

	//Cria log para campos pessoais/sensiveis
	if findFunction('FwPDLogUser'); FwPDLogUser(ProcName(),2); endif

	fMsgPrcss("Gerando Registro T002 - Contabilista...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T002",2)
	
    // Monta o layout T002
    If RegT002()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T002",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T002",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT002
    (Realiza a geracao do registro T002 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 17/04/2013

    @return lGerou, logico, se gerou ou não.
    /*/
Static Function RegT002()

    Local aRegT002 := {}

    Local cAliasQry := ""
    Local cReg := "T002"
    Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"

    Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
	Local nPosicao := 0

	Local lGerou := .F.

    // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
    Aadd(aArqGer,cTxtSys)

	// Busca o proximo alias
	cAliasQry := GetNextAlias()

	// Montando a Estrutura da Query
    BeginSql Alias cAliasQry
		SELECT 
			CVB.R_E_C_N_O_ RECCVB
		FROM %Table:CVB% CVB

		WHERE
			CVB.CVB_FILIAL = %xFilial:CVB%
			AND (
				(
					%Exp:DToS(oWizard:GetDataDe())% BETWEEN CVB.CVB_DTINI AND CVB.CVB_DTFIM
				)
				OR (
					%Exp:DToS(oWizard:GetDataAte())% BETWEEN CVB.CVB_DTINI AND CVB.CVB_DTFIM
				)
				OR (
					CVB.CVB_DTINI <= %Exp:DToS(oWizard:GetDataDe())%
					AND CVB.CVB_DTFIM >= %Exp:DToS(oWizard:GetDataAte())%
				)
				OR (
					CVB.CVB_DTINI <= %Exp:DToS(oWizard:GetDataDe())%
					AND CVB.CVB_DTFIM = %Exp:Replicate(" ",8)%
				)
				OR (
					CVB.CVB_DTINI = %Exp:Replicate(" ",8)%
					AND CVB.CVB_DTFIM >= %Exp:DToS(oWizard:GetDataAte())%
				)
				OR (
					CVB.CVB_DTINI = %Exp:Replicate(" ",8)%
					AND CVB.CVB_DTFIM = %Exp:Replicate(" ",8)%
				)
			)
			AND CVB.%NotDel%
    EndSql

    DbSelectArea(cAliasQry)
    While (cAliasQry)->(!Eof())
		// Posiciona no registro 
		CVB->(DbGoTo((cAliasQry)->RECCVB))

		lGerou := .T.

		aRegT002 := {}
		Aadd(aRegT002,{})
		nPosicao := Len(aRegT002)

		Aadd(aRegT002[nPosicao],cReg)									// 01 - REGISTRO
		Aadd(aRegT002[nPosicao],IIf(!Empty(CVB->CVB_CGC),"2","1"))		// 02 - TP_ESTAB
		Aadd(aRegT002[nPosicao],CVB->CVB_NOME)							// 03 - NOME
		Aadd(aRegT002[nPosicao],CVB->CVB_CPF)							// 04 - CPF
		Aadd(aRegT002[nPosicao],CVB->CVB_CRC)							// 05 - CRC
		Aadd(aRegT002[nPosicao],CVB->CVB_CGC)							// 06 - CNPJ
		Aadd(aRegT002[nPosicao],CVB->CVB_CEP)							// 07 - CEP
		Aadd(aRegT002[nPosicao],"")										// 08 - TP_LOGR
		Aadd(aRegT002[nPosicao],FisGetEnd(CVB->CVB_END,CVB->CVB_UF)[1])	// 09 - END
		Aadd(aRegT002[nPosicao],FisGetEnd(CVB->CVB_END,CVB->CVB_UF)[3])	// 10 - NUM
		Aadd(aRegT002[nPosicao],CVB->CVB_COMPL)							// 11 - COMPL
		Aadd(aRegT002[nPosicao],"")										// 12 - TP_BAIRRO
		Aadd(aRegT002[nPosicao],CVB->CVB_BAIRRO)						// 13 - BAIRRO
		Aadd(aRegT002[nPosicao],"")										// 14 - DDD
		Aadd(aRegT002[nPosicao],CVB->CVB_TEL)							// 15 - FONE
		Aadd(aRegT002[nPosicao],"")										// 16 - DDD
		Aadd(aRegT002[nPosicao],CVB->CVB_FAX)							// 17 - FAX
		Aadd(aRegT002[nPosicao],CVB->CVB_EMAIL)							// 18 - EMAIL
		Aadd(aRegT002[nPosicao],CVB->CVB_UF)							// 19 - UF
		Aadd(aRegT002[nPosicao],CVB->CVB_CODMUN)						// 20 - COD_MUN
		Aadd(aRegT002[nPosicao],"")										// 21 - IDENT_QUALIF

		FConcTxt(aRegT002,nHdlTxt)
		
		// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1
		If cTpSaida == "2"
			FConcST1()
		EndIf
        
        (cAliasQry)->(DbSkip())
    EndDo

    (cAliasQry)->(DbCloseArea())

    // Libero Handle do Arquivo
    If cTpSaida == "1"
        FClose(nHdlTxt)
    EndIf

Return lGerou

/*/{Protheus.doc} fLayT003
    (Função para executar o layout T003)

	@param n_HdlT003, numerico, handle do arquivo T003
	@param a_RegT003, array, Array que sera preenchido com todos os participantes encontrados no T003
	@param c_CodPart, caracter, Código do participante específico a ser gerado
    @param a_WizFin, array, contém a wizard do financeiro

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT003(n_HdlT003,a_RegT003,c_CodPart,a_WizFin, cAlT003, _aListT003 )
	
	Local cTxtSys 		:= cDirSystem + "\T003.TXT"
	Default n_HdlT003 	:= 0

	Default a_RegT003 	:= {}
    Default a_WizFin 	:= {}

	Default c_CodPart 	:= ''
	Default cAlT003		:= 'SA1'
	Default _aListT003 := {}

	//Cria log para campos pessoais/sensiveis
	if findFunction('FwPDLogUser'); FwPDLogUser(ProcName(),2); endif
	
	If Empty(n_HdlT003) .And. cTpSaida=="1"
		n_HdlT003 := MsFCreate(cTxtSys)  
	EndIf

	fMsgPrcss("Gerando Registro T003 - Participantes...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T003",2)
	
	If !lFiltReinf // Gera os registros com movimento e filtra REINF não ou carga (filtra REINF não e Somente Cadastros)
		
		// Monta o layout T003
		If RegT003(@n_HdlT003,@a_RegT003,c_CodPart,a_WizFin, @_aListT003 )
			lGerFilial := .F.
			a_RegT003  := {}	

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,"T003",3)
		Else
			lGerFilPar := .T.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,"T003",1)
		EndIf
		
	Else // Gera os registros com filtra REINF sim
		FatuCrT003( @a_RegT003, oWizard )
		FatuCpT003( @a_RegT003, oWizard )
		NotaEST003( @a_RegT003, oWizard )

		If !Empty( a_RegT003 )
			lGerFilial := .F.
			FisaExtW01(cFilProc,0,"T003",3)
		Else
			lGerFilPar := .T.
			FisaExtW01(cFilProc,0,"T003",1)
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} RegT003
	(Realiza a geracao do registro T003 do TAF)

    @type Static Function
	@author Rodrigo Aguilar
	@since 20/03/2013

	@param n_HdlT003, numerico, handle do arquivo T003
	@param a_RegT003, array, Array que sera preenchido com todos os participantes encontrados no T003
	@param c_CodPart, caracter, Código do participante específico a ser gerado
    @param a_WizFin, array, contém a wizard do financeiro

	@return lGerou, logico, se gerou ou não.

	@obs Os parametros aParticip e c_CodPart foram criados inicialmente para contemplar a geração do Bloco K
	apenas. Contudo foi identIficado a necessidade de ampliar a utilização desses parâmetros
	na geração de outros registros. Devido a isso, a utilização da função RegT003 ficou da
	seguinte forma:
	- Quando chamada a função sem envio do parâmetro c_CodPart, ela irá processar os participantes
		previstos nos JOINS da função ( documentos fiscais e seus complementos ), alimentando no final
		o parametro aParticip
	- Quando chamada a função enviando o parâmetro c_CodPart, a função entEnderá que deverá ser alimentado
		o array aParticip apenas para o participante desejado.
	- No final do processamento da função principal do extrator, antes da consolidação dos arquivos, o
		array aParticip será descarregado no Handle do registro T003. Quando utilizado modelo banco a banco,
		a tabela TAFST1 será gravada por demanda ( o TAF se encarrega de ordenar os registros corretamente
		na integração ).
	/*/
Function RegT003(n_HdlT003,a_RegT003,c_CodPart,a_WizFin, a_ListT003)

	Local cRegT003     := "T003"
	Local cTxtSys      := cDirSystem + "\" + cRegT003 + ".TXT"
	Local cCpf         := ""
	Local cCgc         := ""
	Local cTpPessoa    := ""
	Local cClient      := ""
	Local cFornec      := ""
	Local cAnoRefIni   := ""
	Local cAnoRefFim   := ""
	Local cMesRefIni   := ""
	Local cMesRefFim   := ""
	Local cDataDe      := ""
	Local cDataAte     := ""
	Local cAliasQry    := ""
	Local cQuery       := ""
	Local cJoinSA2     := ""
	Local cJoinSA1     := ""
	Local cJoinSB6     := ""
	Local cExecPAA     := ""
	Local cCodPart     := ""
	Local cEstados     := AllTrim(SuperGetMV("MV_TAFESLB",.F.,"SP|MG"))
	Local nHdlTxt      := IIf(Empty(n_HdlT003),IIf(cTpSaida=="1",MsFCreate(cTxtSys),0),n_HdlT003)
	Local nPosicao     := 0
	Local aFisGetEnd   := {}
	Local lCarga       := !lFiltReinf .And. cFiltInt == "1"
	Local lGerou       := .F.

	//Endereco fornecedor exterior
	Local cPaisEX      := ""
	Local cEndEX       := ""
	Local cNumEx       := ""
	Local cComplEX     := ""
	Local cBaiEX       := ""
	Local cMunEX       := ""
	Local cCepEX       := ""
	Local aGetEndEX    := {}
	Local cRelFont     := ""

	Default n_HdlT003  := 0
	Default a_RegT003  := {}
    Default a_WizFin   := {}
    Default a_ListT003 := {}
	Default c_CodPart  := ''

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)

	if oFisaExtSx:_DHT
		DbSelectArea("DHT")    
		DHT->(DbSetOrder(1))
	EndIF
	//DHT->(DBGOTOP())

	// Tratamento para geração do participante para os itens do bloco k
	n_HdlT003 := nHdlTxt

	cAnoRefIni := Substr(DToS(oWizard:GetDataDe()),1,4)
	cAnoRefFim := Substr(DToS(oWizard:GetDataAte()),1,4)
	cMesRefIni := Substr(DToS(oWizard:GetDataDe()),5,2)
	cMesRefFim := Substr(DToS(oWizard:GetDataAte()),5,2)
	cDataDe := DToS(oWizard:GetDataDe())
	cDataAte := DToS(oWizard:GetDataAte())

	cAliasQry := GetNextAlias()

	// VerIfica se esta sEndo chamado pelo bloco K
	If Empty(c_CodPart)

		If !lCarga
			// Join com a SFT e SF9
			cJoinSA2 := " SELECT DISTINCT "
			If oFisaExtSx:_FT_CLIDVMC
				cJoinSA2 += "	 CASE WHEN SFT.FT_CLIDVMC<>'' THEN SFT.FT_CLIDVMC	Else SFT.FT_CLIEFOR	End CLIEFOR "
				cJoinSA2 += "	,CASE WHEN SFT.FT_LOJDVMC<>'' THEN SFT.FT_LOJDVMC	Else SFT.FT_LOJA	End LOJA"
			Else
				cJoinSA2 += "	 SFT.FT_CLIEFOR CLIEFOR "
				cJoinSA2 += "	,SFT.FT_LOJA LOJA "
			EndIf
			cJoinSA2 += "	,'' ESTADO "
			cJoinSA2 += "	,CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('B','D')) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('B','D')) THEN " 
			cJoinSA2 += "		'SFTFOR' "
			cJoinSA2 += "	 Else "
			cJoinSA2 += "		'SFTCLI' "
			cJoinSA2 += "	 End TIPO "
			cJoinSA2 += " FROM " + RetSqlName("SFT") + " SFT "
			cJoinSA2 += CRLF
			cJoinSA2 += " WHERE "
			cJoinSA2 += "	SFT.D_E_L_E_T_ = ' ' " 
			cJoinSA2 += "	AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
			cJoinSA2 += "	AND SFT.FT_ENTRADA>='" + cDataDe + "' " 
			cJoinSA2 += "	AND SFT.FT_ENTRADA<='" + cDataAte + "' "
			
			If !Empty(oWizard:GetNotaAte())
				cJoinSA2 += "	AND SFT.FT_NFISCAL >= '" + oWizard:GetNotaDe() + "' "
				cJoinSA2 += "	AND SFT.FT_NFISCAL <= '" + oWizard:GetNotaAte() + "' "
				If !(Empty(oWizard:GetSerieDe()) .And. oWizard:GetSerieAte()='ZZZ')
					cJoinSA2 += "	AND SFT.FT_SERIE   >= '" + oWizard:GetSerieDe() + "' "
					cJoinSA2 += "	AND SFT.FT_SERIE   <= '" + oWizard:GetSerieAte() + "' "
				Endif
				
				If !Empty(oWizard:GetEspecie())
					cJoinSA2 += "	AND SFT.FT_ESPECIE IN  (" + oWizard:GetEspecie(.T.) + ") "
				EndIf

				If oWizard:GetTipoMovimento() == '2'		//2-Entradas	(Notas de Entrada)
					cJoinSA2 += "	AND SFT.FT_TIPOMOV = 'E' "
				ElseIf oWizard:GetTipoMovimento() == '3'		//3-Saidas  	(Notas de Saída)
					cJoinSA2 += "	AND SFT.FT_TIPOMOV = 'S' "
				EndIf
				
			EndIf
			
			If !lFiltReinf .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				cJoinSA2 += CRLF
				cJoinSA2 += " UNION "
				cJoinSA2 += CRLF
				cJoinSA2 += " SELECT DISTINCT "
				cJoinSA2 += "	 SF9.F9_CLIENTE CLIEFOR "
				cJoinSA2 += "	,SF9.F9_LOJACLI LOJA "
				cJoinSA2 += "	,'' ESTADO "
				cJoinSA2 += "	,'SF9' TIPO "
				cJoinSA2 += " FROM " + RetSqlName("SF9") + " SF9 "
				cJoinSA2 += CRLF
				cJoinSA2 += " WHERE "
				cJoinSA2 += "	SF9.D_E_L_E_T_ = ' ' " 
				cJoinSA2 += "	AND SF9.F9_FILIAL = '" + xFilial("SF9") + "' "

				If !Empty(oWizard:GetNotaAte())

					If oWizard:GetTipoMovimento() == '2'		//2-Entradas	(Notas de Entrada)

						cJoinSA2 += "	AND (	SF9.F9_DOCNFE >= '" + oWizard:GetNotaDe() + "' "
						cJoinSA2 += "		AND SF9.F9_DOCNFE <= '" + oWizard:GetNotaAte() + "' "
						cJoinSA2 += "		AND SF9.F9_SERNFE >= '" + oWizard:GetSerieDe() + "' "
						cJoinSA2 += "		AND SF9.F9_SERNFE <= '" + oWizard:GetSerieAte() + "') "

					ElseIf oWizard:GetTipoMovimento() == '3'		//3-Saídas		(Notas de Saída)

						cJoinSA2 += "	AND	( 	SF9.F9_DOCNFS >= '" + oWizard:GetNotaDe() + "' "
						cJoinSA2 += "		AND SF9.F9_DOCNFS <= '" + oWizard:GetNotaAte() + "' "
						cJoinSA2 += "		AND SF9.F9_SERNFS >= '" + oWizard:GetSerieDe() + "' "
						cJoinSA2 += "		AND SF9.F9_SERNFS <= '" + oWizard:GetSerieAte() + "') "

					Else

						cJoinSA2 += "	AND ( ( SF9.F9_DOCNFE >= '" + oWizard:GetNotaDe() + "' "
						cJoinSA2 += "			AND SF9.F9_DOCNFE  <= '" + oWizard:GetNotaAte() + "' "
						cJoinSA2 += "			AND SF9.F9_SERNFE >= '" + oWizard:GetSerieDe() + "' "
						cJoinSA2 += "			AND SF9.F9_SERNFE <= '" + oWizard:GetSerieAte() + "') "
						cJoinSA2 += "	OR ( SF9.F9_DOCNFS >= '" + oWizard:GetNotaDe() + "' "
						cJoinSA2 += "			AND SF9.F9_DOCNFS  <= '" + oWizard:GetNotaAte() + "' "
						cJoinSA2 += "			AND SF9.F9_SERNFS  >= '" + oWizard:GetSerieDe() + "' "
						cJoinSA2 += "			AND SF9.F9_SERNFS  <= '" + oWizard:GetSerieAte() + "')) "

					EndIf

				EndIf

				// Join SFT, SF9, SF6 e SL1
				cJoinSA1 := cJoinSA2
				cJoinSA1 += CRLF
				cJoinSA1 += " UNION "
				cJoinSA1 += CRLF
				cJoinSA1 += " SELECT DISTINCT "
				cJoinSA1 += "	 SF6.F6_CLIfOR CLIEFOR "
				cJoinSA1 += "	,SF6.F6_LOJA LOJA "
				cJoinSA1 += "	,SF6.F6_EST ESTADO "
				cJoinSA1 += "	,'SF6' TIPO "
				cJoinSA1 += " FROM " + RetSqlName("SF6") + " SF6 "
				cJoinSA1 += CRLF
				cJoinSA1 += " WHERE "
				cJoinSA1 += "	SF6.D_E_L_E_T_ = ' ' "
				cJoinSA1 += "	AND SF6.F6_FILIAL = '" + xFilial("SF6") + "' "
				cJoinSA1 += "	AND SF6.F6_ANOREF >= '" + cAnoRefIni + "' "
				cJoinSA1 += "	AND SF6.F6_ANOREF <= '" + cAnoRefFim + "' "
				cJoinSA1 += "	AND SF6.F6_MESREF >= '" + cMesRefIni + "' "
				cJoinSA1 += "	AND SF6.F6_MESREF <= '" + cMesRefFim + "' "

				If oFisaExtSx:_SL1 .And. oFisaExtSx:_SL4
					cJoinSA1 += CRLF
					cJoinSA1 += " UNION "
					cJoinSA1 += CRLF
					cJoinSA1 += " SELECT DISTINCT "
					cJoinSA1 += "	 " + xFunExpSql("SUBSTR") + "(SL4.L4_ADMINIS,1,3) CLIEFOR "
					cJoinSA1 += "	,'' LOJA "
					cJoinSA1 += "	,'' ESTADO "
					cJoinSA1 += "	,'SL1' TIPO "
					cJoinSA1 += " FROM " + RetSqlName("SL1") + " SL1 "
					cJoinSA1 += CRLF
					cJoinSA1 += " INNER JOIN " + RetSqlName("SL4") + " SL4 ON "
					cJoinSA1 += "	SL4.D_E_L_E_T_ = ' ' "
					cJoinSA1 += "	AND SL4.L4_FILIAL = SL1.L1_FILIAL "
					cJoinSA1 += "	AND SL4.L4_NUM = SL1.L1_NUM "
					cJoinSA1 += "	AND (SL4.L4_FORMA = 'CC' "
					cJoinSA1 += "	OR SL4.L4_FORMA = 'CD') "
					cJoinSA1 += CRLF
					cJoinSA1 += " WHERE "
					cJoinSA1 += "	SL1.D_E_L_E_T_ = ' ' "
					cJoinSA1 += "	AND SL1.L1_FILIAL = '" + xFilial("SL1") + "' "
					cJoinSA1 += "	AND SL1.L1_DOC <> ' ' "
					cJoinSA1 += "	AND SL1.L1_EMISNF >= '" + cDataDe + "' "
					cJoinSA1 += "	AND SL1.L1_EMISNF <= '" + cDataAte + "' "
					cJoinSA1 += "	AND (SL1.L1_CARTAO > 0 "
					cJoinSA1 += "	OR SL1.L1_VLRDEBI > 0) "
				EndIf

				cJoinSB6 := " SELECT DISTINCT "
				cJoinSB6 += "     SB6.B6_CLIfOR CLIEFOR "
				cJoinSB6 += "    ,SB6.B6_LOJA LOJA "
				cJoinSB6 += "    ,'' ESTADO "
				cJoinSB6 += "    ,'SB6' TIPO "
				cJoinSB6 += " FROM " + RetSqlName("SB6") + " SB6 "
				cJoinSB6 += CRLF
				cJoinSB6 += " WHERE "
				cJoinSB6 += "    SB6.D_E_L_E_T_ = ' ' "
				cJoinSB6 += "    AND SB6.B6_FILIAL = '" + xFilial("SB6") + "' "
				cJoinSB6 += "    AND SB6.B6_DTDIGIT <= '" + cDataAte + "' "
			EndIf		
		EndIf
		
		// Query principal
		cQuery := " SELECT DISTINCT "
		cQuery += "	CAST('SA1' AS char(3)) TABELA "
		cQuery += "	,SA1.R_E_C_N_O_ RECNO "
		cQuery += " FROM " + RetSqlName("SA1") + " SA1 "

		If lCarga
			cQuery += " LEFT OUTER JOIN ( "
			cQuery += "	 SELECT "  
			cQuery += "		SAE.AE_COD CLIEFOR"
			cQuery += "		,'SL1' TIPO "
			cQuery += "	 FROM " + RetSqlName("SAE") + " SAE "
			cQuery += "	 WHERE "
			cQuery += "		SAE.D_E_L_E_T_ = ' ' "
			cQuery += "		AND SAE.AE_FILIAL = '" + xFilial("SAE") + "' "
			cQuery += " ) MOVIM ON "
			cQuery += "	MOVIM.CLIEFOR = SA1.A1_COD "
		Else
			if !lFiltReinf .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				cQuery += " INNER JOIN ( "
				cQuery += cJoinSA1
				cQuery += "UNION "
				cQuery += cJoinSB6
				cQuery += "	AND SB6.B6_TPCF = 'C' "
				cQuery += " ) MOVIM ON "
				cQuery += "	((MOVIM.TIPO = 'SFTCLI' OR MOVIM.TIPO = 'SF9' OR MOVIM.TIPO = 'SB6') AND MOVIM.CLIEFOR = SA1.A1_COD AND MOVIM.LOJA = SA1.A1_LOJA) "
				cQuery += "	OR (MOVIM.TIPO = 'SF6' AND MOVIM.CLIEFOR = SA1.A1_COD AND MOVIM.LOJA = SA1.A1_LOJA AND MOVIM.ESTADO = SA1.A1_EST) "
				cQuery += "	OR (MOVIM.TIPO = 'SL1' AND MOVIM.CLIEFOR = SA1.A1_COD) "
			EndIf
		EndIf
		if !lFiltReinf .And. (cFiltInt $ "1|3" .Or. empty(cFiltInt))
			cQuery += " WHERE "
			cQuery += "	SA1.D_E_L_E_T_ = ' ' "
			cQuery += "	AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		ElseIf (cFiltInt $ "2|3" .Or. empty(cFiltInt))
			cQuery += " INNER JOIN ( "
			cQuery += cJoinSA2 + ") "
			cQuery += " MOVIM2 ON "
			cQuery += "	MOVIM2.CLIEFOR = SA1.A1_COD "
			cQuery += " AND MOVIM2.LOJA = SA1.A1_LOJA " 
		EndIf
		
		// Se for carga, leva somente o quer ativo.
		If lCarga
			cQuery += "	AND SA1.A1_MSBLQL <> '1' "
		EndIf
		
		cQuery += " UNION "
		
		cQuery += " SELECT DISTINCT "
		cQuery += "	CAST('SA2' AS char(3)) TABELA "
		cQuery += "	,SA2.R_E_C_N_O_ RECNO "
		cQuery += " FROM " + RetSqlName("SA2") + " SA2 "
		
		If !lCarga
			If !lFiltReinf .And. (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				cQuery += " INNER JOIN ( "
				cQuery += cJoinSA2
				cQuery += "UNION "
				cQuery += cJoinSB6
				cQuery += "	AND SB6.B6_TPCF = 'F' "
				cQuery += " ) MOVIM ON "
				cQuery += "	MOVIM.TIPO<> 'SFTCLI' "
				cQuery += "	AND MOVIM.CLIEFOR = SA2.A2_COD " 
				cQuery += "	AND MOVIM.LOJA = SA2.A2_LOJA "
			ElseIf (cFiltInt $ "2|3" .Or. empty(cFiltInt))
				cQuery += " INNER JOIN ( "
				cQuery += cJoinSA2
				cQuery += " ) MOVIM ON "
				cQuery += "	MOVIM.TIPO<> 'SFTCLI' "
				cQuery += "	AND MOVIM.CLIEFOR = SA2.A2_COD " 
				cQuery += "	AND MOVIM.LOJA = SA2.A2_LOJA "
			EndIf
		EndIf
		
		cQuery += " WHERE " 
		cQuery += "	SA2.D_E_L_E_T_ = ' ' "
		cQuery += "	AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		
		// Se for carga, leva somente o quer ativo.
		If lCarga
			cQuery += "	AND SA2.A2_MSBLQL <> '1' "
		EndIf
				
		cQuery := ChangeQuery(cQuery)
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry , .F., .T. )

	Else	// Desvio para quando enviado o parâmetro c_CodPart, neste caso fazer uma pesquisa exata pelo participante
		If Substr(Upper(c_CodPart),1,1) == "C"
			cClient := Padr(Substr(c_CodPart,2),TamSX3("A1_COD")[1])
		ElseIf Substr(Upper(c_CodPart),1,1) == "F"
			cFornec := Padr(Substr(c_CodPart,2),TamSX3("A2_COD")[1])
		EndIf
		
		BeginSql Alias cAliasQry
			SELECT
				'SA1' TABELA
				,SA1.R_E_C_N_O_ RECNO
			FROM %Table:SA1% SA1

			WHERE 
				SA1.A1_FILIAL=%xFilial:SA1% 
				AND SA1.A1_COD = %Exp:cClient%	
				AND SA1.%NotDel% 
				
			UNION
			
			SELECT 
				'SA2' TABELA
				,SA2.R_E_C_N_O_ RECNO
			FROM %Table:SA2% SA2
			
			WHERE 
				SA2.A2_FILIAL=%xFilial:SA2% 
				AND SA2.A2_COD = %Exp:cFornec%
				AND SA2.%NotDel%
		EndSql
	EndIf

	DbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())
		// Posiciona na tabela
		((cAliasQry)->TABELA)->(DbGoTo((cAliasQry)->RECNO))

		lGerou := .T.

		cCpf      := ""
		cCgc      := ""
		cTpPessoa := ""
		cExecPAA  := ""
		cPaisEX   := ""
		cEndEX    := ""
		cNumEx    := ""
		cComplEX  := ""
		cBaiEX    := ""
		cMunEX    := ""
		cCepEX    := ""
		aGetEndEX := {}
		cRelFont  := ""

		// Zera o array
		a_RegT003 := {}
		ASize(a_RegT003,0)
		Aadd(a_RegT003,{{}})
		nPosicao := Len(a_RegT003)

		Aadd(a_RegT003[nPosicao][1],"")	// 01 - REGISTRO
		Aadd(a_RegT003[nPosicao][1],"")	// 02 - COD_PART
		Aadd(a_RegT003[nPosicao][1],"")	// 03 - NOME
		Aadd(a_RegT003[nPosicao][1],"")	// 04 - COD_PAIS
		Aadd(a_RegT003[nPosicao][1],"")	// 05 - CNPJ
		Aadd(a_RegT003[nPosicao][1],"")	// 06 - CPF
		Aadd(a_RegT003[nPosicao][1],"")	// 07 - IE
		Aadd(a_RegT003[nPosicao][1],"")	// 08 - COD_MUN
		Aadd(a_RegT003[nPosicao][1],"")	// 09 - SUFRAMA
		Aadd(a_RegT003[nPosicao][1],"")	// 10 - TP_LOGR
		Aadd(a_RegT003[nPosicao][1],"")	// 11 - End
		Aadd(a_RegT003[nPosicao][1],"")	// 12 - NUM
		Aadd(a_RegT003[nPosicao][1],"")	// 13 - COMPL
		Aadd(a_RegT003[nPosicao][1],"")	// 14 - TP_BAIRRO
		Aadd(a_RegT003[nPosicao][1],"")	// 15 - BAIRRO
		Aadd(a_RegT003[nPosicao][1],"")	// 16 - UF
		Aadd(a_RegT003[nPosicao][1],"")	// 17 - CEP
		Aadd(a_RegT003[nPosicao][1],"")	// 18 - DDD
		Aadd(a_RegT003[nPosicao][1],"")	// 19 - FONE
		Aadd(a_RegT003[nPosicao][1],"")	// 20 - DDD
		Aadd(a_RegT003[nPosicao][1],"")	// 21 - FAX
		Aadd(a_RegT003[nPosicao][1],"")	// 22 - EMAIL
		Aadd(a_RegT003[nPosicao][1],"")	// 23 - DT_INCLUSAO
		Aadd(a_RegT003[nPosicao][1],"")	// 24 - TP_PESSOA
		Aadd(a_RegT003[nPosicao][1],"")	// 25 - RAMO_ATV
		Aadd(a_RegT003[nPosicao][1],"")	// 26 - COD_INST_ANP
		Aadd(a_RegT003[nPosicao][1],"")	// 27 - COD_ATIV
		Aadd(a_RegT003[nPosicao][1],"")	// 28 - COD_PAIS_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 29 - LOGRAD_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 30 - NR_LOGRAD_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 31 - COMPLEM_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 32 - BAIRRO_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 33 - NOME_CIDADE_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 34 - COD_POSTAL_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 35 - DT_LAUDO_MOLEST_GRAVE
		Aadd(a_RegT003[nPosicao][1],"")	// 36 - REL_FONTE_PAG_RESID_EXTERIOR
		Aadd(a_RegT003[nPosicao][1],"")	// 37 - INSCR_MUNICIPAL 
		Aadd(a_RegT003[nPosicao][1],"")	// 38 - SIMPLES_NACIONAL
		Aadd(a_RegT003[nPosicao][1],"")	// 39 - ENQUADRAMENTO
		Aadd(a_RegT003[nPosicao][1],"")	// 40 - OBSOLETO
		Aadd(a_RegT003[nPosicao][1],"")	// 41 - INDCPRB
		Aadd(a_RegT003[nPosicao][1],"")	// 42 - CODTRI
		Aadd(a_RegT003[nPosicao][1],"")	// 43 - EXECPAA
		Aadd(a_RegT003[nPosicao][1],"")	// 44 - IND_ASSOC_DESPORT
		Aadd(a_RegT003[nPosicao][1],"")	// 45 - CONTRIBUINTE
		Aadd(a_RegT003[nPosicao][1],"")	// 46 - INDOPCCP

		Aadd(a_RegT003[nPosicao][1],"")	// 47 - ISENCAO_IMUNIDADE 
		Aadd(a_RegT003[nPosicao][1],"")	// 48 - ESTADO_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 49 - TELEFONE_EXT
		Aadd(a_RegT003[nPosicao][1],"")	// 50 - INDICATIVO_NIF
		Aadd(a_RegT003[nPosicao][1],"")	// 51 - NIF
		Aadd(a_RegT003[nPosicao][1],"")	// 52 - FORMA_TRIBUTACAO

		a_RegT003[nPosicao][1][01] := cRegT003

		If (cAliasQry)->TABELA == "SA1"
			
			// Função para retorna a estrutura do Endereco passado
			aFisGetEnd := FisGetEnd(SA1->A1_End,SA1->A1_EST)

			// VerIficar qual o Tipo de Pessoa e CPF/CGC
			If AllTrim(SA1->A1_TIPO) <> "X"
				If AllTrim(SA1->A1_PESSOA) == "F"
					cCpf := SA1->A1_CGC // CPF
					cTpPessoa := "1"
					If TafColumnPos("AI0_CPFRUR")
						If Alltrim(SA1->A1_TIPO) == "L" .And. Alltrim(SA1->A1_EST) $ cEstados 
							cCpf := Posicione( "AI0", 1, xFilial( "AI0" ) + SA1->(A1_COD+A1_LOJA), "AI0_CPFRUR" ) // CPF
							cCgc := Alltrim(SA1->A1_CGC) // SE O CAMPO AI0_CPFRUR TIVER VALOR DIFERENTE DE ZERO E VAZIO, O CAMPO A1_CGC VIRA CNPJ MESMO SENDO PESSOA FISICA
						EndIf
					EndIf
				ElseIf AllTrim(SA1->A1_PESSOA) == "J"
					cCgc := SA1->A1_CGC // CGC
					cTpPessoa := "2"
				EndIf
			Else
				cTpPessoa := "3"
				
				If Len(AllTrim(SA1->A1_CGC)) == 11
					cCpf := SA1->A1_CGC // CPF
					cTpPessoa := "3"
				ElseIf Len(AllTrim(SA1->A1_CGC)) == 14
					cCgc := SA1->A1_CGC // CGC
					cTpPessoa := "3"
				EndIf
			EndIf
			
			If oFisaExtSx:_AI0
				AI0->(DbSetOrder(01))	// AI0_FILIAL+AI0_CODCLI+AI0_LOJA
				If AI0->(DbSeek(SA1->(A1_FILIAL+A1_COD+A1_LOJA))) .And. AI0->AI0_INDPAA == '1' 
					cExecPAA := '1'
				Else
					cExecPAA := '0'
				EndIf
			EndIf

			cCodPart := "C" + SA1->(A1_COD+A1_LOJA)
			a_RegT003[nPosicao][1][02] := cCodPart
			a_RegT003[nPosicao][1][03] := SA1->A1_NOME
			a_RegT003[nPosicao][1][04] := SA1->A1_CODPAIS
			a_RegT003[nPosicao][1][05] := cCgc
			a_RegT003[nPosicao][1][06] := cCpf
			a_RegT003[nPosicao][1][07] := SPEDConType(SPEDVldIE(SA1->A1_INSCR))
			a_RegT003[nPosicao][1][08] := IIf(SA1->A1_EST=="EX","99999",SA1->A1_COD_MUN)
			a_RegT003[nPosicao][1][09] := SA1->A1_SUFRAMA
			a_RegT003[nPosicao][1][11] := aFisGetEnd[1]
			a_RegT003[nPosicao][1][12] := IIf(!Empty(aFisGetEnd[2]),aFisGetEnd[3],"SN")
			a_RegT003[nPosicao][1][13] := SA1->A1_COMPLEM
			a_RegT003[nPosicao][1][15] := SA1->A1_BAIRRO
			a_RegT003[nPosicao][1][16] := SA1->A1_EST
			a_RegT003[nPosicao][1][17] := SA1->A1_CEP
			a_RegT003[nPosicao][1][18] := SA1->A1_DDD
			a_RegT003[nPosicao][1][19] := SA1->A1_TEL
			a_RegT003[nPosicao][1][20] := IIf(!Empty(SA1->A1_FAX),SA1->A1_DDD,"")
			a_RegT003[nPosicao][1][21] := SA1->A1_FAX
			a_RegT003[nPosicao][1][22] := SA1->A1_EMAIL
			a_RegT003[nPosicao][1][23] := SA1->A1_DTCAD
			a_RegT003[nPosicao][1][24] := cTpPessoa
			a_RegT003[nPosicao][1][41] := '0'
			a_RegT003[nPosicao][1][43] := cExecPAA
			a_RegT003[nPosicao][1][45] := SA1->A1_CONTRIB

		ElseIf (cAliasQry)->TABELA == "SA2"
			// Função para retorna a estrutura do Endereco passado
			aFisGetEnd := FisGetEnd(SA2->A2_End,SA2->A2_EST)

			// VerIficar qual o Tipo de Pessoa e CPF/CGC
			If AllTrim(SA2->A2_TIPO) <> "X"
				If AllTrim(SA2->A2_TIPO) == "F"
					cCpf := SA2->A2_CGC // CPF
					cTpPessoa := "1"
					If Alltrim(SA2->A2_INDRUR) != "" .AND.  Alltrim(SA2->A2_INDRUR) != "0" .AND. Alltrim(SA2->A2_EST) $ cEstados 
						If SA2->(DbSeek(SA2->(A2_FILIAL+A2_COD+A2_LOJA)))
							cCpf := Alltrim(SA2->A2_CPFRUR) // CPF
							cCgc := Alltrim(SA2->A2_CGC) // SE O CAMPO A2_INDRUR TIVER VALOR DIFERENTE DE ZERO E VAZIO, O CAMPO A2_CGC VIRA CNPJ MESMO SENDO PESSOA FISICA
						EndIf
					EndIf
				ElseIf AllTrim(SA2->A2_TIPO) == "J"
					cCgc := SA2->A2_CGC // CGC
					cTpPessoa := "2"
				EndIf
			Else
				cTpPessoa := "3"
			
				If Len(AllTrim(SA2->A2_CGC)) == 11
					cCpf := SA2->A2_CGC // CPF
					cTpPessoa := "3"
				ElseIf Len(AllTrim(SA2->A2_CGC)) == 14
					cCgc := SA2->A2_CGC // CGC
					cTpPessoa := "3"
				EndIf

				cPaisEX := SA2->A2_PAISEX
				aGetEndEX := FisGetEnd( SA2->A2_LOGEX, SA2->A2_ESTEX )
				cEndEX  := aGetEndEX[1]
				cNumEx  := Iif( !Empty( aGetEndEX[2]) , aGetEndEX[3], "SN" )
				cComplEX := SA2->A2_COMPLR
				cBaiEX := SA2->A2_BAIEX
				cMunEX := SA2->A2_CIDEX
				cCepEX := SA2->A2_POSEX
				cRelFont := SA2->A2_BREEX				
			EndIf

			cCodPart := "F" + SA2->(A2_COD+A2_LOJA)
			a_RegT003[nPosicao][1][02] := cCodPart
			a_RegT003[nPosicao][1][03] := SA2->A2_NOME
			a_RegT003[nPosicao][1][04] := SA2->A2_CODPAIS
			a_RegT003[nPosicao][1][05] := cCgc
			a_RegT003[nPosicao][1][06] := cCpf
			a_RegT003[nPosicao][1][07] := SPEDConType(SPEDVldIE(SA2->A2_INSCR))
			a_RegT003[nPosicao][1][08] := IIf(SA2->A2_EST=="EX","99999",SA2->A2_COD_MUN)
			a_RegT003[nPosicao][1][11] := aFisGetEnd[1]
			a_RegT003[nPosicao][1][12] := IIf(!Empty(aFisGetEnd[2]),aFisGetEnd[3],"SN")
			a_RegT003[nPosicao][1][13] := SA2->A2_COMPLEM
			a_RegT003[nPosicao][1][15] := SA2->A2_BAIRRO
			a_RegT003[nPosicao][1][16] := SA2->A2_EST
			a_RegT003[nPosicao][1][17] := SA2->A2_CEP
			a_RegT003[nPosicao][1][18] := SA2->A2_DDD
			a_RegT003[nPosicao][1][19] := SA2->A2_TEL
			a_RegT003[nPosicao][1][20] := IIf(!Empty(SA2->A2_FAX),SA2->A2_DDD,"")
			a_RegT003[nPosicao][1][21] := SA2->A2_FAX
			a_RegT003[nPosicao][1][22] := SA2->A2_EMAIL
			a_RegT003[nPosicao][1][23] := ''
			a_RegT003[nPosicao][1][24] := cTpPessoa
			a_RegT003[nPosicao][1][25] := IIf(!Empty(SA2->A2_TIPORUR),"4","")

			a_RegT003[nPosicao][1][28] := cPaisEX
			a_RegT003[nPosicao][1][29] := cEndEX
			a_RegT003[nPosicao][1][30] := cNumEx
			a_RegT003[nPosicao][1][31] := cComplEX
			a_RegT003[nPosicao][1][32] := cBaiEX
			a_RegT003[nPosicao][1][33] := cMunEX
			a_RegT003[nPosicao][1][34] := cCepEX
			a_RegT003[nPosicao][1][36] := cRelFont

			If SA2->(FieldPos("A2_INDCP")) > 0
				a_RegT003[nPosicao][1][46] := SA2->A2_INDCP // Campo utilizado para o evento S-1250
			EndIf	

			If oFisaExtSx:_A2_CPRB
				a_RegT003[nPosicao][1][41] := IIf(!Empty(SA2->A2_CPRB) .And. SA2->A2_CPRB <> '2','1','0')
			EndIf

			If oFisaExtSx:_A2_DESPORT
				a_RegT003[nPosicao][1][44] := IIf(SA2->A2_DESPORT=="1","1","2")
			EndIf

			a_RegT003[nPosicao][1][45] := SA2->A2_CONTRIB

			//Início de onde eu vou começar a fazer.
			IF oFisaExtSx:_A2_ISEIMUN
				a_RegT003[nPosicao][1][47] := SA2->A2_ISEIMUN
			EndIf

			IF oFisaExtSx:_A2_ESTEX
				a_RegT003[nPosicao][1][48] := SA2->A2_ESTEX
			EndIf

			IF  oFisaExtSx:_A2_TELRE
				a_RegT003[nPosicao][1][49] := SA2->A2_TELRE
			EndIf

			IF  oFisaExtSx:_A2_NIFEX .and. oFisaExtSx:_A2_MOTNIF
				a_RegT003[nPosicao][1][50] := IIf(!Empty(SA2->A2_NIFEX),"1",IIf(SA2->A2_MOTNIF=='1','2',IIf(SA2->A2_MOTNIF=='2','3',SA2->A2_MOTNIF)))
			EndIf

			IF  oFisaExtSx:_A2_NIFEX
				a_RegT003[nPosicao][1][51] := SA2->A2_NIFEX
			EndIf

			IF oFisaExtSx:_A2_TRBEX
				a_RegT003[nPosicao][1][52] := SA2->A2_TRBEX
			EndIf

		EndIf

		aadd( a_ListT003 , { cCodPart } )
		// Grava o registro.
		FConcTxt(a_RegT003[nPosicao],nHdlTxt)

		if (cAliasQry)->TABELA == "SA2" 
			a_RegT003AB := {}
			ASize(a_RegT003AB,0)
			nPosicaoAB := Len(a_RegT003AB)
			
			IF oFisaExtSx:_DHT
				IF DHT->(DBSEEK( xFilial("DHT")+SA2->(A2_COD+A2_LOJA)) )
					While DHT->(!Eof()) .and. DHT->(DHT_FILIAL+DHT_FORN+DHT_LOJA) == SA2->(A2_FILIAL+A2_COD+A2_LOJA)
								Aadd(a_RegT003AB,{})
								nColunaAB := Len(a_RegT003AB)

								Aadd(a_RegT003AB[nColunaAB],{"T003AB", DHT->DHT_COD,DHT->DHT_CPF,DHT->DHT_DTNASC,DHT->DHT_NOME,DHT->DHT_RELACA,DHT->DHT_PENSAO})
								FConcTxt(a_RegT003AB[nColunaAB],nHdlTxt)		
						DHT->(DbSkip())
					EndDo
				EndIF
				DHT->(DBCLOSEAREA())
			EndIf
		EndIf
		
		// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
		If cTpSaida == "2"
			FConcST1()
		EndIf

		(cAliasQry)->( DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	// Se estiver ok para execução do finaceiro e existir a função
	If lFFinExtOK .And. Empty(c_CodPart) .And. FindFunction("FExpT003") .And. !Empty(a_WizFin)
		// Gera o T003 conforme as regras do financeiro.
		If FExpT003(cFilAnt,cTpSaida,nHdlTxt,a_WizFin,, lFiltReinf, cFiltInt, @a_ListT003 )
			lGerou := .T.
		EndIf
	EndIf

Return lGerou

/*/{Protheus.doc} fLayT005
    (Função para executar o layout T005)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT005()

    fMsgPrcss("Gerando Registro T005 - Unidade de Medida...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T005",2)
	
    // Monta o layout T005
    If RegT005()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T005",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T005",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT005
    (Realiza a geracao do registro T005 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 21/03/2013

    @return lGerou, logico, se gerou ou não.
    /*/
Static Function RegT005()

Local cSelect := ""
Local cFrom := ""
Local cWhere := ""

Local cReg := "T005"
Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)

Local aRegs := {}

Local cAliasQry := GetNextAlias()
Local lGeraT005 := .T.
Local lGerou := .F.
Local lCarga := (!lFiltReinf  .And. cFiltInt == '1')

// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
Aadd(aArqGer,cTxtSys)

DbSelectArea("C1J")    
C1J->(DbSetOrder(1))

// Montando a Estrutura da Query
cFrom += RetSqlName("SAH") + " SAH "
cWhere += "SAH.AH_FILIAL = '" + xFilial("SAH") + "' AND "
cWhere += "SAH.D_E_L_E_T_ = ' ' "

If !lCarga
	cSelect += "DISTINCT AH_UNIMED, AH_UMRES "
	cWhere  += " AND EXISTS ( SELECT SFT.FT_PRODUTO FROM " + RetSqlName( "SFT" ) + " SFT "
	cWhere  += " 		  JOIN " + RetSqlName( "SB1" ) + " SB1 ON( SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' AND SB1.D_E_L_E_T_ = ' ' AND "
	cWhere  += " 		  SB1.B1_COD = SFT.FT_PRODUTO  )"
	cWhere  += "		  WHERE SAH.AH_UNIMED = SB1.B1_UM  AND SFT.D_E_L_E_T_ = ' ' AND SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' "
	if lFiltReinf
		cWhere  += " AND ( SFT.FT_BASEINS > 0 "
		if FNewMtoFis()
			cWhere  += "OR SFT.FT_IDTRIB <> ' ' "
		endif
		cWhere  += " ) "
	EndIf

	cWhere  += " 		AND SFT.FT_NFISCAL >= '" + oWizard:GetNotaDe() + "' AND SFT.FT_NFISCAL <='" + oWizard:GetNotaAte() + "' "
	If !(Empty(oWizard:GetSerieDe()) .And. oWizard:GetSerieAte()='ZZZ')
		cWhere  += " 		AND SFT.FT_SERIE   >= '" + oWizard:GetSerieDe() + "' AND SFT.FT_SERIE   <='" + oWizard:GetSerieAte() + "' "
	Endif
	cWhere  += "		AND SFT.FT_ENTRADA >= '" + DToS(oWizard:GetDataDe()) + "' "
	cWhere  += "		AND SFT.FT_ENTRADA <= '" + DToS(oWizard:GetDataAte()) + "' "

	If !Empty(oWizard:GetEspecie())
		cWhere += "		AND SFT.FT_ESPECIE IN (" + oWizard:GetEspecie(.T.) + ") "
	EndIf

	If oWizard:GetTipoMovimento() == '2'		// 2-Entradas (Notas de Entrada)
		cWhere += "	AND SFT.FT_TIPOMOV = 'E' "
	ElseIf oWizard:GetTipoMovimento() == '3'	// 3-Saídas (Notas de Saída)
		cWhere += "	AND SFT.FT_TIPOMOV = 'S' "
	EndIf
	cWhere += " )"

Else
	cSelect += " AH_UNIMED, AH_UMRES "
EndIf

// Definindo Estrutura para Execucao do BeginSql
cSelect   := "%" + cSelect  + "%"
cFrom     := "%" + cFrom    + "%"
cWhere    := "%" + cWhere   + "%"

BeginSql Alias cAliasQry
	SELECT
	%Exp:cSelect%
	FROM
	%Exp:cFrom%
	WHERE
	%Exp:cWhere%
EndSql

dbSelectArea( cAliasQry )

While (cAliasQry)->(!Eof())
	
	If lGeraT005
		lGerou := .T.

		aRegs := {}
		
		(cAliasQry)->(Aadd(aRegs,{cReg,(cAliasQry)->AH_UNIMED,(cAliasQry)->AH_UMRES," "}))
		
		FConcTxt(aRegs,nHdlTxt)
		
		// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
		If cTpSaida == "2"
			FConcST1()
		EndIf
	EndIf
	
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

// Libero Handle do Arquivo
If cTpSaida == "1" 
	FClose(nHdlTxt)
EndIf

Return lGerou

/*/{Protheus.doc} fLayT007
    (Função para executar o layout T007)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @param n_HdlT007, numerico, Handle do arquivo T007
    @param a_Produtos, array, Array que sera preenchido com todos os produtos encontrados no T007
    @param c_CodProd, caracter, Código do produto a ser gerado(parâmetro para bloco K)

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT007(n_HdlT007,a_Produtos,c_CodProd)

    Local lGerou := .T.
	Local nCount := 0
	Local cTxtSys := cDirSystem + "\T007.TXT"

	Default n_HdlT007 := 0
	
	Default a_Produtos := {}
	
	Default c_CodProd := ""
	
	If n_HdlT007==0 .And. cTpSaida=="1" 
		n_HdlT007 := MsFCreate(cTxtSys)  
	EndIf
	
	/*
		Geração T007 apenas quando a opção "Deseja Integrar" for diferente da opção 2 -> Movimentos
		ou
		função chamada para geração bloco K
	*/
	fMsgPrcss("Gerando Registro T007 - Produtos...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T007",2)
	
	// Monta o layout T007
	lGerou := RegT007(@n_HdlT007,@a_Produtos,c_CodProd)

	If lGerou
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T007",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T007",1)
	EndIf

Return Nil

/*/{Protheus.doc} RegT007
    (Realiza a geracao do registro T007 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 22/03/2013

    @param n_HdlT007, numerico, Handle do arquivo T007
    @param a_Produtos, array, Array que sera preenchido com todos os produtos encontrados no T007
    @param c_CodProd, caracter, Código do produto a ser gerado(parâmetro para bloco K)

    @return lGerou, logcio, se gerou ou não.

    @obs Os parametros a_Produtos e c_CodProd foram criados inicialmente para contemplar a geração do Bloco K
    apenas. Contudo foi identIficado a necessidade de ampliar a utilização desses parâmetros
    na geração de outros registros. Devido a isso, a utilização da função RegT007 ficou da
    seguinte forma:
    - Quando chamada a função sem envio do parâmetro c_CodProd, ela irá processar os produtos
    previstos nos JOINS da função ( documentos fiscais e seus complementos ), alimentando no final
    o parametro a_Produtos
    - Quando chamada a função enviando o parâmetro c_CodProd, a função entEnderá que deverá ser alimentado
    o array a_Produtos apenas para o produto desejado.
    - No final do processamento da função principal do extrator, antes da consolidação dos arquivos, o
    array a_Produtos será descarregado no Handle do registro T003. Quando utilizado modelo banco a banco,
    a tabela TAFST1 será gravada por demanda ( o TAF se encarrega de ordenar os registros corretamente
    na integração ).
    /*/
Function RegT007(n_HdlT007,a_Produtos,c_CodProd)

	Local aRegT006 := {}
	Local aSpedProd := {}
	
	Local cSelect := ""
	Local cFrom := ""
	Local cWhere := ""
	Local cChave := ""
	Local cCampo := ""
	Local cTipoPrd := ""
	Local cCodGen := ""
	Local cCodANP := ""
	Local cCodISS := ""
	Local cReg := "T007"
	Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
	Local cDataDe := DToS(oWizard:GetDataDe())
	Local cDataAte := DToS(oWizard:GetDataAte())
	Local cAliasQry := GetNextAlias()
	Local cSec := "01"
	Local cCmpIncB1 := oFisaExtSx:_MV_DTINCB1
	Local cTpServ := ""
	
	Local nHdlTxt := IIf(n_HdlT007 == 0,IIf(cTpSaida == "1",MsFCreate(cTxtSys),0),n_HdlT007)
	Local nICMPAD := oFisaExtSx:_MV_ICMPAD
	Local nAlqProd := 0
	Local nPos := 0
	
	Local lSpedProd := ExistBlock("SPEDPROD")
	Local lGeraT007 := .T.
	Local lCmpCdAnp := .F.
	Local cSet      := "HMSet"

	/*
		Combinação para carga completa T007

		Deseja integrar = Cadastros e Filtra Reinf = Não

		As demais combinações entre essas opções gera o T007 a partir de movimentações

	*/
	Local lCarga := !lFiltReinf .And. cFiltInt == "1"
	Local lGerou := .F.

	Default n_HdlT007 := 0
	
	Default a_Produtos := {}
	
	Default c_CodProd := ""
	
	DbSelectArea("C1L")		// IDENTIfICACAO DO ITEM
	C1L->(DbSetOrder(1))	// C1L_FILIAL+C1L_CODIGO
	
	DbSelectArea("C1J")		// UNIDADE DE MEDIDA
	C1J->(DbSetOrder(3))	// C1J_FILIAL+C1J_ID
	
	DbSelectArea("C2M")		// TIPO DE ITEM (INDS,COMS,SERVS)
	C2M->(DbSetOrder(3))	// C2M_FILIAL+C2M_ID
	
	DbSelectArea("C3Z")		// GENERO DO ITEM DE MERCADORIA
	C3Z->(DbSetOrder(3))	// C3Z_FILIAL+C3Z_ID
	
	DbSelectArea("C0B")		// CODIGO SERVICO (LCF 116/2003)
	C0B->(DbSetOrder(3))	// C0B_FILIAL+C0B_ID
	
	DbSelectArea("C03")		// ORIGENS DAS MERCADORIAS
	C03->(DbSetOrder(3))	// C03_FILIAL+C03_ID
	
	DbSelectArea("C0A")		// NOMENCLATURA COMUM MERCOSUL
	C0A->(DbSetOrder(3))	// C0A_FILIAL+C0A_ID
	
	DbSelectArea("C3V")		// INDIC. TAB. INCIDENCIA BEBIDA
	C3V->(DbSetOrder(3))	// C3V_FILIAL+C3V_ID
	
	DbSelectArea("C3X")		// MARCA COMERCIAL DA BEBIDA
	C3X->(DbSetOrder(3))	// C3X_FILIAL+C3X_ID
	
	DbSelectArea("CDN")		// COD. ISS
	CDN->(DbSetOrder(1))	// CDN_FILIAL+CDN_CODISS+CDN_PROD

	DbSelectArea("F2Q")		// COMPLEMENTO FISCAL
	F2Q->(DbSetOrder(1))	// F2Q_FILIAL+F2Q_PRODUT

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)
	
	// Montando a Estrutura da Query
	cSelect += " SB1.B1_COD, SB1.B1_DESC, SB1.B1_CODBAR, SB1.B1_UM, SB1.B1_TIPO, "
	cSelect += " SB1.B1_CODISS, SB1.B1_ORIGEM, SB1.B1_PICM, SB1.B1_IPI, SB1.B1_SEGUM ,SB1.B1_CONV, SB1.B1_FILIAL FILIAL, "
	cSelect += " SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.B1_CEST, SB5.B5_CODGRU, SB5.B5_TABINC "
	If !Empty(cCmpIncB1)
		cCmpIncB1 := StrTran(cCmpIncB1, '"','')
		cCmpIncB1 := StrTran(cCmpIncB1, "'",'')
		cSelect += ", SB1." + AllTrim(cCmpIncB1) + " INCB1"
	Else
		cSelect += ", '' INCB1"
	EndIf
	cFrom += RetSqlName("SB1") + " SB1 "
	
	cFrom += " LEFT JOIN " + RetSqlName("SB5") + " SB5 ON "
	cFrom += "	SB5.D_E_L_E_T_ = ' ' "
	cFrom += "	AND SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
	cFrom += "	AND SB5.B5_COD = SB1.B1_COD "
	
	cWhere += "	SB1.D_E_L_E_T_ = ' ' "
	cWhere += "	AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	
	// Tratamento para movimento
	If Empty(c_CodProd) .And. !lCarga 
		lCmpCdAnp := .T.
		
		cSelect += ", CD6.CD6_CODANP "
	
		cFrom += " INNER JOIN " + RetSqlName("SFT") + " SFT ON "
		cFrom += "	SFT.D_E_L_E_T_ = ' ' "
		cFrom += "	AND SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "'"
		cFrom += "	AND SFT.FT_ENTRADA >= '" + cDataDe + "'"
		cFrom += "	AND SFT.FT_ENTRADA <= '" + cDataAte + "'"
		cFrom += "	AND SFT.FT_PRODUTO = SB1.B1_COD "
		
		If !lCarga
			cFrom += "	AND SFT.FT_NFISCAL >= '" + oWizard:GetNotaDe() + "' "
			cFrom += "	AND SFT.FT_NFISCAL <= '" + oWizard:GetNotaAte() + "' "
			If !(Empty(oWizard:GetSerieDe()) .And. oWizard:GetSerieAte()='ZZZ')
				cFrom += "	AND SFT.FT_SERIE   >= '" + oWizard:GetSerieDe() + "' "
				cFrom += "	AND SFT.FT_SERIE   <= '" + oWizard:GetSerieAte() + "' "
			Endif
			If !Empty(oWizard:GetEspecie())
				cFrom += "	AND SFT.FT_ESPECIE IN (" + oWizard:GetEspecie(.T.) + ") "
			EndIf

			If oWizard:GetTipoMovimento() == '2'        // 2-Entradas (Notas de Entrada)
				cFrom += "	AND SFT.FT_TIPOMOV = 'E' "
			ElseIf oWizard:GetTipoMovimento() == '3'    // 3-Saídas (Notas de Saída)
				cFrom += "	AND SFT.FT_TIPOMOV = 'S' "
			EndIf
		EndIf

		if lFiltReinf
			cFrom += " AND SFT.FT_BASEINS > 0 "
		EndIf

		cFrom += " LEFT JOIN " + RetSqlName("CD6") + " CD6 ON "
		cFrom += "	CD6.D_E_L_E_T_ = ' ' "
		cFrom += "	AND CD6.CD6_FILIAL = '" + xFilial("CD6") + "' "
		cFrom += "	AND SFT.FT_TIPOMOV = CD6.CD6_TPMOV "
		cFrom += "	AND SFT.FT_NFISCAL = CD6.CD6_DOC "
		cFrom += "	AND SFT.FT_SERIE = CD6.CD6_SERIE "
		cFrom += "	AND SFT.FT_CLIEFOR = CD6.CD6_CLIfOR "
		cFrom += "	AND SFT.FT_LOJA = CD6.CD6_LOJA "
		cFrom += "	AND SFT.FT_ITEM = CD6.CD6_ITEM "
		cFrom += "	AND SFT.FT_PRODUTO = CD6.CD6_COD "
		
		if lFiltReinf
			cFrom += " AND SFT.FT_BASEINS > 0 "
		EndIf
		
	ElseIf !Empty(c_CodProd)
		//SE T045 ESTIVER SELECIONADO E EXISTIR UM PRODUTO NO PARAMETRO c_CodProd
		cWhere  += " AND SB1.B1_COD = '" + c_CodProd +"'"
	EndIf
	
	// Se for carga, não considera os registros bloqueados
	If lCarga
		cWhere  += " AND SB1.B1_MSBLQL <> '1' "
	EndIf
	
	// Definindo Estrutura para Execucao do BeginSql
	cSelect	:= "%" + cSelect + "%"
	cFrom	:= "%" + cFrom   + "%"
	cWhere	:= "%" + cWhere  + "%"
	
	BeginSql Alias cAliasQry
		SELECT DISTINCT 
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
	
	DbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())

		cTpServ := ""
		cCodISS := (cAliasQry)->B1_CODISS
		
		// Funcao De/Para referente ao titulo do Produto do Protheus para o TAF
		If lSpedProd
			aSpedProd := Execblock("SPEDPROD", .F., .F., {"SB1",""})
			If Len(aSpedProd) > 11
				cTipoPrd := aSpedProd[6]
			EndIf
		Else
			cTipoPrd := FDeParaTAF( "SB1", { (cAliasQry)->B1_TIPO, cCodISS } )
		EndIf
		
		// Para servico, utilizo sempre "00"
		cCodGen := "00"
		If Empty(cCodISS)
			cCodGen := Left((cAliasQry)->B1_POSIPI,2)
		EndIf
		
		//LePrado
		nAlqProd := nICMPAD
		If (cAliasQry)->B1_PICM > 0
			nAlqProd := (cAliasQry)->B1_PICM
		EndIf
		
		cDtIncB1 := DToS(dDataBase)
		If !Empty((cAliasQry)->INCB1)
			cDtIncB1 := (cAliasQry)->INCB1
		EndIf
		
		cCodANP := ""
		If !lCarga .And. lCmpCdAnp .And. !Empty((cAliasQry)->CD6_CODANP)
			cCodANP := (cAliasQry)->CD6_CODANP
		EndIf

		If lGeraT007
			lGerou := .T.

			/*
				ObtEndo o codigo do ISS atraves do cadastro da tabela CDN. Este codigo deve estar conforme LC 116/03
				Tratamento para considerar também mais de um Cod LST por Cod ISS, conforme a legislação existe a possibilidade de ser n / n   
			*/
			cProdCDN := Alltrim((cAliasQry)->B1_COD)

			//Priorizo o tipo de serviço da reinf que esta no cadastro do produto.
			if F2Q->(MsSeek(xFilial('F2Q')+cProdCDN )) 
				cTpServ := iif(oFisaExtSx:_F2Q_TPSERV,F2Q->F2Q_TPSERV,'')
			endif	

			If CDN->(MsSeek(xFilial("CDN") + cCodIss + cProdCDN)) .Or. CDN->(MsSeek(xFilial("CDN") + cCodIss))
				cCodIss := AllTrim(CDN->CDN_CODLST)
				if empty(cTpServ)
					cTpServ := IIf(oFisaExtSx:_CDN_TPSERV,CDN->CDN_TPSERV,"")
				endif	
			Else
				cCodIss := ""
			EndIf
			
			//Tiro todos os pontos que estiverem no cadastro.
			cCodIss := StrTran(cCodIss,".","")
			
			Aadd(a_Produtos,{{}})
			nPos := Len(a_Produtos)

			IF lBuild
	   			&cSet.( oHashT007, (cAliasQry)->B1_COD, nPos )
			EndIf
			
			Aadd(a_Produtos[nPos][1],cReg)									// 01 - REGISTRO
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B1_COD)					// 02 - COD_ITEM
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B1_DESC)					// 03 - DESCR_ITEM
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B1_CODBAR)					// 04 - COD_BARRA
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B1_UM)						// 05 - UNID_INV
			Aadd(a_Produtos[nPos][1],cTipoPrd)								// 06 - TIPO_ITEM
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B1_POSIPI)					// 07 - COD_NCM
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B1_EX_NCM)					// 08 - EX_IPI
			Aadd(a_Produtos[nPos][1],cCodGen)								// 09 - COD_GEN
			Aadd(a_Produtos[nPos][1],cCodIss)								// 10 - COD_LST -> Na posição 10 vai o código de serviço federal.
			Aadd(a_Produtos[nPos][1],cCodANP)								// 11 - COD_COMB
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B5_TABINC)					// 12 - COD_TAB
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B5_CODGRU)					// 13 - COD_GRU
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B1_ORIGEM)					// 14 - ORIGEM
			Aadd(a_Produtos[nPos][1],cDtIncB1)								// 15 - DT_INCLUSAO
			Aadd(a_Produtos[nPos][1],Val2Str(nAlqProd,6,2))					// 16 - ALIQ_ICMS
			Aadd(a_Produtos[nPos][1],"")										// 17 - ESTOQUE
			Aadd(a_Produtos[nPos][1],Val2Str((cAliasQry)->B1_IPI,5,2))		// 18 - ALIQ_IPI
			Aadd(a_Produtos[nPos][1],"")										// 19 - RED_BC_ICMS
			Aadd(a_Produtos[nPos][1],"")										// 20 - COD_CFQ
			Aadd(a_Produtos[nPos][1],"")										// 21 - COD_CNM
			Aadd(a_Produtos[nPos][1],"")										// 22 - COD_GLP
			Aadd(a_Produtos[nPos][1],"")										// 23 - COD_AFE
			Aadd(a_Produtos[nPos][1],"")										// 24 - COD_UM
			Aadd(a_Produtos[nPos][1],"")										// 25 - COD_CERTIf
			Aadd(a_Produtos[nPos][1],StrTran(cCodIss,".",""))				// 26 - COD_SERV_MUN -> Na posição 26 vai o código de serviço municipal.
			Aadd(a_Produtos[nPos][1],"")										// 27 - TP_PRD
			Aadd(a_Produtos[nPos][1],(cAliasQry)->B1_CEST)					// 28 - CEST
			Aadd(a_Produtos[nPos][1],If(!Empty(cTpServ),'1' + StrZero(Val(cTpServ),08),''))	// 29 - TIP_SERV
			
			//Tratamento para geração do produto para os itens do bloco k
			n_HdlT007 := nHdlTxt
			
		EndIf
	
		If !Empty((cAliasQry)->B1_UM) .And. !Empty((cAliasQry)->B1_SEGUM)
			// Tratamento para evitar duplicidade de informacoes
			nPos := Ascan(aRegT006,{|aX| aX[1]==(cAliasQry)->B1_UM})
			
			If Empty(nPos)
				Aadd(aRegT006,{})
				nPos := Len(aRegT006)
				
				Aadd(aRegT006[nPos],Upper((cAliasQry)->B1_UM))
				Aadd(aRegT006[nPos],Upper((cAliasQry)->B1_SEGUM))
				Aadd(aRegT006[nPos],Val2Str((cAliasQry)->B1_CONV,8,2))
			EndIf
		EndIf
		
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())
	
	// Gravacao dos registros T006 e T006AA
    If oWizard:LayoutSel("T006")
		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T006",2)
	
		If RegT006(aRegT006)
			lGerFilial := .F.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,"T006",3)
		Else
			lGerFilPar := .T.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,"T006",1)
		EndIf
	EndIf
	
Return lGerou

/*/{Protheus.doc} RegT006
    (Realiza a geracao do registro T006 do TAF)

    @type Static Function
    @author Fabio V Santana
    @since 09/05/2013
    
    @return lGerou, logico, se gerou ou não.
    /*/
Static Function RegT006(aRegT006)

    Local aRegs := {}
    Local aRegsAA := {}

    Local cReg := "T006"
    Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
    Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
    Local nCount := 0

    Local lGeraT006 := .T.
	Local lGerou := .F.

    DbSelectArea("C1J")  
    C1J->(DbSetOrder(1))

    DbSelectArea("C1K") 
    C1K->(DbSetOrder(2))

    DbSelectArea("C6X")  
    C6X->(DbSetOrder(1))

    // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
    Aadd(aArqGer,cTxtSys)

    For nCount := 1 to Len(aRegT006)
            
        If lGeraT006
            lGerou := .T.

            aRegs := {}
            aAdd(aRegs,{})
            nPos := Len(aRegs)

            aAdd(aRegs[nPos],"T006")
            aAdd(aRegs[nPos],aRegT006[nCount][01])
            
            FConcTxt(aRegs,nHdlTxt)
            
            aRegsAA := {}
            aAdd(aRegsAA,{})
            nPos := Len(aRegsAA)

            aAdd(aRegsAA[nPos],"T006AA")
            aAdd(aRegsAA[nPos],aRegT006[nCount][02])
            aAdd(aRegsAA[nPos],aRegT006[nCount][03])
            
            FConcTxt(aRegsAA,nHdlTxt)
            
            // Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
            If cTpSaida == "2"
                FConcST1()
            EndIf
        EndIf

    Next

    // Libero Handle do Arquivo
    If cTpSaida == "1"
        FClose(nHdlTxt)
    EndIf

Return lGerou

/*/{Protheus.doc} fLayT009
    (Função para executar o layout T009)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT009()

    fMsgPrcss("Gerando Registro T009 - Natureza de Operação...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T009",2)
	
    // Monta o layout T009
    If RegT009()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T009",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T009",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT009
    (Realiza a geracao do registro T009 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 22/03/2013

    @return lGerou, logico, se gerou ou não.

    @Obs Função refeita - Vitor Ribeiro - 01/12/2017
    /*/
Function RegT009()

	Local cTxtSys := ""
	Local cJoin1 := ""
	Local cJoin2 := ""
	Local cWhereSF4 := ""
	Local cAliasQry := ""
	
	Local lCarga := .F.
	Local lGerou := .F.
	
	Local nHdlTxt := 0
	
	cTxtSys := cDirSystem + "\T009.TXT"
	
	nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)

	lCarga := !lFiltReinf .And. cFiltInt == "1"

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)
		
	// Se não for carga
	If !lCarga
		cJoin1 += " INNER JOIN ( "
		cJoin1 += "	 SELECT DISTINCT "
		cJoin1 += "		 SF4.F4_NATOPER NATOPER "
		cJoin1 += "	 FROM " + RetSqlName("SF4") + " SF4 "
		
		cJoin2 += "	 INNER JOIN ( "

		
			
            cJoin2 += "		 SELECT DISTINCT "
            cJoin2 += "			SFT.FT_TES CODIGO "
            cJoin2 += "		 FROM " + RetSqlName("SFT") + " SFT "
		
			cJoin2 += "		 WHERE "
            cJoin2 += "			SFT.D_E_L_E_T_ = ' ' "
		    cJoin2 += "			AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
            cJoin2 += "			AND SFT.FT_ENTRADA >= '" + DToS(oWizard:GetDataDe())  + "' "
            cJoin2 += "			AND SFT.FT_ENTRADA <= '" + DToS(oWizard:GetDataAte()) + "' "
            cJoin2 += "			AND SFT.FT_NFISCAL >= '" + oWizard:GetNotaDe() + "' "
            cJoin2 += "			AND SFT.FT_NFISCAL <= '" + oWizard:GetNotaAte() + "' "
			If !(Empty(oWizard:GetSerieDe()) .And. oWizard:GetSerieAte()='ZZZ')
				cJoin2 += "			AND SFT.FT_SERIE >= '" + oWizard:GetSerieDe() + "' "
				cJoin2 += "			AND SFT.FT_SERIE <= '" + oWizard:GetSerieAte() + "' "
			Endif
	        // Se foi selecionado 2 - Entradas
			If oWizard:GetTipoMovimento() == '2'
				cJoin2 += "			AND SFT.FT_TIPOMOV='E' "
			// Se foi selecionado 3 - Saídas
			Elseif oWizard:GetTipoMovimento() == '3'
				cJoin2 += "			AND SFT.FT_TIPOMOV='S' "
			Endif
			
			If lFiltReinf
				cJoin2 += " AND ( SFT.FT_BASEINS > 0 OR SFT.FT_BASEFUN > 0 OR SFT.FT_BSSENAR > 0 ) "
			EndIf		

			If !Empty(oWizard:GetEspecie())
				cJoin2 += "			AND SFT.FT_ESPECIE IN (" + oWizard:GetEspecie(.T.) + ") "
			EndIf
    
		cJoin2 += "	 ) NOTA ON "
		cJoin2 += "		NOTA.CODIGO = SF4.F4_CODIGO "
		
		cJoin1 += cJoin2
		
		cJoin1 += "	 WHERE "
		cJoin1 += "		SF4.D_E_L_E_T_ = ' ' "
		cJoin1 += "		AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
		cJoin1 += " ) TES ON "
		cJoin1 += "	TES.NATOPER = CD1.CD1_CODNAT "
	EndIf
	
	cJoin1 := "%" + cJoin1 + "%"
	
	cAliasQry := GetNextAlias()
	
	BeginSql Alias cAliasQry
		SELECT DISTINCT
			CD1.CD1_CODNAT CODIGO
			,CD1.CD1_DESCR DESCR
		FROM %Table:CD1% CD1
		
		%Exp:cJoin1%
		
		WHERE
			CD1.CD1_FILIAL = %xFilial:CD1%
			AND CD1.%NotDel%
	EndSql

	If (cAliasQry)->(!Eof())
		// Função para gravar o registro T009
		lGerou := GrvRegT009(cAliasQry,nHdlTxt)
	EndIf

	// Fecha o alias retornado pela query
	(cAliasQry)->(DbCloseArea())
	
	cJoin2 := "%" + cJoin2 + "%"
	
	// Parametro configurar a NF-e SEFAZ referente a descricao da Natureza da operacao. T = Descricao da tabela 13 do SX5 ou F = Descricao do campo F4_TEXTO.
	If !oFisaExtSx:_MV_SPEDNAT
		// Se for carga, não considera os registros bloqueados
		If lCarga
			cWhereSF4 := "AND SF4.F4_MSBLQL <> '1' " 
		EndIf
		
		cWhereSF4 := "%" + cWhereSF4 + "%"
		
		BeginSql Alias cAliasQry
			SELECT DISTINCT
				SF4.F4_CODIGO CODIGO
				,SF4.F4_TEXTO DESCR
			FROM %Table:SF4% SF4
			
			%Exp:cJoin2%
			
			WHERE
				SF4.F4_FILIAL = %xFilial:SF4%
				%Exp:cWhereSF4%
				AND SF4.%NotDel%
		EndSql
	Else	// Envia o CFOP
		cJoin2 := StrTran(cJoin2,"SFT.FT_TES","SFT.FT_CFOP")
		cJoin2 := StrTran(cJoin2,"SF4.F4_CODIGO","SX5.X5_CHAVE")
		
		BeginSql Alias cAliasQry
			SELECT DISTINCT
				SX5.X5_CHAVE CODIGO
				,SX5.X5_DESCRI DESCR
			FROM %Table:SX5% SX5
			
			%Exp:cJoin2%
			
			WHERE
				SX5.X5_FILIAL = %xFilial:SX5%
				AND SX5.X5_TABELA = '13'
				AND SX5.%NotDel%
		EndSql
	EndIf
		
	If (cAliasQry)->(!Eof())
		// Função para gravar o registro T009
		lGerou := GrvRegT009(cAliasQry,nHdlTxt)
	EndIf

	// Fecha o alias retornado pela query
	(cAliasQry)->(DbCloseArea())
	
	// Libero Handle do Arquivo
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf

Return lGerou

/*/{Protheus.doc} GrvRegT009
	(Função para gravar o registro T009)

	@type Static Function
	@author Vitor Ribeiro
	@since 04/05/2018
	
	@param c_AliasQry, caracter, alias da query na CD1, SF4 ou SX5.
	@param n_HdlTxt, numerico, handle de Gravacao do Arquivo

	@return lGerou, logico, se gerou ou não.
	/*/
Static Function GrvRegT009(c_AliasQry,n_HdlTxt)

	Local lGeraT009 := .T.
	Local lGerou := .T.
	Local aRegt009 := {}
	Local nPosicao := 0

	Default c_AliasQry := ""
	Default n_HdlTxt := 0

	DbSelectArea("C1N")		// Natureza de Operação
	C1N->(DbSetOrder(1))	// C1N_FILIAL+C1N_CODNAT 
	
	// Selecina o alias
	DbSelectArea(c_AliasQry)
	
	// Percorre o resulta da query
	While (c_AliasQry)->(!Eof())
		
		If lGeraT009
			lGerou := .T.

			aRegt009 := {}
			Aadd(aRegt009,{})
			nPosicao := Len(aRegt009)

			Aadd(aRegt009[nPosicao],"T009")					// 1 - REGISTRO
			Aadd(aRegt009[nPosicao],(c_AliasQry)->CODIGO)	// 2 - COD_NAT
			Aadd(aRegt009[nPosicao],(c_AliasQry)->DESCR)	// 3 - DESCR_NAT
			Aadd(aRegt009[nPosicao],"")						// 4 - COD_NAT_ECF
			Aadd(aRegt009[nPosicao],"")						// 5 - OBJ_OPER
			Aadd(aRegt009[nPosicao],"")						// 6 - COD_OPER_ANP
			
			FConcTxt(aRegt009,n_HdlTxt)
			
			// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
			If cTpSaida == "2"
				FConcST1()
			EndIf
		EndIf
		
		(c_AliasQry)->(DbSkip())
	EndDo
	
Return lGerou

/*/{Protheus.doc} fLayT010
    (Função para executar o layout T010)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT010()

    fMsgPrcss("Gerando Registro T010 - Plano de Contas...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T010",2)
	
    // Monta o layout T010
    If RegT010()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T010",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T010",1)		
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT010
	(Realiza a geracao do registro T010 do TAF)

	@type Static Function
	@author Fabio V Santana
	@since 25/03/2013
	
	@return lGerou, logico, se gerou ou não.
	/*/
Static Function RegT010()

	Local cReg := "T010"
	Local cJoin := ""
	Local cWhere := ""
	Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
	Local cAliasQry := GetNextAlias()

	Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
	Local nPosicao := 0

	Local aRegT010 := {}
	Local aContas  := {}	
	Local aGravadas:= {}	
	Local nDeleta  := 0	
	Local lCarga := !lFiltReinf .And. cFiltInt == "1"

	Local dDtAlt := CToD('\\')
	Local lGerou := .F.

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)

	// Montando a Estrutura da Query

	If (!lCarga .Or. lFiltReinf)
		cJoin := "INNER JOIN " + RetSqlName("SFT") + " SFT ON "
		cJoin += "	SFT.D_E_L_E_T_ = ' ' "
		cJoin += "	AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "

		cJoin += "	AND SFT.FT_ENTRADA BETWEEN '" + DToS(oWizard:GetDataDe()) + "' AND '" + DToS(oWizard:GetDataAte()) + "' "
		cJoin += "	AND SFT.FT_NFISCAL BETWEEN '" + oWizard:GetNotaDe() + "' AND '" + oWizard:GetNotaAte() + "' "
		If !(Empty(oWizard:GetSerieDe()) .And. oWizard:GetSerieAte()='ZZZ')
			cJoin += "	AND SFT.FT_SERIE BETWEEN '" + oWizard:GetSerieDe() + "' AND '" + oWizard:GetSerieAte() + "' "
		Endif
		If !Empty(oWizard:GetEspecie())
			cJoin += "	AND SFT.FT_ESPECIE IN (" + oWizard:GetEspecie(.T.) + ") "
		EndIf

		cJoin += "	AND SFT.FT_CONTA = CT1.CT1_CONTA "
	EndIf

	If lCarga
		cWhere := " AND ( CT1.CT1_BLOQ = '2' OR CT1.CT1_BLOQ = ' ' ) "
	EndIf

	// Definindo Estrutura para Execucao do BeginSql
	cJoin := "%" + cJoin + "%"
	cWhere := "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT DISTINCT
			CT1.CT1_CTASUP
			,CT1.CT1_CONTA
			,CT1.R_E_C_N_O_ RECCT1
		FROM %Table:CT1% CT1

		%Exp:cJoin%
			
		WHERE
			CT1.CT1_FILIAL = %xFilial:CT1%
			AND CT1.D_E_L_E_T_ = ' ' 
			%Exp:cWhere%
			
		ORDER BY
			CT1.CT1_CTASUP
			,CT1.CT1_CONTA
	EndSql

	DbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())
		Aadd( aContas,(cAliasQry)->CT1_CONTA)
		(cAliasQry)->(dbSkip())		
	EndDo
	(cAliasQry)->(DbGoTop())
	While Len(aContas) > 0

		dDtAlt := fGetDtExis()

		lGerou := .T.

		aRegT010 := {}
		Aadd(aRegT010,{})
		nPosicao := Len(aRegT010)

		// Se conta Superior vazia e conta ainda não gravada ou  tem conta superior já gravada	
		If (Empty(AllTrim((cAliasQry)->CT1_CTASUP)) .And. Ascan(aContas,(cAliasQry)->CT1_CONTA) > 0 .And. Ascan(aGravadas,(cAliasQry)->RECCT1) = 0 ) .Or. ;
			(!Empty(AllTrim((cAliasQry)->CT1_CTASUP)) .And. Ascan(aContas,(cAliasQry)->CT1_CTASUP) = 0 .And. Ascan(aGravadas,(cAliasQry)->RECCT1) = 0 )

			CT1->(DbGoTo((cAliasQry)->RECCT1))

			Aadd(aRegT010[nPosicao],cReg)										// 01 - REGISTRO
			Aadd(aRegT010[nPosicao],dDtAlt)										// 02 - DT_ALT
			Aadd(aRegT010[nPosicao],CT1->CT1_NTSPED)							// 03 - COD_NAT
			Aadd(aRegT010[nPosicao],IIf(CT1->CT1_CLASSE=='1','0','1'))			// 04 - IND_CTA 
			Aadd(aRegT010[nPosicao],AllTrim(Str(CtbNivCta(CT1->CT1_CONTA))))	// 05 - NÍVEL 
			Aadd(aRegT010[nPosicao],CT1->CT1_CONTA)								// 06 - COD_CTA 
			Aadd(aRegT010[nPosicao],CT1->CT1_DESC01)							// 07 - NOME_CTA 
			Aadd(aRegT010[nPosicao],"")											// 08 - COD_CTA_REF
			Aadd(aRegT010[nPosicao],"")											// 09 - CNPJ_EST
			Aadd(aRegT010[nPosicao],CT1->CT1_CTASUP)							// 10 - COD_CTA_SUP
			Aadd(aRegT010[nPosicao],dDtAlt)										// 11 - DATA_CRIACAO
			Aadd(aRegT010[nPosicao],CT1->CT1_NORMAL)							// 12 - NATUREZA

			nDeleta := Ascan(aContas,(cAliasQry)->CT1_CONTA)
			aDel(aContas, nDeleta)
			aSize(aContas, Len(aContas)-1)
			Aadd(aGravadas, (cAliasQry)->RECCT1)
			FConcTxt(aRegT010,nHdlTxt)
			
			// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
			If cTpSaida == "2"
				FConcST1()
			EndIf
		
		EndIf

		If (cAliasQry)->(EOF())
			(cAliasQry)->(DbGoTop())
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	// Libero Handle do Arquivo
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf

Return lGerou

/*/{Protheus.doc} fGetDtExis
	(Função para retornar a data de alteração)

	@type Static Function
	@author Vitor Ribeiro
	@since 07/05/2018
	
	@return dDtalt, data, data de alteração.
	/*/
Static Function fGetDtExis()

	Local dDtalt := CtoD("")

	If oFisaExtSx:_CT1_DTEXIS .And. !Empty(CT1->CT1_DTEXIS) .And. CT1->CT1_DTEXIS >= CToD("01/01/2000")
		dDtAlt := CT1->(CT1_DTEXIS)
	Else	
		dDtAlt := CToD("01/01/2000")
	EndIf

Return dDtalt

/*/{Protheus.doc} fLayT011
    (Função para executar o layout T011)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT011()

    fMsgPrcss("Gerando Registro T011 - Centro de Custo...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T011",2)
	
    // Monta o layout T011
    If RegT011()
		lGerFilial := .F.
		
		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T011",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T011",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT011
    (Realiza a geracao do registro T011 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 25/03/2013

    @return lGerou, logico, se gerou ou não.
    /*/
Static Function RegT011()

    Local cSelect		:= ""
    Local cSelect2		:= ""
    Local cFrom			:= ""
    Local cFrom2		:= ""
    Local cWhere		:= ""
    Local cReg			:= "T011"
    Local cTxtSys		:= cDirSystem + "\" + cReg + ".TXT"
    Local nHdlTxt		:= IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )
    Local aRegs			:= {}
    Local cAliasQry		:= GetNextAlias()
    Local lGeraT011		:= .T.
    Local cDataDe   	:= DToS(oWizard:GetDataDe())
    Local cDataAte  	:= DToS(oWizard:GetDataAte())
	Local lCarga 		:= !lFiltReinf .and. cFiltInt == "1"
	Local lGerou := .F.

    DbSelectArea("C1P")  
    C1P->(DbSetOrder(1))

    // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
    Aadd(aArqGer,cTxtSys)

    // Montando a Estrutura da Query
	If lCarga
        cSelect += " CTT.CTT_CUSTO, CTT.CTT_DESC01, CTT.CTT_DTEXIS "
        
        cFrom   += RetSqlName( "CTT" ) + " CTT	 "
        
        cWhere  += "CTT.D_E_L_E_T_ = ' ' AND CTT.CTT_FILIAL = '" + xFilial( "CTT" ) + "' AND ( CTT.CTT_BLOQ = '2' OR CTT.CTT_BLOQ = ' ' ) "

    ElseIf (!lCarga .Or. lFiltReinf)
        cSelect := " CTTB.CTT_CUSTO, CTTB.CTT_DESC01, CTTB.CTT_DTEXIS "
        cFrom   +=   RetSqlName("SD2") +" SD2 "
        cFrom   += " JOIN " + RetSqlName("CTT") +" CTTB "
        cFrom   += " ON  SD2.D2_FILIAL  = '" + xFilial("SD2") + "'"
        cFrom   += " AND CTTB.CTT_FILIAL = '" + xFilial("CTT") + "'"
        cFrom   += " AND SD2.D_E_L_E_T_= ' ' AND CTTB.D_E_L_E_T_= ' '  " 
        cFrom   += " AND SD2.D2_EMISSAO >= '" + cDataDe + "' "
        cFrom   += " AND SD2.D2_EMISSAO <= '" + cDataAte + "'"
        cFrom   += " AND SD2.D2_DOC >= '" + oWizard:GetNotaDe() + "'" 
        cFrom   += " AND SD2.D2_DOC <= '" + oWizard:GetNotaAte() + "'"
        cFrom   += " AND SD2.D2_CCUSTO = CTTB.CTT_CUSTO "
        cFrom   += " AND SD2.D2_SERIE	>=	'" + oWizard:GetSerieDe() + "' "
        cFrom   += " AND SD2.D2_SERIE	<=	'" + oWizard:GetSerieAte() + "' "

		If !Empty(oWizard:GetEspecie())
        	cFrom += " AND SD2.D2_ESPECIE	IN (" + oWizard:GetEspecie(.T.) + ") "
        EndIf

        cFrom += " AND SD2.D_E_L_E_T_= ' ' AND CTTB.D_E_L_E_T_= ' '  " 
        
        //Procurando documento de entrada
        cSelect2 += " ( SELECT DISTINCT  CTTC.CTT_CUSTO, CTTC.CTT_DESC01, CTTC.CTT_DTEXIS "
        cFrom2  +=   RetSqlName("SD1") +" SD1 "
        cFrom2  += " JOIN " + RetSqlName("CTT") +" CTTC "
        cFrom2  += " ON  SD1.D1_FILIAL= '" + xFilial("SD1") + "'
        cFrom2  += " AND CTTC.CTT_FILIAL= '" + xFilial("CTT") + "'"
        cFrom2  += " AND SD1.D_E_L_E_T_= ' ' AND CTTC.D_E_L_E_T_= ' '" 
        cFrom2  += " AND SD1.D1_EMISSAO >= '" + cDataDe + "' "
        cFrom2  += " AND SD1.D1_EMISSAO <= '" + cDataAte + "'" 
        cFrom2  += " AND SD1.D1_DOC >= '" + oWizard:GetNotaDe() + "'" 
        cFrom2  += " AND SD1.D1_DOC <= '" + oWizard:GetNotaAte() + "'" 
        cFrom2  += " AND SD1.D1_CC   = CTTC.CTT_CUSTO "
        cFrom2  += " AND SD1.D_E_L_E_T_= ' ' AND CTTC.D_E_L_E_T_= ' '
        cFrom2  += " JOIN " + RetSqlName("SF1") +" SF1C  "
        cFrom2  += " ON  SF1C.F1_FILIAL  	=	SD1.D1_FILIAL  " 
        cFrom2  += " AND SF1C.F1_DOC     	=	SD1.D1_DOC     "
        cFrom2  += " AND SF1C.F1_SERIE   	=	SD1.D1_SERIE   " 
        cFrom2  += " AND SF1C.F1_FORNECE 	=	SD1.D1_FORNECE "
        cFrom2  += " AND SF1C.F1_LOJA    	=	SD1.D1_LOJA    "
        cFrom2  += " AND SF1C.F1_SERIE		>=	'" + oWizard:GetSerieDe() + "'"
        cFrom2  += " AND SF1C.F1_SERIE		<=	'" + oWizard:GetSerieAte() + "'"

		If !Empty(oWizard:GetEspecie())
        	cFrom2 += " AND SF1C.F1_ESPECIE IN (" + oWizard:GetEspecie(.T.) + ") "
		EndIf

        cFrom2  += " AND SF1C.D_E_L_E_T_	=	' ' )"

    EndIf

    // Definindo Estrutura para Execucao do BeginSql
    cSelect   := "%" + cSelect  + "%"
    cSelect2  := "%" + cSelect2 + "%"
    cFrom     := "%" + cFrom    + "%"
    cFrom2    := "%" + cFrom2   + "%"
    cWhere    := "%" + cWhere   + "%"

	If lCarga
		BeginSql Alias cAliasQry
			SELECT
			%Exp:cSelect%
			FROM
			%Exp:cFrom%
			WHERE
			%Exp:cWhere%
		EndSql
	Else
		If oWizard:GetTipoMovimento() == '1'		//1-Ambos (Notas de Entrada e Saída)
			BeginSql Alias cAliasQry
				SELECT
				%Exp:cSelect%
				FROM
				%Exp:cFrom%
				UNION
				%Exp:cSelect2%
				FROM
				%Exp:cFrom2%
			EndSql
		ElseIf oWizard:GetTipoMovimento() == '2'	//2-Entradas (Notas de Entrada) 
			cSelect2 := STRTRAN(cSelect2, "( SELECT", "")
			cFrom2   := STRTRAN(cFrom2  , "SF1C.D_E_L_E_T_	=	' ' )","SF1C.D_E_L_E_T_	=	' ' ")
			BeginSql Alias cAliasQry
				SELECT
				%Exp:cSelect2%
				FROM
				%Exp:cFrom2%			
			EndSql
		ElseIf oWizard:GetTipoMovimento() == '3'	//3-Saidas (Notas de Saída) 	
			BeginSql Alias cAliasQry
				SELECT
				%Exp:cSelect%
				FROM
				%Exp:cFrom%
			EndSql
		EndIf
	EndIf

    DbSelectArea( cAliasQry )
    While (cAliasQry)->(!Eof())
        
        aRegs := {}

        If lGeraT011
            lGerou := .T.

            (cAliasQry)->( Aadd( aRegs, {  cReg,;
            IIf( Valtype(CTT_DTEXIS) == "D", DToS( CTT_DTEXIS ), CTT_DTEXIS) ,;
            CTT_CUSTO,;
            CTT_DESC01,;
            IIf( Valtype(CTT_DTEXIS) == "D", DToS( CTT_DTEXIS ), CTT_DTEXIS) } ) )
            
            FConcTxt( aRegs, nHdlTxt )
            
            // Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1
            If cTpSaida == "2"
                FConcST1()
            EndIf
        EndIf
        
        (cAliasQry)->( DbSkip())
        
    EndDo

    (cAliasQry)->( DbCloseArea() )

    // Libero Handle do Arquivo
    If cTpSaida == "1" 
        FClose(nHdlTxt)
    EndIf

Return lGerou

/*/{Protheus.doc} RegT012
	(Realiza a geracao do registro RegT012 do TAF)

	@type Function
	@author Fabio V Santana
	@since 30/04/2013

	@return Nil, nulo, não tem retorno
	/*/
Function RegT012(aRegs,aRegT012,aRegT012AA,cSituaDoc,cEspecie)

	Local cDisp := ""

	Local nPosT012 := 0

	Local aAidf := {}

	// Utilizo a funcao do MATXMAG para retornar o dispositivo AIDF do documento
	aAidf := RetAidf(aRegs[1,9],aRegs[1,7])
	
	If !Empty(aAidf[1])
		Do Case
		Case Alltrim(aAidf[2]) == "1"
			cDisp :="04"
		Case Alltrim(aAidf[2]) == "2"
			cDisp :="03"
		Case Alltrim(aAidf[2]) == "3"
			cDisp :="00"
		Case Alltrim(aAidf[2]) == "4"
			cDisp :="05"
		Case Alltrim(aAidf[2]) == "6"
			cDisp :="02"
		Case Alltrim(aAidf[2]) == "7"
			cDisp :="01"
		EndCase
		
		// aRegT012(DOCUMENTOS FISCAIS UTILIZADOS)
		If (nPosT012 := Ascan(aRegT012,{|aX| aX[2]==cDisp .And. aX[3] == aAidf[1]}))==0
			aAdd(aRegT012, {})
			nPos	:=	nPosT012	:=	Len (aRegT012)
			aAdd (aRegT012[nPos], "T012")						//01 - REG
			aAdd (aRegT012[nPos], cDisp)						//02 - COD_DIST
			aAdd (aRegT012[nPos], aAidf[1])					//03 - NUM_AUT
			aAdd (aRegT012[nPos], aAidf[5])					//04 - DATA AUT
		EndIf
		
		/*aRegT012AA(DOCUMENTOS FISCAIS CANCELADOS/INUTILIZADOS)

			Este registro deve ser geradoo conforme a combinacao acima dos campo 02, 03 e 04.
			Ao gerar o arquivo texto, eles devem manter a hierarquia, para isso faco o
			relacionamento atraves do primeiro campo do registro aRegT012AA.
		*/
		
		// VerIfico se ja existe T012AA para este registro T012
		nPos := aScan(aRegT012AA,{|x| x[1] = nPosT012 .and. soma1(x[7]) == aRegs[1,9] }) 
		
		// Se nao possuir registro aRegT012AA ainda ou se a numeracao nao for continua, devo criar um registro aRegT012AA novo
		If (nPos == 0) .Or. (Val(aRegs[1,9]) <> Val(aRegT012AA[nPos,7]) + 1)
			aAdd(aRegT012AA, {})
			nPos	:=	Len (aRegT012AA)
			aAdd (aRegT012AA[nPos], nPosT012)		// 01 - RELACIONAMENTO COM T012
			aAdd (aRegT012AA[nPos], "T012AA")		// 02 - REG
			aAdd (aRegT012AA[nPos], cEspecie)		// 03 - COD_MOD
			aAdd (aRegT012AA[nPos], aRegs[1,7])		// 04 - SER
			aAdd (aRegT012AA[nPos], "")				// 05 - SUB
			aAdd (aRegT012AA[nPos], aRegs[1,9])		// 06 - NUM_DOC_INI
			aAdd (aRegT012AA[nPos], aRegs[1,9])		// 07 - NUM_DOC_FIN
		Else
			/*
				O tratamento abaixo eh para quando jah existir um relacionamento, poder ser
				verificado se o proximo documento estah dentro do range dos campos 02 e 03.
			
				Este tratamento leva em consideracao que os documentos apresentados no
				periodo, de emissao propria, seguem a ordem normal de emissao, um numero
				de documento crescente e sequencial.
			*/
			
			// VerIfico se eh um numero maior que o ultimo lido
			If Val(aRegs[1,9])>Val(aRegT012AA[nPos,7])
				aRegT012AA[nPos,7]	:=	aRegs[1,9]
			EndIf
			
			// VerIfico se eh um numero menor que o ultimo lido
			If Val(aRegs[1,9])<Val(aRegT012AA[nPos,6])
				aRegT012AA[nPos,6]	:=	aRegs[1,9]
			EndIf 
		EndIf
	EndIf
	 
Return 

/*/{Protheus.doc} RegT012R
	(Realiza a gravação do registro RegT012 do TAF)

	@type Static Function
	@author Fabio V Santana
	@since 03/05/2013

	@return Nil, nulo, não tem retorno
	/*/
Function RegT012R(aRegT012,aRegT012AA)
	
	Local aRegAux := {}

	Local cReg := "T012"
	Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"

	Local nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
	Local nPos := 0
	Local nX := 0
	Local nY := 0

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)
	aSort(aRegT012AA,,,{|x,y| x[3]<y[3]})
	For nX := 1 to Len(aRegT012)
		
		aRegAux := {}
		
		AAdd(aRegAux,{})
		nPos := Len(aRegAux)

		Aadd(aRegAux[nPos],aRegT012[nX,1])
		Aadd(aRegAux[nPos],aRegT012[nX,2])
		Aadd(aRegAux[nPos],aRegT012[nX,3])
		Aadd(aRegAux[nPos],aRegT012[nX,4])
		Aadd(aRegAux[nPos],"")
		
		For nY := 1 to Len(aRegT012AA)
			
			If aRegT012AA[nY,1] == nX
				AAdd(aRegAux,{})
				nPos := Len(aRegAux)

				Aadd(aRegAux[nPos],aRegT012AA[nY,2])
				Aadd(aRegAux[nPos],aRegT012AA[nY,3])
				Aadd(aRegAux[nPos],aRegT012AA[nY,4])
				Aadd(aRegAux[nPos],aRegT012AA[nY,5])
				Aadd(aRegAux[nPos],aRegT012AA[nY,6])
				Aadd(aRegAux[nPos],aRegT012AA[nY,7])
			EndIf
			
		Next nY
		
		FConcTxt(aRegAux,nHdlTxt)
		
		// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
		If cTpSaida == "2"
			FConcST1()
		EndIf
	Next
	
	If cTpSaida == "1"
		FClose(nHdlTxt)
	EndIf

Return Nil

/*/{Protheus.doc} fLayT013
    (Função para executar o layout T013)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

	@param o_MTProc, objeto, contém a multi thread
	@param n_QtdThr, numerico, quantidade de threads
	@param l_MultiThr, logico, se está ativo a multi thread
	@param l_RegXThr, logico, registro versos a thread
	@param l_TAFGST2, logico, Se deve gravar a TAFST2.
	@param a_JobContr, array, Controle de job
	@param a_RgT022AB, array, registro T022AB
	@param a_VlrMovST, array, valor de movimento de ST
	@param a_IcmPago, array, informações do icms pago
	@param a_LanCDA2, array, lancamento da CDA
	@param a_GerT013J, array, controle de geração do registro T013 pelo JOB.

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT013(o_MTProc,n_QtdThr,l_MultiThr,l_RegXThr,l_TAFGST2,a_JobContr,a_RgT022AB,a_VlrMovST,a_IcmPago,a_LanCDA2,a_GerT013J,aParticip,aProdutos,cTblTemp)

    Local aEntSai := {"E","S"}	// Array para controle de entrada e Saida
    Local aThreads := {}
    Local aParamMT := {}
	Local aWizard := {}
	Local aRegT012AA := {}

    Local cQueryMT := ""    // Query contando as quantidades de registros 
    Local cJobCtr := ""     // Variavel para receber o nome da variavel  
    Local cTxtSys := ""

    Local nCont1 := 0
    Local nCont2 := 0
 
	Local lGerou := .F.

	Default o_MTProc := Nil

    Default n_QtdThr := 0

    Default l_MultiThr := .F.
    Default l_RegXThr := .F.
    Default l_TAFGST2 := .F.
    
    Default a_JobContr := {}
    Default a_RgT022AB := {}
    Default a_VlrMovST := {}
    Default a_IcmPago := {}
    Default a_LanCDA2 := {}
	Default aParticip := {}
	Default aProdutos := {}

    fMsgPrcss("Gerando Registro T013 - Documentos Fiscais...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T013",2)

	Aadd(a_GerT013J,{cFilProc,.F.,.F.,{}})
	
    If lDocSFT
        aEntSai := {cEntSaiSFT}
	Else
		If oWizard:GetTipoMovimento() == "2"
			aEntSai := {"E"}
		ElseIf oWizard:GetTipoMovimento() == "3"
			aEntSai := {"S"}
		EndIf
    EndIf

    // Processa primeiro Entradas e depois Saídas para utilização exata do indice
    cHorIni := Time()

    Aadd(aParamMT,"")     // 01 - cEntSai
    Aadd(aParamMT,.T.)    // 02 - lMultThr
    Aadd(aParamMT,"")     // 03 - aThread
    Aadd(aParamMT,"")     // 04 - cQueryMT
    Aadd(aParamMT,"")     // 05 - cTpSaida
    Aadd(aParamMT,"")     // 06 - cJobAux
    Aadd(aParamMT,"")     // 07 - cNumThr
    Aadd(aParamMT,.F.)    // 08 - l_TAFGST2
    Aadd(aParamMT,"")     // 09 - cTxtSys
	Aadd(aParamMT,.F.)    // 10 - lIntTaf
	Aadd(aParamMT,"")     // 11 - cDirSystem
	Aadd(aParamMT,{})     // 12 - aArqGer
	Aadd(aParamMT,{"",""}) // 13 - SM0MT
	Aadd(aParamMT,.F.)    // 14 - lFiltReinf
	Aadd(aParamMT,"3")    // 14 - cFiltInt
	Aadd(aParamMT,cExtUser)    // 16 - cExtUser

	/*
		Monta a wizard para utilizar no registro T003
		Infelizmente foi preciso utilizar um array no lugar do objeto porque a 
		nova thread não consegue enxerguar um objeto mesmo passado por paramentro
	*/
	Aadd(aWizard,oWizard:LayoutSel("T012"))	// 01 - _SEL_T012_
	Aadd(aWizard,oWizard:LayoutSel("T013"))	// 02 - _SEL_T013_
	Aadd(aWizard,oWizard:GetDataDe())		// 03 - _DATA_DE_
	Aadd(aWizard,oWizard:GetDataAte())		// 04 - _DATA_ATE_
	Aadd(aWizard,oWizard:GetNotaDe())		// 05 - _NOTA_DE_
	Aadd(aWizard,oWizard:GetNotaAte())		// 06 - _NOTA_ATE_
	Aadd(aWizard,oWizard:GetSerieDe())		// 07 - _SERI_DE_
	Aadd(aWizard,oWizard:GetSerieAte())		// 08 - _SERI_ATE_
	Aadd(aWizard,oWizard:GetEspecie())		// 09 - _ESP_S_PR_
	Aadd(aWizard,oWizard:GetEspecie(.T.))	// 10 - _ESP_C_PR_
	Aadd(aWizard,oWizard:GetApuracaoIPI())	// 11 - _APUR_IPI_
	if aWizard[01]
		PUTGLBVARS( '_aRegT012AA', {} ) 
	endif
    For nCont1 := 1 To Len(aEntSai)
        If l_MultiThr
            // Preparação para as threads 
            aThreads := FPrepT013(n_QtdThr,aEntSai[nCont1],@cQueryMT)
            
            If !Empty(aThreads)
                //VerIfica se existe dois ou mais registros por Thread 
                l_RegXThr := IIf((aThreads[n_QtdThr][3]/n_QtdThr) < 1,.F.,.T.)
            EndIf
        EndIf
        
        If l_RegXThr 
            Sleep(2500)
            
            For nCont2 := 1 To n_QtdThr
				If nCont2 <= Len(aThreads)
					// Controle das Threads
					cJobCtr := StrTran(cFilProc," ","") + "_EXT_" + aEntSai[nCont1] + AllTrim(StrZero(nCont2,2))

					Aadd(a_GerT013J[Len(a_GerT013J)][4],cJobCtr + "_GEROU")

					PutGlbValue(cJobCtr,"0")
					PutGlbValue(cJobCtr + "_GEROU","0")
					GlbUnLock()

					Aadd(a_JobContr,{cJobCtr,.T.}) 
					
					TAFConout("    ---- Chamou a thread " + cJobCtr,2,.T.,"EXT")

//					cTxtSys := cDirSystem + cBarraUnix + "T013" + StrZero(nCont2,4) + aEntSai[nCont1] + ".TXT"
					cTxtSys := cDirSystem + '\T013' + StrZero(nCont2,4) + aEntSai[nCont1] + '.TXT'
					
					/*
						DEVE ESTAR FORA DA FUNÇÃO POR SE TRATAR DE MULT THREAD
						Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
					*/
					Aadd(aArqGer,cTxtSys)
					
					aParamMT[01] := aEntSai[nCont1]
					aParamMT[02] := .T.
					aParamMT[03] := aThreads[nCont2]
					aParamMT[04] := cQueryMT 
					aParamMT[05] := cTpSaida
					aParamMT[06] := cJobCtr
					aParamMT[07] := StrZero(nCont2,4) + aEntSai[nCont1]
					aParamMT[08] := l_TAFGST2
					aParamMT[09] := cTxtSys
					aParamMT[10] := lIntTaf
					aParamMT[11] := cDirSystem
					aParamMT[12] := aArqGer
					aParamMT[13] := {cEmpAnt,cFilAnt}
					aParamMT[14] := lFiltReinf
					aParamMT[15] := cFiltInt
					aParamMT[16] := cExtUser 
					
					// RegT013(a_Wizard,a_ParamMT,a_RgT022AB,a_VlrMovST,a_IcmPago,a_LanCDA2)
					o_MTProc:Go(aWizard,aParamMT,@a_RgT022AB,@a_VlrMovST,@a_IcmPago,@a_LanCDA2,@aParticip,@aProdutos,cTblTemp)

					// Para o processamento por 1 segundo
					Sleep(1000)
				EndIf
            Next 
            
        ElseIf !l_MultiThr .Or. !Empty(aThreads)
//			cTxtSys := cDirSystem + cBarraUnix + "T013" + aEntSai[nCont1] + ".TXT"   
			cTxtSys := cDirSystem + '\T013' + aEntSai[nCont1] + '.TXT'

            // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
            Aadd(aArqGer,cTxtSys)

            aParamMT[01] := aEntSai[nCont1]
            aParamMT[02] := .F.
            aParamMT[03] := {}
            aParamMT[04] := ""
            aParamMT[05] := cTpSaida
            aParamMT[06] := ""
            aParamMT[07] := ""
            aParamMT[08] := l_TAFGST2
            aParamMT[09] := cTxtSys
			aParamMT[10] := lIntTaf
			aParamMT[11] := cDirSystem
			aParamMT[12] := aArqGer
			aParamMT[13] := {cEmpAnt,cFilAnt}
			aParamMT[14] := lFiltReinf
			aParamMT[15] := cFiltInt
            
            If RegT013(aWizard,aParamMT,@a_RgT022AB,@a_VlrMovST,@a_IcmPago,@a_LanCDA2,@aParticip,@aProdutos,cTblTemp)
				lGerou := .T.
			EndIf
	
		EndIf
    Next

	If !l_MultiThr .or. ( l_MultiThr .and. ( !l_RegXThr .or. empty(aThreads) ) )
		If lGerou
			lGerFilial := .F.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,"T013",3)
		Else
			lGerFilPar := .T.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,"T013",1)
		EndIf
	EndIf
	if aWizard[01]
		GETGLBVARS( '_aRegT012AA', @aRegT012AA )
		if len(aRegT012AA)>0 
			FisaExtW01(cFilProc,0,"T012",3)
		endif
	endif 
Return Nil

/*/{Protheus.doc} fLayT035
    (Função para executar o layout T035)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT035()

    fMsgPrcss("Gerando Registro T035 - Deduções Diversas...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T035",2)
	
    // Monta o layout T035
    If RegT035()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T035",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T035",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT035
    (Realiza a geracao do registro T035 do TAF)

    @type Static Function
    @author Fabio V. Santana
    @since 22/04/2013

	@return lGerou, logico, se gerou ou não.
    /*/
Static Function RegT035()
	
	Local cReg     	:= "T035"
	Local cTxtSys  	:= cDirSystem + "\" + cReg + ".TXT"
	Local nHdlTxt  	:= IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )
	Local cAliasCF2 := "CF2"
	Local nPos      := 0
	Local lAchouCF2 := .F.
	Local cRegime   := oWizard:GetIncidTribPeriodo()
	Local cPeriodo  := SubStr(DTOS(oWizard:GetDataDe()),5,2) + SubStr(DTOS(oWizard:GetDataDe()),1,4)
	Local aParCF2   := {IIf(cRegime=="1","0",IIf(cRegime=="2","1","")),cPeriodo}
	Local aReg		:= {}

	Local lGerou := .F.
	
	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)
	
	If oFisaExtSx:_CF2
		
		If (lAchouCF2	:=	SPEDFFiltro(1,"CF2",@cAliasCF2,aParCF2))
			
			While !(cAliasCF2)->(Eof())
				lGerou := .T.

				aReg	:= {}
				aAdd(aReg, {})
				nPos := Len(aReg)
				aAdd (aReg[nPos], "T035")
				aAdd (aReg[nPos], SubStr((cAliasCF2)->CF2_PER,3,4)+SubStr((cAliasCF2)->CF2_PER,1,2)+"01")
				aAdd (aReg[nPos],(cAliasCF2)->CF2_ORIDED)
				aAdd (aReg[nPos],(cAliasCF2)->CF2_INDNAT)
				aAdd (aReg[nPos],(cAliasCF2)->CF2_DEDPIS)
				aAdd (aReg[nPos],(cAliasCF2)->CF2_DEDCOF)
				aAdd (aReg[nPos],(cAliasCF2)->CF2_BASE)
				aAdd (aReg[nPos],(cAliasCF2)->CF2_CNPJ)
				aAdd (aReg[nPos],(cAliasCF2)->CF2_INFORM)
			
				FConcTxt( aReg, nHdlTxt )

				// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
				If cTpSaida == "2"
					FConcST1()
				EndIf
				
				(cAliasCF2)->(DbSkip ())
			EndDo
		EndIf
	EndIf
	
	// Libero Handle do Arquivo
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf

Return lGerou

/*/{Protheus.doc} fLayT045
    (Função para executar o layout T045)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

	@Param n_HdlT007, numerico, Random do arquivo T007
	@Param n_HdlT003, numerico, Random do arquivo T003
	@Param a_Produtos, array, Produtos do registro T007
	@Param a_Particip, array, Participantes do registro T003

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT045(n_HdlT003,n_HdlT007,a_Produtos,a_Particip)

	Default n_HdlT003:= 0
	Default n_HdlT007:= 0

	Default a_Produtos  := {}
	Default a_Particip  := {}

    fMsgPrcss("Gerando Registro T045 - Controle de Estoque e Produção...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T045",2)
	
    // Monta o layout T045
    If ExtT045(@n_HdlT003,@n_HdlT007,@a_Produtos,@a_Particip)
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T045",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T045",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} fLayT065
    (Função para executar o layout T065)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT065()

    fMsgPrcss("Gerando Registro T065 - Controle de Créditos(PIS/Cofins)...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T065",2)
	
    // Monta o layout T065
    If RegT065()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T065",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T065",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT065
    (Realiza a geracao do registro T065 do TAF)

    @type Static Function
    @author Fabio V Santana
    @since 25/04/2013

    @return lGerou, logico, se gerou ou não.
    /*/
Static Function RegT065()

    Local cReg		   := "T065"
    Local cTxtSys      := cDirSystem + "\" + cReg + ".TXT"
    Local nHdlTxt	   := IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )
    Local nTotContrb   := 0
    Local nlI          := 0

    Local dDataDe      := oWizard:GetDataDe()
    Local dDataAte     := oWizard:GetDataAte()

    Local aPeriodo     := {}
    Local aRegT065     := {}
    Local aRegT065AA   := {}
    Local aRegT065AB   := {}

	Local lGerou := .F.

    // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
    Aadd(aArqGer,cTxtSys)

    aPeriodo := FGerPerTAF( dDataDe, dDataAte )

    For nlI:=1 To Len( aPeriodo )
        
        dDataDe := FirstDay( aPeriodo[nlI] )
        dDataAte := aPeriodo[nlI]
        
        If oFisaExtSx:_CF6
            // Chamo a função 2 vezes, a primeira vez aglutinara as informações para a geração do registro T065
            RegT065AA(@aRegT065,@aRegT065AA,@aRegT065AB,@nTotContrb,.F.,dDataDe, dDataAte, dDataAte, cTxtSys, nHdlTxt, .T.)
            
            RegT065AA(@aRegT065,@aRegT065AA,@aRegT065AB,@nTotContrb,.F.,dDataDe, dDataAte, dDataAte, cTxtSys, nHdlTxt, .F.)

            // Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
            If cTpSaida == "2" .And. Len(aRegT065) > 0 .And. Len(aDadosST1) > 0
                FConcST1()
            EndIf
        EndIf
    Next

    // Libero Handle do Arquivo
    If cTpSaida == "1" 
        FClose(nHdlTxt)
    EndIf

Return lGerou

/*/{Protheus.doc} RegT065AA
    (Realiza a geracao do registro T065 do TAF)

    @type Function
    @author Vitor Felipe
    @since 02/01/2012

    @param aRegT065, array, 
    @param aRegT065AA, array, 
    @param aRegT065AB, array, 
    @param nTotContrb, numerico, 
    @param lMesAtual, logico, 
    @param dDataDe, data, 
    @param dDataAte, data, 
    @param cPer, caracter, 
    @param cTxtSys, caracter, 
    @param nHdlTxt, numerico, 
    @param lRegT065, logico, 

    @return Nil, nulo, não tem retorno
    /*/
Function RegT065AA(aRegT065,aRegT065AA,aRegT065AB,nTotContrb,lMesAtual,dDataDe,dDataAte,cPer,cTxtSys,nHdlTxt,lRegT065)
	
	Local cAliasCF6 := "CF6"
	Local nPos		:= 0
	Local nPos02	:= 0
	Local dPriDia	:= FirstDay(cPer)-1
	Local cPerAnt 	:= Val2Str(strzero(month(dPriDia),2)) + SubStr(Val2Str(year(dPriDia )),1,4 )
	Local cPerAtu 	:= Val2Str(strzero(month((cPer) ) ,2)) + SubStr(Val2Str(year((cPer) )),1,4)
	Local cFilCF	:=	""
	Local nCredUti	:= 0  //Credito Utilizado
	Local cChavePa	:= ""
	Local cCodCred	:= ""
	Local nPosExt	:= 0
	Local cCusto	:= ""
	Local cConta	:= ""
	Local cCNPJExt	:=	""
	Local aParFil	:=	{}
	Local lAchouCF6	:=	.F.

    Default aRegT065 := {}
    Default aRegT065AA := {}
    Default aRegT065AB := {}

    Default nTotContrb := 0
    Default nHdlTxt := 0

    Default dDataDe := CToD("")
    Default dDataAte := CToD("")

    Default cPer := ""
    Default cTxtSys := ""

    Default lMesAtual := .F.
    Default lRegT065 := .F.
	
	aAdd(aParFil,DTOS(dDataDe))
	aAdd(aParFil,DTOS(dDataAte))
	
	If (lAchouCF6	:=	SPEDFFiltro(1,"CF6",@cAliasCF6,aParFil))
		
		Do While !(cAliasCF6)->(Eof ())
			If (cAliasCF6)->CF6_VALPIS > 0
				
				If oFisaExtSx:_CF6_CNPJ
					cFilCF		:=	Alltrim(SM0->M0_CODFIL)
					cCNPJExt	:=	SM0->M0_CGC
				EndIf
				
				cChavePa	:= ""
				cCusto 		:= ""
				cConta		:= ""
				If !Empty((cAliasCF6)->CF6_TIPONF) .And. !Empty((cAliasCF6)->CF6_CLIfOR)
					cChavePa := IIf(Alltrim((cAliasCF6)->CF6_TIPONF) == "0","F"+(cAliasCF6)->CF6_CLIfOR,"C"+(cAliasCF6)->CF6_CLIfOR)
				EndIf
				cCodCred := (cAliasCF6)->CF6_CODCRE
				If !Empty((cAliasCF6)->CF6_CODCCS)
					cCusto	 := (cAliasCF6)->CF6_CODCCS
				EndIf
				If !Empty((cAliasCF6)->CF6_CODCTA)
					cConta	 := (cAliasCF6)->CF6_CODCTA
				EndIf
				
				If lRegT065
					RegT065R(@aRegT065,cPerAnt,cCNPJExt,(cAliasCF6)->CF6_CODCRE,0,0,@nTotContrb,@nCredUti,cPerAtu,lMesAtual,(cAliasCF6)->CF6_VALPIS,@nPosExt,cPerAnt)
				EndIf
				
				If !lRegT065
					
					If (nPos := Ascan(aRegT065AA,{|aX| aX[2] == cChavePa .And. aX[3] == AModNot((cAliasCF6)->CF6_CODMOD) .And. aX[4] == (cAliasCF6)->CF6_SERIE .And.  aX[6] == (cAliasCF6)->CF6_NUMDOC }))==0
						
						If Len(aRegT065AA) > 0
							// Ao encontrar um novo registro, gravo o anterior
							FConcTxt( aRegT065AA, nHdlTxt )
							
							If Len(aRegT065AB) > 0
								// Ao encontrar um novo registro, gravo o anterior
								FConcTxt( aRegT065AB, nHdlTxt )
							EndIf
						Else
							aRegT065AA := {}
							aAdd(aRegT065AA, {})
							nPos := Len(aRegT065AA)
							aAdd(aRegT065AA[nPos], "T065AA")								//01 - REG
							aAdd(aRegT065AA[nPos], cChavePa)								//02 - COD_PART
							aAdd(aRegT065AA[nPos], AModNot((cAliasCF6)->CF6_CODMOD)) 		//03 - COD_MOD
							aAdd(aRegT065AA[nPos],(cAliasCF6)->CF6_SERIE)   				//04 - SERIE
							aAdd(aRegT065AA[nPos], "")					  					//05 - SUB_SER
							aAdd(aRegT065AA[nPos],(cAliasCF6)->CF6_NUMDOC)  				//06 - NUM_DOC
							aAdd(aRegT065AA[nPos],(cAliasCF6)->CF6_DTOPER)  				//07 - DT_OPER
							aAdd(aRegT065AA[nPos], AllTrim((cAliasCF6)->CF6_CHVNFE)) 		//08 - CHV_NFE
							aAdd(aRegT065AA[nPos], cConta)									//09 - COD_CTA
							aAdd(aRegT065AA[nPos], cCusto)				  					//10 - COD_CCUS
							aAdd(aRegT065AA[nPos], AllTrim((cAliasCF6)->CF6_DESCCO))		//11 - DESC_COMPL
							aAdd(aRegT065AA[nPos],(cAliasCF6)->CF6_PERESC)  				//12 - PER_ESCRIT
							aAdd(aRegT065AA[nPos], cCNPJExt)  								//13 - CNPJ
							
							cChvReg := cChavePa + AModNot((cAliasCF6)->CF6_CODMOD) + (cAliasCF6)->CF6_SERIE + (cAliasCF6)->CF6_NUMDOC
							aAdd(aRegT065AB, {})
						EndIf
					EndIf
					
					If cChvReg == cChavePa + AModNot((cAliasCF6)->CF6_CODMOD) + (cAliasCF6)->CF6_SERIE + (cAliasCF6)->CF6_NUMDOC
						
						nPos02 := Len(aRegT065AB)
						aAdd(aRegT065AB[nPos02],"T065AB")
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_ITEM)					//02 - COD_ITEM
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_VLOPER)				//03 - VL_OPER
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_CFOP)	   				//04 - CFOP
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_NATBCC)  				//05 - NAT_BC_CRED
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_ORICRE)  				//06 - IND_ORIG_CRED
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_CSTPIS)  				//07 - CST_PIS
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_BASPIS)  				//08 - VL_BC_PIS
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_ALQPIS)  				//09 - ALIQ_PIS
						aAdd(aRegT065AB[nPos02],(cAliasCF6)->CF6_VALPIS)  				//10 - VL_PIS
						aAdd(aRegT065AB[nPos02],0)
						aAdd(aRegT065AB[nPos02],0)
						aAdd(aRegT065AB[nPos02],0)
						
					EndIf

					// Grava detalhamento do Registro 1102 apenas para os CST's 53, 54, 55, 56, 63, 64, 65 ou 66 (Mais de uma receita).
					If (cAliasCF6)->CF6_CSTPIS $ "53|54|55|56|63|64|65|66"
						
						Do Case
						Case SubStr(cCodCred,1,1) = "1" //Receita Tributada no Mercado Interno.
							aRegT065AB[nPos02][11] += (cAliasCF6)->CF6_VALPIS
						Case SubStr(cCodCred,1,1) = "2" //Receita Nao Tributada no Mercado Interno.
							aRegT065AB[nPos02][12] += (cAliasCF6)->CF6_VALPIS
						Case SubStr(cCodCred,1,1) = "3" //Receita de Exportação.
							aRegT065AB[nPos02][13] += 	(cAliasCF6)->CF6_VALPIS
						EndCase
						
					EndIf
				EndIf
			EndIf
			(cAliasCF6)->(dbSkip())
		EndDo
	EndIf
	
	If lRegT065
		FConcTxt( aRegT065, nHdlTxt )
		
	ElseIf Len(aRegT065AA) > 0
		// Gravo o ultimo registro
		FConcTxt( aRegT065AA, nHdlTxt )
		
		If Len(aRegT065AB) > 0
			// Gravo o ultimo registro
			FConcTxt( aRegT065AB, nHdlTxt )
		EndIf

		If cTpSaida == "1" 
			FClose(nHdlTxt)
		EndIf
		
	EndIf
	
	If lAchouCF6
		SPEDFFiltro(2,,cAliasCF6)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT065AA
    (Realiza a geracao do registro T065 do TAF)

    @type Function
    @author Fabio V Santana
    @since 12/03/11

    @param aRegT065, array, 
    @param cPer, caracter, 
    @param cCnpj, caracter, 
    @param cCodCred, caracter, 
    @param nValCred, numerico, 
    @param nValDesc, numerico, 
    @param nTotContrb, numerico, 
    @param nCredUti, numerico, 
    @param cPerAtu, caracter, 
    @param lMesAtual, logico
    @param nCredExt, numerico, 
    @param nPosExt, numerico, 
    @param cRefer, caracter, 
    @param nRessar, numerico, 
    @param nComp, numerico, 
    @param nRessaAnt, numerico, 
    @param nCompAnt, numerico, 

    @return Nil, nulo, não tem retorno
    /*/
Function RegT065R(aRegT065,cPer,cCnpj,cCodCred,nValCred,nValDesc,nTotContrb,nCredUti,cPerAtu,lMesAtual,nCredExt,nPosExt,cRefer,nRessar,nComp,nRessaAnt,nCompAnt)
	
	Local nPos			:= 0
	Local nPosT065  	:= 0
	Local nTotCpo8		:= 0
	Local nTotCpo12		:= 0
	Local nTotCpo13		:= 0
	Local nTotCpo18		:= 0
	Local cMV_BCCR		:= oFisaExtSx:_MV_CODBCCR
	Local cMV_BCCC		:= oFisaExtSx:_MV_CODBCCC
	Local nCpo14		:= 0
	Local nCpo15		:= 0
	Local nCrdMesAtu	:= 0
	Local nCrdMesAnt	:= 0

    Default aRegT065 := {}

    Default cPer := ""
    Default cCnpj := ""
    Default cCodCred := ""
    Default cPerAtu := ""
    Default cRefer := ""
    
    Default nValCred := 0
    Default nValDesc := 0
    Default nTotContrb := 0
    Default nCredUti := 0
    Default nCredExt := 0
    Default nPosExt := 0
    Default nRessar := 0
    Default nComp := 0
    Default nRessaAnt := 0
    Default nCompAnt := 0
    
    Default lMesAtual := .F.
    
	If Empty(cRefer)
		cRefer := cPer
	EndIf
	
	If lMesAtual
		nCrdMesAtu	:= nValDesc
	Else
		nCrdMesAnt	:= nValDesc
	EndIf
	
	If nValCred > 0 .Or. nCredExt > 0
		
		nPosT065 := Ascan (aRegT065, {|aX| aX[4]==cRefer })
		nPosExt := nPosT065
		
		If nPosT065 ==0
			aAdd(aRegT065, {})
			nPos := Len(aRegT065)
			nPosExt := nPos
			aAdd (aRegT065[nPos], "T065")						   	//01 - REG
			aAdd (aRegT065[nPos], cPer)							   	//02 - REG 02
			aAdd (aRegT065[nPos], "1")							   	//03 - Tipo de Tributo 03
			aAdd (aRegT065[nPos], cRefer)				   			//04 - PER_APU_CRED 04
			aAdd (aRegT065[nPos], "01")						   		//05 - ORIG_CRED 05
			aAdd (aRegT065[nPos], cCnpj)						   	//06 - CNPJ_SUC 06
			aAdd (aRegT065[nPos], cCodCred)						   	//07 - COD_CRED 07
			aAdd (aRegT065[nPos], nValCred)					   		//08 - VL_CRED_APU 08
			aAdd (aRegT065[nPos], nCredExt)						   	//09 - VL_CRED_EXT_APU 09
			
			nTotCpo8 := nValCred + nCredExt
			aAdd (aRegT065[nPos], nTotCpo8)					   		//10 - VL_TOT_CRED_APU 10
			
			aAdd (aRegT065[nPos], nCrdMesAnt)					   		//11 - VL_CRED_DESC_PA_ANT 11
			aAdd (aRegT065[nPos], IIf(cCodCred$cMV_BCCR,nRessaAnt,""))		//12 - VL_CRED_PER_PA_ANT 12
			aAdd (aRegT065[nPos], IIf(cCodCred$cMV_BCCC,nCompAnt,""))		//13 - VL_CRED_DCOMP_PA_ANT 13
			
			nTotCpo12:= nTotCpo8 - nCrdMesAnt - nRessaAnt - nCompAnt
			aAdd (aRegT065[nPos], nTotCpo12)				   		//14 - SD_CRED_DISP_EFD 14
			
			If nTotContrb > 0 .And. !lMesAtual
				
				If  nTotCpo12  <= nTotContrb // Total de credito do mes anterior for menor que a contribuição deste mes, utiliza o credito
					nTotCpo13  := nTotCpo12	 //Utiliza todo o credito
					nCredUti   += nTotCpo13
					nTotContrb -= nTotCpo13
				Else
					nTotCpo13  := nTotCpo12 - nTotContrb
					nTotCpo13  := nTotCpo12 - nTotCpo13
					nCredUti   += nTotCpo13
					nTotContrb := 0
				EndIf
				
			ElseIf lMesAtual
				nTotCpo13 := nCrdMesAtu
			EndIf
			
			aAdd (aRegT065[nPos], nTotCpo13)						 //15 - VL_CRED_DESC_EFD 15
			nTotCpo18 := nTotCpo12 - nTotCpo13
			
			If (nRessar+nComp) <= nTotCpo18
				nTotCpo18   -= ( nRessar + nComp)
				nCpo14		:= nRessar
				nCpo15		:= nComp
			Else
				nCpo14		:= 0
				nCpo15		:= 0
			EndIf
			
			aAdd (aRegT065[nPos], nCpo14)					   		//16 - VL_CRED_PER_EFD 16
			aAdd (aRegT065[nPos], nCpo15)					   		//17 - VL_CRED_DCOMP_EFD 17
			aAdd (aRegT065[nPos], 0)						   		//18 - VL_CRED_TRANS 18
			aAdd (aRegT065[nPos], 0)						   		//19 - VL_CRED_OUT 19
			aAdd (aRegT065[nPos], nTotCpo18)						//20 - SLD_CRED_FIM 20
			
		Else
			If !lMesAtual
				aRegT065[nPosT065][08]	+= nValCred
				aRegT065[nPosT065][09]	+= nCredExt
				
				nTotCpo8 := nValCred + nCredExt
				aRegT065[nPosT065][10]	+= nTotCpo8
				
				aRegT065[nPosT065][11]	+= nCrdMesAnt
				aRegT065[nPosT065][12]	+= IIf(cCodCred$cMV_BCCR,nRessaAnt,"")
				aRegT065[nPosT065][13]	+= IIf(cCodCred$cMV_BCCC,nCompAnt,"")
				
				nTotCpo12:= nTotCpo8 - nCrdMesAnt - nRessaAnt - nCompAnt
				aRegT065[nPosT065][14]	+= nTotCpo12
				
				If nTotContrb > 0 .And. !lMesAtual
					
					If  nTotCpo12  <= nTotContrb
						nTotCpo13  := nTotCpo12
						nCredUti   += nTotCpo13
						nTotContrb -= nTotCpo13
					Else
						nTotCpo13  := nTotCpo12 - nTotContrb
						nTotCpo13  := nTotCpo12 - nTotCpo13
						nCredUti   += nTotCpo13
						nTotContrb := 0
					EndIf
					
				ElseIf lMesAtual
					nTotCpo13 := nCrdMesAtu
				EndIf
				
				aRegT065[nPosT065][15] += nTotCpo13
				nTotCpo18 := nTotCpo12 - nTotCpo13
				
				If ( nRessar + nComp) <= nTotCpo18
					nTotCpo18         -= ( nRessar + nComp )
					nCpo14		      := nRessar
					nCpo15		      := nComp
				Else
					nCpo14		      := 0
					nCpo15		      := 0
				EndIf
				
				aRegT065[nPosT065][16] += nCpo14
				aRegT065[nPosT065][17] += nCpo15
				aRegT065[nPosT065][18] += 0
				aRegT065[nPosT065][19] += 0
				aRegT065[nPosT065][20] += nTotCpo18
				
			EndIf
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} fLayT072
    (Função para executar o layout T072)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT072()

    fMsgPrcss("Gerando Registro T072 - Valor Agregado...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T072",2)
	
    // Monta o layout T072
    If RegT072()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T072",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T072",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT072
    (Realiza a geracao do registro T072 do TAF)

    @author Rodrigo Aguilar
    @since 26/05/2013

    @return lGerou, logico, se gerou ou não.
    /*/
Static Function RegT072()

    Local cReg    := "T072"
    Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
    Local nHdlTxt := IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )

    Local cDataDe := DToS(oWizard:GetDataDe())
    Local cDataAte := DToS(oWizard:GetDataAte())

    Local cUf      := ""
	Local cSelect := ""

    Local lF4_VLAGREG  := oFisaExtSx:_F4_VLAGREG

    Local nlI := 0
    Local nlY := 0

    Local cAliasQry	:=	GetNextAlias()

    Local aRegs     := {}
    Local aPeriodo  := {}
    Local cChave	:= ""
    Local cMVEstado := oFisaExtSx:_MV_ESTADO
    Local cCodExt	:= "9999999"
    Local cQuery	:= ""

	Local lGerou := .F.

    // Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
    Aadd(aArqGer,cTxtSys)

    aPeriodo := FGerPerTAF( SToD( cDataDe ), SToD( cDataAte ) )

	cSelect := "%," + xFunExpSql("COALESCE") + "(F09.F09_CODIPM,'') CODIPM%"
        
    For nlY := 1 To Len( aPeriodo )
            
        cDataDe  :=  StrZero( Year( aPeriodo[nlY] ), 4 ) + StrZero( Month( aPeriodo[nlY] ), 2 ) + "01"
        cDataAte :=  StrZero( Year( aPeriodo[nlY] ), 4 ) + StrZero( Month( aPeriodo[nlY] ), 2 ) + Right( DToS( LastDay( aPeriodo[nlY] ) ), 2 )
            
        If lF4_VLAGREG
            BeginSql Alias cAliasQry
            
            SELECT
                NOTA.TIPOMOV
                ,NOTA.TIPO
                ,NOTA.PRODUTO
                ,SUM(NOTA.VALCONT) VALCONT
                ,NOTA.VLAGREG
                ,NOTA.EST
                ,NOTA.COD_MUN
                ,NOTA.CODIPM
            FROM (
                SELECT 
                    SFT.FT_TIPOMOV TIPOMOV
                    ,SFT.FT_TIPO TIPO
                    ,SFT.FT_PRODUTO PRODUTO
                    ,SFT.FT_VALCONT VALCONT
                    ,SF4.F4_VLAGREG VLAGREG
                    ,SA1_SA2.EST
                    ,CASE WHEN SFT.FT_CFOP IN ('1949','2949','3949','5949','6949','7949') THEN %Exp:SubStr(AllTrim(SM0->M0_CODMUN),3)%
                     ELSE SA1_SA2.COD_MUN
                     END COD_MUN
                    %Exp:cSelect%
                FROM %Table:SFT% SFT
                
                INNER JOIN (
                    SELECT
                        SA1.A1_COD CLIEFOR
                        ,SA1.A1_LOJA LOJA
                        ,SA1.A1_EST EST
                        ,SA1.A1_COD_MUN COD_MUN
                        ,'SA1' TABELA
                    FROM %Table:SA1% SA1
                
                    WHERE
                        SA1.%NotDel%
                        AND SA1.A1_FILIAL = %xFilial:SA1%
                    
                    UNION ALL
                    
                    SELECT
                        SA2.A2_COD
                        ,SA2.A2_LOJA
                        ,SA2.A2_EST
                        ,SA2.A2_COD_MUN
                        ,'SA2' TABELA
                    FROM %Table:SA2% SA2
                    
                    WHERE
                        SA2.%NotDel%
                        AND SA2.A2_FILIAL = %xFilial:SA2%
                ) SA1_SA2 ON
                    SA1_SA2.TABELA = CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('B','D')) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('B','D')) THEN 'SA2' Else 'SA1' End
                    AND SA1_SA2.CLIEFOR = SFT.FT_CLIEFOR
                    AND SA1_SA2.LOJA = SFT.FT_LOJA
                    AND SA1_SA2.EST = %Exp:cMVEstado%
                    AND SA1_SA2.COD_MUN <> %Exp:cCodExt%
                    
                INNER JOIN (
                    SELECT
                        SD1.D1_DOC DOC
                        ,SD1.D1_SERIE SERIE
                        ,SD1.D1_FORNECE CLIEFOR
                        ,SD1.D1_LOJA LOJA
                        ,SD1.D1_ITEM ITEM
                        ,SD1.D1_TES TES
                        ,'SD1' TABELA
                    FROM %Table:SD1% SD1
                    
                    WHERE
                        SD1.%NotDel%
                        AND SD1.D1_FILIAL = %xFilial:SD1%
                        
                    UNION ALL
                    
                    SELECT
                        SD2.D2_DOC
                        ,SD2.D2_SERIE
                        ,SD2.D2_CLIENTE
                        ,SD2.D2_LOJA
                        ,SD2.D2_ITEM
                        ,SD2.D2_TES
                        ,'SD2'
                    FROM %Table:SD2% SD2
                    
                    WHERE
                        SD2.%NotDel%
                        AND SD2.D2_FILIAL = %xFilial:SD2%
                ) SD1_SD2 ON
                    SD1_SD2.DOC = SFT.FT_NFISCAL 
                    AND SD1_SD2.SERIE = SFT.FT_SERIE 
                    AND SD1_SD2.CLIEFOR = SFT.FT_CLIEFOR 
                    AND SD1_SD2.LOJA = SFT.FT_LOJA 
                    AND SD1_SD2.ITEM = SFT.FT_ITEM
                    
                INNER JOIN %Table:SF4% SF4 ON
                    SF4.%NotDel%
                    AND SF4.F4_FILIAL = %xFilial:SF4%
                    AND SF4.F4_CODIGO = SD1_SD2.TES
                    AND SF4.F4_VLAGREG <> ' '
                    
                LEFT OUTER JOIN %Table:F09% F09 ON
                    F09.%NotDel%
                    AND F09.F09_FILIAL = %xFilial:F09% 
                    AND F09.F09_TES = SF4.F4_CODIGO
                
                WHERE
                    SFT.%NotDel%
                    AND SFT.FT_FILIAL = %xFilial:SFT%
                    AND SFT.FT_ENTRADA >= %Exp:cDataDe%
                    AND SFT.FT_ENTRADA <= %Exp:cDataAte%
                    AND SFT.FT_DTCANC = ' '
                ) NOTA
                
            GROUP BY
                NOTA.TIPOMOV
                ,NOTA.TIPO
                ,NOTA.PRODUTO
                ,NOTA.VLAGREG
                ,NOTA.EST
                ,NOTA.COD_MUN
                ,NOTA.CODIPM
            
            ORDER BY
                NOTA.PRODUTO
                ,NOTA.EST
                ,NOTA.COD_MUN
                
            EndSql

            aRegs := {}
            
            (cAliasQry)->(DbGoTop())
            While (cAliasQry)->(!Eof())
                cChave := Alltrim((cAliasQry)->PRODUTO) + Alltrim((cAliasQry)->EST) + Alltrim((cAliasQry)->COD_MUN) + Alltrim((cAliasQry)->CODIPM)
                aRegs  := {}

				lGerou := .T.
                
                Aadd(aRegs,{"T072",;
                    cDataDe,;
                    AllTrim((cAliasQry)->PRODUTO),;
                    Alltrim((cAliasQry)->EST ),;
                    Alltrim((cAliasQry)->COD_MUN ),;
                    0,;
                    Alltrim((cAliasQry)->CODIPM)})
                    
                While (cAliasQry)->(!Eof()) .And. cChave == Alltrim((cAliasQry)->PRODUTO) + Alltrim((cAliasQry)->EST) + Alltrim((cAliasQry)->COD_MUN) + Alltrim((cAliasQry)->CODIPM)
                
                    If (nPos := Ascan (aRegs, {|aX| aX[3]+aX[4]+aX[5]== Alltrim((cAliasQry)->PRODUTO)+Alltrim((cAliasQry)->EST)+Alltrim((cAliasQry)->COD_MUN)}))> 0
                        If (cAliasQry)->VLAGREG=="D"
                            aRegs[nPos][6] -= (cAliasQry)->VALCONT
                        Else
                            aRegs[nPos][6] += (cAliasQry)->VALCONT
                        EndIf
                    EndIf
                    
                    (cAliasQry)->(DbSkip())
                EndDo
                
                // Realizo a geracao do Registro T072
                FConcTxt( aRegs, nHdlTxt )
                
                // Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
                If cTpSaida == "2"
                    FConcST1()
                EndIf
            EndDo
            
            (cAliasQry)->(DbCloseArea())
        EndIf
    Next

    If cTpSaida == "1"
        FClose(nHdlTxt)
    EndIf

Return lGerou


/*/{Protheus.doc} fLayT078
    (Função para executar o layout T078)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT078()

    fMsgPrcss("Gerando Registro T078 - Movimentos ECF...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T078",2)
	
    // Monta o layout T078
    If RegT078()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T078",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T078",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT078
    (Realiza a geracao do registro T078 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 23/05/2013

    @return lGerou, logico, se gerou ou não.
/*/
Static Function RegT078()
	
	Local cReg     := "T078"
	Local cTxtSys  := cDirSystem + "\" + cReg + ".TXT"
	Local nHdlTxt  := IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )
	
	Local cCodEcf  := ""
	
	Local cDataDe  := DToS(oWizard:GetDataDe())
	Local cDataAte := DToS(oWizard:GetDataAte())
	
	Local nRecSFI  := 0
	
	Local aRegs      := {}
	Local aRegT078AG := {}
	Local aRegT001AJ := {}
	
	Local cAliasQry := GetNextAlias()

	Local lGerou := .F.
	
	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)
	
	BeginSql alias cAliasQry
		SELECT
		LG_CODIGO
		,SFI.R_E_C_N_O_ SFIRECNO
		,FI_DTMOVTO
		,FI_CRO
		,FI_NUMREDZ
		,FI_NUMFIM
		,FI_GTFINAL
		,FI_VALCON
		,FI_ISS
		,FI_DESC
		,FI_CANCEL
		,FI_PDV
		FROM
		%Table:SLG% SLG, %Table:SFI% SFI
		WHERE
		SFI.FI_FILIAL = %xfilial:SFI% AND
		SFI.FI_PDV = LG_PDV AND
		SFI.FI_SERPDV = LG_SERPDV AND
		SFI.%notDel% AND
		SFI.FI_DTMOVTO >= %Exp:cDataDe% AND
		SFI.FI_DTMOVTO <= %Exp:cDataAte% AND
		SLG.LG_FILIAL = %xfilial:SLG% AND
		SLG.%notDel%
		ORDER BY SLG.LG_CODIGO, SFI.FI_DTMOVTO, SFI.FI_PDV, SFI.FI_NUMREDZ
	EndSql
	
	DbSelectArea( cAliasQry )
	While (cAliasQry)->( !Eof() )
		lGerou := .T.

		cCodEcf := (cAliasQry)->LG_CODIGO
		
		aRegs := {}
		(cAliasQry)->( Aadd( aRegs, {  cReg,;
			LG_CODIGO } ) )
		
		FConcTxt( aRegs, nHdlTxt )
		
		aRegT078AG := {}
		
		While (cAliasQry)->( !Eof() ) .And. cCodEcf == (cAliasQry)->LG_CODIGO
			
			RegT078AA( nHdlTxt, cAliasQry )
			
			// Devo posicionar na tabela fisica para utilizar a funcao TotalizSFT padrao no fonte SPEDXFUN
			nRecSFI := (cAliasQry)->SFIRECNO
			If SpedSeek( "SFI", , , nRecSFI )
				
				// Carrego todos os codigos e valores que foram contabilizados no SFI
				aTotaliz := TotalizSFI( nRecSFI, .T. )
				
				RegT078AB(nHdlTxt,aTotaliz,cAliasQry,@aRegT001AJ)
			EndIf
			
			RegT078AD(nHdlTxt,cAliasQry,@aRegT078AG)
			
			RegT078AJ(nHdlTxt,cAliasQry)
			
			(cAliasQry)->(DbSkip())
		EndDo
		
		RegT078AG( nHdlTxt, aRegT078AG )

		// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
		If cTpSaida == "2"
			FConcST1()
		EndIf
		
	EndDo
	(cAliasQry)->( DbCloseArea() )
	
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf
	
Return lGerou

/*/{Protheus.doc} RegT078AA
    (Realiza a geracao do registro T078AA do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 23/05/2013

    @param nHdlTxt, numerico, Handle para gravacao do Registro
    @param cAliasQry, caracter, Alias de Execucao da Query

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT078AA(nHdlTxt,cAliasQry)
	
	Local cReg := "T078AA"
	
	Local aRegs := {}
	
	aRegs := {}
	(cAliasQry)->( Aadd( aRegs, {  cReg,;
		FI_DTMOVTO,;
		Val2Str( FI_CRO, 3 ),;
		Val2Str( FI_NUMREDZ, 6 ),;
		Val2Str( FI_NUMFIM, 6 ),;
		Val2Str( FI_GTFINAL, 16, 2 ),;
		Val2Str( FI_VALCON + FI_ISS + FI_DESC + FI_CANCEL, 16, 2 ),;
		Val2Str( 0, 16, 2 ),;
		Val2Str( 0, 16, 2 ),;
		Val2Str( 0, 16, 2 ),;
		Val2Str( 0, 16, 2 ) } ) )
	
	FConcTxt( aRegs, nHdlTxt )
	
Return Nil

/*/{Protheus.doc} RegT078AB
    (Realiza a geracao do registro T078AB do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 23/05/2013

    @param nHdlTxt, numerico, handle para gravacao do Registro
    @param aTotaliz, array, Array com dados da Contabilizacao SFI
    @param cAliasQry, caracter, Alias da Query do registro PAI

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT078AB(nHdlTxt,aTotaliz,cAliasQry,aRegT001AJ)
	
	Local cReg 	:= "T078AB"
	Local nlI 	:= 1
	Local nPos 	:= 0
	
	Local cTxtSys := cDirSystem + "\T001AJ.TXT"

	Local nHdlT001AJ  := IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )

	Local AregAux	  := {}
	Local aDadosBak   := {}
	Local aRegs := {}

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)
	
	For nlI:=1 To Len( aTotaliz )
		
		aRegs := {}
		Aadd( aRegs, {  cReg,;
			aTotaliz[nlI][1],;
			Val2Str( aTotaliz[nlI][2], 16, 2 ),;
			Val2Str( aTotaliz[nlI][3], 2 ),;
			"" } )
		
		FConcTxt( aRegs, nHdlTxt )
		
		RegT078AC( nHdlTxt, cAliasQry, aTotaliz[nlI][1] )
		
		If (nPos := Ascan(AregAux ,{|aX| aX[2] == aTotaliz[nlI][2]}))==0
			
			aAdd(AregAux, {})
			nPos	:=	Len(AregAux)
			aAdd(AregAux[nPos], "T0001AJ")
			aAdd(AregAux[nPos], aTotaliz[nlI][2])
			aAdd(AregAux[nPos], "")
			aAdd(AregAux[nPos], "")
			aAdd(AregAux[nPos], "")
			
            aDadosBak := aClone(aDadosST1)

			aDadosST1 := {}

			FConcTxt( AregT001AJ, nHdlT001AJ )

			aDadosST1 := aClone(aDadosBak)
			
			AregT001AJ := {}
			aAdd(AregT001AJ, {})
			nPos	:=	Len(AregT001AJ)
			aAdd(AregT001AJ[nPos], "T0001AJ")
			aAdd(AregT001AJ[nPos], aTotaliz[nlI][2])
			aAdd(AregT001AJ[nPos], "")
			aAdd(AregT001AJ[nPos], "")
			aAdd(AregT001AJ[nPos], "")
			
			// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
			If cTpSaida == "2"
				FConcST1()
			EndIf

		EndIf
		
	Next
	
Return Nil

/*/{Protheus.doc} RegT078AC
Realiza a geracao do registro T078AC do TAF

@type Static Function
@author Rodrigo Aguilar
@since 23/05/2013

@param nHdlTxt, numerico, handle para gravacao do Registro
@param cAliasQry, caracter, Alias ds Query do Registro PAI
@param cSitTrib, caracter, Relacao com o PAI

@return Nil, nulo, não tem retorno
/*/
Static Function RegT078AC(nHdlTxt,cAliasQry,cSitTrib)
	
	Local cReg := "T078AC"
	
	Local aRegs		:= {}
	Local aProdB1	:=  {}
	
	Local cDataMov := (cAliasQry)->FI_DTMOVTO
	Local cPdv     := (cAliasQry)->FI_PDV
	
	Local cTemp	:= GetNextAlias()
	
	BeginSql alias cTemp
		SELECT SFT.FT_PRODUTO ,
		SUM(FT_VALCONT) FT_VALCONT , SUM(FT_VALPIS) FT_VALPIS ,
		SUM(FT_VALCOF) FT_VALCOF ,SUM(FT_QUANT) FT_QUANT, SD2.D2_SITTRIB
		
		FROM %table:SFT% SFT  , %table:SD2% SD2
		WHERE   SFT.FT_FILIAL   = %xfilial:SFT%  		AND
		SFT.FT_TIPOMOV  = 'S'   				AND
		SFT.FT_ENTRADA  = %exp:cDataMov% AND
		SFT.FT_PDV      = %exp:cPdv%			AND
		SFT.FT_ESPECIE	= 'CF'					AND
		SFT.FT_DTCANC	= ' '					AND
		SFT.%notDel%       						AND
		SFT.FT_FILIAL   = SD2.D2_FILIAL  		AND
		SFT.FT_PDV      = SD2.D2_PDV     		AND
		SFT.FT_NFISCAL	= SD2.D2_DOC        	AND
		SFT.FT_SERIE	= SD2.D2_SERIE			AND
		SFT.FT_ITEM 	= SD2.D2_ITEM			AND
		SD2.D2_SITTRIB  = %exp:cSitTrib%       AND
		SD2.%notDel%
		
		GROUP BY FT_PRODUTO,FT_FILIAL,FT_TIPOMOV,SD2.D2_SITTRIB
		ORDER BY FT_FILIAL
	EndSql
	
	While (cTemp)->( !Eof() )
		
		aRegs := {}
		(cTemp)->( Aadd( aRegs, {  cReg,;
			FT_PRODUTO,;
			Val2Str( FT_QUANT, 16, 3),;
			RetUMProd( @aProdB1, (cTemp)->FT_PRODUTO)[1],;
			Val2Str( FT_VALCONT, 16, 2 ),;
			Val2Str( FT_VALPIS, 16, 2 ),;
			Val2Str( FT_VALCOF, 16, 2 ) } ) )
		
		FConcTxt( aRegs, nHdlTxt )
		
		(cTemp)->( DbSkip() )
	EndDo
	(cTemp)->(DbCloseArea())
	
Return Nil

/*/{Protheus.doc} RegT078AD
    (Realiza a geracao do registro T078AD do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 23/05/2013

    @param nHdlTxt, numerico, handle para gravacao do Registro
    @param cAliasQry, caracter, Alias ds Query do Registro PAI
    @param aRegT078AG, array, Array com informacoes do registro T078AG

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT078AD(nHdlTxt,cAliasQry,aRegT078AG)
	
	Local cReg := "T078AD"
	
	Local cDataMov := (cAliasQry)->FI_DTMOVTO
	Local cPdv     := (cAliasQry)->FI_PDV
	
	Local cCpfCNPJ  := ""
	Local cSituaDoc := ""
	Local cChave    := ""
	
	Local aInfPart   := {}
	Local aClasFis   := {}
	Local aRegT078AE := {}
	Local aRegT078AF := {}
	Local aRegs      := {}
	
	Local lCmpNRecFT := .F.
	Local lCmpNRecB1 := .F.
	Local lCmpNRecF4 := .F.
	Local cSFTTemp	:= GetNextAlias()
	
	If oFisaExtSx:_FT_TNATREC .And. oFisaExtSx:_FT_CNATREC  .And. oFisaExtSx:_FT_GRUPONC .And. oFisaExtSx:_FT_DTFIMNT
		lCmpNRecFT := .T.
	EndIf
	
	If oFisaExtSx:_B1_TNATREC  .And. oFisaExtSx:_B1_CNATREC  .And. oFisaExtSx:_B1_GRPNATR  .And. oFisaExtSx:_B1_DTFIMNT
		lCmpNRecB1 := .T.
	EndIf
	
	If oFisaExtSx:_F4_TNATREC .And. oFisaExtSx:_F4_CNATREC .And. oFisaExtSx:_F4_GRPNATR .And. oFisaExtSx:_F4_DTFIMNT
		lCmpNRecF4 := .T.
	EndIf
	
	BeginSql alias cSFTTemp
		SELECT 	SFT.FT_FILIAL, SFT.FT_NFISCAL 	, SFT.FT_ENTRADA , SFT.FT_VALCONT, SFT.FT_VALPIS  , SFT.FT_VALCOF,
		SFT.FT_VALCONT 	, SFT.FT_QUANT 	 , SFT.FT_ITEM	 , SFT.FT_PRODUTO , SFT.FT_PRCUNIT 	,
		SFT.FT_CFOP 	, SFT.FT_ALIQICM , SFT.FT_LOJA	 , SFT.FT_CLIEFOR , SFT.FT_TIPO		,
		SFT.FT_CLASFIS  , SFT.FT_CTIPI 	 , SFT.FT_TIPOMOV, SFT.FT_DTCANC  , SFT.FT_BASEICM  ,
		SFT.FT_VALICM 	, SFT.FT_FORMUL	 , SFT.FT_ESPECIE, SFT.FT_SERIE	  , SD2.D2_SITTRIB	, SD2.D2_TES,
		SFT.FT_CONTA    , SFT.FT_DESCONT , SFT.FT_DESPESA, SFT.FT_CSTPIS , SFT.FT_ALIQPS3,
		SFT.FT_BASEPS3  , SFT.FT_VALPS3  , SFT.FT_ALIQPIS, SFT.FT_BASEPIS, SFT.FT_VALPIS,
		SFT.FT_TOTAL    , SFT.FT_PAUTPIS , SFT.FT_PAUTCOF, SFT.FT_CSTCOF,  SFT.FT_ALIQCF3,
		SFT.FT_BASECF3  , SFT.FT_VALCF3  , SFT.FT_ALIQCOF, SFT.FT_BASECOF, SFT.FT_VALCOF,
		SFT.FT_CODISS   , SFT.FT_ISENICM , SFT.FT_OUTRICM, SFT.FT_ICMSCOM, SFT.FT_ICMSRET,
		SFT.FT_ALIQIPI  , SFT.FT_BASEIRR , SFT.FT_BASEINS,	SB1.B1_VLR_PIS, SB1.B1_VLR_COF, SB1.B1_ORIGEM,
		SFT.FT_BASERET  , SFT.FT_OUTRRET , SFT.FT_ISENRET, SFT.FT_BASEIPI, SFT.FT_VALIPI,
		SFT.FT_ISENIPI  , SFT.FT_OUTRIPI , SFT.FT_VALIRR , SFT.FT_VALINS, SFT.R_E_C_N_O_ RECSFT,
		
		(SELECT SUM(LX_QTDE)
		FROM  %table:SLX% SLX
		WHERE 	SLX.LX_FILIAL 	= SFT.FT_FILIAL  AND
		SLX.LX_PDV 		= SFT.FT_PDV 	 AND
		SLX.LX_CUPOM 	= SFT.FT_NFISCAL AND
		SLX.LX_SERIE 	= SFT.FT_SERIE 	 AND
		SLX.LX_DTMOVTO	= SFT.FT_ENTRADA AND
		SLX.LX_PRODUTO  = SFT.FT_PRODUTO AND
		SLX.LX_ITEM		= SFT.FT_ITEM    AND
		SLX.%notDel% ) AS LX_QTDCANC,
		
		(SELECT SUM(LX_VALOR)
		FROM  %table:SLX% SLX
		WHERE 	SLX.LX_FILIAL 	= SFT.FT_FILIAL  AND
		SLX.LX_PDV 		= SFT.FT_PDV 	 AND
		SLX.LX_CUPOM 	= SFT.FT_NFISCAL AND
		SLX.LX_SERIE 	= SFT.FT_SERIE 	 AND
		SLX.LX_DTMOVTO	= SFT.FT_ENTRADA AND
		SLX.LX_PRODUTO  = SFT.FT_PRODUTO AND
		SLX.LX_ITEM		= SFT.FT_ITEM    AND
		SLX.%notDel% ) AS LX_VALOR
		
		FROM %table:SFT% SFT LEFT JOIN %table:SD2% SD2 ON
		SD2.D2_FILIAL = %xfilial:SD2%	AND
		SFT.FT_PDV      = SD2.D2_PDV	AND
		SFT.FT_NFISCAL	= SD2.D2_DOC	AND
		SFT.FT_SERIE    = SD2.D2_SERIE	AND
		SFT.FT_ITEM     = SD2.D2_ITEM	AND
		SD2.%notDel%
		
		LEFT JOIN %table:SB1% SB1 ON
		SB1.B1_FILIAL   = %xfilial:SB1%  AND
		SB1.B1_COD      = SFT.FT_PRODUTO AND
		SB1.%notDel%
		
		WHERE   SFT.FT_FILIAL   = %xfilial:SFT%			AND
		SFT.FT_TIPOMOV  = 'S'					AND
		SFT.FT_ENTRADA  = %exp:cDataMov%  AND
		SFT.FT_PDV      = %exp:cPdv%			AND
		SFT.FT_ESPECIE	= 'CF'					AND
		SFT.%notDel%
		ORDER BY
		SFT.FT_NFISCAL
	EndSql
	
	While (cSFTTemp)->( !Eof() )
		// Aproveito a Query na SFT baseada no movimento para buscar as informacoes do registro T078AG
		cChave := xFilial( "CDG" ) + (cSFTTemp)->( FT_TIPOMOV + FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA )
		If CDG->( MsSeek( cChave ) )
			While CDG->( !Eof() ) .And. cChave == xFilial( "CDG" ) + (cSFTTemp)->( FT_TIPOMOV + FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA )
				If Ascan ( aRegT078AG,{|aX| aX[2] == CDG->CDG_PROCES } ) == 0
					CDG->( aAdd( aRegT078AG, { "T078AG",;
						CDG->CDG_PROCES,;
						CDG_TPPROC  } ) )
				EndIf
				CDG->( DbSkip() )
			EndDo
		EndIf
		
		aRegT078AE := {}
		aRegT078AF := {}
		cNF 	   := (cSFTTemp)->FT_NFISCAL
		
		cCpfCNPJ := ""
		
		If SA1->( MsSeek( xFilial( "SA1" ) + (cSFTTemp)->FT_CLIEFOR + (cSFTTemp)->FT_LOJA ) )
			
			aInfPart := TafPartic( "SA1" )
			cCpfCNPJ := IIf( Empty( aInfPart[4] ), aInfPart[6], aInfPart[4] )
			
			If LJAnalisaLEG(58)[1] 	// Para a Nota Fiscal Gaucha pega os dados do cupom
				DbSelectArea("SL1")
				DbSetOrder(2)
				If MsSeek( xFilial( "SL1" ) + (cSFTTemp)->FT_SERIE + (cSFTTemp)->FT_NFISCAL )
					cCpfCNPJ := AllTrim( SL1->L1_CGCCLI )
				EndIf
			EndIf
		EndIf
		
		cSituaDoc := SPEDSitDoc(,cSFTTemp,,,,,,,,,)
		
		aRegs := {}
		(cSFTTemp)->( Aadd( aRegs, {  cReg,;
			"2D",;
			cSituaDoc,;
			FT_NFISCAL,;
			FT_ENTRADA,;
			0,;
			cCpfCNPJ,;
			aInfPart[7],;
			"" } ) )
		
		While (cSFTTemp)->( !Eof() ) .And. cNF == (cSFTTemp)->FT_NFISCAL
			
			// Soma Valor Total do Doc
			aRegs[1][6] += (cSFTTemp)->FT_VALCONT
			
			
			// Busco o CST de Icm do Item
			aClasFis := SPDRetCCST ( cSFTTemp, .F. )
			
			// Armazeno os valores de Itens da NF
			RegT078AE( @aRegT078AE, @aRegT078AF, cSFTTemp, aClasFis )
			
			(cSFTTemp)->( DbSkip())
		EndDo
		
		// Converto de Numerico para Str para Gravacao
		aRegs[1][6] := Val2Str( aRegs[1][6], 16, 2 )
		
		// Realizo a geracao do Registro T078AD
		FConcTxt( aRegs, nHdlTxt )
		
		// Realizo a geracao do Registro T078AE / T078AF
		RegT078AF( nHdlTxt, aRegT078AE, aRegT078AF )
		
	EndDo
	(cSFTTemp)->( DbCloseArea() )
	
Return Nil

/*/{Protheus.doc} RegT078AE
    (Realiza a geracao do registro T078AE do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 23/05/2013

    @param aRegT078AE, array, Array com os registros T078AE
    @param aRegT078AF, array, array com os registros T078AF
    @param cSFTTemp, caracter, Alias ds Query do Registro PAI
    @param aClasFis, array, CST de ICMS do Item

    @return Nil, nulo, não tem retorno.
    /*/
Static Function RegT078AE(aRegT078AE,aRegT078AF,cSFTTemp,aClasFis)
	
	Local cOrIcm := ""
	Local cProdUN := ""
	Local cEspecie := ""
	
	Local aPartDoc := {}
	Local aProdB1 := {}
	
	If !Empty(aClasFis)
		cOrIcm := Left(aClasFis[1],1)
	EndIf
	
	cProdUN := RetUMProd( @aProdB1, (cSFTTemp)->FT_PRODUTO )[1]
	
	Aadd(aRegT078AE,{{}})
	nPosicao := Len(aRegT078AE)
	
	Aadd(aRegT078AE[nPosicao][1],"T078AE")
	Aadd(aRegT078AE[nPosicao][1],(cSFTTemp)->FT_PRODUTO)
	Aadd(aRegT078AE[nPosicao][1],Val2Str((cSFTTemp)->FT_QUANT,16,3))
	Aadd(aRegT078AE[nPosicao][1],Val2Str((cSFTTemp)->LX_QTDCANC,16,3))
	Aadd(aRegT078AE[nPosicao][1],cProdUN)
	Aadd(aRegT078AE[nPosicao][1],Val2Str((cSFTTemp)->FT_VALCONT,16,3))
	Aadd(aRegT078AE[nPosicao][1],(cSFTTemp)->FT_CFOP)
	Aadd(aRegT078AE[nPosicao][1],(cSFTTemp)->FT_CONTA)
	Aadd(aRegT078AE[nPosicao][1],cOrIcm)
	Aadd(aRegT078AE[nPosicao][1],Val2Str((cSFTTemp)->FT_DESCONT,16,2))
	Aadd(aRegT078AE[nPosicao][1],Val2Str((cSFTTemp)->LX_VALOR,16,2))
	Aadd(aRegT078AE[nPosicao][1],Val2Str((cSFTTemp)->FT_DESPESA,16,2))
	
	// Buscando Dados do Cliente
	If SA1->(MsSeek(xFilial("SA1") + (cSFTTemp)->FT_CLIEFOR))
		// Posiciona no registro da SFT para a função FBusTribNf
		SFT->(DbGoTo((cSFTTemp)->RECSFT))

		// Se estiver posicionado.
		If SFT->(!Eof())
		// Retornar as informações do cliente.
		aPartDoc := TafPartic( "SA1", "SA1" )
		
		// Buscando o Modelo da NF
		cEspecie :=	AModNot( (cSFTTemp)->FT_ESPECIE )
		
		/*
			Função para buscar os tributos do item do movimento ECF
				FBusTribNf(c_Especie,a_PartDoc,a_RgT013AP,a_RgT015AE,n_ItT015,a_RgT078AF,n_ItT078AE,a_RgT080AC,n_ItT080,n_ItT080AA,n_ItT080AB,a_ClasFis,n_RecnoCDG)
		*/
			FBusTribNf(cEspecie,aPartDoc,,,,@aRegT078AF,Len(aRegT078AE),,,,,,)
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT078AF
    (Realiza a geracao do registro T078AF do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 05/06/2013

    @param nHdlTxt, numerico, Handle para gravaca do Registro
    @param aRegT078AE, array, Array com as informacoes do Registro T078AE
    @param aRegT078AF, array, Array com as informacoes do Registro T078AF

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT078AF(nHdlTxt,aRegT078AE,aRegT078AF)
	
	Local nlZ  := 1
	Local nPos := 0
	
	For nlZ := 1 To Len( aRegT078AE )
		
		FConcTxt( aRegT078AE[nlZ], nHdlTxt )
		
		If ( nPos := Ascan( aRegT078AF, { |x| x[1] == nlZ } ) ) > 0
			For nlZ := nPos To Len( aRegT078AF )
				If aRegT078AF[nlZ][1] == nlZ
					FConcTxt( aRegT078AF[nlZ][2], nHdlTxt )
				EndIf
			Next
		EndIf
	Next
	
Return Nil

/*/{Protheus.doc} RegT078AG
	(Realiza a geracao do registro T078AG do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 24/05/2013

	@param nHdlTxt, numerico, Handle para gravaca do Registro
	@param aRegT078AG, array, com as informacoes do Registro T078AG

	@return Nil, nulo, não tem retorno
	/*/
Static Function RegT078AG(nHdlTxt,aRegT078AG)
	
	// Realizo a geracao do Registro T078AG
	FConcTxt(aRegT078AG,nHdlTxt)
	
Return Nil

/*/{Protheus.doc} RegT078AJ
    (Realiza a geracao do registro T078AJ do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 24/05/2013

    @param nHdlTxt, numerico, Handle para gravaca do Registro
    @param cAliasQry, caracter, Alias Principal de geracao do registro T078

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT078AJ(nHdlTxt,cAliasQry)
	
	Local cReg := "T078AJ"
	
	Local cDataMov := (cAliasQry)->FI_DTMOVTO
	Local cPdv     := (cAliasQry)->FI_PDV
	
	Local cSitTrib := ""
	
	Local nAliqSft := 0
	Local nBCIcms	 :=	0
	Local nValIcm	 := 0
	
	Local aRegs    := {}
	
	Local cTemp := GetNextAlias()
	
	BeginSql alias cTemp
		SELECT 	SUM(FT_VALICM) FT_VALICM,SUM(FT_VALCONT) FT_VALCONT,SUM(FT_VALPIS) FT_VALPIS,SUM(FT_VALCOF) FT_VALCOF,SUM(FT_QUANT) FT_QUANT,
		SUM(FT_BASEICM) FT_BASEICM,FT_FILIAL,FT_CLASFIS,FT_CFOP,FT_ALIQICM,D2_SITTRIB, FT_CTIPI,FT_CSTPIS,FT_CSTCOF, FT_TIPO
		FROM
		%table:SFT% SFT  , %table:SD2% SD2
		WHERE
		SFT.FT_FILIAL   = %xfilial:SFT%  		AND
		SFT.FT_TIPOMOV  = 'S'   				AND
		SFT.FT_ENTRADA  = %exp:cDataMov%  AND
		SFT.FT_PDV      = %exp:cPdv%			AND
		SFT.FT_ESPECIE	= 'CF'					AND
		SFT.FT_DTCANC	= ' '					AND
		SFT.%notDel%       						AND
		SFT.FT_FILIAL   = SD2.D2_FILIAL   		AND
		SFT.FT_PDV      = SD2.D2_PDV     		AND
		SFT.FT_NFISCAL	= SD2.D2_DOC        	AND
		SFT.FT_SERIE	= SD2.D2_SERIE			AND
		SFT.FT_ITEM 	= SD2.D2_ITEM			AND
		SD2.%notDel%
		GROUP BY
		FT_FILIAL,FT_CLASFIS,FT_CFOP,FT_ALIQICM,D2_SITTRIB,FT_CTIPI,FT_CSTPIS,FT_CSTCOF,FT_TIPO
		ORDER BY
		FT_FILIAL,FT_CFOP,FT_CLASFIS,FT_ALIQICM
	EndSql
	
	While (cTemp)->( !Eof() )
		
		cSitTrib := (cTemp)->D2_SITTRIB
		
		If ( "T" $ cSitTrib)
			
			If Len( cSitTrib ) > 4
				nAliqSft := Val( SubStr( cSitTrib, 2, 2 ) + "." + SubStr( cSitTrib, 4, Len( cSitTrib ) ) )
			Else
				nAliqSft := Val( SubStr( cSitTrib, 2, Len( cSitTrib ) ) )
			EndIf
			
			nBCIcms	 := (cTemp)->FT_VALCONT
			nValIcm	 := (cTemp)->FT_VALICM
			
		ElseIf ("S" $ cSitTrib)
			nAliqSft := 0
			nBCIcms	 :=	0
			nValIcm	 := 0
		Else
			nAliqSft := (cTemp)->FT_ALIQICM
			nBCIcms	 :=	(cTemp)->FT_BASEICM
			nValIcm	 := (cTemp)->FT_VALICM
		EndIf
		
		aClasFis := SPDRetCCST( cTemp, .F.)
		
		nPos := Ascan( aRegs, {|x| x[2] == aClasFis[1] .And.  x[3] == (cTemp)->FT_CFOP .And. x[4] == nAliqSft } )
		If nPos ==  0
			
			(cTemp)->( aAdd( aRegs, { "T078AJ",;
				Right( aClasFis[1], 2 ),;
				FT_CFOP,;
				nAliqSft,;
				FT_VALCONT,;
				nBCIcms,;
				nValIcm,;
				"" } ) )
		Else
			aRegs[nPos][5] += (cTemp)->FT_VALCONT
			aRegs[nPos][6] += nBCIcms
			aRegs[nPos][7] += nValIcm
		EndIf
		
		(cTemp)->( DbSkip() )
		
	EndDo
	(cTemp)->( DbCloseArea() )
	
	FConcTxt( aRegs, nHdlTxt )
	
Return Nil

/*/{Protheus.doc} fLayCPRB
    (Função para executar os layouts T082)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayCPRB()

    Local aGerou := {}
	Local aRegPROTAF := {}
	Local aDePara := {}

	Local nCount := 0
	Local nPosicao := 0

	fMsgPrcss("Gerando Registros T082")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T082",2)
	
    // Monta o layout T082
    FIS8ExtTAF('BlocoP')

	Aadd(aGerou,{"T082",.F.})

	If !Empty(aRegExtTAF)
		
		// Busca o depara de registros
		aRegPROTAF := RegPROTAF()

		Aeval(aRegPROTAF,{|x| Iif(x[2] $ "T082",Aadd(aDePara,x),) })

		If !Empty(aDePara)
			For nCount := 1 To Len(aDePara)
				// Procura o layout dentro dos registros gerados
				nPosicao := Ascan(aRegExtTAF,{|x| x[2] == aDePara[nCount][1] })

				// Se encontrou
				If !Empty(nPosicao)
					// Procura o layout dentro do controle geração
					nPosicao := Ascan(aGerou,{|x| x[1] == aDePara[nCount][2] })

					// Se encontrou
					If !Empty(nPosicao)
						aGerou[nPosicao][2] := .T.
					EndIf
				EndIf
			Next
		EndIf
	EndIf

    ExtSPEDContr()

	For nCount := 1 To Len(aGerou)
		// Se gerou
		If aGerou[nCount][2]
			lGerFilial := .F.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,aGerou[nCount][1],3)
		Else
			lGerFilPar := .T.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,aGerou[nCount][1],1)
		EndIf
	Next

	// Zera a variavel private
	aRegExtTAF := {}

Return Nil

/*/{Protheus.doc} fLayApura
    (Função para executar os layouts T020|T021|T022)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @param a_RgT022AB, array, Informações populadas com os ajustes vinculados ao documento fiscal ( DA )
    @param a_VlrMovST, array, Array com os valores populados através dos documentos fiscais 
    @param a_IcmPago, array, Valores de ICMS pagos retirados dos movimentos fiscais
    @param a_LanCDA2, array, Array com os lançamentos vinculados aos movimentos fiscais
    @param l_TabComp, logico, tabela complementar da geração do Sped Fiscal        

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayApura(a_WizSped,a_RgT022AB,a_VlrMovST,a_IcmPago,a_LanCDA2,l_TabComp, oWizard,cKeyCent)

	Local aGerou := {}

	Local nCount := 0

	Default a_WizSped := {}
    Default a_RgT022AB := {}
    Default a_VlrMovST := {}
    Default a_IcmPago := {}
    Default a_LanCDA2 := {}

    Default l_TabComp := .F.
	Default	cKeyCent  := " "

    fMsgPrcss("Gerando Registros T020|T021|T022")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T020|T021|T022",2)

    // Monta os layouts T020|T021|T022
    aGerou := ExtIcmIpi(a_WizSped,@a_RgT022AB,a_VlrMovST,a_IcmPago,a_LanCDA2,l_TabComp,@aGerou, oWizard, cKeyCent)

	For nCount := 1 To Len(aGerou)
		If aGerou[nCount][2]
			lGerFilial := .F.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,aGerou[nCount][1],3)
		Else
			lGerFilPar := .T.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,aGerou[nCount][1],1)
		EndIf
	Next
	
Return Nil

/*/{Protheus.doc} ExtIcmIpi
    (Realiza a geração dos registros referentes a apuração de ICMS e IPI)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

	@param a_WizSped, array, InFormaçoes da Wizard do extrator fiscal 
    @param a_RgT022AB, array, Informações populadas com os ajustes vinculados ao documento fiscal ( DA )
    @param a_VlrMovST, array, Array com os valores populados através dos documentos fiscais 
    @param a_IcmPago, array, Valores de ICMS pagos retirados dos movimentos fiscais
    @param a_LanCDA2, array, Array com os lançamentos vinculados aos movimentos fiscais
    @param l_TabComp, logico, tabela complementar da geração do Sped Fiscal

    @return aGerou, array, registros que geram ou não.
    /*/
Static Function ExtIcmIpi(a_WizSped,a_RgT022AB,a_VlrMovST,a_IcmPago,a_LanCDA2,l_TabComp,aGerou, oWizard, cKeyCent)

    Local cMVEstado	:= ""
    Local cMVSubTrib := ""
    Local cMVStnIeUf := ""
    Local cFilDe := "" //variável não é utilizado na função BlocoE, declarado apenas para melhor entEndimento do código
    Local cFilAte := "" //variável não é utilizado na função BlocoE, declarado apenas para melhor entEndimento do código 
    Local cAlias := "" //variável não é utilizado na função BlocoE, declarado apenas para melhor entEndimento do código
    Local cTxtSys := cDirSystem + cBarraUnix

    Local nI, nY, nK, nAux, nX := 0 
    Local nZ, nW := 0
    Local nIniReg := 0
    Local nHdlTxt := 0
	Local nTotT022 := 0

    Local lOldLan  	:= CC6->(FieldPos('CC6_TIPOAJ')) > 0
    Local lTop		 	:= .T. //Para utilizar o TAF deve possuir ambiente TOP
    Local lDIfal		:= .F.

    Local aLanCDA    := {} //variável não é utilizado na função BlocoE, declarado apenas para melhor entEndimento do código
    Local aReg0200   := {} //variável não é utilizado na função BlocoE, declarado apenas para melhor entEndimento do código
    Local aReg0190   := {} //variável não é utilizado na função BlocoE, declarado apenas para melhor entEndimento do código
    Local aReg0220   := {} //variável não é utilizado na função BlocoE, declarado apenas para melhor entEndimento do código

    Local aRegT020   := {}
    Local aRegT020AA := {}
    Local aRegT020AB := {}
    Local aRegT020AC := {}
    Local aRegT020AD := {}
    Local aRegT020AE := {}

    Local aRegT021Est := {}
    Local aRegT021Val := {}
    Local aRegT021AA  := {}
    Local aRegT021AB  := {}
    Local aRegT021AC  := {}
    Local aRegT021AD  := {}
    Local aRegT021AE  := {}

    Local aRegT022    := {}
    Local aRegT022AA  := {} 
    Local aMvRLCSPD	  	:= {} 
    Local aLiv1900    	:= {}
    Local aT020Fmt    	:= {}
    Local aRegsT020   	:= {}
 
	Local aInfRgE313 := {}

    Local aArq := {}
	Local aGerou := {}

	Local oProcess := Nil

	Default a_WizSped := {}
    Default a_RgT022AB := {}
    Default a_VlrMovST := {}
    Default a_IcmPago := {}
    Default a_LanCDA2 := {}
	Default l_TabComp := .F.
	Default	cKeyCent  := " "

	Aadd(aGerou,{"T020",.F.})
	Aadd(aGerou,{"T021",.F.})
	Aadd(aGerou,{"T022",.F.})
	
    // Atribuição de valores iniciais para as variáveis criadas
    cMVEstado := oFisaExtSx:_MV_ESTADO
    cMVStnIeUf := oFisaExtSx:_MV_STNIEUF
    cMVSubTrib := SpedPrSeq('MV_SUBTRI')
    cFilDe := ''
    cFilAte := ''
    cAlias := ''

    nI := 0
    nY := 0
    nK := 0
    nZ := 0
    nW := 0
	nAux:= 0
    nIniReg := 0
	nPosAC := 0

    lDIfal := oFisaExtSx:_F0I .And. oFisaExtSx:_FT_DIfAL

    lTop := .T.

    aLanCDA    := {}
    aReg0200   := {}
    aReg0190   := {}
    aReg0220   := {}

    aRegT020   := {}
    aRegT020AA := {}
    aRegT020AB := {}
    aRegT020AC := {}
    aRegT020AD := {}
    aRegT020AE := {}
    aRegT020AG := {}
	aT020ACaux := {}

    aRegT021Est := {}
    aRegT021Val := {}  
    aRegT021AA  := {}
    aRegT021AB  := {}
    aRegT021AC  := {}
    aRegT021AD  := {}
    aRegT021AE  := {}
    aRegsT020   := {}

    aRegT022   := {}
    aRegT022AA := {}     
    aMvRLCSPD  := {}
    aLiv1900   := {}
	
    aT020Fmt   := Array(17)

    aArq       := {}

    // Criacao do TRB para ser alimentado durante o processamento da rotina
    SPDGerTrb( 1, @aArq, @cAlias,.T., @oTempTab )

	// Realiza a execução do bloco E do sped fiscal para levar as informações ao TAF
	BlocoE( l_TabComp, a_WizSped, cFilDe, cFilAte, cAlias, cMVEstado, lTop, cMVSUBTRIB, @a_RgT022AB,;
			@oProcess, a_VlrMovST, a_IcmPago, aLanCDA, a_LanCDA2, cMVStnIeUf, lOldLan, aReg0200, ;
			aReg0190 , aReg0220 , aInfRgE313, lDIfal , {}, .T., @aRegT020, @aRegT020AA, @aRegT020AB, @aRegT020AC,;
			@aRegT020AD, @aRegT020AE, @aRegT020AG, @aRegT021Val, @aRegT021Est, @aRegT021AA, @aRegT021AB,;
			@aRegT021AC, @aRegT021AD, @aRegT022, @aRegT022AA)

    // Adiciona os registros de apuração da nota
    fGetApurNf(@aRegT020AA,oWizard:GetDataDe())

    /*
        INICO DA GERAÇÃO DAS INFORMAÇÕES REFERENTES A APURAÇÃO DE ICMS PRÓPRIO

        Realizar a emissão dos registros T020 ( Apuração de ICMS ) e seus respectivos filhos 
        de acordo com o retorno de geração do registro E100 do Sped Fiscal do Protheus
    */
    If oWizard:LayoutSel("T020")
        fMsgPrcss("Gerando Registro T020 - Apuração de ICMS...")
        
        If Len(aRegT020) > 0
			aGerou[1][2] := .T.
            
            nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys+"T020.TXT"),0)  
            Aadd(aArqGer,(cTxtSys+"T020.TXT"))
            
            // Geração da Apuração
            RegT020(nHdlTxt,aRegT020,"0")
            
            For nI := 1 To Len( aRegT020AA )
                // Geração do registro T020AA
                RegT020AA(nHdlTxt,aRegT020AA[nI],cMVEstado)
                
				For nAux := 1 To Len ( aRegT020AG )
					if (Alltrim(aRegT020AG[nAux,3]) ==  aRegT020AA[nI,3]  + AllTrim(aRegT020AA[nI,6]))  .and. (AllTrim(aRegT020AG[nAux,1]) ==  AllTrim(aRegT020AA[nI,4]))    
						// Geração do registro T020AG
						RegT020AG(nHdlTxt,aRegT020AG,nAux)                
					Endif
				Next 
        
                // Laço para Geração do registro T020AB
                nIniReg := Ascan( aRegT020AB, {|x| x[1] == nI })
                        
                If nIniReg > 0
                    For nY := nIniReg to len( aRegT020AB )
                        If aRegT020AB[ny][1] == nI
                            RegT020AB(nHdlTxt,aRegT020AB[nY])						
                        Else
                            Exit
                        EndIf
                    Next
                EndIf
                
                // Laço para Geração do registro T020AC
                nIniReg := Ascan( aRegT020AC, {|x| x[1] == nI })
                
                If nIniReg > 0
					For nX:=1 to len( aRegT020AC )
						If aRegT020AC[nX][1]==nI	
							nPosAC := aScan(aT020ACaux, {|x| x[9]==aRegT020AC[nX][9] .And. x[3]==aRegT020AC[nX][3] .And. x[5]==aRegT020AC[nX][5] .And. x[7]==aRegT020AC[nX][7]})
							If nPosAC == 0
								aAdd(aT020ACaux, Array(11))
								aT020ACaux[Len(aT020ACaux)][1] := aRegT020AC[nX][1] 
								aT020ACaux[Len(aT020ACaux)][2] := aRegT020AC[nX][2] 
								aT020ACaux[Len(aT020ACaux)][3] := aRegT020AC[nX][3] 
								aT020ACaux[Len(aT020ACaux)][4] := aRegT020AC[nX][4] 
								aT020ACaux[Len(aT020ACaux)][5] := aRegT020AC[nX][5] 
								aT020ACaux[Len(aT020ACaux)][6] := aRegT020AC[nX][6] 
								aT020ACaux[Len(aT020ACaux)][7] := aRegT020AC[nX][7] 
								aT020ACaux[Len(aT020ACaux)][8] := aRegT020AC[nX][8] 
								aT020ACaux[Len(aT020ACaux)][9] := aRegT020AC[nX][9] 
								aT020ACaux[Len(aT020ACaux)][10] := aRegT020AC[nX][10] 
								aT020ACaux[Len(aT020ACaux)][11] := aRegT020AC[nX][11] 
							Else
								aT020ACaux[nPosAC][10] += aRegT020AC[nX][10]
							Endif
						Endif
					Next
					For nY := 1 to len( aT020ACaux )
						If aT020ACaux[nY][1] == nI
                            RegT020AC(nHdlTxt,aT020ACaux[nY])
                        Else
                            Exit						
                        EndIf
                    Next
                EndIf
				aT020ACaux:={}
            Next
            
            // Geração do registro T020AD
            RegT020AD(nHdlTxt,aRegT020AD)
            
            // Geração do registro T020AE
            RegT020AE(nHdlTxt,aRegT020AE)
            
            // Geração do registro T020AF
            RegT020AF(nHdlTxt, oWizard, cKeyCent)
            
            // Grava o registro na TABELA TAFST1 
            If cTpSaida == "2"
                FConcST1()
            EndIf
            
            //Processamento das subApurações do ICMS pelo registro 1900 e filhos
            If !cMVEstado$"RS"
                aMvRLCSPD := &(oFisaExtSx:_MV_RLCSPD)
                For nI := 1 to Len(aMVRLCSPD)
                    Aadd(aLiv1900,{aMvRLCSPD[nI,1],aMvRLCSPD[nI,2] , aMvRLCSPD[nI,3]})    
                Next nI
                If !Empty(aLiv1900)
					Grupo1900(l_TabComp,a_WizSped,cFilDe,cFilAte,cAlias,cMVEstado,lTop,@oProcess,aLanCDA,@a_LanCDA2,aLiv1900,lOldLan,.T.,@aRegsT020)
                EndIf
                
                /*
                    aRegsT020[nx][1] -> T020   - 1900/1910/1920 
                    aRegsT020[nx][2] -> T020AA - 1921
                    aRegsT020[nx][3] -> T020AB - 1922
                    aRegsT020[nx][4] -> T020AC - 1923
                    aRegsT020[nx][5] -> T020AD - 1925
                    aRegsT020[nx][6] -> T020AE - 1926
                */
                
                // Geração da Sub-Apuração
                For nZ := 1 to len(aRegsT020)
                    //Formata a estrutura dos Regs
                    aT020Fmt[01] := 'T020'
                    aT020Fmt[02] := aRegsT020[nZ][1][1][3]
                    aT020Fmt[03] := 0
                    aT020Fmt[04] := aRegsT020[nZ][1][1][4]
                    aT020Fmt[05] := aRegsT020[nZ][1][1][5]
                    aT020Fmt[06] := aRegsT020[nZ][1][1][6]
                    aT020Fmt[07] := 0
                    aT020Fmt[08] := aRegsT020[nZ][1][1][7]
                    aT020Fmt[09] := aRegsT020[nZ][1][1][8]
                    aT020Fmt[10] := aRegsT020[nZ][1][1][9]
                    aT020Fmt[11] := aRegsT020[nZ][1][1][10]
                    aT020Fmt[12] := aRegsT020[nZ][1][1][11]
                    aT020Fmt[13] := aRegsT020[nZ][1][1][12]
                    aT020Fmt[14] := aRegsT020[nZ][1][1][13]
                    aT020Fmt[15] := aRegsT020[nZ][1][1][14]
                    aT020Fmt[16] := aRegsT020[nZ][1][1][15]
                    aT020Fmt[17] := aRegsT020[nZ][1][1][16]
                    
                    RegT020(nHdlTxt,aT020Fmt,"1")
                    
                    //Limpa array usado nas formatação
                    aT020Fmt := Array(17)
                    
                    For nI := 1 to Len(aRegsT020[nZ][2])
                        // Geração do registro T020AA
                        RegT020AA(nHdlTxt,aRegsT020[nZ][2][nI],cMVEstado)
                        
                        // Laço para Geração do registro T020AB
                        If len( aRegsT020[nZ][3]) > 0
                            nIniReg := Ascan( aRegsT020[nZ][3], {|x| x[1] == nI })		
                            If nIniReg > 0
                                for nY := nIniReg to len( aRegsT020[nZ][3][nY] )
                                    If aRegsT020[nZ][3][nY][1] == nI
                                        RegT020AB( nHdlTxt, aRegsT020[nZ][3][nY] )						
                                    Else
                                        exit
                                    EndIf					
                                next
                            EndIf
                        EndIf

                        // Laço para Geração do registro T020AC
                        If len( aRegsT020[nZ][4]) > 0
                            nIniReg := Ascan( aRegsT020[nZ][4], {|x| x[1] == nI })
                            If nIniReg > 0
                                for nY := nIniReg to len( aRegsT020[nZ][4][nY] )
                                    If aRegsT020[nZ][4][nY][1] == nI
                                        RegT020AC( nHdlTxt, aRegsT020[nZ][4][nY] )
                                    Else
                                        exit						
                                    EndIf
                                next	
                            EndIf
                        EndIf		
                    next
                    
                    // Geração do registro T020AD
                    If len( aRegsT020[nZ][5]) > 0
                        //Altera a ordem das informações
                        aRegsT020[nZ][5][1][2] := aRegsT020[nZ][5][1][3]
                        aRegsT020[nZ][5][1][3] := aRegsT020[nZ][5][1][4]	
                        aRegsT020[nZ][5][1][4] := aRegsT020[nZ][5][1][5]					
                        RegT020AD( nHdlTxt, aRegsT020[nZ][5])
                    EndIf

                    // Geração do registro T020AE
                    If Len(aRegsT020[nZ][6]) > 0
                        //Formata o T20AE para o reg 1926
                        For nW := 1 to Len(aRegsT020[nZ][6])
                            aRegsT020[nZ][6][nW][11] := aRegsT020[nZ][6][nW][12]
                            aRegsT020[nZ][6][nW][12] := aRegsT020[nZ][6][nW][13]		
                        Next

                        // Grava o T020AE
                        RegT020AE(nHdlTxt,aRegsT020[nZ][6])
                    EndIf
                    
                    // Grava o registro na TABELA TAFST1 
                    If cTpSaida == "2"
                        FConcST1()
                    EndIf	
                Next 
            EndIf			 
            
            If cTpSaida == "1" 
                FClose(nHdlTxt)
            EndIf
        EndIf
    EndIf

    /*
        INICO DA GERAÇÃO DAS INFORMAÇÕES REFERENTES A APURAÇÃO DE ICMS ST

        Realizar a emissão dos registros T021 ( Apuração de ICMS/ST ) e seus respectivos filhos 
        de acordo com o retorno de geração do registro E200 do Sped Fiscal do Protheus

        Laço para geração de cada Estado que possue valores de ICMS/ST
    */
    If oWizard:LayoutSel("T021")
        fMsgPrcss("Gerando Registro T021 - Apuração de ICMS-ST...")

        If Len(aRegT021Est) > 0
            nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys+"T021.TXT"),0)     
            Aadd(aArqGer,cTxtSys+"T021.TXT")
        EndIf
        
        For nI := 1 to Len(aRegT021Est)
            
            //------------------------------------------------------------
            //Geração do Registro T021( Apuração de ICMS/ST
            //Somente pode existir uma linha no array aRegT021Val com as 
            //informações do período, faço o Ascan abaixo para garantir 
            //que será passada para a função os valores corretos de acordo
            //com o Estado e Período
            //------------------------------------------------------------
            nIniReg := Ascan( aRegT021Val, {|x| x[1] == nI })
            
            If nIniReg > 0
				aGerou[2][2] := .T.

                RegT021(nHdlTxt,aRegT021Est[nI],aRegT021Val[nIniReg])
            
                //------------------------------------
                //Laço para Geração do registro T021AA
                //------------------------------------
                nIniReg := Ascan( aRegT021AA, {|x| x[1] == nI })
                
                If nIniReg > 0
                    for nY := nIniReg to len( aRegT021AA )
                        If aRegT021AA[ny][1] == nI
                            RegT021AA( nHdlTxt, aRegT021AA[nY] )
                            
                            //------------------------------------
                            //Laço para Geração do registro T021AB
                            //------------------------------------
                            nIniReg := Ascan( aRegT021AB, {|x| x[1] == nY })
                            
                            If nIniReg > 0
                                for nK := nIniReg to len( aRegT021AB )
                                    If aRegT021AB[nK][1] == nY
                                        RegT021AB( nHdlTxt, aRegT021AB[nK] )
                                    Else
                                        exit						
                                    EndIf
                                next		
                            
                                //------------------------------------
                                //Laço para Geração do registro T021AC
                                //------------------------------------
                                nIniReg := Ascan( aRegT021AC, {|x| x[1] == nY })
                                
                                If nIniReg > 0
                                    for nK := nIniReg to len( aRegT021AC )
                                        If aRegT021AC[nK][1] == nY
                                            RegT021AC( nHdlTxt, aRegT021AC[nK] )
                                        Else
                                            exit						
                                        EndIf
                                    next
                                EndIf
                            EndIf	
                                
                        Else
                            exit						
                        EndIf
                    next		
                
                EndIf
                
                //------------------------------------
                //Laço para Geração do registro T021AD
                //------------------------------------
                nIniReg := Ascan( aRegT021AD, {|x| x[1] == nI })
                
                If nIniReg > 0
                    for nY := nIniReg to len( aRegT021AD )
                        If aRegT021AD[ny][1] == nI
                            RegT021AD( nHdlTxt, aRegT021AD[nY] )	
                        Else
                            exit						
                        EndIf
                    next
                EndIf
                
                RegT021AE(nHdlTxt,aRegT021Est[nI][2])
            
                //-----------------------------------
                //Grava o registro na TABELA TAFST1 
                //----------------------------------- 
                If cTpSaida == "2"
                    FConcST1()
                EndIf
            EndIf			
        next
        
        If cTpSaida == "1" .And. len( aRegT021Est ) > 0
            FClose(nHdlTxt)
        EndIf
    EndIf
   
    //-------------------------------------------------------------------------------------
    //INICO DA GERAÇÃO DAS INFORMAÇÕES REFERENTES A APURAÇÃO DE IPI

    //Realizar a emissão dos registros T022 ( Apuração de IPI ) e seus respectivos filhos 
    //de acordo com o retorno de geração do registro E500 do Sped Fiscal do Protheus
    //-------------------------------------------------------------------------------------
    If oWizard:LayoutSel("T022")

		aEval( aRegT022[1], { |n| IIf(ValType( n ) == "N", nTotT022+= n,) } )
			
		If nTotT022 > 0
		
			fMsgPrcss("Gerando Registro T022 - Apuração de IPI...")

    	    nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys+"T022.TXT"),0)
        	Aadd(aArqGer,(cTxtSys+"T022.TXT"))
        
			aGerou[3][2] := .T.

            RegT022(nHdlTxt,aRegT022)
            RegT022AA(nHdlTxt,aRegT022AA)
            RegT022AB(nHdlTxt,a_RgT022AB)
        
            // Grava o registro na TABELA TAFST1 
            If cTpSaida == "2"
                FConcST1()
            EndIf	
        
            If cTpSaida == "1" 
                FClose(nHdlTxt)
            EndIf
        EndIf
            
    EndIf

	// Fecho Arquivo de Trabalho criado
	SPDGerTrb(2,@aArq,@cAlias,.T., @oTempTab)

Return aGerou

/*/{Protheus.doc} RegT020
    (Realiza a geracao do registro T020 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT020, array, Array com informacoes do registro T020
    @param cTipoApur, caracter, Contém o tipo de apuração (0-Apuração/1-SubApuração)		

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT020(nHdlTxt,aRegT020,cTipoApur)
	
    Local aRegs := {}

    Aadd( aRegs, {  'T020',;
                    cTipoApur,;
                    DToS(oWizard:GetDataDe()),;
                    DToS(oWizard:GetDataAte()),;
                    '',;
                    '',;
                    Val2Str( aRegT020[2], 16, 2  ),;
                    Val2Str( aRegT020[3], 16, 2  ),;
                    Val2Str( aRegT020[4], 16, 2  ),;
                    Val2Str( aRegT020[5], 16, 2  ),;
                    Val2Str( aRegT020[6], 16, 2  ),;
                    Val2Str( aRegT020[7], 16, 2  ),;
                    Val2Str( aRegT020[8], 16, 2  ),;
                    Val2Str( aRegT020[9], 16, 2  ),;
                    Val2Str( aRegT020[10], 16, 2 ),;
                    Val2Str( aRegT020[11], 16, 2 ),;
                    Val2Str( aRegT020[12], 16, 2 ),;
                    Val2Str( aRegT020[13], 16, 2 ),;
                    Val2Str( aRegT020[14], 16, 2 ),;
                    Val2Str( aRegT020[15], 16, 2 ) } )
        
    //Tratamento para SubApuração
    If cTipoApur == '1'
        aRegs[1][5] := aRegT020[16]
        aRegs[1][6] := aRegT020[17]
    EndIf

    FConcTxt( aRegs, nHdlTxt )
	
Return Nil

/*/{Protheus.doc} RegT020AA
    (Realiza a geracao do registro T020AA do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT020AA, array, Array com informacoes do registro T020AA
    @param cMVEstado, caracter, Conteúdo do parâmetro MV_ESTADO

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT020AA(nHdlTxt,aRegT020AA,cMVEstado)
	
	Local cSubItem := ""
	Local cCodLanNf := ""
	
	Local aRegs := {}
	Local aSubItem := {}
	
	Local nPosicao := 0

	cSubItem := aRegT020AA[06]
	
	// Se existir a posição 7
	If Len(aRegT020AA) >= 7 
		cCodLanNf := aRegT020AA[07]
	EndIf
	
	// Busco o código do motivo e subitem que devo enviar no registro da apuração
	aSubItem := FSubItRegras(cMVEstado,,,cSubItem)
	
	Aadd(aRegs,{})
	nPosicao := Len(aRegs)
	
	Aadd(aRegs[nPosicao],"T020AA")											// 01 - REGISTRO
	Aadd(aRegs[nPosicao],aRegT020AA[03])									// 02 - COD_AJ_APUR
	Aadd(aRegs[nPosicao],aRegT020AA[04])									// 03 - DESCR_COMPL_AJ
	Aadd(aRegs[nPosicao],Val2Str(aRegT020AA[05],16,2))						// 04 - VL_AJ_APUR
	Aadd(aRegs[nPosicao],SubStr(StrTran(AllTrim(aSubItem[1]),".",""),1,5))	// 05 - COD_SUBITEM
	Aadd(aRegs[nPosicao],aSubItem[2])										// 06 - COD_MOT
	Aadd(aRegs[nPosicao],cCodLanNf)											// 07 - COD_AJ_APUR

	FConcTxt(aRegs,nHdlTxt)
	
Return Nil

/*/{Protheus.doc} RegT020AB
    (Realiza a geracao do registro T020AB do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT020AB, array, Array com informacoes do registro T020AG

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT020AB(nHdlTxt,aRegT020AB)
	
    Local cReg := "T020AB"

    aRegs := {}
    Aadd( aRegs, {  cReg,;
                    aRegT020AB[8],; //COD_DA
                    aRegT020AB[3],; //NUM_DA
                    aRegT020AB[4],; //NUM_PROC
                    aRegT020AB[5]} ) //IND_PROC
                    
    FConcTxt(aRegs,nHdlTxt)
		
Return Nil

/*/{Protheus.doc} RegT020AC
    (Realiza a geracao do registro T020AC do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT020AC, array, com informacoes do registro T020AC

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT020AC(nHdlTxt,aRegT020AC)
	
    Local cReg := "T020AC"
            
    aRegs := {}
    Aadd( aRegs, {  cReg,;
                    aRegT020AC[03],;
                    aRegT020AC[04],;
                    aRegT020AC[05],;
                    aRegT020AC[06],;
                    aRegT020AC[07],;  
                    Right( aRegT020AC[08], 4 ) + Substr( aRegT020AC[08], 3, 2 ) + Left( aRegT020AC[08], 2 ),;
                    aRegT020AC[09],;
                    Val2Str( aRegT020AC[10], 16, 2 ),;
                    Right( aRegT020AC[08], 4 ) + Substr( aRegT020AC[08], 3, 2 ) + Left( aRegT020AC[08], 2 ) } )

    FConcTxt(aRegs,nHdlTxt)
			
Return Nil

/*/{Protheus.doc} RegT020AD
    (Realiza a geracao do registro T020AD do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT020AD, array, com informacoes do registro T020AD

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT020AD(nHdlTxt,aRegT020AD)
	
    Local cReg := "T020AD"
    Local nlX  := 0
        
    For nlX := 1 To Len( aRegT020AD )
        aRegs := {}
        Aadd( aRegs, {  cReg,;
                        aRegT020AD[nlX][02],;
                        Val2Str( aRegT020AD[nlX][3], 16, 2 ),;
                        aRegT020AD[nlX][04] } )
        
        FConcTxt(aRegs,nHdlTxt)
    Next
	
Return Nil

/*/{Protheus.doc} RegT020AE
    (Realiza a geracao do registro T020AE do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT020AE, array, com informacoes do registro T020AE

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT020AE(nHdlTxt,aRegT020AE)
	
    Local cReg := "T020AE"
    Local nlX  := 0
        
    For nlX := 1 To Len( aRegT020AE )
        
        aRegs := {}
        Aadd( aRegs, {  cReg,;
                        aRegT020AE[nlX][13],;//COD_DA
                        aRegT020AE[nlX][12] } )//NUM_DA

        FConcTxt(aRegs,nHdlTxt)
    Next
	
Return Nil

/*/{Protheus.doc} RegT020AF
    (Realiza a geracao do registro RegT020AF do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 17/04/2013

    @Param nHdlTxt, numerico, Handle de geracao do Arquivo

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT020AF(nHdlTxt, oWizard, cKeyCent)
	
    Local cSelect 	:= ""
    Local cFrom   	:= ""
    Local cWhere  	:= ""
    Local cGrpBy  	:= ""
    Local cAliasSFT	:= GetNextAlias()
    Local cDataDe   	:= DToS(oWizard:GetDataDe())
    Local cDataAte  	:= DToS(oWizard:GetDataAte())
    Local cReg     	:= "T020AF"
    Local aRegs    	:= {}

	Default	cKeyCent  := " "
        
    //³Montando a Estrutura da Query³
    cSelect += " MAX( SFT.FT_CONTA ) FT_CONTA, MAX( SFT.FT_CFOP ) FT_CFOP, SUM( SFT.FT_VALCONT ) FT_VALCONT, SUM( SFT.FT_BASEICM ) FT_BASEICM, "
    cSelect += " SUM( SFT.FT_VALICM ) FT_VALICM, SUM( SFT.FT_ISENICM ) FT_ISENICM, SUM( SFT.FT_OUTRICM ) FT_OUTRICM	 "
        
    cFrom   += 	RetSqlName( "SFT" ) + " SFT "
    if oWizard:GetCentralizarUnicaFilial() == '1'   
    	cWhere  += " SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "'  AND ( SFT.FT_ENTRADA >= '" + cDataDe + "' AND SFT.FT_ENTRADA <= '" + cDataAte + "' ) "
	else
		cWhere  += " SFT.FT_FILIAL IN (" + RetFil(oWizard:aFiliais, cKeyCent) + ")  AND ( SFT.FT_ENTRADA >= '" + cDataDe + "' AND SFT.FT_ENTRADA <= '" + cDataAte + "' ) "
	endif 
    cWhere  += " AND SFT.FT_DTCANC = '' "
    cWhere  += " AND SFT.FT_CODISS = '" + Space( TamSx3( 'FT_CODISS' )[ 1 ] ) + "' "
    cWhere  += " AND SFT.D_E_L_E_T_ = ' '  "
        
    cGrpBy  += " SFT.FT_CONTA, SFT.FT_CFOP "
        
    //³Definindo Estrutura para Execucao do BeginSql ³
    cSelect  := "%" + cSelect  + "%"
    cFrom    := "%" + cFrom    + "%"
    cWhere   := "%" + cWhere   + "%"
    cGrpBy   := "%" + cGrpBy   + "%"
        
    BeginSql Alias cAliasSFT
        SELECT
            %Exp:cSelect%
        FROM
            %Exp:cFrom%
        WHERE
            %Exp:cWhere%
        GROUP BY
            %Exp:cGrpBy%
    EndSql
        
    DbSelectArea( cAliasSFT )
    While (cAliasSFT)->( !Eof() )
            
        aRegs := {}
        (cAliasSFT)->( Aadd( aRegs, {  cReg,;
            FT_CONTA,;
            FT_CFOP,;
            Val2Str( FT_VALCONT, 16, 2 ),;
            Val2Str( FT_BASEICM, 16, 2 ),;
            Val2Str( FT_VALICM, 16, 2 ),;
            Val2Str( FT_ISENICM, 16, 2 ),;
            Val2Str( FT_OUTRICM, 16, 2 ) } ) )   
         
        FConcTxt( aRegs, nHdlTxt )
        
        (cAliasSFT)->( DbSkip() )
    EndDo
        
    (cAliasSFT)->( DbCloseArea() )
	
Return Nil

/*/{Protheus.doc} RegT020AG
    (Realiza a geracao do registro RegT020AG do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT020AG, array, Array com informacoes do registro T020AG

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT020AG(nHdlTxt,aRegT020AG,nAux)

    Local cReg := "T020AG"
    Local nlX  := 0
	Local aReg := {aRegT020AG[nAux]}
        
    For nlX := 1 To Len( aReg )
        aRegs := {}
        Aadd( aRegs, {  cReg,;
                        aReg[nlX][01],;
                        aReg[nlX][02] })   
        
        FConcTxt(aRegs,nHdlTxt) 
    Next
	
Return Nil

/*/{Protheus.doc} RegT021
    (Realiza a geracao do registro T021 do TAF)

    @type Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle para geração do arquivo texto
    @param aRegT021Est, array, Estado que possue valores de ICMS/ST calculados na apuração
    @param aRegT021Val, array, Valores calculados para o Estado do array aRegT021Est

    @return Nil, nulo, não tem retorno
    /*/
Function RegT021(nHdlTxt,aRegT021Est,aRegT021Val)

    Local aRegs := {}

    Aadd( aRegs, {  'T021',;
                    aRegT021Est[2],;
                    DToS(oWizard:GetDataDe()),;
                    DToS(oWizard:GetDataAte()),;
                    aRegT021Val[3],;
                    Val2Str( aRegT021Val[4], 16, 2 ),;
                    Val2Str( aRegT021Val[5], 16, 2 ),;
                    Val2Str( aRegT021Val[6], 16, 2 ),;
                    Val2Str( aRegT021Val[7], 16, 2 ),;
                    Val2Str( aRegT021Val[8], 16, 2 ),;
                    Val2Str( aRegT021Val[9], 16, 2 ),;
                    Val2Str( aRegT021Val[10], 16, 2 ),;
                    Val2Str( aRegT021Val[11], 16, 2 ),;
                    Val2Str( aRegT021Val[12], 16, 2 ),;
                    Val2Str( aRegT021Val[13], 16, 2 ),;
                    Val2Str( aRegT021Val[14], 16, 2 ),;
                    Val2Str( aRegT021Val[15], 16, 2 ),;
                    Val2Str( aRegT021Val[16], 16, 2 ) } )

    FConcTxt(aRegs,nHdlTxt)

Return Nil

/*/{Protheus.doc} RegT021AA
    (Realiza a geracao do registro RegT021AA do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT021AA, array, com as informações do registro T021AA

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT021AA(nHdlTxt,aRegT021AA)

    Local cReg := "T021AA"
                
    aRegs := {}
    Aadd( aRegs, {  cReg,;
                    aRegT021AA[03],;
                    aRegT021AA[04],;
                    aRegT021AA[05],;
                    aRegT021AA[06],;
                    "" })

    FConcTxt(aRegs,nHdlTxt)

Return Nil

/*/{Protheus.doc} RegT021AB
    (Realiza a geracao do registro RegT021AB do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT021AB, array, com as informações do registro T021AB

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT021AB(nHdlTxt,aRegT021AB)

    Local cReg := "T021AB"
                
    aRegs := {}
    Aadd( aRegs, {  cReg,;
                    aRegT021AB[08],; //COD_DA
                    aRegT021AB[03],; //NUM_DA
                    aRegT021AB[04],; //NUM_PROC
                    aRegT021AB[05] })//IND_PROC

    FConcTxt(aRegs,nHdlTxt)

Return Nil

/*/{Protheus.doc} RegT021AC
    (Realiza a geracao do registro RegT021AC do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT021AC, array, com as informações do registro T021AC

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT021AC(nHdlTxt,aRegT021AC)

    Local cReg := "T021AC"
                
    aRegs := {}

    Aadd( aRegs, {  cReg,;
                    aRegT021AC[03],;
                    aRegT021AC[04],;
                    aRegT021AC[05],;
                    aRegT021AC[06],;
                    aRegT021AC[07],;
                    Right( aRegT021AC[08], 4 ) + Substr( aRegT021AC[08], 3, 2 ) + Left( aRegT021AC[08], 2 ),;
                    aRegT021AC[09],;
                    Val2Str( aRegT021AC[10], 16, 2 ),;
                    '',;
                    Right( aRegT021AC[08], 4 ) + Substr( aRegT021AC[08], 3, 2 ) + Left( aRegT021AC[08], 2 ) } )

    FConcTxt(aRegs,nHdlTxt)

Return Nil

/*/{Protheus.doc} RegT021AD
    (Realiza a geracao do registro RegT021AD do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT021AD, array, com as informações do registro T021AD

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT021AD(nHdlTxt,aRegT021AD)

    Local cReg := "T021AD"

    //Tratamento para que não seja gerado o registro quando não existir informação
    If !Empty(aRegT021AD[13]) .Or. !Empty(aRegT021AD[12]) .Or. !Empty(aRegT021AD[07]) .Or. !Empty(aRegT021AD[08])

        aRegs := {}
        Aadd( aRegs, {  cReg,;
                        aRegT021AD[13],;  //COD_DA
                        aRegT021AD[12],;  //NUM_DA
                        aRegT021AD[07],;  //NUM_PROC
                        aRegT021AD[08] } )//IND_PROC
        
        FConcTxt(aRegs,nHdlTxt)
    EndIf
			
Return Nil  

/*/{Protheus.doc} RegT021AE
    (Realiza a geracao do registro RegT021AE do TAF)

    @type Static Function
    @author Paulo Sérgio V.B. Santana
    @since 25/11/2016

    @param nHdlTxt, caracter, Handle de geracao do Arquivo
        
    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT021AE(nHdlTxt, cUf)

    Local dDtIni := oWizard:GetDataDe()
    Local dDtFim := oWizard:GetDataAte()
    Local nCount := 0 
    Local aEntrada := {}
    Local aSaida := {}
    Local aApurICST	:= {}
    Local aRegs := {}	
    Local lImpCrdST	:= .T. 
    Local lQbUfCfop	:= .T.
    Local lConsUf := .F. 
	Default cUf 	:= ''

    aApurICST := ResumeF3("IC",	dDtIni,dDtFim,'*',.F.,.F.,0,.F.,1,cFilAnt,cFilAnt,@aEntrada,@aSaida,,,,.T.,,,lImpCrdST,,/*lCrdEst*/,;
                    /*aEstimulo*/,lQbUfCfop,lConsUf,/*@aApurCDA*/,/*@aApurF3*/,/*@aCDAIC*/,/*@aCDAST*/,/*"F3_MATRAPR"*/,/*nParPerg*/,/*aLisFil*/,,/*lICMDes*/,/*@a_IcmPago*/,,/*@aCDADE*/,;
                    /*@aRetEsp*/,,/*Mv_Par20*/,3,,/*@aConv139*/,/*@aRecStDIf*/,/*@aDIfal*/,/*@aCDADIfal*/)		
 
    For nCount:= 1 To len(aApurICST)  
        //verIfico se existe valor a ser gerado
        If cUf ==  aApurICST[nCount][19] .and. ( aApurICST[nCount][07] + aApurICST[nCount][08] + aApurICST[nCount][05] + aApurICST[nCount][06] ) > 0	
            
            aRegs := {}
            Aadd( aRegs, {  "T021AE",;
                aApurICST[nCount][19],;		//UF
                aApurICST[nCount][01],;		//CFOP
                aApurICST[nCount][07],;		//BASE
                aApurICST[nCount][08],;		//IMPOSTO
                aApurICST[nCount][05],;		//ISENTO_NTRIB	
                aApurICST[nCount][06] } )	//OUTROS
            
            FConcTxt(aRegs,nHdlTxt)
        EndIf
    Next

Return Nil

/*/{Protheus.doc} RegT022
    (Realiza a geracao do registro RegT022 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT022, array, Array com as informações do registro T022

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT022(nHdlTxt,aRegT022)
	
    Local aRegs := {}

    Aadd( aRegs, {  'T022',;
                    '0',;
                    DToS(oWizard:GetDataDe()),;
                    DToS(oWizard:GetDataAte()),;
                    Val2Str( aRegT022[1,2], 16, 2  ),;
                    Val2Str( aRegT022[1,3], 16, 2  ),;
                    Val2Str( aRegT022[1,4], 16, 2  ),;
                    Val2Str( aRegT022[1,5], 16, 2  ),;
                    Val2Str( aRegT022[1,6], 16, 2  ),;
                    Val2Str( aRegT022[1,7], 16, 2  ),;
                    Val2Str( aRegT022[1,8], 16, 2  )} )
        
    FConcTxt(aRegs,nHdlTxt)
	
Return Nil

/*/{Protheus.doc} RegT022AA
    (Realiza a geracao do registro RegT022AA do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param aRegT022AA, array, Array com as informações do registro T022AA

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT022AA(nHdlTxt,aRegT022AA)
	
    Local aRegs := {}
    Local nlX := 1

    For nlX := 1 To Len( aRegT022AA )
        aRegs := {}
        Aadd( aRegs, {  'T022AA',;
                        aRegT022AA[nlX][4],;
                        aRegT022AA[nlX][7],;
                        Val2Str( aRegT022AA[nlX][3], 16, 2 ),;
                        aRegT022AA[nlX][2],;
                        aRegT022AA[nlX][5],;
                        aRegT022AA[nlX][6] } )
        
        FConcTxt(aRegs,nHdlTxt)
    Next
	
Return Nil

/*/{Protheus.doc} RegT022AB
    (Realiza a geracao do registro RegT022AB do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 12/09/2016

    @param nHdlTxt, numerico, Handle de geracao do Arquivo
    @param a_RgT022AB, array, Array com as informações do registro T022AB
            
    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT022AB(nHdlTxt,a_RgT022AB)
	
    Local aRegs := {}
    Local nlX := 1

    For nlX := 1 To Len( a_RgT022AB )
        
        aRegs := {}
        Aadd( aRegs, {  'T022AB',;
                        a_RgT022AB[nlX][2],; 
                        a_RgT022AB[nlX][3],;
                        Val2Str( a_RgT022AB[nlX][4], 16, 2 ),;
                        Val2Str( a_RgT022AB[nlX][5], 16, 2 ),;
                        Val2Str( a_RgT022AB[nlX][6], 16, 2 ) } )
        
        FConcTxt( aRegs, nHdlTxt )
        
    Next
	
Return Nil

/*/{Protheus.doc} fLayT066
    (Função para executar o layout T066)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @param l_TabComp, logico, tabela complementar da geração do Sped Fiscal        

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT066(a_WizSped,l_TabComp)

    Local nCount := 0

    Local aListFil := {}

	Default a_WizSped := {}

    Default l_TabComp := .F.

    fMsgPrcss("Gerando Registro T066 - Exportação...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T066",2)
	
    For nCount := 1 To Len(oWizard:aFiliais)
        // Se a filial foi selecionada
        If oWizard:aFiliais[nCount][1] == _MARK_OK_
            // Adiciona a lista de filial
            Aadd(aListFil,{.T.,oWizard:aFiliais[nCount][2]})
        EndIf
    Next

    // Monta os layouts T066
    If ExtInfoExp(a_WizSped,aListFil,l_TabComp)
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T066",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T066",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} fLayT067
    (Função para executar o layout T067)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT067(a_WizSped)

    Local nCount := 0

    Local aListFil := {}

	Default a_WizSped := {}

    fMsgPrcss("Gerando Registro T067 - Controle de Créditos(ICMS)...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T067",2)
	
    For nCount := 1 To Len(oWizard:aFiliais)
        // Se a filial foi selecionada
        If oWizard:aFiliais[nCount][1] == _MARK_OK_
            // Adiciona a lista de filial
            Aadd(aListFil,{.T.,oWizard:aFiliais[nCount][2]})
        EndIf
    Next

    // Monta os layouts T067
    If ExtCtrCred(a_WizSped,aListFil)
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T067",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T067",1)		
	EndIf
	
Return Nil

/*/{Protheus.doc} fLayT079
    (Função para executar o layout T079)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT079(a_WizSped)

	Default a_WizSped := {}

    fMsgPrcss("Gerando Registro T079 - Inventário...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T079",2)
	
    // Monta o layout T079
    If RegT079(a_WizSped)
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T079",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T079",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT079
    (Realiza a geracao do registro T079 do TAF)

    @type Static Function
    @author Rodrigo Aguilar
    @since 02/05/2013

	@param a_WizSped, array, InFormaçoes da Wizard do extrator fiscal 

    @return lGerou, logico, se gerou ou não.
    /*/
Static Function RegT079(a_WizSped)
	
	Local cReg     := "T079"
	Local cTxtSys  := cDirSystem + "\" + cReg + ".TXT"
	Local nHdlTxt  := IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )
	
	Local cAlias   := ""
	Local cCst     := ""
	Local cOrigem  := ""
	Local cVersao  := "007"
	Local aAreaSM0 := SM0->(GetArea())
	
	Local nlI  := 0
	Local nlY  := 0
	Local nPos := 0 
	Local nAdd := 0 
	
	Local cFilDe  := ""
	Local cFilAte := ""
	
	//----------------------------------------------------------------------------------------------------
	//Executo somente para a filial que esta sEndo processada dentro do laço, cada filial terá seus dados
	//de movimentação CIAP individualizado
	//----------------------------------------------------------------------------------------------------
	Local bWhileSM0	:= {|| !SM0->(Eof()) .And. cEmpAnt == SM0->M0_CODIGO .And. cFilAnt == FWGETCODFILIAL }
	
	Local aRegT079   := {} 
	Local aRegT079AA := {}
	Local aRegT079AB := {}
	Local aArq       := {}
	Local aRegs      := {}

	Local lGerou := .F.

	Default a_WizSped := {}
	
	cFilDe := PadR("",FWGETTAMFILIAL)
	cFilAte	:= Repl("Z",FWGETTAMFILIAL)
	
	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	Aadd(aArqGer,cTxtSys)
	
	// Criacao do TRB para ser alimentado durante o processamento da rotina
	SPDGerTrb( 1, @aArq, @cAlias,.T., @oTempTab )
	SM0->(MsSeek (cEmpAnt+cFilAnt, .T.))
	// Realiza a Emissao do Bloco H do Sped Fiscal, alimentando os arrays necessarios para a geracao no TAF
	SPDBlocoH( cAlias, bWhileSM0, a_WizSped, cFilDe, {}, {}, {}, {}, {} , , , .F., cFilAte, .T., @aRegT079, @aRegT079AA, @aRegT079AB, cVersao )
	
	// Ordeno o Array por ordem crescente
	If Len( aRegT079AB ) > 0
		aSort(aRegT079AB, , , {|aX, aY| aX < aY } )
	EndIf
	
	// Realiza a Emissao do Registro T079
	If !Empty( aRegT079[ 1 , 2 ] ) .And. aRegT079[ 1 , 3 ] > 0
		lGerou := .T.

		FConcTxt( aRegT079 , nHdlTxt )
	EndIf
	
	For nlI:=1 To Len( aRegT079AA )
		
		// Realiza a Emissao do Registro T079AA
		aRegs := { { } }
		
		for nAdd := 2 to len( aRegT079AA[ nlI ] )
			Aadd( aRegs[ 1 ], aRegT079AA[ nlI , nAdd ] )
		next nAdd

		FConcTxt( aRegs, nHdlTxt )
		
		If ( nPos := Ascan( aRegT079AB, { |x| x[1] == nlI } ) ) > 0
			For nlY := nPos To Len( aRegT079AB )
				
				If aRegT079AB[nlY][1] <> nlI
					Exit
				EndIf
				
				If Len( aRegT079AB[nlI][3] ) >= 3
					cCst    := Right( aRegT079AB[nlI][3], 2 )
					cOrigem := Left( aRegT079AB[nlI][3], 1 )
				Else
					cCst    := ""
					cOrigem := ""
				EndIf
				
				// Realiza a Emissao do Registro T079AB
				aRegs := {}
				Aadd( aRegs, { aRegT079AB[nlI][2],;
					cCst,;
					cOrigem,;
					aRegT079AB[nlI][4],;
					aRegT079AB[nlI][5] } )
				
				FConcTxt( aRegs, nHdlTxt )
			Next
		EndIf
	Next
	
	// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1.
	If cTpSaida == "2" .And. len( aDadosST1 ) > 0 .And. !Empty(aRegT079[1][2]) 
		FConcST1()
	EndIf

	// Fecho Arquivo de Trabalho criado
	SPDGerTrb( 2, @aArq, @cAlias,.T., @oTempTab )
	
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf
	
	RestArea(aAreaSM0)

Return lGerou

/*/{Protheus.doc} fLayT080
    (Função para executar o layout T080)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT080()

    fMsgPrcss("Gerando Registro T080 - Ident. Equipamento SAT CFE...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T080",2)
	
    // Monta o layout T080
    If ExtT080()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T080",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T080",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} fLayT154
    (Função para executar o layout T154)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

	@param a_WizFin, array, Informações para o financeiro.
	@param aParticip, array, Informações do Participante

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT154(a_WizFin, aParticip)

	Local cTxtSys := ""

	Local nHdlTxt := 0

	Default a_WizFin := {}
	Default aParticip := {}

    fMsgPrcss("Gerando Registro T154 - Cadastro de Recibos / Faturas...")
	cTxtSys := cDirSystem + '\T154.TXT'
//	cTxtSys := cDirSystem + cBarraUnix + "T154.TXT"   
	nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)

	Aadd(aArqGer,cTxtSys)

	// Se estiver ok para execução do finaceiro e existir a função
	If lFFinExtOK .And. FindFunction("FExpT154")
		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T154",2)
	
		// Gera o arquivo T154
		If FExpT154(cFilAnt,cTpSaida,nHdlTxt,a_WizFin, @aParticip,,lFiltReinf, cFiltInt)   
			lGerFilial := .F.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,"T154",3) 
		Else
			lGerFilPar := .T.

			// Atualiza a tela de processamento
			FisaExtW01(cFilProc,0,"T154",1)
		EndIf
	EndIf

	// Libero Handle do Arquivo
	If cTpSaida == "1"
		FClose(nHdlTxt)
	EndIf

Return Nil

/*/{Protheus.doc} fLayT157
    (Função para executar o layout T157)

    @type Static Function
    @author Vitor Ribeiro
    @since 24/05/2018

    @return Nil, nulo, não tem retorno
    /*/
Static Function fLayT157()

    fMsgPrcss("Gerando Registro T157 - Cadastro de Obras...")

	// Atualiza a tela de processamento
	FisaExtW01(cFilProc,0,"T157",2)
	
    // Monta o layout T157
    If RegT157()
		lGerFilial := .F.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T157",3)
	Else
		lGerFilPar := .T.

		// Atualiza a tela de processamento
		FisaExtW01(cFilProc,0,"T157",1)
	EndIf
	
Return Nil

/*/{Protheus.doc} RegT157
	(Realiza a geracao do registro T157 do TAF)

	@type Static Function
	@author flavio.luiz
	@since 05/01/2018

	@return lGerou, logico, se gerou ou não.
	/*/
Static Function RegT157()

	Local aRegt157 := {}
	
	Local cTxtSys := ""

	Local nHdlTxt := 0
	Local nPosicao := 0

	Local lGerou := .F.
	Local cAliasSON := GetNextAlias()
	Local cDtDe := dtos(oWizard:GetDataDe())
	Local cDtAte := dtos(oWizard:GetDataAte())
	Local aArea := GetArea()
	Local cFromSON := '%%'
	Local lCmpCPRB := .f.

	cTxtSys := cDirSystem + "\T157.TXT"
	nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)

	Aadd(aArqGer,cTxtSys)

	If AliasInDic('SON')

		DbSelectArea('SON')
		if( lCmpCPRB := SON->(FieldPos("ON_INDCPRB"))  > 0 )
			cFromSON := "%,SON.ON_INDCPRB%"
		endif

		BeginSql Alias cAliasSON

			SELECT DISTINCT
				SON.ON_CODIGO,
				SON.ON_TPINSCR,
				SON.ON_CNO,
				SON.ON_IDOBRA,
				CASE WHEN SON.ON_TPOBRA = '2' THEN '1' ELSE '2' END ON_TPOBRA,
				SON.ON_DESC
				%Exp:cFromSON%
			FROM %Table:SON% SON
				
			WHERE EXISTS( 
			SELECT 1 FROM %Table:SF2% SF2 
				WHERE SF2.%NotDel% 
				AND SF2.F2_FILIAL = %xFilial:SF2%  
				AND SF2.F2_CNO = SON.ON_CODIGO 
				AND SF2.F2_EMISSAO >= %exp:cDtDe% AND SF2.F2_EMISSAO <= %exp:cDtAte%
				AND SF2.F2_CNO != '' 
				AND SON.%NotDel%
  				AND SON.ON_FILIAL = %xFilial:SON%)
				
			OR EXISTS( 
			SELECT 1 FROM %Table:SD1% SD1 
				WHERE SD1.%NotDel%
				AND SD1.D1_FILIAL = %xFilial:SD1% 
				AND SD1.D1_CNO = SON.ON_CODIGO 
				AND SD1.D1_DTDIGIT >= %exp:cDtDe% AND SD1.D1_DTDIGIT <= %exp:cDtAte%
				AND SD1.D1_CNO != '' 
				AND SON.%NotDel%
  				AND SON.ON_FILIAL = %xFilial:SON%)

			ORDER BY 
				SON.ON_CODIGO
		EndSql

		while (cAliasSON)->(!eof())
			lGerou := .T.

			aRegt157 := {}
			Aadd(aRegt157,{})
			nPosicao := Len(aRegt157)

			Aadd(aRegt157[nPosicao],"T157")             						// 01 - REGISTRO
			Aadd(aRegt157[nPosicao],(cAliasSON)->ON_TPINSCR)    				// 02 - TP_INSCRICAO 1-CNPJ/4-CNO
			Aadd(aRegt157[nPosicao],(cAliasSON)->ON_CNO) 						// 03 - NR_INSC_ESTAB
			Aadd(aRegt157[nPosicao],(cAliasSON)->ON_IDOBRA)     				// 04 - IND_OBRA
			Aadd(aRegt157[nPosicao],(cAliasSON)->ON_TPOBRA)						// 05 - IND_TERCEIRO
			Aadd(aRegt157[nPosicao],(cAliasSON)->ON_DESC)       				// 06 - DESCRICAO

			if lCmpCPRB
				Aadd(aRegt157[nPosicao],(cAliasSON)->ON_INDCPRB)       			// 07 - Contribunite CPRB?
			endif

			(cAliasSON)->(DbSkip())

			FConcTxt(aRegt157,nHdlTxt)

			// Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
			If cTpSaida == "2"
				FConcST1()
			EndIf
		enddo
		(cAliasSON)->(DbCloseArea())
	EndIf

	If cTpSaida == "1"
		FClose(nHdlTxt)
	EndIf
	RestArea(aArea)

Return lGerou

/*/{Protheus.doc} MsgJobExt
Padrao de mensagem enviada ao console do Application Server

@author Felipe C. Seolin
@since  19/07/2013

@Param cMsg = Mensagem a ser enviada

@return Nil, nulo, não tem retorno
/*/
Function MsgJobExt(cMsg)
	
	If lJob
		TAFConout("FISAEXTEXC.PRW: " + DToS(Date()) + "-" + Time() + "-" + cMsg,2,.T.,"EXT")
	EndIf
	
Return Nil

/*/{Protheus.doc} SchedDef
	(Informacoes de definicao dos parametros do schedule)

	@author Felipe C. Seolin 
	@since 22/07/2013
	
	@Return  Array com as informacoes de definicao dos parametros do schedule
	Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
	Array[x,2] -> Caracter, Nome do Pergunte
	Array[x,3] -> Caracter, Alias(para Relatorio)
	Array[x,4] -> Array, Ordem(para Relatorio)
	Array[x,5] -> Caracter, Titulo(para Relatorio)

	@obs Essa função é chamada pela configuração do schedule.
	/*/
Static Function SchedDef()

	Local aSchedule := {}

	aSchedule := {"P","FISAEXTJOB",,,}

Return aSchedule

/*/{Protheus.doc} FPrepT013
	(Função para gerar preparar o registro T013 para multiThead)

	@type Function
	@author Vito Ribeiro
	@since 05/04/2018

	@param n_QtdThr, numerico, quantidade de thread
	@param c_EntSai, caracter, qual o tipo do documento
	@param c_QueryMT, caracter, contém a query para multi thread

	@return aNumThread, array, contém a numeração para execução de cada thread.
	/*/
Function FPrepT013(n_QtdThr,c_EntSai,c_QueryMT)

	Local aNumThread := {}
	
	Local cQuery := ""
	Local cAliasQTD := GetNextAlias() 
	Local cConcat := IIf("MSSQL"$cTCGetDB,"+","||")	// Variavel determina caracter de concatenação do banco
		
	Local nQtdRegs := 0
	Local nCount := 0 
	Local nResult := 0
	Local nControl := 0

	Default n_QtdThr := 0
	
	Default c_EntSai := ""
	Default c_QueryMT := ""
	
	// Query Principal
	c_QueryMT := "SELECT "
	c_QueryMT += "	(MOVI.FT_NFISCAL " + cConcat + " MOVI.FT_SERIE " + cConcat + " MOVI.FT_CLIEFOR " + cConcat + " MOVI.FT_LOJA) DOCUMENTO "
	c_QueryMT += "	,MOVI.FT_ENTRADA ENTRADA "

	If cTCGetDB == "ORACLE"
		c_QueryMT += "	,ROWNUM LINHA "
	Else
		c_QueryMT += "	,ROW_NUMBER() OVER(ORDER BY MOVI.FT_ENTRADA, MOVI.FT_NFISCAL, MOVI.FT_SERIE, MOVI.FT_CLIEFOR, MOVI.FT_LOJA) LINHA "
	EndIf

	c_QueryMT += "FROM ( "
	c_QueryMT += "	SELECT DISTINCT "
	c_QueryMT += "		SFT.FT_NFISCAL "
	c_QueryMT += "		,SFT.FT_SERIE "
	c_QueryMT += "		,SFT.FT_CLIEFOR "
	c_QueryMT += "		,SFT.FT_LOJA "
	c_QueryMT += "		,SFT.FT_ENTRADA "
	c_QueryMT += "	FROM " + RetSqlName("SFT") + " SFT "

	c_QueryMT += "	WHERE "
	c_QueryMT += "		SFT.D_E_L_E_T_ = ' ' "
	c_QueryMT += "		AND SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
	c_QueryMT += "		AND SFT.FT_TIPOMOV = '" + c_EntSai + "' "
	c_QueryMT += "		AND SFT.FT_ENTRADA BETWEEN '" + DToS(oWizard:GetDataDe()) + "' AND '" + DToS(oWizard:GetDataAte()) + "' "

	c_QueryMT += "		AND SFT.FT_NFISCAL BETWEEN '" + oWizard:GetNotaDe() + "' AND '" + oWizard:GetNotaAte() + "' "
	If !(Empty(oWizard:GetSerieDe()) .And. oWizard:GetSerieAte()='ZZZ')	
		c_QueryMT += "		AND SFT.FT_SERIE BETWEEN '" + oWizard:GetSerieDe()	+ "' AND '" + oWizard:GetSerieAte()	+ "' " 
	Endif
	If !Empty(oWizard:GetEspecie())
		c_QueryMT += "		AND SFT.FT_ESPECIE IN  (" + oWizard:GetEspecie(.T.) + ") " 
	EndIf

	c_QueryMT += ") MOVI "

	cQuery := "%" + c_QueryMT + "%"

	// Query Contando os registros
	BeginSql Alias cAliasQTD
		SELECT COUNT(*) COUNT
		FROM (%Exp:cQuery%) MTSFT
	EndSql
	
	// Se retornou registros
	If (cAliasQTD)->(!Eof())
		// Guarda a quantidade de registros
		nQtdRegs := (cAliasQTD)->COUNT

		If !Empty(nQtdRegs)
			// Realizo o controle de quantidade de registros a ser processados por Thread
			nResult := Round((nQtdRegs/n_QtdThr),0)
			
			For nCount := 1 to n_QtdThr
				If nCount <> n_QtdThr
					Aadd(aNumThread,{cValToChar(1+nControl),cValToChar(nResult*nCount)})

					nControl += nResult
				Else
					Aadd(aNumThread,{cValToChar(1+nControl),cValToChar(nQtdRegs),nQtdRegs})
				EndIf  
			Next
		EndIf
	EndIf
	
	// Fecha o alias da query.
	(cAliasQTD)->(DbCloseArea())

Return aNumThread 

//-------------------------------------------------------------------
/*/{Protheus.doc} xGetCmpGnre

Determina quais os campos extras deverão ser gerados para a GNRE de acordo
com a UF e o Código de Receita.


@Param cEstado -> UF do Destinatário
@Param cCodRec -> Codigo da Receita

@Return aCodsRec -> Codigo de Receita e Campos extras da UF

@author Evandro dos Santos O. Teixeira
@since  07/1/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function xGetCmpGnre(cEstado,cCodRec)
	
	Local aCodxEst 	:= {}
	Local oHash 		:= Nil 
	Local aCodsRec 	:= {}
	Local cChave		:= ""
	
	/*
	
	De/Para Campos Internos x Campos Extras
	Os Campos Internos foram criados para agrupar os campos extras que tinham vários códigos
	com a mesma finalidade.
	
	
	01 		Chave de Acesso Nfe								009;012;017;027;030;036;047;076;080;083;084;086;087;101						
	02		Nome do Remetente									024						
	03		Cnpj Remetente									025						
	04		Nro da Nota Fiscal								026						
	05		Obs 1												068						
	06		Obs 2 												069						
	07		Informação Complementar							010;045;056;061;062;065;071;073						
	08		Chave de Acesso Cte								074;078;079;089;095;098;100						
	09		ManIfesto de Carga								014						
	10		Informações Complementares 2					57						
	11		Informações Complementares 3					58						
	12		Detalhes da Receita								082						
	13		Observações										004;011;013;072						
	14		Nota Fiscal/Outros								081						
	15		Saida de Mercadoria								050						
	16		Data do desembaraço								052						
	17		Conhecimento de Transporte Internacional		053						
	18		Protocolo TED de Transmissao do Sintegra		054						
	19		JustIficativa										055						
	20		GUIAST												048						
	21		Chave de Acesso da NFe ou do CTe				088;092;094;099;102;077						
	22		Data de Emissão da NF							016		
					
	*/
	
	If Type("oHashCache") == "U" .Or. oHashCache == Nil 
	
		/*+---------------------------------------------------------+
		  | * Estrutura do arrray aCodxExt                          |
		  | aCodxEst[n] - Estado + Codigo da Receita (chave)        |
		  | aCodxEst[n][y][1] - Codigo do Campo Extra				    |
		  | aCodxEst[n][y][2] - Codigo do Campo Interno			    |
		  | aCodxEst[n][y][3] - Tipo do campo						    |
		  | aCodxEst[n][y][4] - Determina se o campo é Obrigatório  |
		  +---------------------------------------------------------+*/ 	
	
		aAdd(aCodxEst,{"AC100030",{"011","02","T",.F.},{"012","03","T",.F.},{"026","04","T",.F.}})
		aAdd(aCodxEst,{"AC100048",{"068","05","T",.F.},{"069","06","T",.F.}})
		aAdd(aCodxEst,{"AC100099",{"076","01","T",.T.},{"068","05","T",.F.},{"069","06","T",.F.}})
		aAdd(aCodxEst,{"AC100102",{"076","01","T",.T.},{"068","05","T",.F.}})
		aAdd(aCodxEst,{"AC100110",{"068","05","T",.F.}})
		
		aAdd(aCodxEst,{"AL100013",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100030",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100048",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100099",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100102",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100110",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100021",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100056",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100080",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100129",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL100137",{"065","07","T",.F.}})
		aAdd(aCodxEst,{"AL600016",{"065","07","T",.F.}})
		
		aAdd(aCodxEst,{"AM100030",{"014","09","N",.F.},{"095","08","T",.T.}})
		aAdd(aCodxEst,{"AM100048",{"012","01","T",.T.},{"013","13","T",.F.}})
		aAdd(aCodxEst,{"AM100099",{"012","01","T",.F.}})
		aAdd(aCodxEst,{"AM100102",{"013","13","T",.F.}})

		aAdd(aCodxEst,{"AP100099",{"047","01","T",.F.}})
		aAdd(aCodxEst,{"AP100102",{"047","01","T",.T.}})
		
		aAdd(aCodxEst,{"BA100030",{"081","14","T",.T.}})
		aAdd(aCodxEst,{"BA100102",{"086","01","T",.T.}})
		aAdd(aCodxEst,{"BA100129",{"086","01","T",.F.}})

		aAdd(aCodxEst,{"CE100048",{"048","20","N",.F.}})
		aAdd(aCodxEst,{"CE100056",{"053","16","D",.F.}})
		aAdd(aCodxEst,{"CE100099",{"050","15","D",.F.}})
		aAdd(aCodxEst,{"CE100102",{"050","15","D",.F.}})
		aAdd(aCodxEst,{"CE100110",{"048","20","N",.F.}})
		aAdd(aCodxEst,{"CE100080",{"052","16","T",.F.}})
		aAdd(aCodxEst,{"CE100129",{"054","55","D",.F.},{"018","19","T",.F.}})
		aAdd(aCodxEst,{"CE100137",{"050","15","N",.F.}})
		aAdd(aCodxEst,{"CE100137",{"048","20","T",.F.}})

		aAdd(aCodxEst,{"GO100013",{"010","07","T",.F.}})
		aAdd(aCodxEst,{"GO100021",{"010","07","T",.F.}})
		aAdd(aCodxEst,{"GO100030",{"010","07","T",.F.}})
		aAdd(aCodxEst,{"GO100048",{"010","07","T",.F.}})
		aAdd(aCodxEst,{"GO100056",{"010","07","T",.F.}})
		aAdd(aCodxEst,{"GO100099",{"102","21","T",.T.}})
		aAdd(aCodxEst,{"GO100102",{"010","07","T",.F.},{"102","21","T",.T.}})
		aAdd(aCodxEst,{"GO100110",{"010","07","T",.F.}})	
		
		aAdd(aCodxEst,{"MG100013",{"045","07","T",.F.}})
		aAdd(aCodxEst,{"MG100021",{"045","07","T",.F.}})
		aAdd(aCodxEst,{"MG100030",{"045","07","T",.F.}})
		aAdd(aCodxEst,{"MG100048",{"045","07","T",.F.}})
		aAdd(aCodxEst,{"MG100056",{"045","07","T",.F.}})
		aAdd(aCodxEst,{"MG100064",{"045","07","T",.F.}})
		aAdd(aCodxEst,{"MG100080",{"045","07","T",.F.}})	
		aAdd(aCodxEst,{"MG100099",{"045","07","T",.F.}})	
		aAdd(aCodxEst,{"MG600016",{"045","07","T",.F.}})
		
		aAdd(aCodxEst,{"MS100030",{"079","08","T",.F.}})
		aAdd(aCodxEst,{"MS100056",{"027","01","T",.T.}})
		aAdd(aCodxEst,{"MS100099",{"027","01","T",.F.}})
		aAdd(aCodxEst,{"MS100102",{"088","27","T",.F.}})
		aAdd(aCodxEst,{"MS100129",{"088","27","T",.F.}})
									
		aAdd(aCodxEst,{"MT100099",{"016","22","D",.F.}})	
		aAdd(aCodxEst,{"MT100099",{"017","01","T",.F.}})
		aAdd(aCodxEst,{"MT100102",{"016","22","D",.F.}})
		aAdd(aCodxEst,{"MT100102",{"017","01","T",.T.}})
		aAdd(aCodxEst,{"MT100129",{"016","22","D",.F.}})
		aAdd(aCodxEst,{"MT100129",{"017","01","T",.T.}})
		
		aAdd(aCodxEst,{"PB100099",{"030","01","T",.T.}})
		aAdd(aCodxEst,{"PB100102",{"098","08","T",.T.}})
		aAdd(aCodxEst,{"PB100102",{"099","21","T",.T.}})
		aAdd(aCodxEst,{"PB100129",{"030","01","T",.T.}})
		
		aAdd(aCodxEst,{"PE100013",{"004","13","T",.F.}})
		aAdd(aCodxEst,{"PE100080",{"004","13","T",.F.}})
		aAdd(aCodxEst,{"PE100099",{"009","01","T",.T.}})
		aAdd(aCodxEst,{"PE100102",{"092","21","T",.T.}})
		
		aAdd(aCodxEst,{"PI100013",{"011","13","T",.T.}})
		
		aAdd(aCodxEst,{"PR100056",{"056","07","T",.F.}})
		aAdd(aCodxEst,{"PR100056",{"057","10","T",.F.}})
		aAdd(aCodxEst,{"PR100056",{"058","11","T",.F.}})
		aAdd(aCodxEst,{"PR100099",{"056","07","T",.F.}})
		aAdd(aCodxEst,{"PR100099",{"057","23","T",.F.}})
		aAdd(aCodxEst,{"PR100102",{"056","07","T",.F.}})
		aAdd(aCodxEst,{"PR100102",{"057","10","T",.F.}})
		aAdd(aCodxEst,{"PR100102",{"087","01","T",.T.}})
		
		aAdd(aCodxEst,{"RN100013",{"061","07","T",.F.}})
		aAdd(aCodxEst,{"RN100021",{"061","07","T",.F.}})
		aAdd(aCodxEst,{"RN100030",{"061","07","T",.F.}})
		aAdd(aCodxEst,{"RN100048",{"061","07","T",.F.}})
		aAdd(aCodxEst,{"RN100056",{"061","07","T",.F.}})
		aAdd(aCodxEst,{"RN100080",{"061","07","T",.F.}})
		aAdd(aCodxEst,{"RN100099",{"061","07","T",.F.}})
		
		aAdd(aCodxEst,{"RO100030",{"089","08","T",.F.}})
		aAdd(aCodxEst,{"RO100099",{"083","01","T",.T.}})	
		aAdd(aCodxEst,{"RO100102",{"083","01","T",.T.}})		
		
		aAdd(aCodxEst,{"RR100013",{"036","01","T",.F.},{"071","07","T",.F.}})	
		aAdd(aCodxEst,{"RR100021",{"036","01","T",.F.},{"071","07","T",.F.}})	
		aAdd(aCodxEst,{"RR100030",{"036","01","T",.F.},{"071","07","T",.F.}})	
		aAdd(aCodxEst,{"RR100048",{"036","01","T",.F.},{"071","07","T",.F.}})	
		aAdd(aCodxEst,{"RR100056",{"036","01","T",.F.},{"071","07","T",.F.}})	
		aAdd(aCodxEst,{"RR100080",{"036","01","T",.F.},{"071","07","T",.F.}})	
		aAdd(aCodxEst,{"RR100099",{"036","01","T",.T.},{"071","07","T",.F.}})	
		aAdd(aCodxEst,{"RR100102",{"036","01","T",.T.},{"071","07","T",.F.}})	
		aAdd(aCodxEst,{"RR100110",{"071","01","T",.F.}})

		aAdd(aCodxEst,{"RS100013",{"062","07","T",.F.}})	
		aAdd(aCodxEst,{"RS100021",{"062","07","T",.F.},{"082","25","T",.F.}})	
		aAdd(aCodxEst,{"RS100030",{"062","07","T",.F.},{"074","08","T",.F.}})	
		aAdd(aCodxEst,{"RS100048",{"062","07","T",.F.},{"082","25","T",.F.}})	
		aAdd(aCodxEst,{"RS100056",{"062","07","T",.F.}})	
		aAdd(aCodxEst,{"RS100064",{"062","07","T",.F.}})
		aAdd(aCodxEst,{"RS100072",{"062","07","T",.F.}})
		aAdd(aCodxEst,{"RS100080",{"062","07","T",.F.},{"082","12","T",.F.}})	
		aAdd(aCodxEst,{"RS100099",{"062","07","T",.T.},{"074","08","T",.T.}})	
		aAdd(aCodxEst,{"RS100102",{"062","07","T",.T.},{"074","08","T",.T.}})	
		aAdd(aCodxEst,{"RS100110",{"062","07","T",.F.}})
		aAdd(aCodxEst,{"RS100129",{"062","07","T",.F.},{"074","08","T",.T.}})
		aAdd(aCodxEst,{"RS100137",{"062","07","T",.F.},{"082","12","T",.F.}})
		aAdd(aCodxEst,{"RS150010",{"062","07","T",.F.}})
		aAdd(aCodxEst,{"RS500011",{"062","07","T",.F.}})
		aAdd(aCodxEst,{"RS600016",{"062","07","T",.F.},{"082","12","T",.F.}})
		
		aAdd(aCodxEst,{"SC100099",{"084","01","T",.T.}})
		aAdd(aCodxEst,{"SC100102",{"084","01","T",.T.}})
		
		aAdd(aCodxEst,{"SE100030",{"073","07","T",.F.}})
		aAdd(aCodxEst,{"SE100048",{"073","07","T",.F.},{"078","08","T",.F.}})
		aAdd(aCodxEst,{"SE100056",{"073","07","T",.F.}})
		aAdd(aCodxEst,{"SE100080",{"073","07","T",.F.}})
		aAdd(aCodxEst,{"SE100099",{"073","07","T",.F.},{"077","21","T",.T.}})
		aAdd(aCodxEst,{"SE100102",{"073","07","T",.F.},{"077","21","T",.T.}})
		aAdd(aCodxEst,{"SE100110",{"073","07","T",.F.}})
		aAdd(aCodxEst,{"SE100129",{"073","07","T",.F.},{"077","21","T",.T.}})
		aAdd(aCodxEst,{"SE100137",{"073","07","T",.F.}})
		
		aAdd(aCodxEst,{"TO100013",{"072","13","T",.F.}})
		aAdd(aCodxEst,{"TO100021",{"072","13","T",.F.}})
		aAdd(aCodxEst,{"TO100030",{"072","13","T",.F.}})
		aAdd(aCodxEst,{"TO100048",{"072","13","T",.T.}})
		aAdd(aCodxEst,{"TO100056",{"072","13","T",.F.}})
		aAdd(aCodxEst,{"TO100080",{"072","13","T",.F.}})
		aAdd(aCodxEst,{"TO100099",{"072","13","T",.T.},{"080","01","T",.T.}})
		aAdd(aCodxEst,{"TO100102",{"072","13","T",.T.},{"080","01","T",.F.}})
		aAdd(aCodxEst,{"TO100110",{"072","13","T",.T.}})
		aAdd(aCodxEst,{"TO100129",{"072","13","T",.T.},{"080","01","T",.F.}})
		aAdd(aCodxEst,{"TO100137",{"072","13","T",.T.}})

		oHash	:=	AToHM(aCodxEst,1,3)
		oHashCache = oHash
	Else
		oHash = oHashCache
	EndIf
	
	cChave := AllTrim(cEstado)+AllTrim(cCodRec)
	
	HMGet(oHash,cChave,@aCodsRec )
	
Return (aCodsRec)

/*/{Protheus.doc} xRetInfCmp
	(Retorna o conteudo do campo extra da GNRE de acordo com o código interno)

	@author Evandro dos Santos O. Teixeira
	@since  07/1/2016

	@Param cCodInt, caracter, Código Interno

	@Return cValCmp, caracter, Codigo de Receita e Campos extras da UF
	/*/
Static Function xRetInfCmp(cCodInt)

	Local cValCmp := ""
	
	If (cCodInt $ "01|08|15|21|22") .And. AllTrim(cCodInt) != "|"
		SF3->(DbSeek(xFilial("SF3")+SF6->(F6_CLIfOR+F6_LOJA+F6_DOC+F6_SERIE)))	
	EndIf
	
	If cCodInt $ "01|08|21" .And. AllTrim(cCodInt) != "|"
		cValCmp := SF3->F3_CHVNFE
	ElseIf cCodInt == "02"
		cValCmp := SM0->M0_NOMECOM
	ElseIf cCodInt == "03"
		cValCmp := SM0->M0_M0_CGC
	ElseIf cCodInt $ "04|14" .And. AllTrim(cCodInt) != "|"
		cValCmp := SF6->F6_DOC
	ElseIf cCodInt $ "05|07|13|19" .And. AllTrim(cCodInt) != "|"
		cValCmp := SF6->F6_INF
	ElseIf cCodInt == "09" 
		cValCmp := SF6->F6_DESCOMP
	ElseIf cCodInt == "15" 
		cValCmp := SF3->F3_ENTRADA
	ElseIf cCodInt == "22" 
		cValCmp := SF3->F3_EMISSAO
	EndIf	
		
Return cValCmp

//-------------------------------------------------------------------
/*/{Protheus.doc} gnreTpDoc

Retorna o Conteudo do campo tipo de documento 

@Param cCodRec -> Código de Receita
@Param cDocto -> Numero do Documento
@Param lSubTrib -> Determina se existe inscrição estadual no estado de destino
@Param cEspecie -> Espécie da Nota Fiscal
@Param cUF -> UF do Remetente
@Param cF6TpDoc -> Tipo do Documento (da tabela SF6) 

@Return aCodsRec -> Codigo de Receita e Campos extras da UF

@author Evandro dos Santos O. Teixeira
@since  07/1/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function gnreTpDoc(cCodRec,cDocto,lSubTrib,cEspecie,cUF,cF6TpDoc)


	cCodRec := AllTrim(cCodRec)
	cEspecie := AllTrim(cEspecie)

	If cCodRec == "100048" .And. lSubTrib .And. !Empty(cDocto)
		Return "10"
	EndIf
	
	If !(lSubTrib) .And. cCodRec == "100099" .And. !Empty(cEspecie)
		If cEspecie == "NFA"
			Return "01"
		EndIf
		If cEspecie $ "NF/SPED"
			Return "10"
		EndIf
		If cEspecie $ "CTR/CTE"
			Return "07"
		Else
			Return "00"
		EndIf
	EndIf
	
	If Alltrim(cCodRec)$"100056" 
		If !cUF $ "AC"  
			Return cF6TpDoc
		EndIf
	Else
		If !(cUF $"BA|PR" .And. cCodRec $ "100030/100013")
			If cEspecie$"CTR/CTE" .And. cCodRec$"100030" .And. cUF$"TO/SC"
				Return "10"
			Else
				Do Case
					Case cEspecie == "NFA"
						Return "01"
					Case cEspecie $ "NF/SPED/NFP"
						Return "10"
					Case cEspecie == "CA"
						Return "08"
					Case cEspecie $ "CTR/CTE"
						Return "07"
					Case cEspecie $ "NTST/NFCEE" .And. cCodRec $ "100013|100021" .And. !cUF $ "PI"
						Return "10"
					Case cCodRec == "100013" .And. cUF == "PI"
						Return "01"
					OtherWise
						Return "00"
				EndCase
			EndIf
		EndIf
	EndIf

Return ""

/*/{Protheus.doc} fGetApurNf
Função para buscar apuração referente as notas fiscais.

@author Vitor Ribeiro
@since  15/02/2018

@param aRegT020AA, array, Array com informacoes do registro T020AA
@param dDataDe, data, Data inicial

@return Nil, nulo, não tem retorno.
/*/
Static Function fGetApurNf(aRegT020AA,dDataDe)
	
	Local cAliasQry := ""
	
	Local nPosicao := 0
	
	Default aRegT020AA := {}
	
	Default dDataDe := CToD("")
	
	cAliasQry := fQryApurNf(dDataDe)
	
	While (cAliasQry)->(!Eof())
		Aadd(aRegT020AA,{})
		nPosicao := Len(aRegT020AA)
		
		Aadd(aRegT020AA[nPosicao],)						// 01 - NAO USA
		Aadd(aRegT020AA[nPosicao],)						// 02 - NAO USA
		Aadd(aRegT020AA[nPosicao],"")					// 03 - COD_AJ_APUR
		Aadd(aRegT020AA[nPosicao],(cAliasQry)->DESCRI)	// 04 - DESCR_COMPL_AJ
		Aadd(aRegT020AA[nPosicao],(cAliasQry)->VALOR)	// 05 - VL_AJ_APUR
		Aadd(aRegT020AA[nPosicao],(cAliasQry)->SUBITE)	// 06 - SUBITEM
		Aadd(aRegT020AA[nPosicao],(cAliasQry)->CODLAN)	// 07 - COD_AJ_APUR_NF
		
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())
	
Return Nil

/*/{Protheus.doc} fQryApurNf
Função para executar a query para buscar apuração das notas fiscais.

@author Vitor Ribeiro
@since  15/02/2018

@param dDataDe, data, Data inicial

@return caracter, alias da query.
/*/
Static Function fQryApurNf(dDataDe)
	
	Local cAliasQry := ""
	
	Local cQuery01 := ''
	Local cFilCDH := xFilial('CDH')
	Default dDataDe := CToD("")
	
	cAliasQry := GetNextAlias()
	
	cQuery01 := " SELECT "   
	cQuery01 += "  CDH.CDH_CODLAN CODLAN "  
	cQuery01 += " ,CDH.CDH_DESC DESCRI   "  
	cQuery01 += " ,CDH.CDH_VALOR VALOR   "  
	cQuery01 += " ,CDH.CDH_SUBITE SUBITE "  
	cQuery01 += " FROM " + RetSqlName('CDH') + " CDH "  
		
	cQuery01 += " INNER JOIN ( "  
	cQuery01 += " SELECT "  
	cQuery01 += "  CDH.CDH_TIPOIP TIPOIP "  
	cQuery01 += " ,CDH.CDH_TIPOPR TIPOPR "  
	cQuery01 += " ,CDH.CDH_PERIOD PERIOD "  
	cQuery01 += " ,CDH.CDH_DTINI DTINI "  
	cQuery01 += " ,CDH.CDH_LIVRO LIVRO "  
	cQuery01 += " ,MAX(CDH.CDH_SEQUEN) MAX_SEQUEN "  
	cQuery01 += " FROM " + RetSqlName('CDH') + " CDH "  

	cQuery01 += " WHERE "  
	cQuery01 += "     CDH.D_E_L_E_T_ = ' ' "  
	cQuery01 += " AND CDH.CDH_FILIAL = '"  + cFilCDH + "' "  
	cQuery01 += " AND CDH.CDH_TIPOIP = 'IC' "  
	cQuery01 += " AND CDH.CDH_TIPOPR = '3' "  
	cQuery01 += " AND CDH.CDH_PERIOD = '1' "  
	cQuery01 += " AND CDH.CDH_DTINI  = '" + DToS(dDataDe) + "' "  
	cQuery01 += " AND CDH.CDH_CODLAN <> '' "
	cQuery01 += " AND " + xFunExpSql("LENGTH") + "(CDH.CDH_CODLAN) = 10"
	cQuery01 += "                GROUP BY "  
	cQuery01 += "                      CDH.CDH_TIPOIP "  
	cQuery01 += "                      ,CDH.CDH_TIPOPR "  
	cQuery01 += "                      ,CDH.CDH_PERIOD "  
	cQuery01 += "                      ,CDH.CDH_DTINI  "  
	cQuery01 += "                      ,CDH.CDH_LIVRO  "  
	cQuery01 += "     ) APURA ON "  
	cQuery01 += "                APURA.TIPOIP = CDH.CDH_TIPOIP "  
	cQuery01 += "                AND APURA.TIPOPR = CDH.CDH_TIPOPR "  
	cQuery01 += "                AND APURA.PERIOD = CDH.CDH_PERIOD "  
	cQuery01 += "                AND APURA.DTINI = CDH.CDH_DTINI "  
	cQuery01 += "                AND APURA.LIVRO = CDH.CDH_LIVRO "  
	cQuery01 += "                AND APURA.MAX_SEQUEN = CDH.CDH_SEQUEN "  

	cQuery01 += "     WHERE "
	cQuery01 += "           CDH.D_E_L_E_T_ = ' ' "
	cQuery01 += "                AND CDH.CDH_FILIAL = '" + cFilCDH + "' "  
	cQuery01 += "                AND CDH.CDH_TIPOIP = 'IC' "  
	cQuery01 += "                AND CDH.CDH_TIPOPR = '3' "  
	cQuery01 += "                AND CDH.CDH_PERIOD = '1' "  
	cQuery01 += "                AND CDH.CDH_DTINI = '" + DToS(dDataDe) + "' "  
	cQuery01 += "                AND CDH.CDH_CODLAN <> '' "
	cQuery01 += "                AND " + xFunExpSql("LENGTH") + "(CDH.CDH_CODLAN) = 10"
				
	cQuery01 := ChangeQuery(cQuery01)
	DBUseArea(.T.,"TopConn",TCGenQry(,,cQuery01),cAliasQry)

Return cAliasQry

/*/{Protheus.doc} fExceBanco
	(Função para verIficar se o banco possui alguma exceção)

	@author Vito Ribeiro
	@since 05/04/2018

	@param n_QtdThr, numerico, quantidade de threads.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fExceBanco(n_QtdThr)

	Local cQuery := ""
	Local cAliasQry := ""
	Local cAviso := ""

	Default n_QtdThr := 0

	If cTCGetDB == "INFORMIX" 
		If n_QtdThr > 1
			// Query específica para obter versão do Informix 
			cQuery := 'select first 1 '
			cQuery += '	dbinfo("version","full") as versao '
			cQuery += 'from systables '

			cAliasQry := GetNextAlias()
			DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)

			If (cAliasQry)->(!Eof())
				If "11.5" $ (cAliasQry)->VERSAO
					n_QtdThr := 0
					
					cAviso := "Para banco de dados Informix versão 11.5, a extração dos dados será sempre realizada como Mono Thread "
					cAviso += "indepEndente da configuração do parâmetro MV_EXTQTHR, clique em 'Continuar' para seguir com o processamento."

					Aviso("Atenção!",cAviso,{"Continuar"},3)
				EndIf
			EndIf

			// Fecha o alias
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} fTafTabInt

Função auxiliar utilizada para armazenar quais tabelas de cadastros do Proheus foram integradas ao TAF,
considerando a configuração de compartilhamento da tabela do Protheus e do TAF ( De/Para )
para não enviar os mesmos cadastros novamente para a TAFST1/txt

@param cAliasTaf  - Tabela do TAF a ser avaliado a configuração de compartilhamento
@param cAliasPrth - Tabela do Protheus
@param cTabsTaf   - Configuração de compartilhamento das tabelas do TAF ( MV_TAFCMPT )
@param cTabInteg  - Variavel a ser utilizada para armazenar as tabelas integradas ao TAF
                    Ex: "SB1D MG 01" ( Tabela SB1 da filial "D MG 01" )

@author Wesley Pinheiro
@since 03/12/2018
@version 1.0
*/
//-------------------------------------------------------------------
Static Function fTafTabInt( cAliasTaf, cAliasPrth, cTabsTaf, cTabInteg )

	Local cTabConfig := ""

	Local aTabsTaf := { }

	Local nPosTab  := 0

	cTabConfig := cAliasTaf + Upper( AllTrim( FWModeAccess( cAliasPrth, 1 ) + FWModeAccess( cAliasPrth, 2) + FWModeAccess( cAliasPrth, 3 ) ) )
	aTabsTaf   := StrTokArr( cTabsTaf, "|" )
	nPosTab    := aScan( aTabsTaf, { |x| cTabConfig $ x  } )

	if nPosTab > 0
		cTabInteg += AllTrim( cAliasPrth + xFilial( cAliasPrth ) ) + "|"
	EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} cfgTabT003

Função auxiliar utilizada para conferir se a configuração de compartilhamento entre as tabelas SA1 e SA2 são iguais.
Essa verificação é necessária para a correta integração do registro T003, pois o TAF trata essas 3 tabelas como uma única entidade
( tabela C1H ). Caso não sejam iguais as configurações, o registro T003 deve ser enviado considerando configuração exclusiva .

@author Wesley Pinheiro
@since 03/12/2018
@version 1.0
*/
//-------------------------------------------------------------------
Static Function cfgTabT003( )

	Local cSA1Config := Upper( AllTrim( FWModeAccess( "SA1", 1 ) + FWModeAccess( "SA1", 2) + FWModeAccess( "SA1", 3 ) ) )
	Local cSA2Config := Upper( AllTrim( FWModeAccess( "SA2", 1 ) + FWModeAccess( "SA2", 2) + FWModeAccess( "SA2", 3 ) ) )

	Local lOk := .F.

	If ( cSA1Config == cSA2Config )
		lOk := .T.
	EndIf

Return lOk

//-------------------------------------------------------------------
/*/
{Protheus.doc} FMtoFiscal
Verifica se existe estrutura do novo motor fiscal
@author Denis Souza
@since 26.02.2019

/*/
//-------------------------------------------------------------------

Static Function FNewMtoFis()

	Local lRet		:= .F.
	Local alGetArea	:= GetArea()

	DbSelectArea("SFT")

	If FieldPos("FT_IDTRIB") > 0
		lRet := .T.
	endif

	RestArea( alGetArea )

Return lRet

//-------------------------------------------------------------------
/*/
{Protheus.doc} FAllSubTri
	(Função Responsável por aglutinar todos os conteúdos dos parâmetros 
	MV_SUBTRIB, MV_SUBTRI1, MV_SUBTRI2... )
	@type Function
	@author Denis Naves
	@since 01/04/2019 
	@return alSubTri (array com os subtributos)

/*/
//-------------------------------------------------------------------
Function FAllSubTri()

	Local alGetSX6 := SX6->(GetArea())
	Local clSubTri := ''
	Local alSubTri := {} 

	if lAliasCLO
		DbSelectArea ("CLO")
		CLO->(DbSetOrder (1))
	endif

	DbSelectArea ("SX6")
	SX6->(DbSetOrder (1))
	If (SX6->(DbSeek (cFilant+"MV_SUBTRI")))
		Do While !SX6->(Eof ()) .And. cFilant==SX6->X6_FIL .And. "MV_SUBTRI" $ SX6->X6_VAR
			If !Empty(SX6->X6_CONTEUD)
				clSubTri += "/"+AllTrim(SX6->X6_CONTEUD)
			EndIf
			SX6->(DbSkip ())
		EndDo
	ElseIf (SX6->(DbSeek (SPACE(LEN(SX6->X6_FIL))+"MV_SUBTRI")))
		Do While !SX6->(Eof ()) .And. "MV_SUBTRI" $ SX6->X6_VAR
			If !Empty(SX6->X6_CONTEUD)
				clSubTri += "/"+AllTrim(SX6->X6_CONTEUD)
			EndIf
			SX6->(DbSkip ())
		EndDo
	EndIf
	If lAliasCLO .and. (CLO->(DbSeek(xFilial('CLO'))))
		Do While !CLO->(Eof ()) .and. CLO->CLO_FILIAL == xFilial('CLO')
				clSubTri += "/"+AllTrim(CLO->(CLO_UF+CLO_INSCR))
			CLO->(DbSkip ())
		EndDo 
	endif 

	if !Empty(clSubTri)
		clSubTri := StrTran(clSubTri," ","")
		While At("//",clSubTri) > 0
			clSubTri := StrTran(clSubTri,"//","/")
		EndDo
		if SubStr(AllTrim(clSubTri),1,1) == "/"
			clSubTri := SubStr(clSubTri,2,Len(clSubTri))
		endif
		alSubTri := Separa( clSubTri, "/" )
	EndIf

	RestArea(alGetSX6)

Return alSubTri

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado IN no SQL

@author Henrique Pereira
@since 14/02/2020
@version 1.0
@return 

/*/ 
//-------------------------------------------------------------------

Static Function RetFil(aFil, cKeyCent)
	Local cRetFils	as Character
	Local nX		as Numeric

	cRetFils	:= ""
	nX			:= 0 
 
	For nX := 1 to Len(aFil) 
		if aFil[nX][1] == _MARK_OK_  .and. aFil[nX][4] == cKeyCent 
			If !Empty(cRetFils)
				cRetFils += " , '" + alltrim(aFil[nX][2]) + "'"
			Else
				cRetFils += "'" + alltrim(aFil[nX][2]) + "'"  
			EndIf 
		endif
	Next nX

Return cRetFils

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Programa  ³Grupo1900 ³ Autor ³Caio Oliveira               ³ 20.12.2011 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Descri‡ao ³         GERACAO DO REGISTRO 1900 E FILHOS                         ³±± 
±±³          ³REGISTRO 1910 - PERIODO DA APURACAO DO ICMS                        ³±± 
±±³          ³REGISTRO 1920 - APURACAO DE ICMS - OPERACOES PROPRIAS              ³±± 
±±³          ³REGISTRO 1921 - AJUSTES/BENEFICIOS/INCENTIVO DA APURACAO DE ICMS   ³±± 
±±³          ³REGISTRO 1922 - INFORMACOES ADICIONAIS DOS AJUSTES DE APURACAO DO  ³±± 
±±³          ³                ICMS                                               ³±± 
±±³          ³REGISTRO 1923 - INF. ADICIONAIS DA APURACAO DO ICMS                ³±± 
±±³          ³REGISTRO 1926 - OBRIGACOES DO ICMS A RECOLHER - OPERACOES PROPRIAS ³±±
±±³          ³                                                                   ³±±
±±³          ³Funcao utilizada para montar a estrutura dos registros acima e     ³±±
±±³          ³  gravar no TRB para geracao do TXT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lTabComp - Flag de existencia das tabelas complementares           ³±±
±±³          ³aWizard  - Informacoes do assistente da rotina                     ³±±
±±³          ³cFilDe   - Filial inicial para processament multifilial            ³±±
±±³          ³cFilAte  - Filial final para processament multifilial              ³±±
±±³          ³cAlias   - Alias do TRB                                            ³±±
±±³          ³cMVEstado- Conteudo do parametro MV_ESTADO                         ³±±
±±³          ³lTop     - Flag para identificar ambiente TOP                      ³±±
±±³          |oProcess -> Objeto da nova barra de progressao                     ³±±
±±³			 |aLanCDA  - Array com informacoes da tabela CDA.                    ³±±
±±³			 |aLanCDA2 - Array com informacoes da tabela CDA (Totalizador).		 ³±±
±±³			 |aLiv1900 - Contém os números de Livro para buscar a SubApuração	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Grupo1900(lTabComp,aWizard,cFilDe,cFilAte,cAlias,cMVEstado,lTop,oProcess,aLanCDA,aLanCDA2,aLiv1900,lOldLan,lExtratTAF,aRegsT020,aReg0190,aReg0220,aReg0200,aReg0150)

Local aReg1900	 := {}
Local aReg1910	 := {}
Local aReg1920	 := {}
Local aReg1921	 := {}
Local aReg1922	 := {}
Local aReg1923	 := {}
Local aReg1925	 := {}
Local aReg1926	 := {}
Local aApICM  	 := {}
Local cICMGNR	 :=	""
Local cMvSFUfGnr :=	aSPDSX6[MV_SFUFGNR]
Local cCodRec	 :=	""
Local dDataDe	 :=	''
Local dDataAte	 :=	''
Local lSeekCDH	 := .F.
Local nYY		 := 0
Local nPos		 := 0
Local nPos1900	 := 0
Local nPos1920	 := 0 
Local nPos1925	 := 0
Local nPeriodo	 := 1
Local nApuracao	 := 3
Local nZZ		 := 0
Local nCnt		 := 1
Local cPeriodo   := ''

Default lExtratTAF := .F.
Default aRegsT020  := {}

aSort(aLiv1900,,,{|x, y| x[1]<y[1]})

dDataDe	 :=	aWizard[1][3]
dDataAte :=	aWizard[1][4]
cPeriodo :=	StrZero(Year(dDataDe),4)+StrZero(Month(dDataAte),2)

For nYY := 1 to Len(aLiv1900)
	lSeekCDH := .F.
	aApICM	 := {}
	cICMGNR	 := ""
	If lTabComp //Flag de existencia das tabelas complementares do SPED
		lSeekCDH :=	AP1900ICM(cFilDe,cFilAte,nApuracao,nPeriodo,aLiv1900[nYY][2],"IC",cAlias,dDataDe,dDataAte,cMVEstado,lTop,,aLanCDA,@aLanCDA2, {aLiv1900[nYY][1],aLiv1900[nYY][3]},@aReg1900,@aReg1910,@aReg1920,@aReg1921,@aReg1922,@aReg1923,@aReg1926,lOldLan,,,lExtratTAF,aWizard,@aReg0190,@aReg0220,@aReg0200,@aReg0150) //function
	EndIf
	If !lSeekCDH
		//Leio o arquivo de apuracao ICMS
		aApICM := FisApur("IC",Year(dDataAte),Month(dDataAte),nApuracao,nPeriodo,aLiv1900[nYY][2],.F.,{},1,.F.,"") //function
		If Len(aApICM) > 0
			//GRAVACAO DO REGISTRO 1900 - INDICAÇÃO DA SUB-APURACAO
			aAdd(aReg1900, {})
			nPos1900 :=	Len (aReg1900)
			aAdd(aReg1900[nPos1900], "1900")			//01 - REG
			aAdd(aReg1900[nPos1900], aLiv1900[nYY][1])	//02 - IND_APUR_ICM
			aAdd(aReg1900[nPos1900], aLiv1900[nYY][3])	//03 - DESCR_COMPL_OUT_APUR

			//GRAVACAO DO REGISTRO 1910 - PERIODO DA APURACAO DO ICMS
			aAdd(aReg1910, {})
			nPos :=	Len (aReg1910)
			aAdd(aReg1910[nPos], nPos1900)	//01 - REG
			aAdd(aReg1910[nPos], "1910")	//01 - REG
			aAdd(aReg1910[nPos], dDataDe)	//02 - DT_INI
			aAdd(aReg1910[nPos], dDataAte)	//03 - DT_FIN

			aAdd(aReg1920, {nPos,"1920",0,0,0,0,0,0,0,0,0,0,0,0})
			nPos1920 := Len(aReg1920)

			aReg1920[nPos1920][3]  := Iif(aScan(aApICM, {|a| a[1]=="001"}   )<>0, aApICM[aScan(aApICM, {|a| a[1]=="001"   })][3],0)
			aReg1920[nPos1920][4]  := Iif(aScan(aApICM, {|a| a[4]=="002.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="002.00"})][3],0)
			aReg1920[nPos1920][5]  := Iif(aScan(aApICM, {|a| a[4]=="003.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="003.00"})][3],0)
			aReg1920[nPos1920][6]  := Iif(aScan(aApICM, {|a| a[1]=="005"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="005"   })][3],0)
			aReg1920[nPos1920][7]  := Iif(aScan(aApICM, {|a| a[4]=="006.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="006.00"})][3],0)
			aReg1920[nPos1920][8]  := Iif(aScan(aApICM, {|a| a[4]=="007.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="007.00"})][3],0)
			aReg1920[nPos1920][9]  := Iif(aScan(aApICM, {|a| a[1]=="009"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="009"   })][3],0)
			aReg1920[nPos1920][10] := Iif(aScan(aApICM, {|a| a[1]=="011"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="011"   })][3],0)
			aReg1920[nPos1920][11] := Iif(aScan(aApICM, {|a| a[4]=="012.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="012.00"})][3],0)
			aReg1920[nPos1920][12] := Iif(aScan(aApICM, {|a| a[1]=="013"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="013"   })][3],0)
			aReg1920[nPos1920][13] := Iif(aScan(aApICM, {|a| a[1]=="014"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="014"   })][3],0)
			aReg1920[nPos1920][14] := Iif(aScan(aApICM, {|a| a[4]=="900.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="900.00"})][3],0)

			If aReg1920[nPos1920][13] > 0
				cICMGNR := Iif(aScan(aApICM,{|a| a[1]=="GNR" .And. AllTrim(a[4])==AllTrim(aReg1920[nPos1920][13])})<>0, aApICM[aScan(aApICM, {|a| a[1]=="GNR" .And. AllTrim(a[4])==AllTrim(aReg1920[nPos1920][13])})][2],"")
				cICMGNR := SubStr(cICMGNR,1,At("/",cICMGNR)-3)
				//Verifico se a UF de Recolhimento do ICMS Proprio deve apresentar o campo 05 - COD_REC
				//considerando o Codigo da Receita + Classe de Vencimento ( F6_CODREC + F6_CLAVENC )
				cCodRec	:= Iif( cMvEstado $ cMvSFUfGnr , "SF6->( Alltrim( F6_CODREC ) + Alltrim( F6_CLAVENC ) )" , "SF6->F6_CODREC" )
				//Posicionamento da tabela SF6, conforme dados do .IC0
				If SPEDSeek("SF6",1,aSPDFil[PFIL_SF6]+cMVESTADO+cICMGNR) //function
					aAdd(aReg1926, {})
					nPos := Len(aReg1926)
					aAdd(aReg1926[nPos], nPos1920 )		 //01 - RELACIONAMENTO
					aAdd(aReg1926[nPos], "1926")		 //01 - REG
					aAdd(aReg1926[nPos], Iif(aSPDSX3[FP_F6_COBREC] .And. !Empty(SF6->F6_COBREC),SF6->F6_COBREC,"000")) //02 - COD_OR
					aAdd(aReg1926[nPos], SF6->F6_VALOR)	 //03 - VL_OR
					aAdd(aReg1926[nPos], SF6->F6_DTVENC) //04 - DT_VCTO
					aAdd(aReg1926[nPos], &( cCodRec ))	 //05 - COD_REC
					aAdd(aReg1926[nPos], "")			 //06 - NUM_PROC
					aAdd(aReg1926[nPos], "")			 //07 - IND_PROC
					aAdd(aReg1926[nPos], "")			 //08 - PROC
					aAdd(aReg1926[nPos], SF6->F6_OBSERV) //09 - TXT_COMPL
					If cVersao >= "004"
						aAdd(aReg1926[nPos],SF6->(StrZero(F6_MESREF,2)+cValToChar(F6_ANOREF)))//10 - MES_REF
					EndIf
					//Para o extrator fiscal preciso levar o número e o Tipo (0=Doc. Arrecad. 1= GNRE) da GNRE para amarrar no TAF
					if lExtratTAF
						aAdd(aReg1926[nPos], SF6->F6_NUMERO) //11-Numero da Guia
						aAdd(aReg1926[nPos], IIF(Empty(SF6->F6_NUMERO),"",IIF(SF6->F6_TIPOIMP=="0","0","1")))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	//Grava no array do extrator
	If lExtratTAF
		If(Len(aReg1920) > 0)
			aAdd(aReg1920[1], aReg1900[1][2])
			aAdd(aReg1920[1], aReg1900[1][3])
			aAdd(aRegsT020	,{ aReg1920,;
								aReg1921,;
								aReg1922,;
								aReg1923,;
								aReg1925,;
								aReg1926} )
			//Limpo os arrays
			aReg1920 := {}
			aReg1921 := {}
			aReg1922 := {}
			aReg1923 := {}
			aReg1925 := {}
			aReg1926 := {}
		EndIf
	EndIf
Next nYY

If Len(aReg1900) > 0
	If aSPDSX2[AI_CDV] .OR. lExtratTAF
		dbSelectArea("CDV")
	    CDV->(DbSetOrder(2))
	    For nYY := 1 To Len(aLiv1900)
			CDV->(MsSeek(aSPDFil[PFIL_CDV]+cPeriodo+aLiv1900[nYY][2]))
			While !CDV->(Eof()) .And. CDV->CDV_FILIAL==aSPDFil[PFIL_CDV] .And. CDV->CDV_PERIOD==cPeriodo .And. CDV->CDV_LIVRO == aLiv1900[nYY][2]
				cDados:= "NF: " + Alltrim(CDV->CDV_DOC) + " SERIE: " + Alltrim(CDV->CDV_SERIE) + " CLI/FOR: " + Alltrim(CDV->CDV_CLIFOR) + " LOJA: " + Alltrim(CDV->CDV_LOJA)
                nZZ += 1
				aAdd( aReg1925, {})
				nPos1925 :=Len(aReg1925)
				aAdd(aReg1925[nPos1925], nZZ )
				aAdd(aReg1925[nPos1925], "1925")			//01 - REG
				aAdd(aReg1925[nPos1925], CDV->CDV_CODAJU)	//02 - COD_INF_ADIC
				aAdd(aReg1925[nPos1925], CDV->CDV_VALOR)	//03 - VL_INF_ADIC
				aAdd(aReg1925[nPos1925], AllTrim(CDV->CDV_DESCR)+" "+ cDados)	//04 - DESCR_COMPL_AJ
				//Grava no array do extrator
				If lExtratTAF
					//sobreponhe o array aRegs1925 usado no extrator
					aAdd(aRegsT020[nCnt][5], aReg1925[nPos1925])
				EndIf
				CDV->(DbSkip())
			EndDo
			If !Empty(aLiv1900[nYY][1]) .AND. lExtratTAF
				nCnt++
			EndIf
		Next nYY
	Endif
	SPEDRegs(cAlias,{aReg1900,aReg1910,aReg1920,aReg1921,{aReg1925,3},{aReg1926,3},{aReg1922,4},{aReg1923,4}}) //function
EndIf

Return Nil
