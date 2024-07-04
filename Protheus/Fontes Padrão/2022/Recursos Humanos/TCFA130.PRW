#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCFA130.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA130()
Manutencao senhas portal

@author Marcelo Faria
@since 30/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function TCFA130()
	Local oMBrowse := FWMBrowse():New()	
	oMBrowse:SetAlias("RD0")
	oMBrowse:Activate()	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional

@return aRotina - Estrutura
            [n,1] Nome a aparecer no cabecalho
            [n,2] Nome da Rotina associada            
            [n,3] Reservado
            [n,4] Tipo de Transação a ser efetuada:
                1 - Pesquisa e Posiciona em um Banco de Dados
                2 - Simplesmente Mostra os Campos
                3 - Inclui registros no Bancos de Dados
                4 - Altera o registro corrente
                5 - Remove o registro corrente do Banco de Dados
                6 - Alteração sem inclusão de registros
                7 - Copia
                8 - Imprimir
            [n,5] Nivel de acesso
            [n,6] Habilita Menu Funcional
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  				ACTION "PESQBRW"       		OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar" 				ACTION "VIEWDEF.TCFA130"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Gerenciar Usuarios"		ACTION "GerenciarUsuarios"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"   				ACTION "VIEWDEF.TCFA130"	OPERATION 8 ACCESS 0	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do modelo da regra de negocios
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := MPFormModel():New("TCFA130", NIL, NIL, {|oModel| TCFA130Commit(oModel)})
	Local oStructRD0 := FWFormStruct(1, "RD0")
	oStructRD0:RemoveField("RD0_FILIAL")

	oModel:AddFields("TCFA130_RD0", NIL, oStructRD0)
	oModel:SetPrimaryKey({"RD0_CODIGO"})
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= FWFormView():New()	
	Local oModel 	:= FWLoadModel("TCFA130")	
	Local oStructRD0:= FWFormStruct(2,"RD0")
	oStructRD0:RemoveField("RD0_FILIAL")
		
	oView:SetModel(oModel)
	
	oView:AddField("TCFA130_RD0", oStructRD0)   	
	oView:CreateHorizontalBox("FIELDS", 100)	
	oView:SetOwnerView("TCFA130_RD0", "FIELDS")
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} CommitTCFA130
/*/
//-------------------------------------------------------------------
Static Function TCFA130Commit(oModel)
	Local oWSConteudo, oConteudo
	Local nOldSet := SetVarNameLen(255)	
	SetVarNameLen(nOldSet)	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GerarSenhas
/*/
//-------------------------------------------------------------------
Function GerenciarUsuarios()
Local aArea		:= GetArea()
Local aAreaSRA	:= {}
Local aSays		:= {}
Local aButtons	:= {}
Local nOpca		:= 0.00
Local cGCHSDoc	:= SuperGetMv( "MV_GCHSDOC" , .F. , "1" ) // '1' = RD0_CIC  '2'= RD0_DOCID
Local oDlg

Private cCadastro := OemtoAnsi( STR0001 ) //"Gerenciador de Acessos"

IF ( ChkVazio("SRA") )
	aAreaSRA := SRA->( GetArea() )
	
	aAdd(aSays,OemToAnsi( STR0002 ) ) //"Este processo gerencia o acesso de pessoas ao Portal Web RH Protheus."
	aAdd(aSays,OemToAnsi( STR0003 ) ) //"A senha é formada da seguinte forma: "

	If cPaisLoc == "BRA"
			aAdd(aSays,OemToAnsi( STR0004 ) ) //"Ano de Nascimento do Funcionário + Dia Admissäo + Dígito do CPF."
			aAdd(aSays,OemToAnsi( STR0006 ) ) //"Ex.: Um funcionário nascido em 20/11/66, admitido em 14/09/90 e"
			aAdd(aSays,OemToAnsi( STR0005 ) ) //"com CPF 123732768-55, a senha gerada será: ** 661455 ** "
	Else
		If cGCHSDoc = "1"	
			aAdd(aSays,OemToAnsi( STR0004 ) ) //"Ano de Nascimento do Funcionário + Dia Admissäo + Dígito do CPF."
			aAdd(aSays,OemToAnsi( STR0006 ) ) //"Ex.: Um funcionário nascido em 20/11/66, admitido em 14/09/90 e"
			aAdd(aSays,OemToAnsi( STR0005 ) ) //"com CPF 123732768-55, a senha gerada será: ** 661455 ** "
		Else
			aAdd(aSays,OemToAnsi( STR0010 ) ) //"Ano de Nascimento do Funcionário + Dia Admissäo + 2 ultimos dígitos do Documento padrão."
			aAdd(aSays,OemToAnsi( STR0011 ) ) //"Ex.: Um funcionário nascido em 20/11/66, admitido em 14/09/90 e"
			aAdd(aSays,OemToAnsi( STR0012 ) ) //"com Documento 12373276855, a senha gerada será: ** 661455 ** "
		EndIf			
	EndIf

	aAdd(aButtons, { 5,.T.,{|| Pergunte("TCF130A",.T. ) } } )
	aAdd(aButtons, { 1,.T.,{|o| nOpca := 1,IF( gpconfOK() , FechaBatch() , nOpca := 0 ) } } )
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons,,, If(cPaisLoc<>"BRA",580,) )
	IF ( nOpcA == 1 )
		Processa( { || TCFA130Processa() } )
	EndIF
	RestArea( aAreaSRA )
	
