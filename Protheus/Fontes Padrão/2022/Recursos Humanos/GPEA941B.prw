#include "Protheus.ch"
#include "GPEA941B.CH"
#Include 'FWMVCDEF.CH' 
#INCLUDE "FWMBROWSE.CH"

Static lIntTaf      := SuperGetMv("MV_RHTAF",, .F.) //Integracao com TAF
Static lMiddleware  := If(cPaisLoc == 'BRA' .And. Findfunction("fVerMW"), fVerMW(), .F.)
Static lOk          := (lIntTaf .Or. lMiddleware)

/*/{Protheus.doc} GPEA934
Vínculo de processos - Estabelecimentos/Obras Próprias
Esta rotina é a manutenção da tabela RJL - Processos de Estabelecimentos/Obras Próprias

@Author   lidio.oliveira
@Since    16/03/2020 
@Version  1.0 
@Type     Function
/*/
Function GPEA941B()

	Local cFiltraRh     := ""
	Local lNewCT        := .F.
    Local oBrwRJL

	IF ChkFile("RJ3") .And. fVldObraRJ(@lNewCT, .F.) .And. !lNewCT
        Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0011), 1, 0 ) //STR0011: Este cadastro não pode ser utilizado por usuários com o Novo Controle de Lotações
        Return
    EndIf

    If !ChkFile("RJL")
        Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0003), 1, 0 )//STR0003: "Atenção"#"Tabela RJL não encontrada. Execute o UPDDISTR - Atualizador de dicionário e base de dados."
        Return
    EndIf

    If !lOk
        Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0034), 1, 0 )//"Atenção"#"A rotina somente deverá ser utilizada quando a integração do eSocial estiver ativa"
        Return
    EndIf

  	oBrwRJL := FWmBrowse():New()
	oBrwRJL:SetAlias( 'RJL' )
	oBrwRJL:SetDescription(OemToAnsi(STR0001))	//STR0001: Processos - Estabelecimentos/Obras Próprias

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh	:= CHKRH(FunName(),"RJL","1")
	
	//Filtro padrao do Browse conforme tabela RJL (Processos - Estabelecimentos/Obras Próprias)
	oBrwRJL:SetFilterDefault(cFiltraRh)
	oBrwRJL:SetLocate()

	oBrwRJL:ExecuteFilter(.T.)

	oBrwRJL:Activate()
	
Return

/*/{Protheus.doc}
Menu Funcional
@type      	Static Function
@author   	lidio.oliveira
@since		16/03/2020
@version	1.0
@return		oMdlRJL
/*/
Static Function MenuDef()
	Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA941B'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0007)  Action 'VIEWDEF.GPEA941B'  OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0008)  Action 'VIEWDEF.GPEA941B'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0009)  Action 'VIEWDEF.GPEA941B'	OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina

/*/{Protheus.doc}
Modelo de dados e Regras de Preenchimento
@type      	Static Function
@author   	lidio.oliveira
@since		16/03/2020
@version	1.0
@return		oMdlRJL
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRJL := FWFormStruct( 1, 'RJL', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oMdlRJL
	
	// Blocos de codigo do modelo
    Local bPosValid 	:= { |oMdlRJL| Gp941BPsVal( oMdlRJL )}
    
	// Bloco de codigo Fields
	Local bTOkVld		:= { |oGrid| Gp934TOk( oGrid, oMdlRJL)}
	
	// Cria o objeto do Modelo de Dados
	oMdlRJL := MPFormModel():New('GPEA941B', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oMdlRJL:AddFields( 'MDLGPEA941B', /*cOwner*/, oStruRJL, /*bLOkVld*/, bTOkVld, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oMdlRJL:SetDescription(OemToAnsi(STR0001))//"Processos - Estabelecimentos/Obras Próprias"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRJL:GetModel( 'MDLGPEA941B' ):SetDescription(OemToAnsi(STR0001)) //"Processos - Estabelecimentos/Obras Próprias"

    // VALIDA AS VERSÕES DO ESOCIAL.
    oMdlRJL:SetVldActivate({|oModel| Iif(FindFunction("fVldDifVer"), fVldDifVer(oMdlRJL, @lIntTAF), .T.)})
	
    //Definição de chave primário do modelo
	oMdlRJL:SetPrimaryKey({'RJL_FILIAL', 'RJL_FIL', 'RJL_CC', 'RJL_COMPET', 'RJL_TP', 'RJL_TPPROC', 'RJL_NRPROC', 'RJL_CSUSP' })

Return oMdlRJL
	

