#INCLUDE "PROTHEUS.CH"
#INCLUDE "VDFXFUN.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFINITFUN()
Função executada na entrada do módulo SIGAVDF
@return		.T.
@author	    Fabricio Amaro
@since		11/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFINITFUN()
	If !fUsaGFP()
		MsgAlert(STR0036) //"Para utilizar o módulo Vida Funcional corretamente, deverá utilizar também o módulo Gestão de Folha Pública (parâmetro MV_SIGAGFP)."
	EndIf
	If !CompTabVDF()
		Final(STR0037) //"Realize os ajustes solicitados na tela anterior."
	EndIf
Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} CompTabVDF()
Função que compara o compartilhamento das tabelas
@return		lRet
@author	    Fabricio Amaro
@since		11/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function CompTabVDF()
Local cEnt		:= chr(13) + chr(10)
Local aCompart	:= {}
Local aArea		:= GetArea()
Local cMsgInfo	:= ""
Local lRet		:= .T.

	//VERIFICA COMPARTILHAMENTO ENTRE AS TABELAS REV/SRJ/SQ3/SQG/REW/RI7/REX/REY/REZ/RI5/RI6
	aAdd(aCompart,{"REV",FWModeAccess( "REV", 3) + FWModeAccess( "REV", 2) + FWModeAccess( "REV", 1)})	//01 - Requisitos Gerais
	aAdd(aCompart,{"SRJ",FWModeAccess( "SRJ", 3) + FWModeAccess( "SRJ", 2) + FWModeAccess( "SRJ", 1)})	//02 - Funções
	aAdd(aCompart,{"SQ3",FWModeAccess( "SQ3", 3) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 1)})	//03 - Cargos
	aAdd(aCompart,{"SQG",FWModeAccess( "SQG", 3) + FWModeAccess( "SQG", 2) + FWModeAccess( "SQG", 1)})	//04 - Candidatos
	aAdd(aCompart,{"REW",FWModeAccess( "REW", 3) + FWModeAccess( "REW", 2) + FWModeAccess( "REW", 1)})	//05 - Concursos
	aAdd(aCompart,{"RI7",FWModeAccess( "RI7", 3) + FWModeAccess( "RI7", 2) + FWModeAccess( "RI7", 1)})	//06 - Funções por Concurso
	aAdd(aCompart,{"REX",FWModeAccess( "REX", 3) + FWModeAccess( "REX", 2) + FWModeAccess( "REX", 1)})	//07 - Requisitos por Função por Concurso
	aAdd(aCompart,{"REY",FWModeAccess( "REY", 3) + FWModeAccess( "REY", 2) + FWModeAccess( "REY", 1)})	//08 - Concursos por Candidato
	aAdd(aCompart,{"REZ",FWModeAccess( "REZ", 3) + FWModeAccess( "REZ", 2) + FWModeAccess( "REZ", 1)})	//09 - Requisitos por Função por Concurso por Candidato
	aAdd(aCompart,{"RI5",FWModeAccess( "RI5", 3) + FWModeAccess( "RI5", 2) + FWModeAccess( "RI5", 1)})	//10 - Atos e Portarias - Cabeçalho
	aAdd(aCompart,{"RI6",FWModeAccess( "RI6", 3) + FWModeAccess( "RI6", 2) + FWModeAccess( "RI6", 1)})	//11 - Atos e Portarias - Itens
	aAdd(aCompart,{"SQL",FWModeAccess( "SQL", 3) + FWModeAccess( "SQL", 2) + FWModeAccess( "SQL", 1)})	//12 - Histórico Profissional do Candidato
	aAdd(aCompart,{"SQM",FWModeAccess( "SQM", 3) + FWModeAccess( "SQM", 2) + FWModeAccess( "SQM", 1)})	//13 - Cursos do Candidato
	aAdd(aCompart,{"SQI",FWModeAccess( "SQI", 3) + FWModeAccess( "SQI", 2) + FWModeAccess( "SQI", 1)})	//14 - Qualificações do Candidato
	aAdd(aCompart,{"SQR",FWModeAccess( "SQR", 3) + FWModeAccess( "SQR", 2) + FWModeAccess( "SQR", 1)})	//15 - Avaliações do Candidato

	If aCompart[4,2] > aCompart[5,2] .OR. aCompart[12,2] > aCompart[5,2] .OR. aCompart[13,2] > aCompart[5,2] .OR. aCompart[14,2] > aCompart[5,2] .OR. aCompart[15,2] > aCompart[5,2]
		// se o compartilhamento da SQG estiver mais compartilhado que a REW
		//O cadastro de Candidatos (SQG, SQL, SQM, SQI, SQR) deve possuir nível de compartilhamento igual ou maior (mais compartilhado) que o cadastro de Concursos (REW).
		cMsgInfo := OemToAnsi(STR0043) + cEnt
		cMsgInfo += aCompart[04,1] +" - "+ aCompart[04,2] + " - " + OemToAnsi(STR0053) + cEnt //"Cadastro de Candidatos"
		cMsgInfo += aCompart[12,1] +" - "+ aCompart[12,2] + " - " + OemToAnsi(STR0054) + cEnt //"Histórico Profissional do Candidato"
		cMsgInfo += aCompart[13,1] +" - "+ aCompart[13,2] + " - " + OemToAnsi(STR0055) + cEnt //"Cursos do Candidato"
		cMsgInfo += aCompart[14,1] +" - "+ aCompart[14,2] + " - " + OemToAnsi(STR0056) + cEnt //"Qualificações do Candidato"
		cMsgInfo += aCompart[15,1] +" - "+ aCompart[15,2] + " - " + OemToAnsi(STR0057) + cEnt //"Avaliações do Candidato"
		cMsgInfo += aCompart[05,1] +" - "+ aCompart[05,2] + " - " + OemToAnsi(STR0046) + cEnt + cEnt
		lRet := .F.
	EndIf

	If aCompart[1,2] > aCompart[5,2] // se o compartilhamento da REV estiver mais compartilhado que a REW
		//O cadastro de Requisitos (REV) deve possuir nível de compartilhamento igual ou maior (mais compartilhado) que o cadastro de Concursos (REW).
		cMsgInfo += OemToAnsi(STR0044) + cEnt
		cMsgInfo += aCompart[1,1] +" - "+ aCompart[1,2] + cEnt
		cMsgInfo += aCompart[5,1] +" - "+ aCompart[5,2] + cEnt + cEnt
		lRet := .F.
	EndIf

	If  !(aCompart[5,2] == aCompart[6,2]) .OR. !(aCompart[5,2] == aCompart[7,2]) .OR. !(aCompart[5,2] == aCompart[8,2]) .OR.;
		!(aCompart[5,2] == aCompart[9,2])
		//As tabelas envolvidas no processo de Concursos devem possuir o mesmo nível de compartilhamento.
		//Realize a revisão desta configuração nas tabelas a seguir:
		cMsgInfo += OemToAnsi(STR0045)+ cEnt
		cMsgInfo += aCompart[05,1] +" - "+ aCompart[05,2] + " - " + OemToAnsi(STR0046) + cEnt //Cadastro de Concursos
		cMsgInfo += aCompart[06,1] +" - "+ aCompart[06,2] + " - " + OemToAnsi(STR0047) + cEnt //Cadastro de Funções por Concurso
		cMsgInfo += aCompart[07,1] +" - "+ aCompart[07,2] + " - " + OemToAnsi(STR0048) + cEnt //Requisitos por Função por Concurso
		cMsgInfo += aCompart[08,1] +" - "+ aCompart[08,2] + " - " + OemToAnsi(STR0049) + cEnt //Cadastro de Concursos por Candidato
		cMsgInfo += aCompart[09,1] +" - "+ aCompart[09,2] + " - " + OemToAnsi(STR0050) + cEnt //Requisitos por Função por Concurso por Candidato
		lRet := .F.
	EndIf

	If !lRet
		cMsgInfo += OemToAnsi(STR0020)
		MsgAlert(cMsgInfo, OemToAnsi(STR0021))
	EndIf

