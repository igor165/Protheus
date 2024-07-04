#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'GTPA003.CH'

STATIC lRevisao	:= .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA003()
Manutenção dos Trechos da Linha

@sample  	GTPA003()

@return  	oBrowse - Manutenção  dos Trechos da Linha

@author	Lucas Brustolin -  Inovação
@since	  	09/10/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Function GTPA003()
	
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias('GI3')
//Seleção do filtro no carregamento do historico

oBrowse:SetFilterDefault( "GI3_HIST == '2'" ) //Registros Ativos

//Criação do botão de historico para browse dos registros ativo
oBrowse:AddButton(STR0025, {|| GTPA003His(oBrowse)}   ) //Criando botão do historico


oBrowse:SetDescription(STR0001)	//Trechos e Tarifas
oBrowse:Activate()
	
Return ( oBrowse )



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados

@sample  	ModelDef()

@return  	oModel - Objeto do Model

@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	
Local oModel		:= Nil
Local oStruGI3	 := FWFormStruct( 1,"GI3" )
Local oStruGI4	 := FWFormStruct( 1,"GI4" )
Local oStruGI4B := FWFormStruct( 1,"GI4" )
Local oStruG5G	:= FWFormStruct( 1,"G5G" )

Local bActive	:= {|oModel| TP03VldAct(oModel)}
Local bCommit		:= {|oModel| A03Grv(oModel)}
Local bInitData	:= {|oModel| A03Init(oModel)}

GA003Struct(oStruGI4,oStruGI4B)

oStruGI3:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )
oStruGI4:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )
oStruGI4B:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )
oStruG5G:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

If FwIsInCallStack('GTPIRJ003') .OR. FwIsInCallStack('GI003Receb') .OR. FwIsInCallStack('GTPA002F') 
	oStruGI3:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGI3:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruGI3:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})

	oStruGI4:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGI4:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruGI4:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
EndIf

oModel := MPFormModel():New('GTPA003', /*bPreValidacao*/, , /*bCommit*/, /*bCancel*/ )
oModel:SetCommit(bCommit)
If !FwIsInCallStack('GTPA002') .OR. !FwIsInCallStack('GTPA002F') 

	// GATILHO - alterar o status do sentido de ida e volta caso for ida                
	oStruGI4B:AddTrigger( ;
		'GI4_MSBLQL'  , ;                  	// [01] Id do campo de origem
		'GI4_MSBLQL'  , ;                  	// [02] Id do campo de destino
		{ || FwFldGet("GI4_SENTID") == '1' } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		{ || A03Tr01(oModel)	} ) // [04] Bloco de codigo de execução do gatilho
		
	// GATILHO - alterar o status do sentido de ida e volta caso for ida                
	oStruGI4B:AddTrigger( ;
		'GI4_CCS'  , ;                  	// [01] Id do campo de origem
		'GI4_CCS'  , ;                  	// [02] Id do campo de destino
		{ || FwFldGet("GI4_SENTID") == '1' } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		{ || A03Tr02(oModel)	} ) // [04] Bloco de codigo de execução do gatilho	 

Endif

oModel:AddFields('GI3MASTER',/*cPai*/, oStruGI3)
oModel:AddGrid('GI4DETAIL','GI3MASTER', oStruGI4)

If !FwIsInCallStack('GTPA002')  .OR. !FwIsInCallStack('GTPA002F')
	oModel:AddFields('FIELDGI4B','GI4DETAIL', oStruGI4B)
	oModel:AddGrid('G5GGRID','GI4DETAIL', oStruG5G)
Endif

// Relação entre GI4DETAIL e GI3MASTER
oModel:SetRelation( 'GI4DETAIL', { { 'GI4_FILIAL', 'xFilial( "GI4" )' }, { 'GI4_LINHA', 'GI3_LINHA' }, { 'GI4_VIA', 'GI3_VIA' }, { 'GI4_REVISA', 'GI3_REVISA' } }, "GI4_ITEM")

If !FwIsInCallStack('GTPA002')  .OR. !FwIsInCallStack('GTPA002F')

	// Relação entre GI4DETAIL e FILEDGI4B
	oModel:SetRelation( 'FIELDGI4B', {	{'GI4_FILIAL','xFilial( "GI4" )'},; 
											{'GI4_LINHA','GI4_LINHA' },;
											{'GI4_VIA','GI4_VIA' },;
											{'GI4_LOCORI','GI4_LOCORI' },;
											{'GI4_LOCDES','GI4_LOCDES' },;
											{'GI4_REVISA','GI4_REVISA'}},; 
							GI4->(IndexKey(1)))
					
oModel:SetRelation( 'G5GGRID', { { 'G5G_FILIAL'	, 'xFilial( "G5G" )' }, { 'G5G_CODLIN'	, 'GI4_LINHA' }, { 'G5G_VIA'	, 'GI4_VIA' }, { 'G5G_LOCORI'	, 'GI4_LOCORI' }, { 'G5G_LOCDES'	, 'GI4_LOCDES' },{ 'G5G_SENTID'	, 'GI4_SENTID' },{ 'G5G_REVISA'	, 'GI4_REVISA' } } , G5G->(IndexKey(3)))

Endif

oModel:GetModel( 'GI4DETAIL' ):SetMaxLine(999999)

If !FwIsInCallStack('GTPA002')  .OR. !FwIsInCallStack('GTPA002F')
	oModel:GetModel('FIELDGI4B'):SetOptional(.T.)
	oModel:GetModel('G5GGRID'):SetOptional(.T.)
	oModel:GetModel('FIELDGI4B'):SetDescription(STR0003) //"Tarifas"
Endif

