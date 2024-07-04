//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Define
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
#DEFINE ALIAS_MDCO 	"B72"
#DEFINE ALIAS_MDPO 	"BG9"
#DEFINE PLS_MODELO 	"PLSPARAUD"
//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Modelo de dados Parecer Auditoria Fluig

/*/
//-------------------------------------------------------------------

Function PLSPARAUD()
Local oBrowse
Private aRotina := MenuDef()

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B53' )
oBrowse:SetDescription( "Auditoria Saúde" ) //'Auditoria - Aprovação de Solicitação de Procedimentos'.
oBrowse:Activate()

Return( NIL )

//-------------------------------------------------------------------
/*/MenuDef
Menudef utilizado no cadastros do programa e também na janela de 
movimentação para algumas funcionalidades

@author Saúde
@since 08/2012
@version P11.5
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina 	:= {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'         	, 0, 1, 0, .T. } )
aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSPARAUD'	, 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 				'VIEWDEF.PLSPARAUD'	, 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'   , 				'VIEWDEF.PLSPARAUD'	, 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'   , 				'VIEWDEF.PLSPARAUD'	, 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  , 				'VIEWDEF.PLSPARAUD'	, 0, 8, 0, NIL } )

Return aRotina

Static Function ModelDef()
Local oStrB53 := FWFormStruct(1,'B53')
Local oStrB72 := FWFormStruct(1,'B72')

oModel 	:= MPFormModel():New("PLSPARAUD",,,{|oModel| PLGRPARA(oModel)})

oModel:AddFields( 'B53MASTER', NIL, oStrB53 )
oModel:Addfields('B72DETAIL','B53MASTER',oStrB72)

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation('B72DETAIL', { { 'B72_FILIAL', 'xFilial("B72")' },;
									{ 'B72_ALIMOV', 'B53_ALIMOV' },;
									{ 'B72_RECMOV', 'B53_RECMOV' } }, B72->(IndexKey(3)) )

oModel:SetPKIndexOrder(3)

oModel:SetPrimaryKey({"B53_CODOPE","B53_CODLDP","B53_CODPEG","B53_NUMERO","B53_ORIMOV"})

oModel:SetDescription( "Parecer Auditoria" ) //'Parecer Auditoria'
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B53MASTER' ):SetDescription( "Dados do Benef" ) //"Dados Benef"
oModel:GetModel( 'B72DETAIL' ):SetDescription( "Parecer" ) //"Parecer"

oModel:SetActivate({|oModel| VldCpo(@oModel)})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Visualizador de dados do Parecer Auditoria. 

@version 1.0	
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
//Local oModel	:= ModelDef()
Local oModel   := FWLoadModel( 'PLSPARAUD' )
Local oStrB53	:= FWFormStruct(2, 'B53', {|cCampo| AllTrim(cCampo)  $ "B53_CODOPE, B53_CODLDP, B53_CODPEG, B53_NUMERO, B53_ORIMOV, B53_STATUS, B53_SITUAC, B53_OPERAD, B53_NOMOPE, B53_NUMGUI, B53_TIPO, B53_DATMOV, B53_MATUSU, B53_NOMUSR, B53_CODRDA, B53_NOMRDA "})
Local oStrB72	:= FWFormStruct(2, 'B72', {|cCampo| AllTrim(cCampo)  $ "B72_ALIMOV,B72_RECMOV,B72_CODPAD, B72_CODPRO, B72_DESPRO, B72_PARECE, B72_ACOTOD, B72_OBSANA, B72_MOTIVO, B72_DESMOT, B72_QTDAUT, B72_VLRAUT, B72_INFPRO, B72_VALORI, B72_VIA, B72_PERVIA"})
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField('VIEW_B53' , oStrB53,'B53MASTER' )
oView:AddField('VIEW_B72' , oStrB72,'B72DETAIL' )  

oView:CreateFolder( 'FLDCIMA')
oView:AddSheet('FLDCIMA','FLDB72','Dados Guia')
oView:AddSheet('FLDCIMA','FLDB53','Parecer')

oView:SetFldHidden('VIEW_B53','B53_CODOPE')
oView:SetFldHidden('VIEW_B53','B53_CODLDP')
oView:SetFldHidden('VIEW_B53','B53_CODPEG')	
oView:SetFldHidden('VIEW_B53','B53_NUMERO')
oView:SetFldHidden('VIEW_B53','B53_STATUS')
oView:SetFldHidden('VIEW_B53','B53_SITUAC')
oView:SetFldHidden('VIEW_B72','B72_ALIMOV')
oView:SetFldHidden('VIEW_B72','B72_RECMOV')

oView:CreateHorizontalBox( 'ITEMB72', 100, /*owner*/, /*lUsePixel*/, 'FLDCIMA', 'FLDB53')
oView:CreateHorizontalBox( 'CABB53', 100, /*owner*/, /*lUsePixel*/, 'FLDCIMA', 'FLDB72')

oView:SetOwnerView('VIEW_B53','CABB53')
oView:SetOwnerView('VIEW_B72','ITEMB72')


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPARAUD
Cria Workflow de Parecer de Auditoria.

@author Wendel e Tabosa
@since 13/02/2014
@version 1.0	
/*/
//-------------------------------------------------------------------
*/
Function PLSAUDFLG
Local cSituac := '2'
Local cChaveBd5:= BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)    
Local aAreaBD6 :=  BD6->(GetArea())
Local cUsrIdFl := FWWFColleagueId(GetNewPar("MV_PLUSAFL","000000"))

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Executando PLSAUDFLG" , 0, 0, {})
FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "IdUsrFl:" + cUsrIdFl , 0, 0, {})