RestArea(aArea)

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} FPD_S106()
Codição do Gatilho FSALDODIA para ativar seu disparo.
@sample
@param		aParametro - Função
@return		L
@author	    Everson S P	Junior
@since		28/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function FPD_S106()
Local lRet   := .F.
Local nX     := 0
Local oModel
Local oMdlRIA
Local cPD
Local dDTBAS
Local dDTFIM

If !IsInCallStack("gp051Mnt")
	oModel := FWModelActive()
	oMdlRIA:= oModel:GetModel('RIADETAIL')
	cPD    := oModel:GetValue('SRFDETAIL', 'RF_PD')
	dDTBAS := oModel:GetValue('SRFDETAIL', 'RF_DATABAS')
	dDTFIM := oModel:GetValue('SRFDETAIL', 'RF_DATAFIM')


	If ALLTRIM(cPD) == AllTRIM(FDESCRCC("S106",cPD,057,003,057,003))
		If !Empty(dDTBAS) .AND. !Empty(dDTFIM)
			lRet := .T.
		EndIf
	EndIf
	If !Empty(dDTBAS)
		For nX:= 1 To oMdlRIA:Length()
			oMdlRIA:GoLine(nX)
			oModel:SetValue( 'RIADETAIL','RIA_DTINPA',dDTBAS)
		Next
	EndIf
EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} WHEN_S106()
@sample
@param		aParametro - Função
@return		N
@author	    Everson S P	Junior
@since		16/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function WHEN_S106()
Local nInde   := 0
Local lRet   := .T.
Local oModel
Local cPD

If !IsInCallStack("gp051Mnt")
	oModel := FWModelActive()
	cPD    := oModel:GetValue('SRFDETAIL', 'RF_PD')

	nInde:= VAL(AllTRIM(FDESCRCC("S106",cPD,057,003,053,001)))

	lRet := IIF(nInde == 1,.T.,.F.)
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} RI6NOMERLC()
Função específica para o Inic. Padrão.
@sample
@param		aParametro - cRet
@return		C
@author	    Everson S P	Junior
@since		10/09/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function RI6NOMERLC()
	cRet  := ''

	cRet := Iif(Type('INCLUI') <> 'U' .AND. INCLUI,"",Iif(!Empty(RI6_FILMAT+RI6_MAT),Posicione("SRA",1,RI6->(RI6_FILMAT+RI6_MAT),"RA_NOME"),;
	Posicione("SQG",3,xFilial("SQG")+RI6->RI6_CPF,"QG_NOME")))// Função específica para o Inic. Padrão.

Return cRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFTPDOC()
Valida o tipo de documento, de acordo com o fonte que chamou.
@sample
@param		aParametro - 	[1] - Nome do Fonte
						  	[2]- Tipo do documento