oModel:SetDescription(STR0001)	//"Trechos e Tarifas"
oModel:GetModel('GI3MASTER'):SetDescription(STR0001)	//"Trechos e Tarifas"
oModel:GetModel('GI4DETAIL'):SetDescription(STR0002) //"Trechos da Linha"
oModel:SetVldActivate(bActive)
oModel:SetActivate(bInitData)

oModel:SetOnDemand(.T.)

Return ( oModel )
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface

@sample  	ViewDef()

@return  	oView - Objeto do View

@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version 	P12
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
	
Local oView		:= FWFormView():New()
Local oModel		:= FWLoadModel('GTPA003')
Local oStruGI3	:= FWFormStruct(2,'GI3',{|cCampo| !(AllTrim(cCampo) $ "GI3_VIGENC,GI3_DTINC,GI3_ATUALI")})
Local oStruGI4	:= FWFormStruct(2,'GI4',{|cCampo|AllTrim(cCampo) $ "GI4_ITEM,GI4_LOCORI,GI4_NLOCOR,GI4_LOCDES,GI4_NLOCDE"})
Local oStruGI4B  	:= FWFormStruct(2,'GI4',{|cCampo|AllTrim(cCampo) $ "GI4_TAR,GI4_TAX,GI4_PED,GI4_SGFACU,GI4_KMPED,GI4_KMTERR,"+;
																				"GI4_KMASFA,GI4_KM,GI4_MSBLQL,GI4_CCS,GI4_SENTID,GI4_TARANU,GI4_VIGTAR,GI4_VIGTAX,GI4_VIGPED,GI4_VIGSGF,GI4_TEMPO" })
Local aListBox   := {}
Local oListBox   := NIL

oStruGI3:RemoveField('GI3_HIST')
oStruGI3:RemoveField('GI3_DEL')

oStruGI4B:SetProperty("GI4_SENTID" , MVC_VIEW_ORDEM, '01')
oStruGI4B:SetProperty("GI4_MSBLQL" , MVC_VIEW_ORDEM, '02')
oStruGI4B:SetProperty("GI4_TARANU" , MVC_VIEW_ORDEM, '03')
oStruGI4B:SetProperty("GI4_VIGTAR" , MVC_VIEW_ORDEM, '04')
oStruGI4B:SetProperty("GI4_TAR" 	, MVC_VIEW_ORDEM, '05')
oStruGI4B:SetProperty("GI4_VIGTAX" , MVC_VIEW_ORDEM, '06')
oStruGI4B:SetProperty("GI4_TAX" 	, MVC_VIEW_ORDEM, '07')
oStruGI4B:SetProperty("GI4_VIGPED" , MVC_VIEW_ORDEM, '08')
oStruGI4B:SetProperty("GI4_PED" 	, MVC_VIEW_ORDEM, '09')
oStruGI4B:SetProperty("GI4_VIGSGF" , MVC_VIEW_ORDEM, '10')
oStruGI4B:SetProperty("GI4_SGFACU" , MVC_VIEW_ORDEM, '11')
oStruGI4B:SetProperty("GI4_KMPED" 	, MVC_VIEW_ORDEM, '12')
oStruGI4B:SetProperty("GI4_KMASFA" , MVC_VIEW_ORDEM, '13')
oStruGI4B:SetProperty("GI4_KMTERR" , MVC_VIEW_ORDEM, '14')
oStruGI4B:SetProperty("GI4_KM" 		, MVC_VIEW_ORDEM, '15')
oStruGI4B:SetProperty("GI4_CCS" 	, MVC_VIEW_ORDEM, '16')
oStruGI4B:SetProperty("GI4_TEMPO" 	, MVC_VIEW_ORDEM, '17')

oView:SetModel(oModel)

oView:AddField('VIEW_GI3',	oStruGI3,	'GI3MASTER')
oView:AddGrid( 'VIEW_GI4',	oStruGI4,	'GI4DETAIL')
oView:AddField('VIEW_GI4B' ,oStruGI4B,	'FIELDGI4B')

oView:AddIncrementField('VIEW_GI4','GI4_ITEM')

// Criar um box horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Quebra em 2 "box" vertical para receber algum elemento da view
oView:CreateVerticalBox( 'EMCIMAESQ', 55, 'SUPERIOR' )
oView:CreateVerticalBox( 'EMCIMADIR', 45, 'SUPERIOR' )

// Quebra em 2 "box" vertical para receber algum elemento da view
oView:CreateVerticalBox( 'EMBAIXOESQ', 55, 'INFERIOR' )
oView:CreateVerticalBox( 'EMBAIXODIR', 45, 'INFERIOR' )

oView:CreateHorizontalBox( 'FILTRO', 22, 'EMBAIXOESQ' )
oView:CreateHorizontalBox( 'DETAIL', 78, 'EMBAIXOESQ' )

oView:SetOnlyView('VIEW_GI3','GIE_ORGAO')
oView:SetOwnerView('VIEW_GI3','EMCIMAESQ')
oView:SetOwnerView('VIEW_GI4','DETAIL')
oView:SetOwnerView('VIEW_GI4B','EMBAIXODIR')
oView:AddOtherObject('OTHER_PANEL1', {|oPanel| A03Pesq(oPanel,oView)})
oView:AddUserButton( STR0004, STR0004 , {|oView| A03Linha(oModel:Getvalue( 'GI3MASTER','GI3_LINHA'))} ) // "Seção da Linha"#"Seção da Linha"
oView:SetOwnerView("OTHER_PANEL1",'FILTRO')
oView:AddOtherObject("OTHER_PANEL2", {|oPanel| A03Prec(oModel, oPanel, @aListBox, @oListBox)} )
oView:SetOwnerView("OTHER_PANEL2",'EMCIMADIR')