/*/{Protheus.doc}
Visualizador de dados do Cadastro de Processos - Estabelecimentos/Obras Próprias
@type      	Static Function
@author   	lidio.oliveira
@since		17/03/2020
@version	1.0
@return		oView
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oMdlRJL   := FWLoadModel( 'GPEA941B' )
	// Cria a estrutura a ser usada na View
	Local oStruRJL := FWFormStruct( 2, 'RJL' )
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlRJL )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_GPEA941B', oStruRJL, 'MDLGPEA941B' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_GPEA941B', 'FORMFIELD' )

Return oView


/*/{Protheus.doc}
Pos-validacao do Cadastro de Processos - Estabelecimentos/Obras Próprias
@type      	Static Function
@author   	lidio.oliveira
@since		16/03/2020
@version	1.0
@param		oMdlRJL, object, Modelo a ser validado
@return		lRetorno
/*/
Static Function Gp941BPsVal( oMdlRJL )
	
    Local aAreaSM0  := SM0->( GetArea() )
    Local cChave	:= ""
	Local nOpcRJL	:= oMdlRJL:GetOperation()
	Local lRet		:= .T.
    Local cChaveCTT := ""
    Local cFil      := ""
    Local aEmpresas := {}
    Local cCompRJM  := ""
    Local cMsgErro  := ""
    Local dBkpDtBa  := dDatabase
 
    If nOpcRJL == MODEL_OPERATION_INSERT .Or. nOpcRJL == MODEL_OPERATION_UPDATE
        
        //Valida se o registro informado já está gravado na tabela RJL
        cChave := oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL') + oMdlRJL:GetValue('MDLGPEA941B','RJL_CC') + oMdlRJL:GetValue('MDLGPEA941B','RJL_COMPET') + ;
        oMdlRJL:GetValue('MDLGPEA941B','RJL_TP') + oMdlRJL:GetValue('MDLGPEA941B','RJL_NRPROC')
        dbSelectArea( "RJL" )
        If dbSeek(xFilial("RJL") + cChave ) .And. (nOpcRJL == MODEL_OPERATION_INSERT .Or. xFilial("RJL")+cChave != RJL->RJL_FILIAL+RJL->RJL_FIL+RJL->RJL_CC+RJL->RJL_COMPET+RJL->RJL_TP+RJL->RJL_NRPROC)
            //Atenção # Já existe um registro com a chave informada:
            Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0012), 2 , 0 , , , , , , { OemToAnsi(STR0013) } )
            lRet := .F.
            Return lRet     
        EndIf

        //Valida tratar-se de obra própria 
        If !Empty(oMdlRJL:GetValue('MDLGPEA941B','RJL_CC'))
            cChaveCTT := oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL') + oMdlRJL:GetValue('MDLGPEA941B','RJL_CC')

            dbSelectArea( "CTT" )
            If dbSeek(cChaveCTT)
                If !(CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. !(Empty(CTT->CTT_CEI2)))
                    //Atenção # Só podem ser selecionadas lotações do tipo 01 e Tipo eSocial 4 - CNO
                    Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0014), 2 , 0 , , , , , , { OemToAnsi(STR0016) } )
                    lRet := .F.
                EndIf 
            //valida se o valor preenchido no campo RJL_FIL é inválido
            ElseIF !(ALLTRIM(oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL')) $ xFilial("CTT",cFilAnt))
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0027), 2 , 0 , , , , , , { OemToAnsi(STR0028) } ) //STR0027: O conteúdo informado no campo FIL (RJL_FIL) é inválido.
                lRet := .F.
            Else
                //Atenção # Código da Lotação não encontrado no cadastro de centro de custo (Tabela CTT)
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0015), 2 , 0 , , , , , , { OemToAnsi(STR0017) } )
                lRet := .F.
            EndIf
        //Valida a gravação do processo para o cadastro da Filial
        ElseIf !Empty(oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL'))
            aEmpresas   := FWLoadSM0()
            nPos        := aScan(aEmpresas, {|x| x[1] == cEmpAnt .And. x[2] = oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL')})
            cFil        := ALLTRIM(oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL'))
            If nPos == 0 .Or. !(nPos > 0 .And. cEmpAnt == aEmpresas[npos,1] .And. (Empty(xFilial("RJL",cFilAnt)) .Or. alltrim(xFilial("RJL",cFilAnt)) $ cFil))
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0030), 2 , 0 , , , , , , { OemToAnsi(STR0031) } ) //STR0030: Filial não localizada no cadastro de empresas.
                lRet := .F.
            EndIf
        Else
            //Os campos RJL_FIL e RJL_CC não podem ficar em branco
            //STR0032: Os campos Fili e CC estão branco, o preenchimento de ao menos um deles é obrigatório.
            Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0032), 2 , 0 , , , , , , { OemToAnsi(STR0033) } )
            lRet := .F.
        EndIf

        //Demais validações
        If lRet
            If !(oMdlRJL:GetValue('MDLGPEA941B','RJL_TP') $ "1*2")
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0018), 2 , 0 , , , , , , { OemToAnsi(STR0019) } ) //STR0018: Informe um conteúdo válido para o Campo Tipo Contrib (RJL_TP)
                lRet := .F.
            ElseIf oMdlRJL:GetValue('MDLGPEA941B','RJL_TP') == "1" .And. !(oMdlRJL:GetValue('MDLGPEA941B','RJL_TPPROC') $ "1*2")
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0020), 2 , 0 , , , , , , { OemToAnsi(STR0021) } ) //STR0020: Informe um conteúdo válido para o Campo Tipo de Proc (RJL_TPPROC)
                lRet := .F.
            ElseIf oMdlRJL:GetValue('MDLGPEA941B','RJL_TP') == "2" .And. !(oMdlRJL:GetValue('MDLGPEA941B','RJL_TPPROC') $ "1*2*4")
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0020), 2 , 0 , , , , , , { OemToAnsi(STR0022) } ) //STR0020: Informe um conteúdo válido para o Campo Tipo de Proc (RJL_TPPROC)
                lRet := .F.
            ElseIf Empty(oMdlRJL:GetValue('MDLGPEA941B','RJL_NRPROC'))
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0023), 2 , 0 , , , , , , { OemToAnsi(STR0024) } ) //STR0023: Informe um conteúdo válido para o campo Num. Proc (RJL_NRPROC).
                lRet := .F.
            ElseIf Empty(oMdlRJL:GetValue('MDLGPEA941B','RJL_CSUSP'))
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0025), 2 , 0 , , , , , , { OemToAnsi(STR0026) } ) //STR0025: Informe um conteúdo válido para o campo Cód. Susp. (RJL_CSUSP)..
                lRet := .F.
            EndIf
        EndIf
    EndIf

    //Integração S-1005
    If lRet
        cCompRJM    := oMdlRJL:GetValue('MDLGPEA941B','RJL_COMPET')
        If !Empty(oMdlRJL:GetValue('MDLGPEA941B', 'RJL_CC'))
            cChaveCTT   := oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL') + oMdlRJL:GetValue('MDLGPEA941B','RJL_CC')            
            If CTT->( dbSeek( oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL') + oMdlRJL:GetValue('MDLGPEA941B','RJL_CC') ) )
                RegToMemory("CTT", .F., .F., .F., "GPEA941B")
                dDatabase   := sToD(cCompRJM+"01")
                lRet        := Ctb030eSoc(Iif(nOpcRJL != MODEL_OPERATION_DELETE, nOpcRJL, 4), .T., @cMsgErro, Nil, oMdlRJL)
                If !lRet
                    Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0035 + CRLF + cMsgErro), 1, 0 )//"Atenção"##"Há inconsistências(s) no cadastro da lotação que impede(m) a integração do evento S-1005:"
                ElseIf !Empty(cMsgErro)
                    MsgInfo(STR0035 + CRLF + cMsgErro, OemToAnsi(STR0002))//"Atenção"##"Há inconsistências(s) no cadastro da lotação que impede(m) a integração do evento S-1005:"
                EndIf
                dDatabase   := dBkpDtBa
            Else
                Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0036), 1, 0 )//"Atenção", "Não existe registro relacionado a este código de lotação."
                lRet := .F.
            EndIf
        Else
            SM0->( dbSeek( cEmpAnt+oMdlRJL:GetValue('MDLGPEA941B','RJL_FIL') ) )
            lRet  := fInt005Vl(oMdlRJL, Nil, .T., .F., .T., 4)
            If lRet
                dDatabase   := sToD(cCompRJM+"01")
                lRet        := fIntExt005(oMdlRJL, Nil, .T., .F., .T., 4, @cMsgErro)
                If !lRet
                    Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0035 + CRLF + cMsgErro), 1, 0 )//"Atenção"##"Há inconsistências(s) no cadastro da lotação que impede(m) a integração do evento S-1005:"
                EndIf
                dDatabase   := dBkpDtBa
            EndIf
        EndIf
    EndIf

RestArea(aAreaSM0)

Return lRet                                  

/*/{Protheus.doc}
Tudo Ok do Cadastro de Lotações eSocial
@type      	Static Function
@author   	lidio.oliveira
@since		13/03/2019
@version	1.0
@param		oGrid, 		object, 	Objeto da Grid a ser validada
@param		oMdlRJ3,	object, 	Objeto do Modelo a ser validado
@return		lRet,		logic
/*/

Static Function Gp934TOk( oGrid, oMdlRJL )
Local lRet		:= .T.

// futura implementação para integração do evento com o TAF

Return lRet

/*/{Protheus.doc}
Consulta padrão do campo Centro de Custo
@type      	Static Function
@author   	lidio.oliveira
@since		17/03/2020
@version	1.0
/*/
Function gpea941bf3( oMdlRJL )

    Local cAlias   	:=	"CTT"
    Local cFilBkp 	:= cFilAnt
    Local cFil      :=  M->RJL_FIL
    Local aArea		:=	( cAlias )->( GetArea() )
    Local lRet      := .F.
    Local oModel

    oModel  := FWModelActive()    
    If oModel != nil .And. oModel:isActive()
        cFilAnt := FWxFilial("CTT", cFil)
        lRet    := ConPad1(,,,cAlias)
        
        If lRet 
		    VAR_IXB := aCpoRet[1]
	    EndIf

        cFilAnt := cFilBkp
    EndIf
    
    ( cAlias )->( RestArea(aArea) )

Return lRet
