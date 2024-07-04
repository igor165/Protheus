#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA665APL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA665APL

Tela de configuração de aprovação automática de viagens 

@author Antonio Florêncio Domingos Filho
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function FINA665APL()
Local oBrowse

_SetNamedPrvt("aTabelas",{},"FINA665APL")

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FL5' )
oBrowse:SetDescription(STR0001) //"Aprovação em Lote"
oBrowse:Activate()

Return 

/*/{Protheus.doc} MenuDef
Definição de Menu

@author Antonio Florêncio Domingos Filho
@since 14/05/2015
@version 12.1.6
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002  Action 'FN665ALP()'  OPERATION 4 ACCESS 0	//'Aprov. Solicitação'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do Modelo de Dados

@author Antonio Florêncio Domingos Filho
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	  := Nil
Local oStruct	  := FWFormModelStruct():New() 
Local oStruFL5  := FWFormStruct(1,'FL5', {|cCampo|(AllTrim(cCampo) $ "FL5_VIAGEM|FL5_CODORI|FL5_CODDES|FL5_DESORI|FL5_DESDES|FL5_DTINI|FL5_DTFIM|FL5_IDSOL|FL5_STATUS|FL5_OBS") } )		  // FL5 - Solicitação de Viagens	
Local oStruFL6  := FWFormStruct(1,'FL6')		  // FL6 - SUP_RESERVas.

//Criação do Modelo de Dados
oModel := MPFormModel():New('FINA665APL', /*bPreValidacao*/, /*{ |oModel| AF036Pos(oModel) }/*bPosValidacao*/, /*bGravacao*/ , /*bCancel*/ )
//Criando master falso para a alimentação dos details.
oStruct:AddTable('FL0',,'FL0')
oStruct:AddField(		  ;
"Campo01"		, ;	// [01] Titulo do campo		//"Nome Fornecedor"
"Campo01"		, ;	// [02] ToolTip do campo	//"Nome Fornecedor"
"FL5_CPO"		, ;	// [03] Id do Field
"C"				, ;	// [04] Tipo do campo
1				, ;	// [05] Tamanho do campo
0				, ;	// [06] Decimal do campo
{ || .T. }		, ;	// [07] Code-block de validação do campo
{ || .T. }		, ;	// [08] Code-block de validação When do campo
				, ;	// [09] Lista de valores permitido do campo
.F.)				// [10] Indica se o campo tem preenchimento obrigatório

oModel:AddFields('FL0MASTER', /*cOwner*/, oStruct , , ,{|| {}} )
oModel:AddGrid('FL5DETAIL','FL0MASTER',oStruFL5)
oModel:AddGrid('FL6DETAIL','FL5DETAIL',oStruFL6)

oModel:SetRelation('FL6DETAIL', {{'FL6_FILIAL', 'XFILIAL("FL5")'}, {'FL6_VIAGEM', 'FL5_VIAGEM'}}, FL6->(IndexKey(1)))
	
//Adicional campo OK para controle da operação
oStruFL5:AddField('','' , 'OK', 'L', 1, 0, /*bValid */	, , {}	, .F.	, , .F., .t., .F., , )//''#//'Seleção'

//Descrição
oModel:SetDescription(STR0003) // "Aprovação"
oModel:GetModel('FL5DETAIL' ):SetDescription(STR0004)	//'Viagens' 
oModel:GetModel('FL6DETAIL' ):SetDescription(STR0005)	//'Serviços'

//Permite a deleção de todas as linhas do Grid
oModel:GetModel('FL5DETAIL'):SetDelAllLine(.F.)
oModel:GetModel('FL6DETAIL'):SetDelAllLine(.F.)

//Desabilita a Gravação automatica do Model
oModel:GetModel( 'FL0MASTER'):SetOnlyQuery ( .T. )
oModel:GetModel( 'FL5DETAIL'):SetOnlyQuery ( .T. )
oModel:GetModel( 'FL6DETAIL'):SetOnlyQuery ( .T. )

oModel:GetModel( 'FL5DETAIL'):SetOptional( .T. )
oModel:GetModel( 'FL6DETAIL'):SetOptional( .T. )

