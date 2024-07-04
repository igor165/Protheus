#include "VDFA110.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFA110
Abono Permanência Cadastramento do Direito.
@author Everson S P Junior
@since 22/01/2014
@version P11
/*/
//-------------------------------------------------------------------
Function VDFA110()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SRA')
oBrowse:SetDescription(STR0001)//'Abono Permanência'
//oBrowse:DisableDetails()
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Abono Permanência Cadastramento do Direito.
@author Everson S P Junior
@since 22/01/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.VDFA110' OPERATION 4 ACCESS 0	//'Manutenção'
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.VDFA110' OPERATION 5 ACCESS 0	//'Excluir'

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Abono Permanência Cadastramento do Direito.
@author Everson S P Junior
@since 22/01/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruRIJ := FWFormStruct( 1, 'RIJ', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

oStruRIJ:SetProperty("RIJ_MAT", MODEL_FIELD_OBRIGAT, .F. )

// Altera a origatoriedade dos campos
oStruRIJ:SetProperty( 'RIJ_VALRET', MODEL_FIELD_OBRIGAT, .T.)
oStruRIJ:SetProperty( 'RIJ_PAGTO' , MODEL_FIELD_OBRIGAT, .T.)
oStruRIJ:SetProperty( 'RIJ_PARCEL', MODEL_FIELD_OBRIGAT, .T.)

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('VDFA110M', /*bPreValidacao*/, {|oModel| IIf( VDFSETVAL(oModel,SRA->RA_MAT),VDF110PUBL(oModel),.T.)}, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'RIJMASTER', /*cOwner*/, oStruRIJ, /*bPreValidacao*/, /*bPosValidacao*/, {|oModel| VDFQRYRIJ(oModel,SRA->RA_FILIAL,SRA->RA_MAT)} )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0004 )//'Cadastramento do Direito'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'RIJMASTER' ):SetDescription( STR0004 )//'Cadastramento do Direito'

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Abono Permanência Cadastramento do Direito.
@author Everson S P Junior
@since 22/01/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'VDFA110' )
Local oStruRIJ := FWFormStruct( 2, 'RIJ' )
// Cria a estrutura a ser usada na View
Local oView  

oStruRIJ:RemoveField("RIJ_MAT") 	// Retira a matricula da ViewDef
oStruRIJ:RemoveField("RIJ_NUMID") 	// Retira o NumId da ViewDef

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_RIJ', oStruRIJ, 'RIJMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_RIJ', 'TELA' )

oView:AddUserButton( STR0015,"CLIPS",{|oView|VDFCALRET(oView),oView:Refresh()})	//'Calc.Retro'

oView:SetCloseOnOk({||.T.})

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} VDFQRYRIJ
Abono Permanência Cadastramento do Direito.
@author Everson S P Junior
@since 22/01/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function VDFQRYRIJ(oMdl,cRaFilial,cRaMat)
Local cQuery := ""
Local cTmpRIJ    := GetNextAlias()

BeginSql alias cTmpRIJ
	COLUMN RIJ_DSOLIC	AS DATE
	COLUMN RIJ_DINDIR	AS DATE                             
	COLUMN RIJ_PAGTO 	AS DATE
	SELECT * FROM %table:RIJ%  RIJ
	WHERE 
	RIJ.RIJ_FILIAL = %exp:cRaFilial%
	AND RIJ.RIJ_MAT = %exp:cRaMat% 
	AND RIJ.%NotDel%
	
	ORDER BY RIJ_MAT