oView:SetViewProperty('VIEW_GI4' , 'CHANGELINE',{{|| A03PrecAt(oModel, @aListBox, @oListBox) }} )

oView:SetDescription(STR0001) //"Trechos e Tarifas"

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_GI3',STR0012)//"Manutenção dos Trechos"
oView:EnableTitleView('VIEW_GI4',STR0002)//"Trechos da Linha"
oView:EnableTitleView('VIEW_GI4B',STR0003)//"Tarifas"
oView:EnableTitleView('OTHER_PANEL1',STR0005)	//"Filtro"
oView:EnableTitleView('OTHER_PANEL2',STR0016)	//"Historico"

oView:GetModel("GI4DETAIL"):SetNoInsertLine()
oView:GetModel("GI4DETAIL"):SetNoUpdatetLine()
oView:GetModel("GI4DETAIL"):SetNoDeleteLine()
	
	
Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} A03Linha()
Monta tela para visualização dos trechos da linha.

@sample  	A03Linha()

@author	Enaldo Cardoso -  Inovação
@since		05/03/2015
@version 	P12
/*/
//-------------------------------------------------------------------

Static Function A03Linha(cLinha)
	
Local cAliasG5I	:= GetNextAlias()
Local aDados  	:= {}
Local aInteface := FWGetDialogSize( oMainWnd )
Local oBrowse	:= Nil
Local oDlg		:= Nil
Local oCancelar	:= Nil

BeginSql  Alias cAliasG5I
	
	SELECT G5I_SEQ,G5I_LOCALI,G5I_STATUS
	FROM %Table:G5I% G5I
	WHERE G5I.G5I_FILIAL = %xFilial:G5I%
	AND G5I.G5I_CODLIN =  %Exp:cLinha%
	AND G5I.%NotDel%
	Order BY G5I_SEQ
EndSql

While (cAliasG5I)->(!Eof())
	
	Aadd(aDados,{	(cAliasG5I)->G5I_SEQ	,;
		(cAliasG5I)->G5I_LOCALI	,;
		Posicione("GI1",1,xFilial("GI1")+(cAliasG5I)->G5I_LOCALI,"GI1_DESCRI") })
	(cAliasG5I)->(DbSkip())
EndDo

Define MsDialog oDlg Title STR0004 From aInteface[1],aInteface[2] To aInteface[3],aInteface[4] Pixel STYLE nOr( WS_VISIBLE, WS_POPUP )	//'Seção da Linha'

Define FwFormBrowse oBrowse Data Array Array aDados Line Begin 1 Of oDlg

oBrowse:SetDescription(STR0004)

ADD COLUMN oColumns DATA &("{ || aDados[oBrowse:At()][1] }") TITLE RetTitle('G5I_SEQ')		SIZE TamSX3('G5I_SEQ')[1]		OF oBrowse
ADD COLUMN oColumns DATA &("{ || aDados[oBrowse:At()][2] }") TITLE RetTitle('G5I_CODIGO')	SIZE TamSX3('G5I_CODIGO')[1]	OF oBrowse
ADD COLUMN oColumns DATA &("{ || aDados[oBrowse:At()][3] }") TITLE RetTitle('G5I_DESLOC') 	SIZE TamSX3('G5I_DESLOC')[1] 	OF oBrowse

ADD Button oCancelar Title STR0006 Action { || oDlg:End()} Of oBrowse // 'Sair'

Activate FwFormBrowse oBrowse

Activate MSDIALOG oDlg Centered
	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A03Pesq()
Função que faz a busca das localidades informadas

@sample  	A03Pesq()

@return  	Nil

@author	Enaldo Cardoso Junior -  Inovação
@since		26/02/2015
@version 	P12
/*/
//-------------------------------------------------------------------

Static Function A03Pesq(oPanel,oView)
	
Local oMdlFull  := oView:GetModel()
Local oButton	  := Nil
Local oFonte	  := Nil
Local cOrigem	  := Space(6)
Local cDestino  := Space(6)
Local cDescOri  := Space(50)
Local cDescDest := Space(50)

DEFINE FONT oFonte NAME "Arial" BOLD

@ 017,005 Say STR0007 SIZE 50, 10 Of oPanel Pixel FONT oFonte	//"Origem:"
@ 015,035 MsGet cOrigem  SIZE 50, 10 Of oPanel F3 "GI1" VALID A03GetDesOri(cOrigem,@cDescOri) PIXEL WHEN .T.
@ 015,086 MsGet cDescOri SIZE 180, 10 Of oPanel PIXEL WHEN .F.

@ 032,005 Say STR0008 SIZE 50, 10 Of oPanel Pixel FONT oFonte	//"Destino:"
@ 030,035 MsGet cDestino  SIZE 50, 10 Of oPanel F3 "GI1" VALID A03GetDesDe(cDestino,@cDescDest) PIXEL WHEN .T.
@ 030,086 MsGet cDescDest SIZE 180, 10 Of oPanel PIXEL WHEN .F.

@ 015,270 Button oButton Prompt STR0009 Of oPanel Size 060, 012 Pixel	//"Pesquisar"
oButton:bAction := { || A03ExecPesq(oMdlFull,M->cOrigem,M->cDestino,oView) }
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A03GetDesOri()
Busca o nome da localidade origem.

@sample  	A03GetDesOri()

@return  	cDescOri

