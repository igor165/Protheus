# include "VDFA060.CH"
# INCLUDE "PROTHEUS.CH"
# INCLUDE "FWMBROWSE.CH"
# INCLUDE "FWMVCDEF.CH"
# INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA060
Geracao dos Itens de Atos/Portarias.
@sample 	VDFA060(aParametro)
@param		Fonte que Chamado: VDFM030 - Concurso - Itens Atos/Portarias
			aParametro[1] Fonte 	Fonte que chamou.
			aParametro[2] cConcurso	Concuro que o funcionario participou.
			aParametro[3] cCatFunc	Categoria do Funcionario.

			Fonte que Chamado:GPEA180 - Transferencia
			                 	GPEA010 - Inclusao do Servidor
			                 	VDFM180 - Alteração de Cargos e Subsídios
			aParametro[1] Fonte 	Fonte que chamou.
			aParametro[2] RA_MAT 	Matricula do Funcionario.
			aParametro[3] CatFunc   Categoria do Funcionario.
			aParametro[4] Chave 	Para gravação do Historioco RI6
			aParametro[5] Filial 	Filial do funcionario transferido
			aParametro[6] CPF Do funcionario transferido
			aParametro[7] Data de Efeito
			aParametro[8] Indice da tabela
			aParametro[9] Alias da tabela

			Fonte que Chamado: PONA161 - Troca de Turno
			aParametro[1] Fonte 	Fonte que chamou.
			aParametro[2] RA_MAT 	Matricula do Funcionario.
			aParametro[3] CatFunc   Categoria do Funcionario.
			aParametro[4] Chave 	Para gravação do Historioco RI6
			aParametro[5] Filial 	Filial do funcionario transferido
			aParametro[6] CPF 	Do funcionario transferido
			aParametro[7] Alias da Tabela
			aParametro[8] Data de Efeito
			aParametro[9] Indice da tabela

			Fonte que Chamado: GPEA051 - Dias de Direito  e  GPA240 - Ausências
			aParametro[1] Fonte 	Fonte que chamou.
			aParametro[2] RA_MAT 	Matricula do Funcionario.
			aParametro[3] CatFunc   Categoria do Funcionario.
			aParametro[4] Chave 	Para gravação do Historioco RI6
			aParametro[5] Filial 	Filial do funcionario transferido
			aParametro[6] CPF Do funcionario transferido
			aParametro[7] Data de Efeito
			aParametro[8] Indice da tabela
			aParametro[9] Alias da tabela
			aParametro[10] Data Base Inicio
			aParametro[11] Data Base Fim
			aParametro[12] Data Inicio Gozo ou Direito
			aParametro[13] Data Fim Gozo
			aParametro[14] Dias de Gozo
			aParametro[15] Dias Indenizados
			aParametro[16] Dias Oportunos
			aParametro[17] Filial do Substituto
			aParametro[18] Matricula do Substituto
			aParametro[19] Nome do Substituto
			aParametro[20] Tipo de Dia de Direito
			aParametro[21] Dias Remanescentes
			aParametro[22] Ato/Portaria Anterior
			aParametro[23] Data da Suspensão
			aParametro[24] Descrição do Status da Linha
			aParametro[25] Usando quando vem da rotina GPEA240 para filtrar a query.