EndSql	
aRet := FwLoadByAlias( oMdl, cTmpRIJ )
(cTmpRIJ)->(DbCloseArea())

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VDFSETVAL
Abono Permanência Cadastramento do Direito.
@author Everson S P Junior
@since 22/01/2014
@version P11
/*/
//-------------------------------------------------------------------
Function VDFSETVAL(oModel,cMat)
Local lRet		:= .T.
Local nExclui	:= oModel:GetOperation()
Local oRIJ		:= oModel:GetModel("RIJMASTER")

If nExclui <> 5
	oRIJ:SetValue("RIJ_FILIAL",xFilial("SRA"))
	oRIJ:SetValue("RIJ_MAT",cMat)
EndIf
If oRIJ:GetValue("RIJ_DSOLIC") == oRIJ:GetValue("RIJ_DINDIR")
	If oRIJ:GetValue("RIJ_VALRET") > 0
		Help(,,"Help",,STR0005,1,0)	//'O valor Retroativo deve ser igual a 0,00'
		lRet := .F.
	EndIf	
EndIf 

If oRIJ:GetValue("RIJ_DSOLIC") > oRIJ:GetValue("RIJ_DINDIR")
	If oRIJ:GetValue("RIJ_VALRET") == 0
		Help(,,"Help",,STR0006,1,0)	//'O valor Retroativo deve ser informado. Utilize Ações Relacionadas.'
		lRet := .F.
	ElseIf Empty(oRIJ:GetValue("RIJ_PAGTO"))
		Help(,,"Help",,STR0007,1,0)//'Data de Pagamento deve ser informado'
		lRet := .F.
	ElseIf EMPTY(oRIJ:GetValue("RIJ_PARCEL"))
		Help(,,"Help",,STR0008,1,0)//'Numero de parcelas deve ser informado'
		lRet := .F.
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VDFCALRET
Abono Permanência Cadastramento do Direito.
@author Everson S P Junior
@since 22/01/2014
@version P11
/*/
//-------------------------------------------------------------------
Function VDFCALRET(oView)
	
	Local cId0064	 	:= FgetCodFol("0064") + "/" + FgetCodFol("1374")
	Local oModel 	  	:= FWModelActive()
	Local oModelRIJ 	:= oModel:GetModel( 'RIJMASTER' )
	Local dPerIni		:= oModelRIJ:GetValue("RIJ_DINDIR")
	Local dPerFim		:= IIF(Empty(oModelRIJ:GetValue("RIJ_DSOLIC")), "", MonthSub(oModelRIJ:GetValue("RIJ_DSOLIC"), 1))
	Local nValor		:= 0
	Local nQtd			:= 0
	
	If Empty(dPerIni) .Or. Empty(dPerFim)
		Help(,,"Help", , STR0009, 1, 0)//'Informar Dt.Ini.Pagto e Dt.Ini.Direi'
		Return
	EndIf
	
	fBuscaAcmPer(cId0064,, "V", @nValor, @nQtd, Year2Str(dPerIni) + Month2Str(dPerIni), Year2Str(dPerFim) + Month2Str(dPerFim), , , NIL, .F., .F., ,)
	
	nValor:= (nValor * (-1))
	
	If oModelRIJ:SetValue("RIJ_VALRET", nValor) .AND. !Empty(nValor)
		oView:Refresh()
		Help(,, "Help",, STR0010, 1, 0) // 'Valor Retroativo foi efetuado com Sucesso'
	Else
		Help(,, "Help",, STR0011 + Dtoc(dPerIni) + ' até ' + Dtoc(dPerFim), 1, 0) // 'Valor retroativo não encontrado para o período de '
	EndIf
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} VDF110ValDt
Valida as datas do VDFA110 - RIJ
@author IP RH GPS
@since 18/03/2014
@version P11
/*/
//-------------------------------------------------------------------
Function VDF110ValDt(cCampo)
Local lRet  := .F.
Local lErr1 := .F.
Local lErr2 := .F.
Local aPerAtual := {}

Default cCampo := ""

//-fGetPerAtual( aPerAtual, cFilRCH, cProcesso, cRoteiro )
fGetPerAtual( @aPerAtual,,SRA->RA_PROCES,fGetRotOrdinar(.F.,SRA->RA_FILIAL) )

//-aPerAtual, { RCH_PER, RCH_NUMPAG, RCH_ROTEIR, RCH_MES, RCH_ANO, RCH_DTINI, RCH_DTFIM, RCH_PROCES } 
If Len(aPerAtual) == 0
	Help(,,"Help",,STR0012, 1,0)//'Periodo em Aberto não localizado!'
Else
	If Alltrim(cCampo) == "RIJ_DSOLIC"	//-Data Inicio do Pagamento
		If M->RIJ_DSOLIC >= aPerAtual[1,6]
			lRet := .T.
		Else
			lErr1 := .T.
		EndIf
	ElseIf Alltrim(cCampo) == "RIJ_DINDIR"	//-Data Inicio do Direito
		lRet := .T.
		If YEAR(M->RIJ_DINDIR) < Val(SubStr(fGetFolmes(),1,4))
			MsgAlert(STR0016,STR0017)	//'O Valor Retroativo informado deve refletir somente o total do ano do Período em Aberto. Valores de anos anteriores devem ser pagos por meio de RRA em rotina específica!',"Atenção!")
		EndIf
	ElseIf Alltrim(cCampo) == "RIJ_PAGTO"	//-Dt.Pagto 1. Mes/Retroativo
		If M->RIJ_PAGTO >= aPerAtual[1,6]
			lRet := .T.
		Else
			lErr1 := .T.
		EndIf
	EndIf
	If lErr1
		//-help(cRotina,nLinha,cCampo,cNome,cMensagem,nLinha1,nColuna,lPop,hWnd,nHeight,nWidth,lGravaLog)
		Help(,,"Help",,STR0013+aPerAtual[1,1], 1,0)//'Data informada tem que ser maior ou igual ao Periodo em Aberto - Cód.: '
	EndIf
	If lErr2
		//-help(cRotina,nLinha,cCampo,cNome,cMensagem,nLinha1,nColuna,lPop,hWnd,nHeight,nWidth,lGravaLog)
		Help(,,"Help",,STR0014+aPerAtual[1,1], 1,0)//'Não é permitido informar data de anos anteriores ao do Periodo em Aberto - Cód.: '
	EndIf
EndIf
/*
vamos permitir ele colocar qualquer data retroativa. 
Se for ano anteiror, dar um alerta para o usuário dizendo que deverá ajustar no cadastro o valor para refletir somente os meses do ano corrente, e 
que deverá pagar os demais meses como RRA em rotina específica.
*/
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} VDF110PUBL
Chama rotina de Publicação de Ato/Portaria
@author IP RH GPS
@since 18/03/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function VDF110PUBL(oModel)
	Local cRetRI6  := QueryRI6( DToS(M->RIJ_DSOLIC),SRA->RA_FILIAL,SRA->RA_MAT,"RIJ" )
	Local aParTela := {"VDFA110",;       //aParametro[1] Fonte que chamou.
				  SRA->RA_MAT,;          //aParametro[2] RA_MAT Matricula do Funcionario.
				  SRA->RA_CATFUNC,;      //aParametro[3] CatFunc Categoria do Funcionario.
				  DToS(M->RIJ_DSOLIC),;  //aParametro[4] Chave 	Para gravação do Historioco RI6
				  SRA->RA_FILIAL,;       //aParametro[5] Filial do funcionario transferido
				  SRA->RA_CIC,;          //aParametro[6] CPF Do funcionario transferido
				  M->RIJ_DSOLIC,;        //aParametro[7] Data de Efeito
				  "1",;                  //aParametro[8] Indice da tabela
				  "RIJ",;                //aParametro[9] Alias da tabela
				  "",;                   //aParametro[10] Data Base Inicio
				  "",;                   //aParametro[11] Data Base Fim
				  "",;                   //aParametro[12] Data Inicio Gozo
				  "",;                   //aParametro[13] Data Fim Gozo
				  "",;                   //aParametro[14] Dias de Gozo/Direito
				  "",;                   //aParametro[15] Dias Indenizados
				  "",;                   //aParametro[16] Dias Oportunos
				  "",;                   //aParametro[17] Filial do Substituto
				  "",;                   //aParametro[18] Matricula do Substituto
				  "",;                   //aParametro[19] Nome do Substituto
				  "",;                   //aParametro[20] Tipo de Dia de Direito
				  0,;                    //aParametro[21] Dias Remanescentes
				  "",;                   //aParametro[22] Ato/Portaria Anterior
				  "",;                   //aParametro[23] Data da Suspensão
				  "";                    //aParametro[24] Descrição do Status da Linha
				  }

	If oModel:GetOperation() <> 5
		If cRetRI6 == "NP"
			ExcluiRI6()
		EndIf

		VDFA060(aParTela)
	Else
		If cRetRI6 == "P" 
			Help(,,STR0018,,STR0019,1,0, NIL, NIL, NIL, NIL, NIL, {STR0020}) //O registro não pode ser excluído, pois já foi publicado.
			Return .F.
		ElseIf cRetRI6 == "NP"
			ExcluiRI6()
		EndIf
	EndIf
Return(.T.)
