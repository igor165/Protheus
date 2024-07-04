#include "Protheus.ch"
#INCLUDE "GPEA937.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

Static cCatTSV		:= SuperGetMv("MV_NTSV",,"")

/*/
{Protheus.doc} function GPEA937
Função Principal para manipulação do Browse.
@author  oliveira.hugo
@since   29/08/2019
@version 1.0
/*/
Function GPEA937()
	Local oBrowse
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local aFldRel		:= {"RA_NOME", "RA_CIC"}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

	If !ChkFile("RJI")
		Help(" ", 1, STR0015,, OemToAnsi(STR0001), 1, 0) // "Erro no Dicionário de Dados.", "Tabela RJI não encontrada. Execute o UPDDISTR (atualizador de dicionário e base de dados)."
		return .F.
	EndIf

	//Tratamento de acesso a Dados Sensíveis
	If lBlqAcesso
		//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Return
	EndIf

	Aviso(STR0003, STR0004,{ STR0005 }) // "Atenção.", "Esta rotina deverá ser utilizada apenas quando a RFB solicitar a alteração do CPF do trabalhador.", "Ok"

	//Monta o Browse
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'RJI' )
	oBrowse:SetDescription( OemToAnsi(STR0016) ) // "Alteração de CPF"

	//Legendas
	oBrowse:AddLegend( "RJI->RJI_STATUS == '0' ", "YELLOW", STR0011 )  // "0-Não Processado"
	oBrowse:AddLegend( "RJI->RJI_STATUS == '1' ", "GREEN",	STR0012 )  // "1 - Eventos S-2299/S-2399 gerados
	oBrowse:AddLegend( "RJI->RJI_STATUS == '2' ", "BLUE",	STR0013 )  // "2 - Eventos S-2299/S-2399/S-2200/S-2300 gerados e SRA Atualizado

	//Busca o filtro a ser utilizado no Browse
    oBrowse:SetFilterDefault( "RJI->RJI_PRI == '1'" )
	oBrowse:Activate()
Return


/*/
{Protheus.doc} function MenuDef
Função Principal para manipulação do Menu.
@author  oliveira.hugo
@since   29/08/2019
@version 1.0
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title OemToAnsi(STR0006) Action 'VIEWDEF.GPEA937' OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina Title OemToAnsi(STR0007) Action 'VIEWDEF.GPEA937' OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina Title OemToAnsi(STR0008) Action 'VIEWDEF.GPEA937' OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina Title OemToAnsi(STR0009) Action 'VIEWDEF.GPEA937' OPERATION 4 ACCESS 0 // "Manutenção"
	ADD OPTION aRotina Title OemToAnsi(STR0010) Action 'VIEWDEF.GPEA937' OPERATION 5 ACCESS 0 // "Excluir"
Return aRotina


/*/
{Protheus.doc} function ModelDef
Função Principal para manipulação do Model.
@author  oliveira.hugo
@since   29/08/2019
@version 1.0
/*/
Static Function ModelDef()
	Local oModel	As Object
	Local oDet 		As Object
	Local oCab		As Object
	Local bCpCab   	:= { |cCampo| AllTrim(cCampo) + "|" $ "RJI_FILIAL|RJI_MAT|RJI_NOME|RJI_CPFA|RJI_CPF|RJI_DTEF|RJI_DTALT|RJI_OBS|" }
	Local bCpDet   	:= { |cCampo| AllTrim(cCampo) + "|" $ "RJI_FILIAL|RJI_MAT|RJI_CPFA|RJI_CPF|RJI_DTEF|RJI_DTALT|RJI_STATUS|" }
	Local bGetDet   := { |oModel| fGetRJI(oModel, "0", RJI->RJI_CPFA) }
	Local bCommit   := { |x| fCommit(x) }
	Local bPosVal := { |oModel| Gp937CPosVal( oModel )}

	//oModel 	:= MPFormModel():New('GPEA937')
	oModel := MPFormModel():New("GPEA937",  /*bPreValidacao*/, bPosVal/*bPosValidacao*/, bCommit, /*bCancel*/)

	oCab 	:= FWFormStruct(1, "RJI", bCpCab)
	oDet 	:= FWFormStruct(1, "RJI", bCpDet)

	oModel:AddFields("MDLGPEA937", , oCab)
	oModel:AddGrid("GPEA937_DET", "MDLGPEA937", oDet, {|oModel|.T.}, {|oModel|.T.}, {|oModel|.T.}, {|oModel|.T.}, bGetDet)

	oModel:GetModel("GPEA937_DET"):SetDescription( OemToAnsi("Teste") )
	oModel:GetModel("GPEA937_DET"):SetOptional( .T. )

	oModel:SetRelation("GPEA937_DET", { {"RJI_CPFA","RJI_CPFA"} }, RJI->( IndexKey(3) ) )
	oModel:SetPrimaryKey( {} )