oModel:SetPrimarykey({})

oModel:SetActivate( {|oModel| F665APLCarga(oModel) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da Interface

@author Antonio Florêncio Domingos Filho
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   	:= FWLoadModel('FINA665APL')         //Carrega o model
Local oView     	:= FWFormView():New()	          //Objeto da view
Local oStruFL5	:= FWFormStruct(2,'FL5', {|cCampo|(AllTrim(cCampo) $ "FL5_VIAGEM|FL5_CODORI|FL5_CODDES|FL5_DESORI|FL5_DESDES|FL5_DTINI|FL5_DTFIM") } )	
Local oStruFL6 	:= FWFormStruct(2,'FL6', {|cCampo|(AllTrim(cCampo) $ "FL6_ITEM/FL6_TIPO/FL6_DTCRIA/FL6_NOMESO/FL6_TOTAL") } )

//Não permite alteração dos campos.
oStruFL5:RemoveField( 'FL5_STATUS' )
oStruFL5:SetProperty("*", MVC_VIEW_CANCHANGE, .F. )
oStruFL6:SetProperty("*", MVC_VIEW_CANCHANGE, .F. )
oView:SetModel(oModel)
//-----------Cria Grid-----------------------//
oView:AddGrid('VIEW_FL5',oStruFL5,'FL5DETAIL')
oView:AddGrid('VIEW_FL6',oStruFL6,'FL6DETAIL')

oStruFL5:AddField( 'OK' ,'01','','',, 'Check' ,,,,,,,,,,,, ) //''#//''
oStruFL5 := FWFormStruct(2,'FL5')		  // FL5 - Viagens Solicitadas	
oStruFL6 := FWFormStruct(2,'FL6')		  // FL6 - Pedidos

/*
 * Criar "box" horizontal para receber algum elemento da view
 */
oView:CreateHorizontalBox('BOXAD'		,50) //Viagens Solicitadas
oView:CreateHorizontalBox('BOXPC'		,50) //Pedidos
/*
 * Relaciona o ID da View com o "box" para exibicao
 */
oView:SetOwnerView('VIEW_FL5'		,'BOXAD' )	// 
oView:SetOwnerView('VIEW_FL6'		,'BOXPC')	// 
/*
 * Habilita a exibição do titulo
 */
oView:EnableTitleView('VIEW_FL5'	, STR0006) //'Viagens Solicitadas'
oView:EnableTitleView('VIEW_FL6'	, STR0007) //'Pedidos'

oView:AddUserButton(STR0008,STR0010,{|oView|FN665APLAPR(oView,.f.)}) //'Aprovar'#'Ok'
oView:AddUserButton(STR0009,STR0010,{|oView|FN665APLREP(oView,.f.)}) //'Reprovar'#'Ok'

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F665APLCarga

Realiza a carga de dados nas grides de acordo com a tabela FW0

@author Antonio Florêncio Domingos Filho

@since 23/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function F665APLCarga(oModel)
Local cViagem	:= ""
Local oModelFL0	:= oModel:GetModel('FL0MASTER')
Local oModelFL5	:= oModel:getModel('FL5DETAIL')
Local oModelFL6	:= oModel:getModel('FL6DETAIL')
Local oView		:= FWViewActive() 
Local nCont 		:= 1
Local cQuery 		:= ''
Local aArea    	:= GetArea()
Local cTmp      	:= CriaTrab(,.F.)

cQuery += 'SELECT  DISTINCT FL5_VIAGEM,FL5_DTINI,FL5_DTFIM,FL5_NACION,FL5_CLIENT,FL5_LOJA,FL5_CODORI,FL5_STATUS,FL5_IDSOL,'+chr(13)+chr(10) 
cQuery += 'FL5_DESORI,FL5_CODDES,FL5_DESDES,FL5_DESDES,FL6_VIAGEM,FL6_ITEM,FL6_TIPO,FL6_DTCRIA,FL6_NOMESO,FL6_TOTAL '+chr(13)+chr(10)
cQuery += ' FROM ' + RetSqlName("FL5") + " FL5 "+chr(13)+chr(10)
cQuery += 'INNER JOIN ' + RetSqlName("FL6") + " FL6 "+chr(13)+chr(10)
cQuery += "ON FL6_FILIAL = '" + xFilial("FL6") + "' AND FL6_VIAGEM = FL5_VIAGEM "+chr(13)+chr(10)
cQuery += 'INNER JOIN ' + RetSqlName("FLJ") + " FLJ "+chr(13)+chr(10)
cQuery += "ON FLJ_FILIAL = '" + xFilial("FLJ") + "' AND FL6_VIAGEM = FL5_VIAGEM "+chr(13)+chr(10)
cQuery += 'INNER JOIN ' + RetSqlName("FW3") + " FW3 "+chr(13)+chr(10)
cQuery += "ON FW3_FILIAL = '" + xFilial("FL5") + "' AND FW3_SOLICI = FL5_IDSOL "+chr(13)+chr(10)
cQuery += "WHERE FL5_FILIAL = '" + xFilial("FL5") + "'"+chr(13)+chr(10)
cQuery += "AND FL5_STATUS = '5' "+chr(13)+chr(10)
cQuery += "AND FL5.FL5_IDSOL != ' ' "+chr(13)+chr(10)
cQuery += "AND FL5.D_E_L_E_T_ = ' ' "+chr(13)+chr(10) 
cQuery += "AND FL6.D_E_L_E_T_ = ' ' "+chr(13)+chr(10)
cQuery += "AND FLJ.D_E_L_E_T_ = ' ' "+chr(13)+chr(10)
cQuery += "AND ( FLJ.FLJ_PARTIC IN "+chr(13)+chr(10)
cQuery += "( SELECT RD0_CODIGO FROM " + RetSqlName("RD0") + " RD0 "+chr(13)+chr(10)
cQuery += "  WHERE RD0.RD0_USER = '"+ __cUserId+"' "+chr(13)+chr(10)
cQuery += "	 AND RD0.D_E_L_E_T_ = ' ' ) "+chr(13)+chr(10)
cQuery += "OR FLJ.FLJ_PARTIC = '' AND FW3_USER IN "+chr(13)+chr(10)
cQuery += "( SELECT RD0_CODIGO FROM " + RetSqlName("RD0") + " RD0 "+chr(13)+chr(10)
cQuery += "  WHERE RD0.RD0_USER = '"+ __cUserId+"' "+chr(13)+chr(10)
cQuery += "AND RD0.D_E_L_E_T_ = ' ' ) ) "+chr(13)+chr(10)
cQuery += "AND FW3.D_E_L_E_T_ = ' ' "+chr(13)+chr(10)
cQuery += " ORDER BY FL5_VIAGEM	"+chr(13)+chr(10)

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)

TcSetField(cTmp, "FL5_DTINI"   , "D", TamSx3("FL5_DTINI")  [1], TamSx3("FL5_DTINI")[2])
TcSetField(cTmp, "FL5_DTFIM"   , "D", TamSx3("FL5_DTFIM")  [1], TamSx3("FL5_DTFIM") [2])
TcSetField(cTmp, "FL6_DTCRIA"  , "D", TamSx3("FL6_DTCRIA") [1], TamSx3("FL6_DTCRIA") [2])

dbSelectArea(cTmp)
dbGoTop()

While !(cTmp)->(Eof())
	If cViagem <> FL5_VIAGEM
		cViagem := FL5_VIAGEM
		//Viagem Solicitadas
		If !oModelFL5:IsEmpty()
			oModelFL5:AddLine()
		EndIf
		oModelFL0:SetValue("FL5_CPO","1") 
		oModelFL5:SetValue("OK", .F. )
		oModelFL5:LoadValue("FL5_VIAGEM",FL5_VIAGEM)
		oModelFL5:LoadValue("FL5_DTINI",FL5_DTINI )
		oModelFL5:LoadValue("FL5_DTFIM",FL5_DTFIM)
		oModelFL5:LoadValue("FL5_CODORI",FL5_CODORI)
		oModelFL5:LoadValue("FL5_DESORI",FL5_DESORI)
		oModelFL5:LoadValue("FL5_CODDES",FL5_CODDES)
		oModelFL5:LoadValue("FL5_DESDES",FL5_DESDES)
		oModelFL5:LoadValue("FL5_IDSOL",FL5_IDSOL)
	EndIf
	
	While !Eof() .And. FL5_VIAGEM = cViagem
	
		If !oModelFL6:IsEmpty()
			oModelFL6:AddLine()
		EndIf
		oModelFL6:LoadValue("FL6_ITEM",FL6_ITEM)
		oModelFL6:LoadValue("FL6_TIPO",FL6_TIPO)
		oModelFL6:LoadValue("FL6_DTCRIA",FL6_DTCRIA)
		oModelFL6:LoadValue("FL6_NOMESO",FL6_NOMESO)
		oModelFL6:LoadValue("FL6_TOTAL",FL6_TOTAL)
	
		(cTmp)->(DbSkip())
	
	EndDo
	
EndDo

If oView != Nil
	/* Bloqueia a inclusão de novas linhas */
	oView:SetNoInsertLine('FL5DETAIL')
	oView:SetNoInsertLine('FL6DETAIL')
	/* Bloqueia a exclusão de linhas do grid */
	oView:SetNoDeleteLine('FL5DETAIL')
	oView:SetNoDeleteLine('FL6DETAIL')
EndIf

(cTmp)->(dbCloseArea())
RestArea(aArea)

Return 

/*/{Protheus.doc} FN665APLAPR(oView)
Aprovação da Viagem Solicitada

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN665APLAPR(oView)
Local oModel665	:= Nil
Local cLog			:= ""
Local aArea 		:= GetArea()
Local oModel    	:= FWModelActive()
Local oModelFL5 	:= oModel:GetModel('FL5DETAIL')
Local cTo       	:= ""
Local cAssunto	:= STR0011 //"Aprovação da Viagem Solicitada" 
Local cMensagem	:= ""
Local cRegistro	:= ""
Local cEntidade 	:= "FL5"
Local cProcesso 	:= ""
Local lRet      	:= .F.
Local nLayout   	:= 5
Local nInteressado := 1
Local cStatus   	:= STR0012 //"Aprovada"
Local nI			:= 0
Local nX			:= 0
Local aAprv			:= FResAprov("1") //"1" = Adiantamentos
Local lAprov		:= .F.
Local cViagem		:= ""
Local aAdiaFLD		:= {}

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/
If !aAPrv[1] .AND. !aAPrv[2] // Aprovação Automatica.
	lAprov := .T.
ElseIf aAPrv[1] .AND. !aAPrv[2] // Aprovação Automatica
	lAprov := MsgYesNo(STR0045, STR0046)//"Deseja Aprovar todos os Adiantamentos vinculados nesta Solicitação de Viagem?" "Atenção!"
EndIf

DbSelectArea("FLD")
FLD->( DbSetOrder(1) ) // FLD_FILIAL + FLD_VIAGEM + FLD_PARTIC

For nI := 1 To oModelFL5:Length()

	If oModelFL5:GetValue('OK', nI)
		cViagem := oModelFL5:GetValue('FL5_VIAGEM', nI)
		cRegistro := "VIAGEM " + cViagem
		cProcesso := "SOLICITAÇÃO " + oModelFL5:GetValue('FL5_IDSOL', nI)
		
		//-----------------------------------------
		//Processo de Atualização da Solicitação
		//-----------------------------------------
		If FW3->(dbSeek(xFilial("FW3") + oModelFL5:GetValue('FL5_IDSOL', nI)))

			If FL5->(dbSeek(xFilial("FL5")+oModelFL5:GetValue('FL5_VIAGEM', nI)))
				
				//Carrega o modelo de dados para gerar adiantamento e prestação de contas para os viajantes.
				oModel665 := FWLoadModel("FINA665")
				oModel665:SetOperation( MODEL_OPERATION_VIEW )
				oModel665:Activate()
				//Gera Prestação de Contas.
				F677GerPC(oModel665)
				
				//Aprova os Adiantamentos.
				If lAprov
				
					oModelFLC:= oModel665:GetModel("FLCDETAIL")
					oModelFLD:= oModel665:GetModel("FLDDETAIL")
					
					For nX := 1 To oModelFLC:Length()
						
						oModelFLC:GoLine(nX)
						
						If !oModelFLD:IsEmpty()

							If FLD->( DbSeek( xFilial('FLD') + cViagem + oModelFLD:GetValue("FLD_PARTIC") ) )
								Reclock("FLD",.F.)
									FLD->FLD_VALAPR := oModelFLD:GetValue("FLD_VALOR")
									FLD->FLD_DTPREV := F666DtPrev()
								FLD->(MsUnlock())
								AAdd( aAdiaFLD , { xFilial('FLD') + cViagem + oModelFLD:GetValue("FLD_PARTIC") } )
							EndIf
						EndIf
					Next nX
				EndIf
				
				oModel665:DeActivate()
				oModel665:Destroy()
				//
				Reclock("FL5",.F.)
					FL5->FL5_STATUS := '1'
				FL5->(MsUnlock())
			EndIf

			//Atualiza o Status da Solicitação Para Finalizada
			RecLock("FW3",.F.)
				FW3->FW3_STATUS := "4" //Finalizada //Status 0=Em Aberto;1=Conferencia;2=Cancelada;3=Aguardando Aprovacao;4=Finalizada
			FW3->(MsUnlock())
			//Envia email para o Aprovador
			dbSeek(xFilial("FLJ")+oModelFL5:GetValue('FL5_VIAGEM', nI),.T.) 
			
			If Found() .And. FLJ->FLJ_FILIAL==xFilial("FLJ") .And. FLJ->FLJ_VIAGEM == FL5->FL5_VIAGEM
			
				dbSeek(xFilial("RD0")+FLJ->FLJ_PARTIC)
				
				cTo := F665DUser(RD0->RD0_APROPC) //alltrim(RD0->RD0_EMAIL)
				
				If !Empty(cTO)
			
					cMensagem += F665LDtVg(oView,cStatus) //Detalhamento da Viagem			
			
					FINXRESEMa(cMensagem,cEntidade,cProcesso,cRegistro,cTO,cAssunto)
		
				Else
					Help(" ",1,"F665NOEMAIL",,STR0013,1,0) //Aprovador não tem email cadastrado	
				EndIf
			EndIf
		Else
			Help(" ",1,"F665NOSOLIC",,STR0014+" "+oModelFL5:GetValue('FL5_IDSOL', nI)+" "+STR0015,1,0) //"Solicitaçao#"não cadastrada!"
		EndIf

	EndIf

Next nI

If oModel:VldData()
	oModel:CommitData()
	If lAprov
		
		DbSelectArea("FLD")
		FLD->( DbSetOrder(1) )
		For nX := 1 To Len(aAdiaFLD)
			// FLD_FILIAL + FLD_VIAGEM + FLD_PARTIC
			If FLD->( MSSeek( aAdiaFLD[nX][1] ) )
				FI667APGES( FLD->FLD_VIAGEM, FLD->FLD_PARTIC, FLD->FLD_ADIANT, .F. )
				F667CanFlu( FLD->FLD_VIAGEM, FLD->FLD_PARTIC, FLD->FLD_ADIANT )
			EndIf
		Next nX
	EndIf
	
Else
	cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[6])            
	Help( ,,"F770RETTIT",,cLog, 1, 0 )    
	lRet := .F.  
EndIf

oView:Refresh()

// Define fechamento da tela
oView:ButtonOkAction(.T.)

RestArea(aArea)

Return lRet

/*/{Protheus.doc} FN665ASL()
Aprovação da solicitação
@author Antonio Florêncio Domingos Filho
@since 23/06/2015
@version 12.1.6
/*/
Function FN665ALP(lAutomato)
Local nRet	 			:= 0
Local aArea  			:= GetArea()
Local aUsers			:= {}
Local cTitulo       	:= ""
Local cPrograma     	:= ""
Local nOperation    	:= 0
Local lRet          	:= .T.
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,STR0016},{.T.,STR0017},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local bOk				:= {||}

Default lAutomato		:= .F.

//Valida acesso do usuário
aUsers := FN683PARTI()

If Alltrim(aUsers[1]) == "NO"
	If !lAutomato
		Help(" ",1,"F665USER",,STR0019,1,0) // "Apenas usuários do departamento de viagens deverão ter acesso a essa rotina."
	EndIf
	lRet := .F.
EndIf

If lRet
	FL5->(MsRLock())

	cTitulo      	:= "Aprovação em Lote"
	cPrograma    	:= 'FINA665APL'
	nOperation   	:= MODEL_OPERATION_UPDATE
	If !lAutomato
		nRet        := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
	Else
		lRet := FN665APLREP()
	EndIf
	FL5->(MsRUnlock())
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN665DtVg()
Detalhamento da Viagem - Servicos FL6

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function F665LDtVg(oView,cStatus)

Local aArea 	:= GetArea()
Local oModel    := FWModelActive()
Local oModelFL6 := oModel:GetModel("FL6DETAIL")
Local oModelFL5 := oModel:GetModel("FL5DETAIL")
Local cDetMensg := CHR(13)+CHR(10)+" "
Local cServico	:= ""
Local cMensagem := ""
Local nI

oModelFL5:Activate()

//Cabeçalho da Mensagem
cMensagem += STR0021+" "+oModelFL5:GetValue('FL5_VIAGEM')+" " //"Viagem"
cMensagem += STR0022+" "+oModelFL5:GetValue('FL5_IDSOL')+" "+cStatus+"."+CHR(13)+CHR(10)+CHR(13)+CHR(10) //"da Solicitação"
cMensagem += STR0023+" "+rtrim(oModelFL5:GetValue('FL5_CODORI'))+"-"+rtrim(oModelFL5:GetValue('FL5_DESORI'))+" " //"Origem"
cMensagem += STR0024+" "+rtrim(oModelFL5:GetValue('FL5_CODDES'))+"-"+rtrim(oModelFL5:GetValue('FL5_DESDES'))+"."+CHR(13)+CHR(10)+CHR(13)+CHR(10) //"Destino" 
cMensagem += STR0025+" "+DTOC(oModelFL5:GetValue('FL5_DTINI'))+" " //"Data Inicial "
cMensagem += STR0026+" "+DTOC(oModelFL5:GetValue('FL5_DTFIM'))+"."+CHR(13)+CHR(10)+CHR(13)+CHR(10) //"Data Final" 
If !Empty(oModelFL5:GetValue('FL5_OBS'))
	cMensagem += STR0027+": "+oModelFL5:GetValue('FL5_OBS')+CHR(13)+CHR(10) //"Observação"
EndIf

oModelFL6:Activate()

For nI := 1 To oModelFL6:Length()
				
		oModelFL6:GoLine(nI)

		cDetMensg += oModelFL6:GetValue("FL6_ITEM")
				
		//1=Aereo;2=Hotel;3=Carro;4=Seguro;5=Rodoviario;6=Outros                                                                          
		If oModelFL6:GetValue("FL6_TIPO") == '1'
			cServico := STR0028 //"Aereo"
		ElseIf oModelFL6:GetValue("FL6_TIPO") == '2'	 
			cServico := STR0029 //"Hotel"
		ElseIf oModelFL6:GetValue("FL6_TIPO") == '3'	 
			cServico := STR0030 // "Carro"
		ElseIf oModelFL6:GetValue("FL6_TIPO") == '4'	 
			cServico := STR0031 //"Seguro"
		ElseIf oModelFL6:GetValue("FL6_TIPO") == '5'	 
			cServico := STR0032 //"Rodoviario"
		Else	 
			cServico := STR0033 //"Outros"																					
		Endif
		
		cDetMensg += " "+STR0034+" "+cServico //"Serviço"
		cDetMensg += " "+STR0035+" "+DTOC(oModelFL6:GetValue("FL6_DTCRIA")) //"Data"
		If !Empty(oModelFL6:GetValue("FL6_NOMESO")) 
			cDetMensg += " "+STR0036+" "+oModelFL6:GetValue("FL6_NOMESO") //Participante
		EndIf
		If !Empty(oModelFL6:GetValue("FL6_TOTAL"))
			cDetMensg += " "+STR0037+" "+Alltrim(Str(oModelFL6:GetValue("FL6_TOTAL"),17,2)) //Valor Total
		EndIf
			
Next nI

cMensagem += cDetMenSg

Return cMensagem

//-------------------------------------------------------------------
/*/{Protheus.doc} FN665APLREP()
Reprovação da Viagem

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN665APLREP(oView)
Local nI		:= 0
Local aArea 	:= GetArea()
Local oModel    := FWModelActive()
Local oModelFL5 := oModel:GetModel('FL5DETAIL')
Local cTo       := ""
Local cAssunto	:= STR0038 //"Reprovação da Viagem Solicitada"
Local cMensagem	:= ""
Local cRegistro	:= ""
Local cEntidade := "FL5"
Local cProcesso := ""
Local lRet      := .F.
Local nLayout   := 5
Local nInteressado := 1
Local cStatus   := STR0039 //"Reprovada"
Local cLog		:= ""

For nI := 1 To oModelFL5:Length()

	If oModelFL5:GetValue('OK', nI)

		dbSelectArea("FL5")
		cRegistro := STR0040+" "+oModelFL5:GetValue('FL5_VIAGEM', nI)//"VIAGEM"
		cProcesso := STR0041+" "+oModelFL5:GetValue('FL5_IDSOL', nI) //"SOLICITAÇÃO "
		
		//-----------------------------------------
		//Processo de Atualização da Solicitação
		//-----------------------------------------
		dbSelectArea("FW3")
		dbSetOrder(1)
		dbSeek(xFilial("FW3")+oModelFL5:GetValue('FL5_IDSOL', nI))
		If Found()
			
			
			//-----------------------------------------
			//Atualiza o Status da Solicitação Para Cancelada
			//-----------------------------------------
			RECLOCK("FW3",.F.)
			FW3->FW3_STATUS := "3" //Cancelada - Status 0=Em Aberto;1=Conferencia;2=Cancelada;3=Aguardando Aprovacao;4=Finalizada
			MSUNLOCK()
		
			//-----------------------------------------
			//Atualiza o Status da Viagem para Aguardando Conferência
			//-----------------------------------------
		
			oModelFL5:GoLine( nI )
			oModelFL5:SetValue('FL5_STATUS','4') //Cancelada - 1=Aguardando Conferencia;2=Conferida;3=Finalizada;4=Cancelada;5-Aguardando Aprovação
			
			dbSelectArea("FL5")
			dbSetOrder(1)
			dbSeek(xFilial("FL5")+oModelFL5:GetValue('FL5_VIAGEM', nI))
			If Found()
				RECLOCK("FL5",.F.)
				FL5->FL5_STATUS := '4'
			EndIf
			
			//-----------------------------------------
			//Envia email para o Solicitante
			//-----------------------------------------
			cTo := F665DUser(AllTrim(FW3->FW3_USER)) //alltrim(RD0->RD0_EMAIL)
			
			If !Empty(cTO)
				
				cMensagem += F665LDtVg(oView,cStatus) //Detalhamento da Viagem		
				
				FINXRESEMa(cMensagem,cEntidade,cProcesso,cRegistro,cTO,cAssunto)
		
			Else
				Help(" ",1,"F665NOEMAIL",,STR0042,1,0) //Solicitante não tem email cadastrado!	
			EndIf

		Else
			Help(" ",1,"F665NOSOLIC",,STR0014+" "+oModelFL5:GetValue('FL5_IDSOL', nI)+STR0015,1,0) //"Solicitaçao#"não cadastrada!"
		EndIf

	EndIf

Next

If oModel:VldData()
	oModel:CommitData()
Else
	cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[6])            
	Help( ,,"F770RETTIT",,cLog, 1, 0 )    
	lRet := .F.
EndIf

If !IsBlind()
	oView:Refresh()
	oView:ButtonOkAction(.T.)
EndIf

RestArea(aArea)

Return lRet	