@author	Enaldo Cardoso Junior -  Inovação
@since		26/02/2015
@version 	P12
/*/
//-------------------------------------------------------------------

Static Function A03GetDesOri(cLocalidade,cDescOri)
	
	cDescOri  := Rtrim(Posicione("GI1",1,xFilial("GI1")+cLocalidade,"GI1_DESCRI"))
	
Return cDescOri

//-------------------------------------------------------------------
/*/{Protheus.doc} A03GetDesDe()
Busca o nome da localidade destino.

@sample  	A03GetDesDe()

@return  	cDescDest

@author	Enaldo Cardoso Junior -  Inovação
@since		26/02/2015
@version 	P12
/*/
//-------------------------------------------------------------------

Static Function A03GetDesDe(cLocalidade,cDescDest)
	
	cDescDest := Rtrim(Posicione("GI1",1,xFilial("GI1")+cLocalidade,"GI1_DESCRI"))
	
Return cDescDest

//-------------------------------------------------------------------
/*/{Protheus.doc} A03ExecPesq()
Executa busca e posiciona na grid de acordo com os
parametros informados.

@sample  	A03ExecPesq()

@return  	Nil

@author	Enaldo Cardoso Junior -  Inovação
@since		26/02/2015
@version 	P12
/*/
//-------------------------------------------------------------------

Static Function A03ExecPesq(oMdlFull,cOrigem,cDestino,oView)
	
Local oModel := oMdlFull:GetModel("GI4DETAIL")

If oModel:SeekLine({{ "GI4_LOCORI", cOrigem }, { "GI4_LOCDES", cDestino }})
	oView:Refresh("VIEW_GI4")
Else
	Help( ,, 'Help',"GTPA003", STR0010, 1, 0 )	//"O Trecho informado não existe."
EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu

@sample  	MenuDef()

@return  	aRotina -  Retorna as opções do Menu

@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	
Local aRotina := {}

If !FwIsInCall('GTPA003HIS')
	ADD OPTION aRotina TITLE STR0012 ACTION 'GA003Manut()' 		OPERATION OP_COPIA ACCESS 0  	//"Manutenção dos Trechos"
EndIf

ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.GTPA003'	OPERATION 2 ACCESS 0 	//Visualizar



Return ( aRotina )
	


/*/{Protheus.doc} GA003Manut
Função utilizada para remover o botão de Salva e incluir um novo
@author Jacomo Lisa
@since 13/04/2015
@version 1.0
/*/
Function GA003Manut()
Local oModel := FwLoadModel("GTPA003")

Local aButtons := {	{.F.,Nil},;
				       {.F.,Nil},;
				       {.F.,Nil},;
				       {.F.,Nil},;
				       {.F.,Nil},;
				       {.F.,Nil},;
				       {.T.,STR0030},; //"Confirmar"
				       {.T.,STR0031},; //"Cancelar"
				       {.F.,Nil},;
				       {.F.,Nil},;
				       {.F.,Nil},;
				       {.F.,Nil},;
				       {.F.,Nil},;
				       {.F.,Nil}}

oModel:Activate()
If	oModel:GetModel("GI3MASTER"):GetValue("GI3_HIST") == '2' .AND. oModel:GetModel("GI4DETAIL"):GetValue("GI4_HIST") == '2'
	// Opção para realização do Versionamento
	If SuperGetMv('MV_TPREV') == '1'
		If IsBlind() .or. MsgYesNo(STR0026,STR0027) //" Deseja confirmar operação?""Atenção"
			lver		:= .T.
		Else
			lver		:= .F.
		Endif
	ElseIf SuperGetMv('MV_TPREV') == '2'
		lver		:= .T.
	ElseIf SuperGetMv('MV_TPREV') == '3'
		lver		:= .F.
	EndIf
	//Verifica se vai executar o versionamento 
	If lver
		//Executa ação de upadate custimazado para versionamento 
		lRevisao := .T.
		FWExecView(STR0012,"GTPA003",OP_COPIA,,{|| .T.},,,aButtons)//Revisão
	Else 
		//Executa ação normal de update
		FWExecView(STR0012,"GTPA003",MODEL_OPERATION_UPDATE,,{|| .T.},,,aButtons)//Sem Revisao
	EndIf
ElseIf oModel:GetModel("GI3MASTER"):GetValue("GI3_DEL") != '2' 

	Help( ,, 'Help',"GTPA003", STR0029 , 1, 0 ) //"Não é possível realizar a manutenção dos trechos em registro Deletado" 

Else 

	Help( ,, 'Help',"GTPA003", STR0028, 1, 0 ) //"Não é possível realizar a manutenção dos trechos em Histórico"
	 
EndIf

lRevisao := .F.
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP003MdlAct
Validação de ativação do Model.

@sample	TP003MdlAct(oModel)

@param		oModel  Modelo de Dados
@return		lRet  	Retorna a validação do Modelo

@author		Cristiane Nishizaka
@since		07/07/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP03VldAct(oModel)
	
Local aArea     := GetArea()
Local aAreaGI2  := GI2->(GetArea())
Local nOper 	:= oModel:GetOperation()
Local cLinha	:= ""
Local cVia		:= ""
Local cRevisa	:= ""
Local lRet		:= .T.

//Valida se quem está tentando alterar o registro é alguma alteração no cadastro de linhas
If !IsInCallStack("GTPA002") .OR. !IsInCallStack("GTPA002F")
	If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_INSERT
		cLinha := GI3->GI3_LINHA
		cVia	:= GI3->GI3_VIA
		cRevisa	:= GI3->GI3_REVISA
		If !Empty(cLinha)
			
			DbSelectArea("GI2")
			GI2->(DbSetOrder(1)) //GI2_FILIAL+GI2_COD+GI2_REVISA
			//Se a linha estiver inativa, não ativa o model
			If GI2->(DbSeek(xFilial("GI2") + AllTrim(cLinha) + cRevisa))
				If GI2->GI2_MSBLQL == "1" .And. GI2->GI2_HIST != "2"
					Help( ,, 'Help',"GTPA003", STR0014 + cLinha + STR0015, 1, 0 ) //"Não é possível realizar a manutenção dos trechos da linha inativa " //". Visualize os trechos ou altere o status da linha para possibilitar a manutenção."
					lRet :=  .F.
				EndIf
			EndIf
			
		EndIf
		
	EndIf
EndIf

RestArea(aAreaGI2)
RestArea(aArea)

	
Return lRet



//------------------------------------------------------------------------------  
/*/{Protheus.doc} A03Prec 
  