@return		lRet, lógico, indica se realizou o processamento com sucesso.
@author		Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFA060(aParametro, lAut)
	Local aArea			:= GetArea()
	Local nS			:= 0
	Local lRet			:= .F.
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
	Private aTab      	:= aParametro
	Private aParanTra	:= aTab
	Private cFonte    	:= aTab[1]
	Private cCatFunc  	:= aTab[3]
	Private cTpPubl		:= ""
	Private cTpdoc    	:= Space(03)
	Private cClass    	:= Space(02)
	Private nAno      	:= Space( TamSX3("RI5_ANO")[1] )
	Private nNumero   	:= Space( TamSX3("RI5_NUMDOC")[1] )
	Private cClassExo  	:= ""
	Private cClassNom  	:= ""
	Private cClassDes  	:= ""
	Private aTabS101	:= {}
	Private cCtlMenu  	:= 'VDFA060'
	Private lSubsTp 	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'
	Private dDtDoc		:= CtoD("  /  /  ")

	DEFAULT lAut := .F.

	//Tratamento de acesso a Dados Sensíveis
	If lBlqAcesso
		//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Return
	EndIf

	//Busca na S101 os enquadramentos das classificacoes
	fCarrTab( @aTabS101, "S101", Nil, .T.)
	For nS := 1 to len(aTabS101)
		IF LEN(aTabS101[nS]) >= 11
			If aTabS101[nS,11] $ '4/5' 			//4-Exoneracao 5-Tornar sem Efeito
				cClassExo += aTabS101[nS,5]+'/'
			ElseIf aTabS101[nS,11] $ '1/2'		//1-Nomeacao 2-Credenciamento de Estagiario
				cClassNom += aTabS101[nS,5]+'/'
			ElseIf aTabS101[nS,11] $ '3'			//3-Designacao
				cClassDes += aTabS101[nS,5]+'/'
			EndIf
		ENDIF
	Next nS

	If aTab[1]== "GPEA240"
	    cTpPubl := AllTrim(StrTran(aParametro[25],"/","','"))
	EndIf

	If Type("aTipoDoc") == "U"
	    Private aTipoDoc	:= {}
	EndIf

	If aTab[1]== "VDFM030" 			//Concurso - Itens Atos/Portarias
	   lRet := VD060SELEC()
	Endif

	If aTab[1]== "PONA161" 			//Troca de Turno/Jornada
	   lRet := VD060PO161()
	Else
       If aTab[1]!= "VDFM030"       //Nao sendo Concurso - Itens Atos/Portarias
    	  lRet := VD060GPE(lAut)
       EndIf
	Endif

	MBrChgLoop(.F.)

	RestArea( aArea )