Return oModel


/*/
{Protheus.doc} function ViewDef
Função Principal para manipulação da View.
@author  oliveira.hugo
@since   29/08/2019
@version 1.0
/*/
Static Function ViewDef()
	Local oView	 AS Object
	Local oModel AS Object
	Local oCab	 AS Object
	Local oDet	 AS Object
	Local bCpCab := {|cCampo| AllTrim(cCampo) + "|" $ "RJI_FILIAL|RJI_MAT|RJI_NOME|RJI_CPFA|RJI_CPF|RJI_DTEF|RJI_DTALT|RJI_OBS|" }
	Local bCpDet := {|cCampo| AllTrim(cCampo) + "|" $ "RJI_FILIAL|RJI_MAT|RJI_CPFA|RJI_CPF|RJI_DTEF|RJI_DTALT|RJI_STATUS|" }

	oCab := FWFormStruct(2, "RJI", bCpCab)
	oDet := FWFormStruct(2, "RJI", bCpDet)

	oModel 	:= FWLoadModel( 'GPEA937' )
	oView 	:= FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("VIEW_GPEA937_1", oCab, "MDLGPEA937" )
	oView:AddGrid("VIEW_GPEA937_2", oDet, "GPEA937_DET" )

    oView:CreateHorizontalBox("FORMCAB", 60)
    oView:CreateHorizontalBox("GRID", 40)

    oView:SetOwnerView("VIEW_GPEA937_1", "FORMCAB")
	oView:SetOwnerView("VIEW_GPEA937_2", "GRID")

    // Adiciona o Título
    oView:EnableTitleView('VIEW_GPEA937_1', OemToAnsi(STR0023)) // "Vínculo Principal"
    oView:EnableTitleView('VIEW_GPEA937_2', OemToAnsi(STR0024)) // "Demais Vínculos"

    // Adiciona pergunta de confirmação ao fechar a tela
    oView:SetCloseOnOk( {||.T.} )

    // Bloqueia Grid de detalhe para edição
    oView:SetViewProperty("VIEW_GPEA937_2", "ONLYVIEW")

    // Adiciona o botão para chamada do evento S-2299
    oView:AddUserButton(OemToAnsi(STR0025), "S-2299", {||Gera2299()})
    oView:AddUserButton(OemToAnsi(STR0026), "S-2200", {||Gera2200()})

Return oView


/*/
{Protheus.doc} function fGetRJI
Função que realiza o preenchimento da GRID Detalhe
@author  oliveira.hugo
@since   29/08/2019
@version 1.0
/*/
Static Function fGetRJI(oMdl, cPRI, cCPF)
    Local aRet       := {}
    Local cTmpTrab   := GetNextAlias()

    BeginSql alias cTmpTrab
        COLUMN RJI_DTALT   AS DATE
        COLUMN RJI_DTEF    AS DATE

        SELECT * FROM %table:RJI%  RJI
        WHERE RJI.RJI_CPFA = %exp:cCPF%
            AND RJI.RJI_PRI = %exp:cPRI%
            AND RJI.%NotDel% ORDER BY RJI_CPFA
    EndSql

    aRet := FwLoadByAlias( oMdl, cTmpTrab )
    (cTmpTrab)->(DbCloseArea())
Return aRet