EndIF

RestArea( aArea )
Return( NIL )

//----------------------------------------------------------------------
Static Function TCFA130Processa()
//----------------------------------------------------------------------
Local nProcReg	:= 0
Local bEval		:= { |e| &(e) }
Local cExclui	:= "" 
Local cFim		:= ""
Local cSenha	:= ""
Local cSenhaC	:= ""
Local lRet		:= .T.
Local cDocOfic	:= ""
Local cDtAdm	:= ""
Local cGCHSDoc	:= SuperGetMv( "MV_GCHSDOC" , .F. , "1" ) // '1' = RD0_CIC  '2'= RD0_DOCID
Local cDescSDoc	:= AllTrim( RetTitle( If( cGCHSDoc=="2", "RD0_DOCID", "RD0_CIC" ) ) )
Local nPolSeg	:= SuperGetMv("MV_POLSEG", .F. , 0)
Local lSHA512	:= IIf(TamSX3("RD0_SENHAC")[1]==128, .T. , .F.)
Local lLastPwd  := RD0->(ColumnPos("RD0_ULI")) > 0
Local cAliasQry := getNextAlias()
Local lAchouRA	:= .F.
Local lFiltro	:= .F.
Local cCpoCPF	:= "%%"

Private cInicio:= ""

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Carrega Pergunte																												³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Pergunte("TCF130A",.F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Carregando mv_par para variaveis do Sistema.                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private cFilDe		:= mv_par01			//Filial De
Private cFilAte		:= mv_par02			//Filial Ate
Private cCodDe		:= mv_par03			//Codigo De
Private cCodAte		:= mv_par04			//Codigo Ate
Private cSituacao	:= mv_par05			//Situacao (1=Todos /2=Ativos)
Private lClearPassW	:= (mv_par06 == 2)	//Gerar ou Limpar

cCpoCPF := If( cGCHSDoc == "1", "%, RD0.RD0_CIC%", "%, RD0.RD0_DOCID%")

BeginSql alias cAliasQry
	SELECT RD0.RD0_FILIAL, RD0.RD0_CODIGO, RD0.RD0_LOGIN, RD0.RD0_SENHA, RD0.RD0_SENHAC, RD0.RD0_DTADMI, RD0.RD0_DTNASC, RD0.R_E_C_N_O_  %Exp:cCpoCPF%	
	FROM
		%Table:RD0% RD0
	WHERE 	RD0.RD0_FILIAL BETWEEN %exp:xFilial("RD0",cFilDe)% AND %exp:xFilial("RD0",cFilAte)% AND
			RD0.RD0_CODIGO <> '' AND RD0.RD0_CODIGO BETWEEN %exp:cCodDe% AND %exp:cCodAte% AND 
			RD0.RD0_CIC <> '' AND
			RD0.%notDel%
EndSql

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carrega a Regua de Processamento									   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ProcRegua( (cAliasQry)->(RecCount() ) )

(cAliasQry)->(DbGoTop())
While !(cAliasQry)->(Eof())

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Aborta o Processamento                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IncProc()

	// Busca informacoes do funcionario na SRA
	DbSelectArea("RDZ")
	DbSetOrder(2)
	If DbSeek(xFilial("RDZ",(cAliasQry)->RD0_FILIAL)+(cAliasQry)->RD0_CODIGO+cEmpAnt)
		DBSelectArea("SRA")
		DbSetOrder(1) // Filial + Matricula
		While RDZ->(!Eof() .and. RDZ->RDZ_ENTIDA == 'SRA' .and. (cAliasQry)->RD0_CODIGO == RDZ->RDZ_CODRD0)
			If SRA->(DbSeek( RTrim(RDZ->RDZ_CODENT)) )
				If RDZ->RDZ_FILENT+(cAliasQry)->RD0_CIC == SRA->RA_FILIAL+SRA->RA_CIC
					lAchouRA = .T.
					If SRA->RA_FILIAL >= xFilial("SRA",cFilDe) .And. SRA->RA_FILIAL <= xFilial("SRA",cFilAte)
						lFiltro = .T.
					Else
						lFiltro = .F.
					EndIf
				EndIf
			EndIf
			IF ((lAchouRA .And. lFiltro) .Or. !lAchouRA)
				IF !lClearPassW .And. Empty((cAliasQry)->RD0_SENHA)
					//Gerar senha padrao
					nProcReg++
					
					IF Empty((cAliasQry)->RD0_DTADMI)
						cDtAdm := "00"
					Else
						cDtAdm := (cAliasQry)->RD0_DTADMI
					EndIf
					
					If cGCHSDoc == "1"
						cDocOfic := (cAliasQry)->RD0_CIC
					Else
						cDocOfic := (cAliasQry)->RD0_DOCID
					EndIf
					IF Empty(cDocOfic)
						cDocOfic := "00"
					EndIf
					
					cSenha	:= (cAliasQry)->( Substr(  RD0_DTNASC , 3 , 2 ) + Substr( cDtAdm , -2 ) + Substr( AllTrim( cDocOfic ) , -2 ) )
					cSenhaC := cSenha
					cSenha	:= Embaralha(cSenha, 0) 
					
					dbselectArea("RD0")
					RD0->(dbGoTo((cAliasQry)->R_E_C_N_O_))
					
					If RD0->( Reclock("RD0", .F.) )
						RD0->RD0_SENHA := cSenha
						
						If nPolSeg > 0
							//Inicializa senha criptografada
							If lSHA512
								//Cliente possui tamanho do campo RD0_SENHAC atualizado no dicionario
								RD0->RD0_SENHAC := SHA512(AllTrim(cSenhaC))
							Else
								//Cliente possui tamanho padrão(40) do campo RD0_SENHAC no dicionario
								RD0->RD0_SENHAC := SHA1(AllTrim(cSenhaC))
							EndIf
						EndIf
						
						RD0->( MsUnlock() )
					EndIf
					If lAchouRA .And. lFiltro .And. SRA->(RecLock('SRA',.F.))
						SRA->RA_SENHA := cSenha
						SRA->( MsUnlock() )
					EndIF
					
				ElseIF ( lClearPassW )
					//Inicializa usuarios
					nProcReg++
					
					dbselectArea("RD0")
					RD0->(dbGoTo((cAliasQry)->R_E_C_N_O_))
					
					If RD0->( Reclock("RD0", .F.) )
						RD0->RD0_LOGIN	:= Space( Len( RD0->RD0_LOGIN ) )
						RD0->RD0_SENHA	:= Space( Len( RD0->RD0_SENHA ) )
						RD0->RD0_SENHAC := Space( Len( RD0->RD0_SENHAC ) )
						RD0->( MsUnlock() )
					EndIf
					
					If lAchouRA .And. lFiltro .And. SRA->(RecLock('SRA',.F.))
						SRA->RA_SENHA := Space( Len( SRA->RA_SENHA ) )
						SRA->( MsUnlock() )
					EndIf
				EndIf
				//Zera o contador de senhas incorretas caso exista na base
				If lLastPwd .And. (RD0->RD0_ULI) > 0
					If RD0->( Reclock("RD0", .F.) )
						RD0->RD0_ULI := 0
						RD0->( MsUnlock() )
					EndIf					
				EndIf
			EndIf
			lAchouRA := .F.
			lFiltro  := .F.
			RDZ->(DbSkip())
		EndDo
	EndIf
	
	(cAliasQry)->(DbSkip())

End While

RD0->(DbCloseArea())
(cAliasQry)->(DbCloseArea())

If nProcReg > 0
	ApMsgInfo( AllTrim( Str( nProcReg ) ) + ' ' + OemToAnsi( STR0013 ) )
Else
	ApMsgInfo( OemToAnsi( STR0014 ) )
EndIf

Return( NIL )