Exibe ListBox com valores anteriores de passagens
  
@sample 	 A03Prec(oModel, oDlg, aListBox, oListBox) 
  
@return	 Nil  
@author	 Wanderley Monteiro da Silva  
@since	 04/11/2015  
@version	 P12  
@comments  
/*/  
//------------------------------------------------------------------------------
Function A03Prec(oModel, oDlg, aListBox, oListBox)
//Header Data Reaj. Hora.Reaj Tarifa Pedágio Embarque Seguro 
@ 012, 005 LISTBOX oListBox Fields HEADER STR0021,STR0022,STR0017,STR0018,STR0019,STR0020  SIZE 500, 250 OF oDlg COLORS 0, 16777215 PIXEL

A03PrecAt(oModel, @aListBox, @oListBox)
	
Return


//------------------------------------------------------------------------------  
/*/{Protheus.doc} A03PrecAt
  
Atualiza ListBox com valores anteriores de passagens
  
@sample 	 A03PrecAt(oModel, aListBox, oListBox)
  
@return	 Nil  
@author	 Yuki Shiroma  
@since	 16/03/2017  
@version	 P12  
@comments  
/*/  
//------------------------------------------------------------------------------
Function A03PrecAt(oModel, aListBox, oListBox)
Local cAliasTmp	:= GetNextAlias()
Local cLinha		:= oModel:Getvalue( 'GI3MASTER','GI3_LINHA')
Local cSentid		:= oModel:Getvalue( 'FIELDGI4B','GI4_SENTID')
Local cLocOri		:= oModel:Getvalue( 'GI4DETAIL','GI4_LOCORI')
Local cLocDes		:= oModel:Getvalue( 'GI4DETAIL','GI4_LOCDES')
Local dDtReaj		:= nil
Local cHrReaj		:= ''

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
Endif

aListBox := {}
//Realizando pesquisa na tabela G5G, pegando valores correto de acordo com revisao
//Trazendo todo historico de alteração das tarifas
BeginSql Alias cAliasTmp
	Column G5G_DTREAJ as Date
	Column G5G_VIGENC as Date
	Select G5G_VIGENC,G5G_VALOR,G5G_TPREAJ,G5G_DTREAJ, G5G_HRREAJ from %Table:G5G% G5G
	WHERE G5G.%notdel%
	AND G5G_FILIAL = %xfilial:G5G%
	AND G5G_CODLIN = %exp:cLinha%
	AND G5G_SENTID = %exp:cSentid%
	AND G5G_LOCORI = %exp:cLocOri%
	AND G5G_LOCDES = %exp:cLocDes%
	Order by G5G_DTREAJ, G5G_HRREAJ, G5G_TPREAJ
EndSql
//Verifica se existe um historico de tarifa
If !(cAliasTmp)->(EOF())
	Aadd(aListBox,{(cAliasTmp)->G5G_DTREAJ,(cAliasTmp)->G5G_HRREAJ,;
		" R$ " + Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		" R$ " + Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		" R$ " + Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		" R$ " + Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC"))})
Else
	Aadd(aListBox,{STOD(''),':',;
		Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC"))})
EndIf
//Carrega a lista de historico de tarifa
While !(cAliasTmp)->(EOF())
	
	aListBox[Len(aListBox), Val((cAliasTmp)->G5G_TPREAJ)+2] := 	" R$ " + Transform((cAliasTmp)->G5G_VALOR,PesqPict("G5G","G5G_VALOR")) + '  ' + Transform((cAliasTmp)->G5G_VIGENC,PesqPict("G5G","G5G_VIGENC"))

	dDtReaj 	:= (cAliasTmp)->G5G_DTREAJ
	cHrReaj	:= (cAliasTmp)->G5G_HRREAJ
	
	(cAliasTmp)->(DbSkip())
	
	//SE QUEBROU , cria nova linha
	If (dDtReaj != (cAliasTmp)->G5G_DTREAJ .Or.  cHrReaj != (cAliasTmp)->G5G_HRREAJ) .And. !(cAliasTmp)->(EOF())
		Aadd(aListBox,{(cAliasTmp)->G5G_DTREAJ,(cAliasTmp)->G5G_HRREAJ,;
		" R$ " + Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		" R$ " + Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		" R$ " + Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC")),;
		" R$ " + Transform(0,PesqPict("G5G","G5G_VALOR"))+ "  " + Transform('00/00/0000',PesqPict("G5G","G5G_VIGENC"))})
	EndIf
	
	
EndDo

oListBox:SetArray(aListBox)
//Carrega no grid a lista de historico de tarifa
oListBox:bLine := {|| { aListBox[oListBox:nAt,1],;
	aListBox[oListBox:nAt,2],;
	aListBox[oListBox:nAt,3],;
	aListBox[oListBox:nAt,4],;
	aListBox[oListBox:nAt,5],;
	aListBox[oListBox:nAt,6] }}
(cAliasTmp)->(DbCloseArea())
oListBox:Refresh()

Return
//------------------------------------------------------------------------------  
/*/{Protheus.doc} A03Tr01
  
