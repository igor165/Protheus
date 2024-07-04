#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TMSAC20.ch'

/*/{Protheus.doc} TMSAC20()
Configuração Planejamento de Rotas (TPR)
Uso: SIGATMS
@sample
//TMSAC20()
@author Katia
@since 19/08/2021
@version 12.1.35
/*/ 
Function TMSAC20()
Local oBrowse   := Nil				

Private  aRotina   := MenuDef()		

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DLV")			    
oBrowse:SetMenuDef("TMSAC20")		
oBrowse:SetDescription( STR0002 + " " + STR0001 )		//"Configuração Planejamento de Rotas (TPR)"
oBrowse:SetFilterDefault( "DLV_ROTERI == '2'")   //TPR
oBrowse:Activate()

Return Nil

/*/{Protheus.doc} ModelDef()
Definição do Modelo
Uso: TMSAC20
@sample
//ModelDef()
@author Katia  
@since 19/08/2021
@version 12.1.35
/*/
Static Function ModelDef()
Local oModel	:= Nil		
Local oStruDLV	:= Nil		
Local bCommit 	:= { |oModel| CommitMdl(oModel) }
Local bPosValid := { |oModel| PosVldMdl(oModel) }

oStruDLV:= FWFormStruct( 1, "DLV" )

oModel := MPFormModel():New( "TMSAC20",,bPosValid, bCommit , /*bCancel*/ ) 

oModel:AddFields( 'MdFieldDLV',, oStruDLV,,,/*Carga*/ ) 

oModel:GetModel( 'MdFieldDLV' ):SetDescription( STR0002 + " " + STR0001  ) 	//"Configuração Planejamento de Rotas (TPR)"

oModel:SetPrimaryKey({"DLV_FILIAL" , "DLV_ID"})  
     
oModel:SetActivate( )
     
Return oModel 

/*/{Protheus.doc} ViewDef()
Definição da View
Uso: TMSAC20
@sample
//ViewDef()
@author Katia
@since 19/08/2021
@version 12.1.35
/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDLV	:= Nil		// Recebe a Estrutura da tabela DLV
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAC20")
oStruDLV := FWFormStruct( 2, "DLV" )

//Campos específicos da integração maplink - Rota Inteligente
oStruDLV:RemoveField("DLV_TIMETK")
oStruDLV:RemoveField("DLV_APPID")
oStruDLV:RemoveField("DLV_APPCOD")
oStruDLV:RemoveField("DLV_KEY")
oStruDLV:RemoveField("DLV_SECRET")

If nModulo = 39
	oStruDLV:RemoveField("DLV_TMPEXP")

	oStruDLV:RemoveField("DLV_AUTH")
	oStruDLV:RemoveField("DLV_DESROT")

	If DLV->(FieldPos('DLV_ROTA')) > 0  
		oStruDLV:RemoveField("DLV_ROTA")
	EndIf
EndIf

oView := FwFormView():New()
oView:SetModel(oModel)     

oView:AddField('VwFieldDLV', oStruDLV , 'MdFieldDLV')   

oView:CreateHorizontalBox('CABECALHO', 100)  
oView:SetOwnerView('VwFieldDLV','CABECALHO')

Return oView

/*/{Protheus.doc} CommitMdl()
Commit Mdl
Uso: TMSAC20
@sample
@author Katia   
@since 19/08/2021
@version 12.1.35
/*/
Static Function CommitMdl(oModel)
Local lRet	:= .T. 

lRet	:= FwFormCommit(oModel)

Return lRet

/*/{Protheus.doc} PosVldMdl()
pos validações
Uso: TMSAC20
@sample
@author Katia 
@since 19/08/2021
@version 12.1.35
/*/
Static Function PosVldMdl(oModel)
Local lRet			:= .T. 
Local nOperation	:= oModel:GetOperation()

If nOperation == 3 
	lRet := ExistChav("DLV",FwFldGet("DLV_ID") )
EndIf

If lRet .And. !Empty(M->DLV_ROTERI) .And. M->DLV_ROTERI <> '2'   //1-Maplink, 2-TPR
    Help("",1,"TMSAC2002") //-- Este cadastro está habilitado somente para o Roteirizador TPR- Neolog
    lRet:= .F.
EndIf

If lRet 
	If (nOperation == 3  .Or. nOperation == 4)
		lRet:= TMSAO20ROT("2")   //1- Maplink, 2- TPR Neolog
		If !lRet
			Help("",1,"TMSAC2001") //-- Não é permitido mais de um ID ativo.
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  
Uso: TMSAC20
@sample
//MenuDef()
@author Katia 
@since 19/08/2021
@version 12.1.35
/*/
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0011  ACTION "TMSAC20Pln()" 	OPERATION 2 ACCESS 0 // "Planos TPR"
	ADD OPTION aRotina TITLE STR0007  ACTION "AxPesqui"        	OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAC20" 	OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAC20" 	OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAC20" 	OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAC20" 	OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0008  ACTION "TMSAC20Con()" 	OPERATION 6 ACCESS 0 // "Testar Conexão"