@return	.T. ou .F.
@author	Nivia Ferreira
@since		20/09/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFTPDOC(aParametro)

	Local aArea   	:= GetArea()
	Local cQuery  	:= ''                 	// Variavel da query
	Local xRet		:= .T.
    Local nZ        := 0

	Private lSubsTp 	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

	For nZ := 1 to len(aParametro[2])
		If !(LETTERORNUM(substr(aParametro[2],nZ,1))) //verifica se digitado caracter invalido na classificacao
			MsgInfo(STR0001, '')//"Tipo de Documento invalido."
		    xRet := .F.
		    exit
		EndIf
	Next nZ

	If xRet

		If Select("TRB")>0
		   TRB->( dbCloseArea() )
		Endif

		cQuery  += "SELECT "
		If lSubsTp
			cQuery  += " DISTINCT (SUBSTRING(RCC.RCC_CONTEU,1,3)) CODIGO,"
			cQuery  += " SUBSTRING(RCC.RCC_CONTEU,4,30) DESCRI "
		Else
			cQuery  += " DISTINCT (SUBSTR(RCC.RCC_CONTEU,1,3)) CODIGO,"
			cQuery  += " SUBSTR(RCC.RCC_CONTEU,4,30) DESCRI "
		EndIf
		cQuery  += " FROM " + RetSqlName( 'RCC' ) + " RCC "
		cQuery  += " LEFT JOIN " + RetSqlName( 'RCC' ) + " RCC1 ON RCC1.D_E_L_E_T_=' '"
		cQuery  += " AND RCC1.RCC_CODIGO='S101' "
		IF !Empty(aParametro[1])
			cQuery  += " AND RCC1.RCC_CONTEU LIKE('%"+ aParametro[1] +"%')"
		Endif
		cQuery  += " WHERE RCC.RCC_CODIGO='S100' "
		cQuery  += " AND RCC.D_E_L_E_T_=' ' "
		If lSubsTp
			cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,1,3) = SUBSTRING(RCC1.RCC_CONTEU,33,3) "
			cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,1,3) = '"+ aParametro[2] +"'"
		Else
			cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,1,3) = SUBSTR(RCC1.RCC_CONTEU,33,3) "
		    cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,1,3) = '"+ aParametro[2] +"'"
		EndIf
		cQuery  += " Order By CODIGO "

		If Select("TRB") > 0
			TRB->(DbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
		dbSelectArea("TRB")
		If TRB->(EOF())
			MsgInfo(STR0001, '')//'Tipo de Documento invalido.'
		    xRet := .F.
		Endif
		TRB->( dbCloseArea() )

	EndIf

	RestArea( aArea )
Return (xRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFCLASSIF()
Valida a classificação, de acordo com o tipo de documento.
@sample
@param		aParametro - 	[1]- Nome do Fonte
						  	[2]- Tipo do documento
						  	[3]- Categoria do funcionario
						  	[4]- Tipo da classificação

@return	.T. ou .F.

@author	Nivia Ferreira
@since		20/09/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFCLASSIF(aParametro)

	Local aArea   	:= GetArea()
	Local cQuery  	:= ''                 	// Variavel da query
	Local xRet		:= .T.
	Local nZ        := 0

	Private lSubsTp := "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

	For nZ := 1 to len(aParametro[4])
		If !(LETTERORNUM(substr(aParametro[4],nZ,1))) //verifica se digitado caracter invalido na classificacao
			MsgInfo(STR0002, '')//'Classificação invalida.'
		    xRet := .F.
		    exit
		EndIf
	Next nZ

	If xRet

		If Select("TRB")>0
		   TRB->( dbCloseArea() )
		Endif

		cQuery  += "SELECT "
		If lSubsTp
			cQuery  += "DISTINCT (SUBSTRING(RCC.RCC_CONTEU,1,2)) CODIGO,"
			cQuery  += " SUBSTRING(RCC.RCC_CONTEU,3,30) DESCRI "
		Else
			cQuery  += "DISTINCT (SUBSTR(RCC.RCC_CONTEU,1,2)) CODIGO,"
			cQuery  += " SUBSTR(RCC.RCC_CONTEU,3,30) DESCRI "
		EndIf
		cQuery  += " FROM " + RetSqlName( 'RCC' ) + " RCC "
		cQuery  += " WHERE RCC.RCC_CODIGO='S101'"
		cQuery  += " AND RCC.D_E_L_E_T_=' '"
		If aParametro[3] $ '0*1'
		   	If lSubsTp
		   		cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,36,3) ='"+aParametro[2]+"'"
		   		cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,01,2) ='"+aParametro[4]+"'"
		   	Else
		 		cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,36,3) ='"+aParametro[2]+"'"
		        cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,01,2) ='"+aParametro[4]+"'"
		   	EndIf
		Else
			If lSubsTp
				cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,33,3) ='"+aParametro[2]+"'"
		        cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,01,2) ='"+aParametro[4]+"'"
			Else
				cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,33,3) ='"+aParametro[2]+"'"
		        cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,01,2) ='"+aParametro[4]+"'"
			EndIf
		Endif
		cQuery  += " AND RCC_CONTEU LIKE('%"+ aParametro[1] +"%')"
		cQuery  += " Order By CODIGO"

		If Select("TRB") > 0
			TRB->(DbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
		dbSelectArea("TRB")
		If TRB->(EOF())
			MsgInfo(STR0002, '')//'Classificação invalida.'
		    xRet := .F.
		Endif
		TRB->( dbCloseArea() )

	EndIf

	RestArea( aArea )
Return (xRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} INIDATPAG()
Inicializador padrao do campo RIA_DATPAG
será gravada respeitando-se a data de corte do mês (hoje, dia 15)
consultando a tabela RCH campo RCH_DCORTE.
@return		cRet
@author	    Everson S P Junior
@since		23/09/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
/*
Fabricio 20/12/2013
	dData = Data do período que deseja pesquisar
	lVerProx = Indica se deseja ou não verificar o próximo período, caso o próximo esteja fechado ou a data de corte já foi atingida
	cProcesso = Processo do Funcionário
	cRoteiro = Opcional
	dIniPer = Data do Inicio do Período aberto
	Ajustes:
	- Verifica se a data de corte foi atingida
	- Retorna a data do Inicio do Periodo
*/
Function INIDATPAG(dData,lVerProx,cProcesso,cRoteiro,dIniPer)
	Local dRet
	Local aPerAberto  := {}
	Local aPerFechado := {}
	Local aPerTodos   := {}

	Default dData 	  := Date()
	Default lVerProx  := .F.
	Default cProcesso := ""
	Default cRoteiro  := ""
	Default dIniPer   := stod("")

	//-aAdd(aPerAberto, RCH->({RCH_PER, RCH_NUMPAG, RCH_MES, RCH_ANO, RCH_DTINI, RCH_DTFIM, RCH_PROCES, RCH_ROTEIR, RCH_DTPAGO, RCH_DTCORT}))
	fRetPerComp( STRZERO(Month(dData),2)			,;	// Obrigatorio - Mes para localizar as informacoes
						Alltrim(STR(Year(dData)))	,;	// Obrigatorio - Ano para localizar as informacoes
						FwxFilial('RCH')			,;	// Opcional - Filial a Pesquisar
						cProcesso					,;	// Obrigatorio - Filtro por Processo
						cRoteiro					,;	// Opcional - Filtro por Roteiro
						@aPerAberto					,;	// Por Referencia - Array com os periodos Abertos
						@aPerFechado				,;	// Por Referencia - Array com os periodos Fechados
						@aPerTodos    				 ;	// Por Referencia - Array com os periodos Abertos e Fechados em Ordem Crescente
						 )

	If !Empty(aPerAberto)
		dRet  	:= aPerAberto[1][9]
		dIniPer := aPerAberto[1][5] //RCH_DTINI
		//Verifica data de corte
		If dData >= aPerAberto[1][5] .AND. dData <= aPerAberto[1][6] //RCH_DTCORT
			dRet := INIDATPAG( LastDate(aPerAberto[1][6]) +1,.T.,cProcesso,,@dIniPer)
		EndIf
	ElseIf !Empty(aPerFechado)
		If lVerProx
			dRet := INIDATPAG( LastDate(aPerFechado[1][6]) + 1,.T.,cProcesso,,@dIniPer)
		Else
			dRet 	:= aPerFechado[1][9]
			dIniPer := aPerFechado[1][5] //RCH_DTINI
		EndIf
	EndIf

Return dRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} fSaldo_Dia()
Gatilho RF_PD RF_DATABAS + RF_DATAFIM
Tem como Objetivo Gatilhar o campo RF_DIASDIR e RF_DFERVAT
@sample
@param		aParametro - Função
@return		N
@author	    Everson S P	Junior
@since		16/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fSaldo_Dia()
Local nRet   := 0
Local oModel
Local cPD
Local dDTBAS
Local dDTFIM