Função para gatilho que ao alterar o status do sentido de ida, também altere o sentido de volta
  
@sample 	 A03Tr01(oModel)
  
@return	 Nil  
@author	 Inovação  
@since	 07/02/2017  
@version	 P12  
@comments  
/*/  
//------------------------------------------------------------------------------
Function A03Tr01(oModel)
Local oGI4Field	:= oModel:GetModel('FIELDGI4B')
Local oGI4Grid	:= oModel:GetModel('GI4DETAIL')
Local oView		:= nil
Local nLine		:= oGI4Grid:GetLine() 
//Realizar a buscar do registro trecho volta 
If oGI4Grid:SeekLine({{"GI4_LOCORI",oModel:Getvalue( 'GI4DETAIL','GI4_LOCDES')},;
						{"GI4_LOCDES",oModel:Getvalue( 'GI4DETAIL','GI4_LOCORI')},;
						{"GI4_SENTID",'2'}, {"GI4_HIST",'2'}, {"GI4_REVISA",oModel:Getvalue( 'GI4DETAIL','GI4_REVISA')}})
	//Realiza a alteração do status
	IIF(oGI4Field:GetValue('GI4_MSBLQL') == "1", oGI4Field:SetValue('GI4_MSBLQL','2'), oGI4Field:SetValue('GI4_MSBLQL','1'))
	
Endif

oGI4Grid:GoLine(nLine)
If !IsBlind()
	oView		:= FwViewActive()
	oView:Refresh()
Endif	
	
Return
//------------------------------------------------------------------------------  
/*/{Protheus.doc} A03Tr01
  
Função para gatilho que ao alterar o CCS do trecho ida, replique a informação para o trecho de volta.
  
@sample 	 A03Tr01(oModel)
  
@return	 Nil  
@author	 Inovação  
@since	 07/02/2017  
@version	 P12  
@comments  
/*/  
//------------------------------------------------------------------------------
Function A03Tr02(oModel)
Local oGI4Field	:= oModel:GetModel('FIELDGI4B')
Local oGI4Grid	:= oModel:GetModel('GI4DETAIL')
Local oView		:= nil
Local nLine		:= oGI4Grid:GetLine()
Local cCss		:= oModel:Getvalue( 'FIELDGI4B','GI4_CCS')

//Realizar a buscar do registro trecho volta 	
If oGI4Grid:SeekLine({{"GI4_LOCORI",oModel:Getvalue( 'GI4DETAIL','GI4_LOCDES')},;
						{"GI4_LOCDES",oModel:Getvalue( 'GI4DETAIL','GI4_LOCORI')},;
						{"GI4_SENTID",'2'}, {"GI4_HIST",'2'}, {"GI4_REVISA",oModel:Getvalue( 'GI4DETAIL','GI4_REVISA')}})
	//Replicar o valor do campo CCS para volta
	oGI4Field:SetValue('GI4_CCS',cCss)
Endif
oGI4Grid:GoLine(nLine)
If !IsBlind()
	oView	:= FwViewActive()
	oView:Refresh()
Endif	

Return

/*/{Protheus.doc} A03Grv
  
Realiza o update para tabela GI4 e realiza inserção dos preços e data vigência 
na tabela G5G aonde será gerado o historico de alteração
  
@sample 	 A03Grv(oModel)
  