/*/
{Protheus.doc} function fCommit
Função que realiza a gravação dos dados.
@author  oliveira.hugo
@since   29/08/2019
@version 1.0
/*/
Function fCommit( oModel )
    Local nX        := 0
    Local lRet      := .T.
    Local aRetSRA   := {}
    Local cFilRJI   := ""
    Local cMatRJI   := ""
    Local cCPFARJI  := ""
    Local cCPFRJI   := ""
    Local cDtAltRJI := ""
    Local cDtEfRJI  := ""
    Local cObsRJI   := ""
    Local nOper     := oModel:GetOperation()
    Local oCab      := oModel:GetModel("MDLGPEA937")

    lRet := fPreValid(oModel)

    If lRet
        Begin Transaction
            DbSelectArea("RJI")
            RJI->(DbSetOrder(3)) // RJI_CPFA, RJI_FILIAL, RJI_MAT, RJI_STATUS
            RJI->(DbGoTop())

            cFilRJI   := oCab:GetValue("RJI_FILIAL")
            cMatRJI   := oCab:GetValue("RJI_MAT")
            cCPFARJI  := oCab:GetValue("RJI_CPFA")
            cCPFRJI   := oCab:GetValue("RJI_CPF")
            cDtAltRJI := oCab:GetValue("RJI_DTALT")
            cDtEfRJI  := oCab:GetValue("RJI_DTEF")
            cObsRJI   := oCab:GetValue("RJI_OBS")

            // Inclusão
            IF nOper == 3
                aRetSRA := fGetSRA(cCPFARJI)

                For nX := 1 To Len(aRetSRA)
                    RecLock("RJI", .T.)
                        RJI->RJI_FILIAL := aRetSRA[nX][1] // FILIAL
                        RJI->RJI_MAT    := aRetSRA[nX][2] // MAT
                        RJI->RJI_CPFA   := aRetSRA[nX][3] // CPFA
                        RJI->RJI_CPF    := cCPFRJI
                        RJI->RJI_DTALT  := cDtAltRJI
                        RJI->RJI_DTEF   := cDtEfRJI
                        RJI->RJI_OBS    := cObsRJI
                        RJI->RJI_STATUS := "0"

                        // Se Matrícula Principal
                        IF (aRetSRA[nX][1] == cFilRJI) .AND. (aRetSRA[nX][2] == cMatRJI) .AND. (aRetSRA[nX][3] == cCPFARJI)
                            RJI->RJI_PRI := "1"
                        Else
                            RJI->RJI_PRI := "0"
                        EndIf
                    RJI->(MsUnLock())
                Next nX

            // Alteração de todos os registros com RJI_PRI = 0
            ElseIf nOper == 4
                If RJI->( DbSeek( cCPFARJI ) )
                    While !RJI->( Eof() ) .And. RJI->RJI_CPFA == cCPFARJI
                        RecLock("RJI", .F.)
                            RJI->RJI_CPF    := cCPFRJI
                            RJI->RJI_DTALT  := cDtAltRJI
                            RJI->RJI_DTEF   := cDtEfRJI
                            RJI->RJI_OBS    := cObsRJI
                        RJI->( MsUnLock() )
                        RJI->( dbSkip() )
                    Enddo
                EndIf

            // Exclusão de todos os registros com RJI_PRI = 0
            ElseIf nOper == 5
                If RJI->( DbSeek( cCPFARJI ) )
                    While !RJI->( Eof() ) .And. RJI->RJI_CPFA == cCPFARJI
                        RecLock("RJI", .F. )
                        RJI->( dbDelete() )
                        RJI->( MsUnlock() )
                        RJI->( FkCommit() )
                        RJI->( dbSkip() )
                    Enddo
                EndIf
            EndIf
        End Transaction
    EndIf
Return lRet