If !IsInCallStack("gp051Mnt")
	oModel := FWModelActive()
	cPD    := oModel:GetValue('SRFDETAIL', 'RF_PD')
	dDTBAS := oModel:GetValue('SRFDETAIL', 'RF_DATABAS')
	dDTFIM := oModel:GetValue('SRFDETAIL', 'RF_DATAFIM')
	nRet:= (((dDTFIM-dDTBAS)+1)*VAL(AllTRIM(FDESCRCC("S106",cPD,057,003,051,001))))
EndIf
Return nRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} REYWHEN()
Validação When Dos campos da Tabela REY
onde status diferente de M os campos não poderão ser
editados em tela.
@sample REYWHEN()
@param		aParametro - Função
@return		L
@author	    Everson S P
@since		16/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function REYWHEN()
	Local lRet := .F.
	Local lSTATUS := .T.
	Local oModel := FWModelActive()
	Local oModelREY := oModel:GetModel( 'REYDETAIL' )

	If oModelREY:Length() > 0
		If !IsInCallStack("VDFM010")
			lSTATUS := .F.
		EndIf

		If oModel:GetValue('REYDETAIL', 'REY_STATUS') == 'M' .Or. lSTATUS
			lRet := .T.
		EndIF
	EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VdfSRJFIL()