Return(aRotina)  

/*/{Protheus.doc} TMSAC20Con
Função para Testar a Conexão
@author Katia
@since  20/08/2021
@version P12.1.35
@return lRet
/*/
Function TMSAC20Con()
Local lRet		:= .T. 
Local oTPRNeolog:= Nil

If DLV->DLV_MSBLQL == '1'
	Help("",1,"TMSAC2003") //-- Não será possível validar a conexão! O roteirizador não está ativo, verifique.
Else	
	oTPRNeolog:= TMSBCATPRNeolog():New() 

	If !oTPRNeolog:Auth()
		lRet:= .F.
		oTPRNeolog:ShowError()
	Else
		MsgInfo( STR0009 )   //Token Autorizado
	EndIf 
EndIf

FwFreeObj(oTPRNeolog)

Return lRet 

/*/{Protheus.doc} TMSAC20Vld
Validação de campos
@author Katia
@since  15/10/2021
@version P12.1.35
@return lRet
/*/
Function TMSAC20Vld()
Local lRet    := .T.
Local cCampo  := ReadVar()
Local cTmpExp := ""
Local nPos    := 0
Local nHora   := 0
Local cCdrOri := Padr(GetMv("MV_CDRORI",,""),Len(DA8->DA8_CDRORI))

If cCampo $ 'M->DLV_TMPEXP'
	If !Empty(M->DLV_TMPEXP)
		cTmpExp:= Transform(M->DLV_TMPEXP,x3Picture('DLV_TMPEXP'))
    	nPos   := RAT(':',cTmpExp)
    	nHora  := Val( Left(cTmpExp,nPos-1) )

		If nHora < 24	
		//--- Deverá ser maior/igual a 24 horas, pois existe um tempo de espera e tentativa do CallBack da TPR para processamento.
			Help(,,'HELP',, STR0010 + ' 24 horas', 1, 0) //'O Prazo para expiração deve ser superior a 
			lRet:= .F.
		EndIf		
	EndIf
ElseIf cCampo $ 'M->DLV_ROTA'	
	DA8->(DbSetOrder(1))
	If DA8->(MsSeek(xFilial("DA8")+M->DLV_ROTA))
	 	If DA8->DA8_TIPTRA <> StrZero(1,Len(DA8->DA8_TIPTRA))
			Help(' ', 1, 'TMSAC2004') //"Rota não pertence ao Tipo de Transporte Rodoviario"
			lRet := .F. 
		ElseIf DA8->DA8_SERTMS <> StrZero(3,Len(DA8->DA8_SERTMS)) 
			Help(' ', 1, 'TMSAC2005') //"Rota não pertence ao Serviço de Transporte de Entrega"
			lRet := .F.
		ElseIf DA8->DA8_CDRORI != cCdrOri 
			Help(' ', 1, 'TMSAC2006',,cCdrOri,2,1) //"Rota não pertence a região de origem: "
			lRet := .F.
		ElseIf DA8->DA8_ATIVO == StrZero(2,Len(DA8->DA8_ATIVO))
			Help(' ', 1, 'TMSAC2007',,DA8->DA8_COD,3,1) //"Rota não está ativa no Cadastro de Rotas "
			lRet := .F.
		EndIf
	Else
		Help('',1,'REGNOIS')
		lRet:= .F.
	EndIf	
EndIf

Return lRet


/*/{Protheus.doc} TMSAC20Whe
Condição de Edição de Campo
@author Katia
@since  15/10/2021
@version P12.1.35
@return lRet
/*/
Function TMSAC20Whe()
Local lRet    := .T.
Local cCampo  := ReadVar()