/*/
{Protheus.doc} function fPreValid
Função que realiza a Pré-Validação dos dados.
@author  oliveira.hugo
@since   29/08/2019
@version 1.0
/*/
Static Function fPreValid(oModel)
    Local lRet          := .T.
    Local cCPFa         := ""
    Local cCPF          := ""
    Local cFilRJI       := ""
    Local cMatRJI       := ""
    Local cAliasRJI     := "RJI"
    Local nOper         := oModel:GetOperation()
    Local oCab          := oModel:GetModel("MDLGPEA937")

    DbSelectArea(cAliasRJI)
	(cAliasRJI)->( DbSetOrder(1) ) // Filial + Matrícula + CPF Antigo

    cFilRJI :=  oCab:GetValue("RJI_FILIAL")
    cMatRJI :=  oCab:GetValue("RJI_MAT")
    cCPFa   :=  oCab:GetValue("RJI_CPFA")
    cCPF    :=  oCab:GetValue("RJI_CPF")

    // Valida Inclusão
    If nOper == 3
         If (cAliasRJI)->( DbSeek(cFilRJI + cMatRJI + cCPFa) )
            IF !(cAliasRJI)->(Eof()) .AND. cFilRJI == (cAliasRJI)->RJI_FILIAL .AND. cMatRJI == (cAliasRJI)->RJI_MAT .AND. cCPFa == (cAliasRJI)->RJI_CPFA
                oModel:SetErrorMessage("",,oModel:GetId(),"",OemToAnsi(STR0003),OemToAnsi(STR0021) + CRLF) // "Atenção", "Não é possível realizar a inclusão pois já existe um registro para este funcionário."
                lRet := .F.
            EndIf
        EndIf

    // Valida Alteração ou Exclusão
    ElseIf nOper == 4 .OR. nOper == 5
        If (cAliasRJI)->( DbSeek(cFilRJI + cMatRJI + cCPFa) )
            IF !(cAliasRJI)->(Eof()) .AND. cFilRJI == (cAliasRJI)->RJI_FILIAL .AND. cMatRJI == (cAliasRJI)->RJI_MAT .AND. cCPFa == (cAliasRJI)->RJI_CPFA .AND. ;
                (cAliasRJI)->RJI_PRI == "1" .AND. (cAliasRJI)->RJI_STATUS $ "1|2"
                    oModel:SetErrorMessage("",,oModel:GetId(),"",OemToAnsi(STR0003),OemToAnsi(STR0022) + CRLF) // "Atenção", "Não é possível realizar a operação pois o registro já foi integrado com o TAF."
                    lRet := .F.
            EndIf
        EndIf
    EndIf
Return lRet


/*/
{Protheus.doc} function fGetSRA
Função que pega os demais vínculos do Funcionário
@author  oliveira.hugo
@since   01/09/2019
@version 1.0
/*/
Static Function fGetSRA( cCPF )
    Local aTemp := {}
    Local aRet  := {}
    Local aArea	:= GetArea()
    Local cTmp  := GetNextAlias()
    Local cCatTSV		:= SuperGetMV("MV_NTSV",Nil,"")
    Local cQryTSV		:= ""

    If !Empty(cCatTSV)
    	cQryTSV := "% AND SRA.RA_CATEFD NOT IN (" + fSqlIN( StrTran(cCatTSV,"/",""), 3 ) + ") %"
    Endif

    BeginSql alias cTmp
        SELECT RA_FILIAL, RA_MAT, RA_CIC
        FROM %table:SRA%  SRA
        WHERE SRA.RA_CIC = %exp:cCPF%
        AND SRA.%NotDel%
        %exp:cQryTSV%
    EndSql

    While (cTmp)->(!Eof())
        aTemp := {}
        aadd(aTemp, (cTmp)->RA_FILIAL)
        aadd(aTemp, (cTmp)->RA_MAT)
        aadd(aTemp, (cTmp)->RA_CIC)
        aadd(aRet, aTemp)
        (cTmp)->(dbskip())
    EndDo

    (cTmp)->(DbCloseArea())
    RestArea(aArea)
Return aRet



/*/
{Protheus.doc} function Gp937CPosVal
Função que valida as categorias eSocial
@author  staguti
@since   04/10/2019
@version 1.0
/*/
Function Gp937CPosVal( oModel )

Local oCab      := oModel:GetModel("MDLGPEA937")
Local lRet		:= .T.
Local cFilRJI :=  oCab:GetValue("RJI_FILIAL")
Local cMatRJI :=  oCab:GetValue("RJI_MAT")
Local cCPFa   :=  oCab:GetValue("RJI_CPFA")


	nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .or.  nOperation == MODEL_OPERATION_UPDATE

	    SRA->(dbSetOrder(1))

	    If SRA->(dbSeek(cFilRJI+ cMatRJI ))
	    	If SRA->RA_CATEFD $ cCatTSV
	    		Help( " ", 1, OemToAnsi(STR0003),, OemToAnsi(STR0027), 1, 0 )
	    		lRet := .F.
	    	Endif
	    Endif
	Endif

Return lRet