Função para montagem do filtro da Consulta Padrão SRJFIL.
Filtra Filiais de acordo com a Filial do registro de Concursos (REW) posicionado.
@return		cFiltro, caractere, filtro a ser utilizado na consulta (F3)
@author	    esther.viveiro
@since		02/10/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function VdfSRJFIL()
Local cFiltro	:= ''
Local oModel

	If FunName() = "VDFA030" // Funcoes/Requisitos x Concurso
		oModel := FWModelActive()
		If !Empty(xFilial("REW"))
			cFiltro := "xFilial('REW',SM0->M0_CODFIL) == '" + oModel:GetModel("REWMASTER"):GETVALUE("REW_FILIAL")+"'"
		EndIf
	ElseIf IsInCallStack("VDFM040") //Inclui na Folha de Pagto
		cFiltro := "'" + AllTrim(FwFldGet('REY_FILFUN')) + "' $ SM0->M0_CODFIL"
	ElseIf FunName() = "VDFA040" // Candidatos X Concursos
		oModel := FWModelActive()
		If !Empty(xFilial("SQG"))
			cFiltro := "RI7->RI7_FILIAL == '" + oModel:GetModel( 'SQGMASTER' ):GetValue('QG_FILIAL')  + "' .AND. RI7->RI7_CODCON == '" + oModel:GetModel( 'REYDETAIL' ):GetValue('REY_CODCON') + "'"
		EndIf
	ElseIf FunName() == "VDFM010" //Importação Candidatos
		If !Empty(xFilial("REW"))
			cFiltro := 'REW->REW_FILIAL == xFilial("REW",SM0->M0_CODFIL) .AND. '
		EndIf
		cFiltro += "RI7->RI7_CODCON == '" + MV_PAR01 + "'"
	EndIf

	cFiltro := "@#" + cFiltro + "@#"

Return cFiltro


//------------------------------------------------------------------------------
/*/{Protheus.doc} VdfSRJFunc()
Função para montagem do filtro da Consulta Padrão SRJVDF.
Filtra os códigos de Função de acordo com o preenchimento do campo RI7_FILFUN da tabela.
Uso: "VDFA030" - Cadastro Funções/Requisitos por Concurso
@return		cFiltro, caractere, filtro a ser utilizado na consulta (F3)
@author		esther.viveiro
@since		02/10/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function VdfSRJFunc()
Local cFiltro	:= ''
Local cFilFun	:= ''
Local oModel	:= FWModelActive()

	If !Empty(xFilial("SRJ"))
		cFilFun := oModel:GetModel( 'RI7DETAIL' ):GetValue('RI7_FILFUN')
		cFiltro := "SRJ->RJ_FILIAL == '" + cFilFun + "'"
	EndIf
	cFiltro := "@#" + cFiltro + "@#"

Return cFiltro


//------------------------------------------------------------------------------
/*/{Protheus.doc} VdfRI7Func()
Função para montagem do filtro da Consulta Padrão SRJVDF.
Filtra os códigos de Função de acordo com o preenchimento do campo REY_FILFUN da tabela.
Uso: "VDFA040" - Cadastro Concursos por Candidato
@return		cFiltro, caractere, filtro a ser utilizado na consulta (F3)
@author		esther.viveiro
@since		02/10/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function VdfRI7Func()
Local cFiltro	:= ''
Local cFilFun	:= ''
Local oModel	:= FWModelActive()

	If FunName() == "VDFM010" //Importação Candidatos
		If Empty(mv_par02)
			Filtro := "RI7->RI7_CODCON == '" + mv_par01
		Else
			cFiltro := "RI7->RI7_CODCON == '" + mv_par01 + "' .AND. RI7->RI7_FILFUN == '" + xFilial("SRJ",mv_par02) + "'"
		EndIf
	Else
		cFiltro := "RI7->RI7_FILIAL == '" + oModel:GetModel( 'SQGMASTER' ):GetValue('QG_FILIAL') + "' .AND. RI7->RI7_CODCON == '" + oModel:GetModel( 'REYDETAIL' ):GetValue('REY_CODCON') + "'"
		If !Empty(xFilial("SRJ"))
				cFilFun := oModel:GetModel( 'REYDETAIL' ):GetValue('REY_FILFUN')
				cFiltro += " .AND. RI7->RI7_FILFUN == '" + cFilFun + "'"
		EndIf
	EndIf
	cFiltro := "@#" + cFiltro + "@#"

Return cFiltro


//------------------------------------------------------------------------------
/*/{Protheus.doc} fRetFil()
Função para retornar valor da Consulta Padrão SRJFIL
@return		cFilRet, caractere, filial a ser gravada no campo de retorno da Cosulta Padrão SRJFIL
@author		esther.viveiro
@since		08/10/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function fRetFil()
Local cFilRet	:= ''

	If FunName() = "VDFA030" // Funcoes/Requisitos x Concurso
		cFilRet := xFilial("SRJ",SM0->M0_CODFIL)
	ElseIf IsInCallStack("VDFM040") //Inclui na Folha de Pagto
		cFilRet := xFilial("SRA",SM0->M0_CODFIL)
	EndIf

Return cFilRet