//Executa rotina Reservar/Analisar - Auditoria. 
PLS790RTG(cSituac)
dbSelectArea("BD6")
dbSetorder(1)//BD6_FILIAL, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, BD6_CODPAD, BD6_CODPRO
If BD6->(MsSeek(xFilial("BD6")+cChaveBd5))
	While !BD6->(EOF()) .And. BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChaveBd5
		If (BD6->BD6_STATUS == '1' .or. BD6->BD6_STATUS == '0')
			AudStartProcess('PLPARE',cUsrIdFl, BD6->(Recno()))
		EndIf	
	BD6->(dbskip())	
	EndDo
EndIf	
RestArea(aAreaBD6)
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} 
Função para gravar as informações e iniciar processo no fluig
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AudStartProcess(cProcess,cUserId,nRecBD6)
Local nRet 		 := 0
Local aDados 	 	:= {} 
Local lValid     := .T.
lOCAL cChaveBE2	:= ""
Local oView      := FWViewActive()

	oView := FWLoadView('PLSPARAUD')
	oModel := FWLoadModel('PLSPARAUD')
	oModel:setOperation(4)
	
	// Coloco os dados do procedimento na View
	BD6->(dBGoTo(nRecBD6))
	
	oView:SetModel( oModel )
	oModel:Activate()
		
	oModel:SetValue("B72DETAIL","B72_CODPAD",BD6->BD6_CODPAD)
	oModel:SetValue("B72DETAIL","B72_CODPRO",BD6->BD6_CODPRO)
	oModel:SetValue("B72DETAIL","B72_DESPRO",BD6->BD6_DESPRO)
	oModel:SetValue("B53MASTER","B53_NOMRDA",BD6->BD6_NOMRDA)
			
		dbSelectArea("BE2")
		dbSetOrder(1)
		cChaveBE2 := xFilial("BE2")+Left(B53->B53_NUMGUI,4)+SubStr(B53->B53_NUMGUI,5,4)+SubStr(B53->B53_NUMGUI,9,2)+ Right(B53->B53_NUMGUI,8)
		If dbSeek(cChaveBE2)
			If BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == cChaveBE2
			oModel:SetValue("B72DETAIL","B72_VLRAUT",BE2->BE2_VLPGGU)
			EndIf
		EndIf
		

	aDados := FWViewCardData(oView)
	
	aAdd(aDados,{'ecm-validate','0'})
	
	nRet:= FWECMStartProcess(cProcess,;                            //cProcessId Código do processo no ECM
	0,;                                   //nNextTask Número da atividade no ECM. Se informado 0 a solicitação inicia na primeira atividade
	'Inicialização de solicitação',;  //cComments Comentários da tarefa
	aDados,;            //cXMLData XML com os dados do formulário. Para usar certifique-se que o fluxo possua um fichário.
	{},;                                  //aAttach Documentos anexos da solicitação
	cUserId,;           //cUserId Matricula do colaborador que irá iniciar a solicitação. Ver documentação do ECM sobre mecanismo de atribuição.
	{};          //aColleagueIds Lista de colaboradores que receberão a tarefa. Ver documentação do ECM sobre mecanismo de atribuição.
	,.F.)                                 //lComplete Indica se deve ou completar a tarefa. Se a tarefa não for completa o fluxo não muda de atividade no ECM.
	
Return  	lValid //Alltrim(Str(nRet))

//Chama função padrão da Auditoria para validação e gravação.

FUNCTION PLGRPARA(oModel)
Local lRet 		:= .T.
Local cChaveBE2	:= ""
Local aAreaBE2 :=  BE2->(GetArea())
LOCAL oPADC		:= PLSPADRC():New("B72") 

	dbSelectArea("BE2")
		dbSetOrder(1)
		
		cChaveBE2 := xFilial("BE2")+Left(B53->B53_NUMGUI,4)+SubStr(B53->B53_NUMGUI,5,4)+SubStr(B53->B53_NUMGUI,9,2)+ Right(B53->B53_NUMGUI,8)
		If dbSeek(cChaveBE2)
			If BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == cChaveBE2
				If BE2->BE2_QTDSOL == 0
					BE2->(Reclock("BE2",.F.))
					BE2->BE2_QTDSOL :=  BE2->BE2_QTDPRO
					BE2->(MsUnlock())
				EndIf
			EndIf
		EndIf
		
			oPADC:VWOkButtonVLD(oModel,  ALIAS_MDCO, "B72DETAIL")
			oPADC:MDPosVLD(oModel,  ALIAS_MDCO, "B72DETAIL")
			oPADC:MDCommit(oModel,  ALIAS_MDPO, "B72DETAIL")
	
	RestArea(aAreaBE2)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldCpo

@author
@since 10/06/2014
@version P120
@Atribui Inicializador padrão ao campo B72_QTDAUT
*/
//-------------------------------------------------------------------
Function VldCpo(oModel)
Local cOper	:= () 
Local aArea		:= GetArea()
	oModel:LoadValue("B72DETAIL","B72_QTDAUT",CriaVar("B72_QTDAUT"))
	oModel:LoadValue("B72DETAIL","B72_ACOTOD",CriaVar("B72_ACOTOD"))
	RestArea(aArea)
Return