@return	 Retonar validação .T. ou .F. para validar o commite 
@author	 Inovação  
@since	 08/02/2017  
@version	 P12  
@comments  
/*/  
//------------------------------------------------------------------------------

Function A03Grv(oModel)
	
Local oGI4Field	:= oModel:GetModel('FIELDGI4B')
Local oGI4Grid	:= oModel:GetModel('GI4DETAIL')
Local oG5GGrid 	:= oModel:GetModel('G5GGRID')
Local oMdlGI3		:= oModel:GetModel('GI3MASTER')
Local cLinha		:=	oMdlGI3:GetValue('GI3_LINHA')
Local cRevisa		:= oMdlGI3:GetValue('GI3_REVISA')
Local lRet 		:= .T.
Local nY		:= 0
Local nX		:= 0
Local cTmReaj	:= TIME()
Local dDtReaj	:= dDataBase
Local lVersi	:= .T.
Local aArea		:= GetArea()
Local cOp		:= oModel:GetOperation()
If lRevisao	== .T.
	oModel:GetModel("GI4DETAIL"):SetOnlyQuery(.T.) 
ElseIf oModel:GetOperation() == MODEL_OPERATION_INSERT
	
	If Ascan(oModel:GetModelIds(),'FIELDGI4B') > 0
		oModel:GetModel("FIELDGI4B"):SetOnlyQuery(.T.)
	Endif

EndIf

If oModel:GetOperation() <> MODEL_OPERATION_DELETE
	If cOp == MODEL_OPERATION_INSERT 
		//Verifica se possui uma data de alteração caso possua foi realizado uma revisão
		If SuperGetMv('MV_TPREV') == '1' .Or. SuperGetMv('MV_TPREV') == '2'
			If lVersi == .T. .And. cOp == MODEL_OPERATION_INSERT
				//Versionamento na alteração do cadastro
				oGI4Grid:SetNoUpdateLine(.F.)
				oMdlGI3:SetValue('GI3_REVISA',cRevisa)
				oMdlGI3:SetValue('GI3_HIST','2')
				oMdlGI3:SetValue('GI3_DEL','2')
				oMdlGI3:SetValue('GI3_DTALT',DDATABASE)
				For nX := 1 To oGI4Grid:Length()
					oGI4Grid:GoLine(nX)
					oGI4Grid:SetValue('GI4_REVISA',cRevisa)
					oGI4Grid:SetValue('GI4_HIST','2')
					oGI4Grid:SetValue('GI4_DTALT',DDATABASE)
					
				Next
			EndIf	
		EndIf
		
		oGI4Grid:SetNoUpdateLine(.T.)
		lRevisao	:= .F.
	Endif
	
	If !FwIsInCallStack('GTPA002') .And. !FwIsInCallStack('GI002Receb')
	
		For nY := 1 to oGI4Grid:Length()
			oGI4Grid:GoLine(nY)	
			
			//Adiciona no modelo o historio de tarifa
			//Tarifa - Verifica se o campo de valor ou data vigencia foi alterada
			If oGI4Field:IsFieldUpdated('GI4_TAR') .Or. oGI4Field:IsFieldUpdated('GI4_VIGTAR')
				GA003G4GHIS(oG5GGrid,'1',oGI4Field:GetValue('GI4_TAR'),oGI4Field:GetValue('GI4_VIGTAR'),dDtReaj,cTmReaj)
			Endif
			
			//Pedagio- Verifica se o campo de valor ou data vigencia foi alterada
			If oGI4Field:IsFieldUpdated('GI4_PED') .Or. oGI4Field:IsFieldUpdated('GI4_VIGPED')
				GA003G4GHIS(oG5GGrid,'2',oGI4Field:GetValue('GI4_PED'),oGI4Field:GetValue('GI4_VIGPED'),dDtReaj,cTmReaj)
			Endif
		
			//Taxa- Verifica se o campo de valor ou data vigencia foi alterada
			If oGI4Field:IsFieldUpdated('GI4_TAX') .Or. oGI4Field:IsFieldUpdated('GI4_VIGTAX')
				GA003G4GHIS(oG5GGrid,'3',oGI4Field:GetValue('GI4_TAX'),oGI4Field:GetValue('GI4_VIGTAX'),dDtReaj,cTmReaj)
			Endif
			
			//Seguro- Verifica se o campo de valor ou data vigencia foi alterada
			If oGI4Field:IsFieldUpdated('GI4_SGFACU') .Or. oGI4Field:IsFieldUpdated('GI4_VIGSGF')
				GA003G4GHIS(oG5GGrid,'4',oGI4Field:GetValue('GI4_SGFACU'),oGI4Field:GetValue('GI4_VIGSGF'),dDtReaj,cTmReaj)
			Endif
				
		Next nY

	Endif

EndIf
//Valida o commite de GI4
If oModel:VldData()
	FwFormCommit(oModel)// Realizando commite no GI4
	//Alteração do HIST
	If cOp == MODEL_OPERATION_INSERT 
		//Verifica se possui uma data de alteração caso possua foi realizado uma revisão
		If SuperGetMv('MV_TPREV') == '1' .Or. SuperGetMv('MV_TPREV') == '2'
			If lVersi == .T. .And. oMdlGI3:GetOperation() == MODEL_OPERATION_INSERT
				cRevisa := StrZero(Val(cRevisa)-1,tamsx3('GI3_REVISA')[1])
				//Altera a flag anterior para historico
				dbSelectArea("GI3")
				GI3->(DBOrderNickname('GI3REVISA'))//GI3_FILIAL+GI3_LINHA+GI3_REVISA
				If 	GI3->(dbSeek(xFilial("GI3")+cLinha+cRevisa))
					GI3->(RecLock(("GI3"),.F.))
					GI3->GI3_HIST:= "1"
					GI3->(MsUnlock())
					GI3->(dbSkip())
				
				EndIf
				
				
				dbSelectArea("GI4")
				GI4->(dbSetOrder(3))
				
				If GI4->(dbSeek(xFilial("GI4")+cLinha+cRevisa))
					While GI4->(!Eof()) .AND. GI4->GI4_LINHA == cLinha .AND. GI4->GI4_REVISA == cRevisa
						GI4->(RecLock(("GI4"),.F.))
						GI4->GI4_HIST:= "1"
						GI4->(MsUnlock())
						GI4->(dbSkip())
					EndDo
				EndIf
			EndIf	
		EndIf
	Endif
Else
	JurShowErro( oModel:GetModel():GetErrormessage() )	
	lRet := .F.		
EndIf
RestArea(aArea)
Return (lRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Return GTPI003( cXml, nTypeTrans, cTypeMessage )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A03Init

Funcção que inicializa os dados do

@sample 	
@param		oModel - Modelo de dados
			
@return                         
@author  	Yuki Shiroma
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function A03Init(oModel)

Local oMdlGI3		:= oModel:GetModel("GI3MASTER")
Local oMdlGI4G	:= oModel:GetModel("GI4DETAIL")
Local cNewRev		:= StrZero(Val(GI3 -> GI3_REVISA)+1,tamsx3('GI3_REVISA')[1])

If lRevisao /*.Or. oModel:GetOperation() ==  MODEL_OPERATION_VIEW */
	oMdlGI4G:SetNoUpdateLine(.F.)
	
	oMdlGI3:LoadValue("GI3_LINHA",GI3->GI3_LINHA)
	oMdlGI3:LoadValue("GI3_VIA",GI3->GI3_VIA)
	oMdlGI3:LoadValue("GI3_ORGAO",GI3->GI3_ORGAO)
	oMdlGI3:LoadValue("GI3_DTALT",GI3->GI3_DTALT)
	If GI4->(dbSeek(xFilial("GI4")+GI3->GI3_LINHA+'2'))
		While GI4->(!Eof()) .AND. GI4->GI4_LINHA == GI3->GI3_LINHA .AND. GI4->GI4_HIST == '2'
			oMdlGI4G:SetValue("GI4_LOCORI",GI4->GI4_LOCORI)
			oMdlGI4G:SetValue("GI4_LOCDES",GI4->GI4_LOCDES)
			GI4->(dbSkip())
		EndDo
	EndIF
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oMdlGI3:LoadValue("GI3_REVISA",cNewRev)
	EndIf
	oMdlGI3:LoadValue("GI3_HIST",GI3->GI3_HIST)
	oMdlGI4G:SetNoUpdateLine(.T.)
EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA003Struct

Crinado as structs

@sample 	
@param		oModel - Modelo de dados
			
@return                         
@author  	Yuki Shiroma
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function GA003Struct(oStruGI4,oStruGI4B,cTipo)

Local aFldOut	:= {"GI4_LINHA","GI4_VIA"}
Local aTamSx3   := {}
Local nI		:= 0

Default cTipo := "M"

If ( cTipo == "M" )
	
	SX3->(DbSetOrder(2))	//X3_CAMPO
	
	For nI := 1 to Len(aFldOut)
	
		If ( SX3->(DbSeek(aFldOut[nI])) )
            aTamSx3 := TamSx3(aFldOut[nI])

			If ( !oStruGI4:HasField(aFldOut[nI]) )
				
				oStruGI4:AddField(FWX3Titulo(aFldOut[nI]),;             //  [01]  C   Titulo do campo   //"Arquivo"
                                FWX3Titulo(aFldOut[nI]),;                     //  [02]  C   ToolTip do campo  //"Caminho e Nome do Arquivo"
	                            AllTrim(aFldOut[nI]),;        //  [03]  C   Id do Field
                                aTamSx3[3],;          //  [04]  C   Tipo do campo
	                            aTamSx3[1],;	  //  [05]  N   Tamanho do campo
	                            aTamSx3[2],;              //  [06]  N   Decimal do campo
	                            Nil,;       //  [07]  B   Code-block de validação do campo
	                            Nil,;       //  [08]  B   Code-block de validação When do campo
	                            Nil,;       // [09]  A   Lista de valores permitido do campo
	                            .F.,;       // [10]  L   Indica se o campo tem preenchimento obrigatório
	                            Nil,;       // [11]  B   Code-block de inicializacao do campo
	                            .F.,;       // [12]  L   Indica se trata-se de um campo chave
	                            .F.,;       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                            .F. )       //  [14]  L   Indica se o campo é virtual
				
			EndIf
			
			If ( !oStruGI4b:HasField(aFldOut[nI]) )
				
				oStruGI4b:AddField(FWX3Titulo(aFldOut[nI]),;             //  [01]  C   Titulo do campo   //"Arquivo"
                                FWX3Titulo(aFldOut[nI]),;                     //  [02]  C   ToolTip do campo  //"Caminho e Nome do Arquivo"
	                            AllTrim(aFldOut[nI]),;        //  [03]  C   Id do Field
                                aTamSx3[3],;          //  [04]  C   Tipo do campo
                                aTamSx3[1],;	  //  [05]  N   Tamanho do campo
                                aTamSx3[2],;              //  [06]  N   Decimal do campo
                                Nil,;       //  [07]  B   Code-block de validação do campo
	                            Nil,;       //  [08]  B   Code-block de validação When do campo
	                            Nil,;       // [09]  A   Lista de valores permitido do campo
	                            .F.,;       // [10]  L   Indica se o campo tem preenchimento obrigatório
	                            Nil,;       // [11]  B   Code-block de inicializacao do campo
	                            .F.,;       // [12]  L   Indica se trata-se de um campo chave
	                            .F.,;       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                            .F. )       //  [14]  L   Indica se o campo é virtual
				
			EndIf
			
		EndIf
	
	Next nI
	
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA003His
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
Realiza chamada do browse com lista de todos historico
/*/
//-------------------------------------------------------------------
Function GTPA003His(oBrowseOri)

Local oBrowseHis 	:= FWMBrowse():New()

oBrowseHis:SetAlias('GI3')
//Seleção do filtro no carregamento do historico

oBrowseHis:SetFilterDefault( "GI3_HIST == '1'" ) // Registro Historico
oBrowseHis:AddLegend( "GI3_DEL == '2'","YELLOW"	,	OemToAnsi(STR0023))//Alteração 
oBrowseHis:AddLegend( "GI3_DEL == '1'","RED"	,	OemToAnsi(STR0024))//Deleção

oBrowseHis:SetDescription(STR0001)	//Trechos e Tarifas
oBrowseHis:Activate()

oBrowseHis::Destroy()

oBrowseOri:Refresh(.T.)


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GA003G4GHIS
Cria uma linha de Historico da Tarifa
@author Inovação 
@since 13/07/2018
@version undefined
@param oModel
@type function
/*/
//-------------------------------------------------------------------
Function GA003G4GHIS(oModelG5G,cTpReaj,nValor,dVigenc,dDtReaj,cHrReaj)
Default dDtReaj := dDataBase
Default cHrReaj	:= Time()

	If !oModelG5G:IsEmpty() .or. !Empty(oModelG5G:GetValue('G5G_TPREAJ'))
		oModelG5G:AddLine()
	Endif
	oModelG5G:SetValue('G5G_DTREAJ' ,dDtReaj)
	oModelG5G:SetValue('G5G_HRREAJ' ,cHrReaj)
	oModelG5G:SetValue('G5G_TPREAJ' ,cTpReaj)
	oModelG5G:SetValue('G5G_VALOR'  ,nValor)
	oModelG5G:SetValue('G5G_VIGENC' ,dVigenc)

Return