Return (lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD060SELEC
Geracao dos Itens de Atos/Portarias.
@sample 	VD060SELEC()
@return	.t. ou .f.
@author	Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD060SELEC()
	Local lRet    	:= .F.
	Local nOpc    	:= 0
	Local cQuery  	:= ''
	Local bOk     	:= {|| If(ValidaData(), (lRet := .T.,oDlg:End()),)}
	Local bCancel 	:= {||oDlg:End()}
	Local cTitcab 	:= STR0009// 'Geração dos Itens de Atos/Portarias '
	Local cBlqCV	:= SuperGetMv("MV_BLQCV",,"1")
	Local lActRsp	:= SQG->(ColumnPos("QG_ACTRSP")) > 0
	Local oDlg
	Local oData
	Local oGet1
	Local oGet2
	Local oGet3

	Private dPosse  := ctod("  /  /  ")
	Private dNomeac := ctod("  /  /  ")
	Private cFuncao := ""
	Private cConcurso:= aTab[2]
	Private lPosse  := .F.
	Private lNomeac := .F.
	Private cTitulo := STR0013 //"Data"
	Private oMark

	cFuncao 	:= Space( TamSX3("REX_CODFUN")[1] )
	cTpdoc  	:= Space(03)
	cClass  	:= Space(02)
	cFilFun		:= SPACE(FWGetTamFilial)
		//Se chamado pelo Concurso
	Begin Sequence

		DEFINE MSDIALOG oDlg TITLE STR0009 FROM 9,0 TO 24,60 OF oMainWnd

			@ 20,005 SAY STR0014 PIXEL //"CONCURSO: "
			@ 20,052 SAY cConcurso  +" - " + Alltrim(POSICIONE("REW",1,FWXFILIAL("REW")+cConcurso ,"REW_DESCRI")) PIXEL

			@ 33,005 SAY STR0040 OF oDlg PIXEL //"Filial da Função:"
			@ 33,052 MSGET oGet4 VAR cFilFun Valid (ExistCpo("SM0", cEmpAnt + cFilFun)) F3 "SM0" SIZE 45,8 OF oDlg PIXEL HASBUTTON
			@ 33,110 MSGET Alltrim(POSICIONE("SM0",1,cEmpAnt+cFilFun,"M0_NOMECOM")) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

			@ 46,005 SAY STR0015 OF oDlg PIXEL //"Função:"
			@ 46,052 MSGET oGet1 VAR cFuncao  PICTURE "@!" Valid(VDFFUNCAO({cConcurso ,cFuncao, cFilFun})) F3 "RI7" SIZE 45,8 OF oDlg PIXEL HASBUTTON
			@ 46,110 MSGET Alltrim(POSICIONE("SRJ",1,XFILIAL("SRJ",cFilFun)+cFuncao,"RJ_DESC")) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

			@ 59,005 SAY STR0016 PIXEL //"Tipo Doc:"
			@ 59,052 MSGET oGet2 VAR cTpdoc   PICTURE "@!" Valid (VDFTPDOC({aParanTra[1],cTpdoc})) F3 "S100" SIZE 45,8 OF oDlg PIXEL HASBUTTON
			@ 59,110 MSGET Alltrim(fDescRCC("S100",cTpdoc,1,3,34,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

			@ 72,005 SAY  STR0017 PIXEL //"Classificação:"
			@ 72,052 MSGET oGet3 VAR cClass   PICTURE "@!" VALID VDF60VLCSF() F3 "S101" SIZE 45,8 OF oDlg PIXEL HASBUTTON
			@ 72,110 MSGET Alltrim(fDescRCC("S101",cClass,1,2,03,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

			@ 85,005 SAY cTitulo PIXEL
			@ 85,052 MSGET oData VAR dNomeac  PICTURE "@D" Valid VDF60VLDAT("1")F3 SIZE 45,8 OF oDlg PIXEL HASBUTTON WHEN lNomeac

			@ 98,005 SAY  STR0018 PIXEL //"Data Posse:"
			@ 98,052 MSGET oData VAR dPosse   PICTURE "@D" VALID VDF60VLDAT("2") F3 SIZE 45,8 OF oDlg PIXEL HASBUTTON  WHEN lPosse


		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

	End Sequence

	If lRet //CHAMA MVC - FWMBrowse

		DbSelectArea("REY")
		DbSetOrder(2)
		oMark := FWMarkBrowse():New()
		oMark:SetAlias('REY')
		oMark:SetOnlyFields( { 'REY_CPF', 'REY_NOME', 'REY_CLASSI', 'REY_SITUAC' } )
		oMark:SetSemaphore(.T.)
		oMark:SetDescription(STR0001+ cConcurso  +"-"+Alltrim(REW->REW_DESCRI)+ ;//'Seleção de Candidatos do Concurso: '
							 If(Empty(xFilial('SRJ')),'',"   /   " + STR0040 + " " + xFilial('SRJ',cFilFun) + "  ") + ;
		                     STR0019+cFuncao+"-"+ Alltrim(SRJ->RJ_DESC)) //'   Função: '
		oMark:SetFieldMark( 'REY_OK' )
		oMark:SetAllMark( { || oMark:AllMark() } )
		oMark:AddLegend( "REY_SITUAC=='1' .And. Empty(REY_NOMEAC) .And. Empty(REY_EXONER)  ", "GREEN"  , STR0029) //"Aprovado"
		oMark:AddLegend( "REY_SITUAC=='2' .And. Empty(REY_NOMEAC) .And. Empty(REY_EXONER)  ", "YELLOW" , STR0030 ) //"Classificado"
		oMark:AddLegend( "!Empty(REY_NOMEAC).And. Empty(REY_EXONER)  ", "BLUE"   , STR0031) //"Nomeado"
		oMark:AddLegend( "!Empty(REY_EXONER) ", "RED"    , STR0032 ) //"Exonerado"
		oMark:SetFilterDefault( "REY_SITUAC $'1*2' .And. REY_CODCON==cConcurso  .And. REY_FILFUN==xFilial('SRJ',cFilFun) .AND. REY_CODFUN==cFuncao" )
		If lActRsp
			oMark:AddFilter(STR0050, "REY_CPF = QG_CIC AND QG_ACTRSP <> '1'", .T., .T., 'SQG') //"Consentimento do Responsável"
		EndIf
		If cBlqCV == "2"
			oMark:AddFilter(STR0049, "REY_CPF = QG_CIC AND (QG_MAT <> '' OR QG_ACEITE = '2')", .T., .T., 'SQG') //"Consentimento do Candidato"
		EndIf

		oMark:Activate()
	Endif

Return (lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF60VLCSF
Valida a classificação para habilitar ou nao data.
@sample 	VDF60VLCSF()
@return	V ou F
@author	Nivia Ferreira
@since		14/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF60VLCSF()
	Local xRet := .T.

	If xRet:= VDFCLASSIF({aParanTra[1],cTpdoc,cCatFunc,cClass})
		If  (cClass $ cClassExo) //Exoneracao e Tornar sem Efeito
	   		lPosse := .F.
	   		lNomeac:= .T.
	   		cTitulo:= STR0010//"Data Exoneração:"
		ElseIf cClass $ cClassNom //Nomeaçao  - Designação - Estagiario
	   		lPosse := .T.
	   		lNomeac:= .T.
	   		cTitulo:= STR0011//"Data Nomeação:"
	   	Endif
	Endif
Return (xRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFFUNCAO
Valida a funcao.
@sample 	VDFFUNCAO(aParametro)
@param		aParametro - 	[1]- Codigo do concurso
						  	[2]- Funcao
@return		V ou F
@author		Nivia Ferreira
@since		20/09/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFFUNCAO(aParametro)
	Local xRet := .T.
	DbSelectArea("REX")
	DbSetOrder(1) //REX_FILIAL+REX_CODCON+REX_FILFUN+REX_CODFUN+REX_CODREQ
	If (!DbSeek(FWXFILIAL("REX",RI7->RI7_FILIAL)+aParametro[1]+xFilial("SRJ",aParametro[3])+aParametro[2]))
	    MsgInfo(STR0002, '')//'Codigo da função invalido.'
	    xRet := .F.
	Endif
Return (xRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF60VLDAT
Valida a data.
@sample		VDF60VLDAT()
@return		V ou F
@author		Nivia Ferreira
@since		23/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF60VLDAT(Tipo)
	Local lRet := .T.
	If Tipo== '1' .And. dNomeac < date()
	   If (cClass $ cClassExo) //Exoneracao e Tornar sem Efeito
	      MsgInfo(STR0003, '')//'Data da exoneração invalida.'
	   Else
	      MsgInfo(STR0004, '')   //'Data da nomeação invalida.'
	   Endif
	   lRet := .F.
	ElseIf Tipo== '2' .And. dNomeac > dPosse
	   MsgInfo(STR0012)//"Data da nomeação maior que a data da posse."
	   lRet := .F.
	Endif
Return (lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaData
Valida a data de posse e data de nomeacao/exoneração.
@sample 	ValidaData(cClass)
@return		V ou F
@author		Nivia Ferreira
@since		15/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function ValidaData()
	Local lRet := .T.
	If lNomeac == .T. .And.  Empty(dNomeac)
	   If (cClass $ cClassExo) //Exoneracao e Tornar sem Efeito
	      MsgInfo(STR0005, '') //'Data da exoneração não informada.'
	   Else
	      MsgInfo(STR0006, '') //'Data da nomeação não informada.'
	   Endif
	   VDF60VLCSF()
	   lRet := .F.
	ElseIf lPosse == .T. .And.  Empty(dPosse)
	   MsgInfo(STR0007, '') //'Data da Posse não informada.'
	   VDF60VLCSF()
	   lRet := .F.
	Endif
	If lRet .AND. (cClass $ cClassDes) .AND. (FunName() == "VDFM030")  //'225' 08-Designação
		//"Não é permitido realizar Designações via rotina de Convoca/Registra Ato/Portaria. Para realizar o processo de Designação, favor utilizar as rotinas Histórico Aatos/Portarias (VDFA210) e Designações (VDFA220)."##'ATENCAO'
		MsgInfo(OemToAnsi(STR0036), OemToAnsi(STR0035))
		lRet := .F.
	EndIf
Return (lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD060PROC
Verifica os candidatos selecionados..
@sample 	VD060PROC()
@return		Nil
@author		Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD060PROC()
	Local aArea   	:= GetArea()
	Local cMarca  	:= oMark:Mark()
	Local cChave  	:= ''
	Local cCateg  	:= ''
	Local cMensagem	:= ''
	Local cExiste 	:= .F.

	REY->( dbGoTop() )
	While !REY->( EOF() )

		If oMark:IsMark(cMarca)

			cCateg:= VDFCATEG(cFuncao)
			If !Empty(cCateg)

				If  cClass $ cClassExo  //'225' 02-Exoneração,25-Tornar sem Efeito
					If !Empty(REY->REY_NOMEAC) .And. !Empty(REY->REY_NUMDOC) .And. Empty(REY->REY_EXONER) .And. Empty(REY->REY_EXERCI)
						cExiste :=.F.
					Else
						If 	Empty(REY->REY_NOMEAC)
							MsgInfo(STR0024, OemToAnsi(STR0035)) //"Candidato não foi Nomeado."##Atenção
						ElseIf !Empty(REY->REY_NOMEAC) .And. Empty(REY->REY_NUMDOC)
							MsgInfo(STR0025, OemToAnsi(STR0035)) //"Não foi publicado Ato/Portaria da nomeação do candidato."##Atenção
						ElseIf !Empty(REY->REY_EXONER) .Or. !Empty(REY->REY_EXERCI)
							MsgInfo(STR0026, OemToAnsi(STR0035)) //"Tipo de Classificação invalida para esse candidato."##Atenção
						Endif
						cExiste :=.T.
					Endif
				ElseIf  Empty(REY->REY_NOMEAC)
					cExiste :=.F.
				Else
					If !Empty(REY->REY_NOMEAC)
						cMensagem:= STR0041+CRLF //"Candidato já foi Nomeado:"
						cMensagem+= STR0042 + DtoC(REY->REY_NOMEAC)+CRLF //"Data Nomeação: "
					ElseIf !Empty(REY->REY_EXONER)
						cMensagem:= STR0043+CRLF //"Candidato já foi Exonerado:"
						cMensagem+= STR0044 + DtoC(REY->REY_EXONER)+CRLF //"Data Exoneração: "
					ElseIf !Empty(REY->REY_EXERCI)
						cMensagem:= STR0045+CRLF //"Candidato está em Exercício:"
						cMensagem+= STR0046 + DtoC(REY->REY_EXERCI)+CRLF //"Data Início de Exercício: "
					EndIf
					cMensagem+= STR0047 + REY->REY_NUMDOC + CRLF //"Número Documento: "
					cMensagem+= STR0048 + Alltrim(POSICIONE("SQG",3,XFILIAL("SQG",REY->REY_FILIAL)+REY->REY_CPF,"QG_NOME")) //"Candidato: "
					MsgInfo(cMensagem, OemToAnsi(STR0035)) //"Atenção"
					cExiste :=.T.
				Endif

				If cExiste == .F.
					cChave := REY->REY_CPF+REY->REY_CODCON+REY->REY_FILFUN+REY->REY_CODFUN
					VDFM210({cClass,cTpdoc,cCateg,'','REY','1',cChave,REY->REY_FILIAL,REY->REY_CPF,dPosse,'4','',''})
				Else
					oMark:MarkRec()
				Endif
				cExiste := .F.
			Else
				If Empty(cMensagem)
					cMensagem := OemToAnsi(STR0037) //"O cargo atrelado à função escolhida não possui categoria definida. Revise o cadastro das Funções a seguir: " + CRLF + CRLF
					cMensagem += OemToAnsi(STR0038) + REY->REY_FILFUN //"Filial da Função: "
					cMensagem += OemToAnsi(STR0039) + cFuncao + CRLF //" - Função: "
					MsgInfo( cMensagem, OemToAnsi(STR0035) )//Atenção
					Exit
				EndIf
			Endif
		Endif

		REY->( dbSkip() )

	EndDo
	RestArea( aArea )
	oMark:Refresh(.T.)
Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD060PO161
Geracao dos Itens de Atos/Portarias.
@sample 	VD060PO161(aParametro)
@param		Fonte que Chamado: PONA161 - Troca de Turno
			aParametro[1] Fonte 	Fonte que chamou.
			aParametro[2] RA_MAT 	Matricula do Funcionario.
			aParametro[3] CatFunc Categoria do Funcionario.
			aParametro[4] Chave 	Para gravação do Historioco RI6
			aParametro[5] Filial 	Filial do funcionario transferido
			aParametro[6] CPF Do funcionario transferido
			aParametro[7] Alias Alias corrente
			aParametro[8] Data de Efeito
			aParametro[9] Indice da tabela
@return		lRet
@author		Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD060PO161()
	Local lRet    	:= .F.
	Local bCancel 	:= {||oDlg:End()}
	Local aVdfm210	:= {}
	Local oDlg
	Local oGet1
	Local oGet2

	Begin Sequence
	  DEFINE MSDIALOG oDlg TITLE STR0009 FROM 9,0 TO 22,62 OF oMainWnd

	    @ 40,025 SAY STR0020 PIXEL //"Servidor: "
	    @ 40,062 SAY aParanTra[2] +" - " + Alltrim(Posicione('SRA',1,FWXFILIAL("SRA")+aParanTra[2],'RA_NOME')) PIXEL

		@ 60,025 SAY  STR0021 OF oDlg PIXEL //"Tipo Doc:"
		@ 60,062 MSGET oGet1 VAR cTpdoc  PICTURE "@!" Valid (VDFTPDOC({aParanTra[1],cTpdoc})) F3 "S100" SIZE 25,8 OF oDlg PIXEL HASBUTTON
	    @ 60,110 MSGET Alltrim(fDescRCC("S100",cTpdoc,1,3,34,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

		@ 75,025 SAY STR0022 PIXEL //"Classificação:"
		@ 75,062 MSGET oGet2 VAR cClass PICTURE "@!" Valid(VDFCLASSIF({aParanTra[1],cTpdoc,cCatFunc,cClass})) F3 "S101" SIZE 29,8 OF oDlg PIXEL HASBUTTON
	    @ 75,110 MSGET Alltrim(fDescRCC("S101",cClass,1,2,03,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

	   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(lRet:=VDFM210({cClass,cTpdoc,aParanTra[3],;
	                                           aParanTra[2],aParanTra[7],'1',aParanTra[4],aParanTra[5],aParanTra[6],aParanTra[8],aParanTra[9],'',''}),oDlg:End(),.F.)},bCancel)

	End Sequence
Return (lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD060GPE
Geracao dos Itens de Atos/Portarias.
@author	Everson S P Junior
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD060GPE(lAut)
	Local lRet    	:= .f.
	Local bCancel	:= {||oDlg:End()}
	Local oDlg
	Local oGet1
	Local oGet2

	Local aVdfm210	:= {}
	Local cFilSub	:= ""
	Local cMatSub	:= ""

	DEFAULT lAut := .F.

	If aParanTra[1] == "VDFA070" //SUBSTITUIÇÃO
		cFilSub := aParanTra[17]
		cMatSub := aParanTra[18]
	EndIf

	If !lAut .AND. Len(aTipoDoc) == 0
		Begin Sequence
		  DEFINE MSDIALOG oDlg TITLE STR0009 FROM 9,0 TO 25,65 OF oMainWnd

		 	@ 20,005 SAY STR0023 OF oDlg PIXEL //"Servidor:"
			@ 20,042 SAY aParanTra[2] +" - " + Alltrim(Posicione('SRA',1,FWXFILIAL("SRA")+aParanTra[2],'RA_NOME')) PIXEL

			@ 33,005 SAY STR0021 OF oDlg PIXEL //"Tipo Doc:"
			@ 33,042 MSGET oGet1 VAR cTpdoc  PICTURE "@!" Valid (VDFTPDOC({aParanTra[1],cTpdoc})) F3 "S100" SIZE 25,8  OF oDlg PIXEL HASBUTTON
			@ 33,080 MSGET Alltrim(fDescRCC("S100",cTpdoc,1,3,34,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

			@ 46,005 SAY  STR0022 PIXEL //"Classificação:"
			@ 46,042 MSGET oGet2 VAR cClass PICTURE "@!" Valid(VDFCLASSIF({aParanTra[1],cTpdoc,cCatFunc,cClass})) F3 "S101" SIZE 29,8 OF oDlg PIXEL HASBUTTON
			@ 46,080 MSGET Alltrim(fDescRCC("S101",cClass,1,2,03,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.

			If aParanTra[1] == "GPEM040"	//Se for Rescisão Antecipada, informa a data.
			 	@59,005 SAY OemToAnsi(STR0033) OF oDlg PIXEL 	//"Data da Rescisão:"
				@59,080 MSGET oGet3 VAR dDtDoc  PICTURE "@D" Valid {|| ,oDlg:Refresh(), VdfDtDoc(dDtDoc),	;
										aParanTra[4] := DtoS(dDtDoc),	;	//Chave
										aParanTra[7] := dDtDoc		,	;	//Data de Efeito
										} SIZE 90,8  OF oDlg Pixel
			EndIf

		   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(lRet:=VDFM210({cClass,cTpdoc,aParanTra[3],;
		                                                       aParanTra[2],aParanTra[9],'1',aParanTra[4],aParanTra[5],aParanTra[6],aParanTra[7],aParanTra[8],cFilSub,cMatSub}),oDlg:End(),.F.)},bCancel)
		End Sequence

		If !empty(cClass) .and. !empty(cTpdoc) //Necessario verificar se tem conteudo, pois o usuario pode ter cancelado
			AAdd(aTipoDoc,{cClass,cTpdoc})
		EndIf

	Else
		lRet := VDFM210({aParanTra[10],aParanTra[11],aParanTra[3],aParanTra[2],aParanTra[9],'1',aParanTra[4],aParanTra[5],aParanTra[6],aParanTra[7],aParanTra[8],cFilSub,cMatSub}, lAut)
	EndIf

Return (lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFS100
Monta Consulta Padrao - S100.
@sample 	VDFS100()
@return		xRet	.V. ou .F.
@author		Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFS100()
	Local aArea     	:= GetArea()
	Local bFilterPEK	:= { || .T. }
	Local cFilter   	:= ""
	Local cCons 		:= ""
	Local cCpoRet 		:= ""
	Local cConteud 		:= ""
	Local nCPn      	:= 0                        //variavel utilizada quando é aberta mais de uma getdados ao mesmo tempo
	Local cQuery    	:= ''                 		// Variavel da query
	Local xRet

	Private lSubsTp 	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

	If Select("TRB")>0
	   TRB->( dbCloseArea() )
	Endif

		cQuery  += "SELECT "
		If lSubsTp
			cQuery  += " DISTINCT(SUBSTRING(RCC.RCC_CONTEU,1,3))CODIGO,"
			cQuery  += " SUBSTRING(RCC.RCC_CONTEU,4,30) DESCRI "
		Else
			cQuery  += " DISTINCT(SUBSTR(RCC.RCC_CONTEU,1,3))CODIGO,"
	        cQuery  += " SUBSTR(RCC.RCC_CONTEU,4,30) DESCRI "
		EndIf

		cQuery  += " FROM " + RetSqlName( 'RCC' ) + " RCC "
		cQuery  += " LEFT JOIN " + RetSqlName( 'RCC' ) + " RCC1 ON RCC1.D_E_L_E_T_ = ' '"
		cQuery  += " AND RCC1.RCC_CODIGO='S101' "
		IF !Empty(cFonte)
			cQuery  += " AND RCC1.RCC_CONTEU LIKE('%"+ cFonte +"%')"
		Endif
		cQuery  += " WHERE RCC.RCC_CODIGO='S100' "
		cQuery  += " AND RCC.D_E_L_E_T_ = ' ' "
		If lSubsTp
			cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,1,3) = SUBSTRING(RCC1.RCC_CONTEU,33,3) "
		Else
			cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,1,3) = SUBSTR(RCC1.RCC_CONTEU,33,3) "
		EndIf
		cQuery  += " Order By CODIGO "
	    dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
	    dbSelectArea("TRB")

	    While TRB->(!EOF())
	         cConteud := cConteud + (TRB->codigo+';')
	 		 TRB->(DBSKIP())
		EndDo
		TRB->( dbCloseArea() )

	If 	Empty(cConteud)
		MsgInfo(STR0028, '')   //'Tabela Auxiliar S100 esta vazia.'
		xRet := .F.
	Else
		cCpoRet := "BR1_S10001"
		cCons   := "S100"
		cFilter := "{ || Substr(RCC->RCC_CONTEU,1,3) $  '" + cConteud + "' }"
		bFilterPEK := &cFilter

		// n - variável de posicionamento do objeto GetDados
		// o trecho abaixo controla para que não haja conflito entre 2 GetDados, caso seja
		// disparada uma consulta F3 entre 2 tabelas. Ex.: S008 faz consulta em S016
		If Type('n') =="N"
			nCpn := n
		EndIf

		xRet := Gp310SXB(cCons, cCpoRet, bFilterPEK )

		If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
			VAR_IXB := &__READVAR
		Endif

		If nCpn > 0
			n := nCpn
		EndIf

		If ValType(xRet) <> "L"
			xRet := .F.
		EndIf

		RestArea( aArea )
	Endif
Return xRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFS101
Monta Consulta Padrao - S101.
@sample 	VDFS101()
@param
@return	xRet	.V. ou .F.
@author	Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFS101()
	Local aArea     	:= GetArea()
	Local bFilterPEK	:= { || .T. }
	Local cFilter   	:= ""
	Local cCons 		:= ""
	Local cCpoRet 		:= ""
	Local cConteud 		:= ''
	Local nCPn      	:= 0              //variavel utilizada quando é aberta mais de uma getdados ao mesmo tempo
	Local cQuery    	:= ''             // Variavel da query
	Local xRet

	If TYPE("cTpPubl") == "U"
	   Private cTpPubl := ''
	Endif

	Private lSubsTp := "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

	If Select("TRB")>0
	   TRB->( dbCloseArea() )
	Endif

	cQuery  += "SELECT "
	If lSubsTp
		cQuery  += "DISTINCT(SUBSTRING(RCC.RCC_CONTEU,1,2))CODIGO,"
        cQuery  += " SUBSTRING(RCC.RCC_CONTEU,3,30) DESCRI "
	Else
		cQuery  += "DISTINCT(SUBSTR(RCC.RCC_CONTEU,1,2))CODIGO,"
        cQuery  += " SUBSTR(RCC.RCC_CONTEU,3,30) DESCRI "
	EndIf

	cQuery  += " FROM " + RetSqlName( 'RCC' ) + " RCC "
	cQuery  += " WHERE RCC.RCC_CODIGO='S101'"
	cQuery  += " AND RCC.D_E_L_E_T_ = ' '"
	If cCatFunc $ '0*1'
    	If lSubsTp
    		cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,36,3) ='"+cTpdoc+"'"
    	Else
  			cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,36,3) ='"+cTpdoc+"'"
    	EndIf
    Else
		If lSubsTp
			cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,33,3) ='"+cTpdoc+"'"
		Else
			cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,33,3) ='"+cTpdoc+"'"
		EndIf
	Endif
	If !Empty(cTpPubl)
		If lSubsTp
			cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,1,2) IN ('"+cTpPubl+"')"
		Else
			cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,1,2) IN ('"+cTpPubl+"')"
		EndIf
	EndIf
	cQuery  += " AND RCC_CONTEU LIKE('%"+ cFonte +"%')"
	cQuery  += " Order By CODIGO"
    dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
    dbSelectArea("TRB")

    While TRB->(!EOF())
         cConteud := cConteud+(TRB->codigo+';')
 		 TRB->(DBSKIP())
	EndDo
	TRB->( dbCloseArea() )

	If 	Empty(cConteud)
		MsgInfo(STR0027, '')   //'Tabela Auxiliar S101 esta vazia.'
		xRet := .F.
	Else
		cCpoRet := "BR1_S10101"
		cCons   := "S101"
		cFilter := "{ || Substr(RCC->RCC_CONTEU,1,2) $  '" + cConteud + "' }"
		bFilterPEK := &cFilter

		// n - variável de posicionamento do objeto GetDados
		// o trecho abaixo controla para que não haja conflito entre 2 GetDados, caso seja
		// disparada uma consulta F3 entre 2 tabelas. Ex.: S008 faz consulta em S016
		If Type('n') =="N"
			nCpn := n
		EndIf

		xRet := Gp310SXB(cCons, cCpoRet, bFilterPEK )

		If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
			VAR_IXB := &__READVAR
		Endif

		If nCpn > 0
			n := nCpn
		EndIf

		If ValType(xRet) <> "L"
			xRet := .F.
		EndIf

		RestArea( aArea )
	Endif
Return xRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VdfDtDoc
Valida data de Rescisão para Publicação
Utilização na Rotina de Rescisão Contratual, para publicação
	antecipada de Rescisão Contratual futura.
@sample 	VdfDtDoc(dDtDoc)
@param		dDtDoc	- Data informada para publicação da Rescisão
@return		lRet
@author		Tânia Bronzeri
@since		29/04/20014
@version	P. 11.90
/*/
//------------------------------------------------------------------------------
Function VdfDtDoc(dDtDoc)
Local lRet := .T.

If dDtDoc < date()
	lRet	:= MsgYesNo(OemToAnsi(STR0034) , OemToAnsi(STR0035) )		//"Data para Publicação anterior à Data Atual. Confirma geração do Item para Publicação?" ### "Atenção"
EndIf

Return lRet