If cCampo $ 'M->DLV_ROTA'
	lRet:= M->DLV_ROTERI == '2'  //Campo habilitado somente para TPR
EndIf

Return lRet

/*/{Protheus.doc} TMSAO20ROT
Valida o Cadastro do Roteirizador, permitindo apenas um ID Ativo
Uso: TMSAC20
@author Katia
@since  20/08/2021
@version 12.1.35
@return lRet
/*/
Function TMSAO20ROT(cRoteri)
Local lRet       := .T.
Local lCmpRoteri := DLV->(ColumnPos('DLV_ROTERI')) > 0 
Local aAreaDLV	 := DLV->(GetArea())

Default cRoteri  := '1'   //1-Maplink, 2-TPR Neolog

DLV->(dbSetOrder(1))
If DLV->( dbSeek( xFilial("DLV")  )) 
	While DLV->( !Eof() ) .And. DLV->DLV_FILIAL == xFilial("DLV")
		If DLV->DLV_ID <> FwFldGet("DLV_ID") .And. DLV->DLV_MSBLQL == "2" .And. FwFldGet("DLV_MSBLQL") == "2" .And. DLV->DLV_MSBLQL == "2"	
			If lCmpRoteri 
				If cRoteri == '1'
					lRet:= !Empty(DLV->DLV_ROTERI) .And. DLV->DLV_ROTERI <> cRoteri
				Else
					lRet:= Empty(DLV->DLV_ROTERI) .Or. (!Empty(DLV->DLV_ROTERI) .And. DLV->DLV_ROTERI <> cRoteri)
				EndIf
			Else
				lRet:= .F.
			EndIf

			If !lRet
				Exit
			EndIf
		EndIf
		DLV->(dbSkip())
	EndDo
EndIf

RestArea(aAreaDLV)
Return lRet


/*/{Protheus.doc} TMSAC20Pln
Dispara a URL de planos TPR no navegador padrão do usuário
@author Equipe OMS
@since  10/11/2021
@version P12.1.35
@return 
/*/
Function TMSAC20Pln()
	Local cURLPlaPrd := "https://planejamentorotas.totvs.com/#/tpr/plan/"     //URL Ambiente Produção
	//Local cURLPlaTst := "https://planejamentorotasqa.totvs.com/#/tpr/plan/"   //URL Ambiente Teste

	If Empty(DLV->DLV_TOKEN)
		MsgAlert(STR0013 + STR0014, STR0012)
		//"O token (DLV_TOKEN) de integração não foi previamente gerado. 
		//Para gerar o token e acessar os Planos TPR disponíveis realize os seguintes passos: 1-Clique em alterar, 2-Informe a URL Token (DLV_URLTK), 3-Confirme, 4-Clique no botão Testar Conexão, 5-Realize a ativação do token recebido via e-mail.", "Atenção"
	Else
		//---- IMPORTANTE
		//O link informado na cURLPlaPrd é para o ambiente de Produção
		//Para Ambiente de Testes é necessário mudar o link para URL de Teste (cURLPlaTst) 
		//ShellExecute("Open", cURLPlaTst + DLV->DLV_TOKEN, "", "", 1)
		ShellExecute("Open", cURLPlaPrd + DLV->DLV_TOKEN, "", "", 1)
	EndIf

Return

/*/{Protheus.doc} TMSAC20Rot
Retorna o campo ROTA
@author Katia
@since  22/11/21
@version P12.1.35
@return 
/*/
Function TMSAC20Rot(cRoteiri)
Local cQuery   := ""
Local cAliasQry:= GetNextAlias()
Local cRet     := CriaVar('DF8_ROTA', .F.)

Default cRoteiri:= ""

    cQuery := " SELECT DLV_ROTA FROM "
    cQuery += RetSqlName("DLV") + "  DLV "
    cQuery += "   WHERE DLV_FILIAL = '" + xFilial("DLV") + "' "
    cQuery += "   AND DLV_ROTERI = '" + cRoteiri + "' "
    cQuery += "   AND DLV_MSBLQL = '2'
    cQuery += "   AND D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasQry, .T., .T.)
    If (cAliasQry)->( !Eof() )
        cRet:= (cAliasQry)->DLV_ROTA
    EndIf

    (cAliasQry)->(dbCloseArea())

Return cRet
