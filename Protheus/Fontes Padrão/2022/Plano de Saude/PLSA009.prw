#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'TBICONN.CH'
#Include 'TBICODE.CH'
#Include 'TopConn.CH'
#Include 'PLSA009.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSA009  � Autor �F�bio S. dos Santos	� Data �01/09/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela de an�lise da solicita��o de opcionais.			      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS			                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA009()
Local oBrowse

//Instancia objeto
oBrowse := FWMBrowse():New()

//Define tabela de origem do Browse
oBrowse:SetAlias('BBA')

//Define nome da tela
oBrowse:SetDescription(STR0001)//'Analisa Solicita��o de Opcionais'

//Filtra somente os registros de opcionais
oBrowse:SetFilterDefault("BBA_TIPSOL = '1'")

//Adiciona Legenda
oBrowse:AddLegend( "PLS009LEGE()=='1'"	, "YELLOW"	, STR0002)//"Pendente Documenta��o"
oBrowse:AddLegend( "PLS009LEGE()=='2'"	, "ORANGE"	, STR0003)//"Em an�lise"
oBrowse:AddLegend( "PLS009LEGE()=='3'"	, "GREEN"	, STR0004)//"Processado"

oBrowse:Activate()

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef	  � Autor � F�bio S. dos Santos   � Data �01/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para criar o menu da tela.							���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0005/*'Visualizar'*/	Action 'VIEWDEF.PLSA009' Operation 2 Access 0
Add Option aRotina Title  STR0006/*'Analisar'*/  	Action 'VIEWDEF.PLSA009' Operation 4 Access 0
ADD OPTION aRotina Title  STR0007/*'Legenda'*/		Action "PLS009MNLEG()" Operation 9 Access 0
Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef	  � Autor � F�bio S. dos Santos   � Data �01/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do modelo de Dados.								���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()
Local oModel // Modelo de dados constru�do
Local oStrBBA	:= FWFormStruct(1,'BBA')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que ir� considerar
Local oStrBBW	:= FWFormStruct(1,'BBW')

oModel := MPFormModel():New( 'PLSA009', , { |oModel| PLS009OK(oModel) }  ) // Cria o objeto do Modelo de Dados e insere a fun�ao de p�s-valida��o e de cancelamento

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'BBAMASTER', /*cOwner*/, oStrBBA )

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'BBWDETAIL', 'BBAMASTER', oStrBBW )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'BBWDETAIL', {	{ 'BBW_FILIAL'	, 'xFilial( "BBW" )'	},;
       									{ 'BBW_CODSOL'	, 'BBA_CODSEQ' }} ,;
       				   					BBW->( IndexKey( 1 ) ) )
 
// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( STR0001 )

// Adiciona a descri��o dos Componentes do Modelo de Dados
oModel:GetModel( 'BBAMASTER' ):SetDescription( STR0001 )
oModel:SetPrimaryKey({"BBA_FILIAL","BBA_CODSEQ","BBA_NROPRO"})

oModel:SetVldActivate({ |oModel| PLS009Pre(oModel) })

Return oModel // Retorna o Modelo de dados

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ViewDef	  � Autor � F�bio S. dos Santos   � Data �01/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do interface.										���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualiza��o constru�da
Local oModel	:= FWLoadModel( 'PLSA009' ) // Cria as estruturas a serem usadas na View

Local oStrBBA	:= FWFormStruct(2,'BBA', { |cCampo| PLS009BBAV(cCampo)})
Local oStrBBW	:= FWFormStruct(2,'BBW', { |cCampo| PLS009BBWV(cCampo)})

oModel:SetPrimaryKey( { "BBA_FILIAL","BBA_CODSEQ","BBA_NROPRO" } )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados ser� utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:AddField( 'VIEW_BBA', oStrBBA, 'BBAMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_BBW', oStrBBW, 'BBWDETAIL' )

//N�o deixa inserir linhas
oView:SetNoInsertLine("BBWDETAIL")

//N�o deixa inserir linhas
oView:SetNoDeleteLine("BBWDETAIL")

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 50 )
oView:CreateHorizontalBox( 'INFERIOR', 50 )

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_BBA', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_BBW', 'INFERIOR' )

oStrBBA:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
oStrBBW:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)

if(BBA->BBA_STATUS <> '3')
	oStrBBA:SetProperty('BBA_STATUS',MVC_VIEW_CANCHANGE,.T.)
	oStrBBA:SetProperty('BBA_OBSERV',MVC_VIEW_CANCHANGE,.T.)
	oStrBBW:SetProperty('BBW_STATUS',MVC_VIEW_CANCHANGE,.T.)
	oStrBBW:SetProperty('BBW_OBSERV',MVC_VIEW_CANCHANGE,.T.)
endIf

oStrBBA:SetProperty( 'BBA_STATUS',	MVC_VIEW_COMBOBOX,  { "1=Pendente de documenta��o", "2=Em an�lise", "3=Processado"} )
oView:AddUserButton(STR0008/*'Anexos'*/       , "", {|| PLSBAN009(oModel)  } )
// Retorna o objeto de View criado
Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PLS009LEGE � Autor � F�bio S. dos Santos   � Data �01/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o da Legenda a ser apresentada.						���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009LEGE()

Local cRet

cRet := BBA_STATUS

Return cRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PLS009BBAV � Autor � F�bio S. dos Santos   � Data �01/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o dos campos que pertencer�o ao Model.				���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009BBAV(cCampo)
Local lRet := .T.

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PLS009BBWV � Autor � F�bio S. dos Santos   � Data �02/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o dos campos que pertencer�o ao Model.				���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009BBWV(cCampo)
Local lRet := .T.

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PLS009Pre  � Autor � F�bio S. dos Santos   � Data �03/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o dos campos que pertencer�o ao Model.				���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009Pre(oModel)
Local lRet	:= .T.
Local nOperation := oModel:GetOperation()
If nOperation == MODEL_OPERATION_UPDATE .And. BBA->BBA_STATUS == "3"
	Help( ,, 'HELP',, STR0009, 1, 0)//'A solicita��o j� se encontra processada, n�o poder� ser analisada!!!'
	lRet := .F.	
EndIf 

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PLS009OK	  � Autor � F�bio S. dos Santos   � Data �01/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a inclus�o do Registro.								���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009OK(oModel)
Local lRet		:= .T.
Local oBBA		:= oModel:getmodel("BBAMASTER")
Local oBBW		:= oModel:getmodel("BBWDETAIL")
Local nTamBBW	:= oBBW:length()
Local nI		:= 1
Local aOpc		:= {}
Local lObs := .T.
Local oModel	:= FwModelActive()
Local oView		:= FwViewActive()
Local aOpcTit	:= {}
Local lHabOpc	:= GetNewPar("MV_PVLOPCT",.F.)//Habilita ou n�o a inclus�o de opcionais para dependentes sem titular
Local lRetOpc	:= .T.
Local nCont		:= 0
Local cTipReg := ""
Local aMatrics := {}
oView:SetModel(oModel)

BBW->(DbSetOrder(1))//BBW_FILIAL+BBW_CODSOL+BBW_CODOPC+BBW_MATRIC                                                                                                                     
BA1->(DbSetOrder(2))
For nI := 1 To nTamBBW
		
	oBBW:goLine(nI)
	
	If lHabOpc
		If BA1->(DbSeek(xFilial("BA1")+oBBW:GetValue("BBW_MATRIC")))
			If BA1->BA1_TIPUSU == "T"  
				aadd(aOpcTit,{AllTrim(oBBW:GetValue("BBW_CODOPC")), oBBW:GetValue("BBW_VEROPC"), oBBW:GetValue("BBW_STATUS") }) 
			EndIf
		EndIf
	EndIf	
	
	BBW->(DbSeek(xFilial("BBW")+oBBW:GetValue("BBW_CODSOL")+oBBW:GetValue("BBW_CODOPC")+oBBW:GetValue("BBW_MATRIC")))
	If ( AllTrim(oBBW:GetValue("BBW_OBSERV")) == AllTrim(BBW->BBW_OBSERV))
		lObs := .F.		
	EndIf
	
	If oBBW:GetValue("BBW_STATUS") == "1"
		aAdd(aOpc,{nI})
	EndIf
	
Next nI

If(oBBA:getValue("BBA_STATUS") == "3")
	For nI := 1 To nTamBBW
		
		oBBW:goLine(nI)
		
		If lHabOpc
			If BA1->(DbSeek(xFilial("BA1")+oBBW:GetValue("BBW_MATRIC")))
				If BA1->BA1_TIPUSU == "D" .And. oBBW:GetValue("BBW_STATUS") == "2"
					nPos := aScan(aOpcTit, { |x| x[1]+x[2] == AllTrim(oBBW:GetValue("BBW_CODOPC"))+oBBW:GetValue("BBW_VEROPC")})
					If nPos > 0
						If aOpcTit[nPos,3] <> "2"
							lRetOpc := .F.
							
						Else
							lRetOpc := .T.	
						EndIf
						
					EndIf		
				EndIf
			EndIf
		Else
			Exit
		EndIf				
				
	
	Next nI
	If lRetOpc 
		If Len(aOpc) > 0 //caso tenha algum item com status "Pendente de Documenta��o"
			MsgAlert(STR0010)//'Existem itens com documenta��o pendente, a solicit��o ficar� em An�lise!!!'	
			oBBA:SetValue("BBA_STATUS","2")
		Else
			If MsgYesNo(STR0011,STR0012)//"Deseja realmente finalizar a an�lise?"/"Aten��o"
				//gravar tabela BF4 dos itens aprovados
				BF4->(DbSetOrder(1))
				Begin Transaction
					For nI := 1 To nTamBBW
						oBBW:goLine(nI)
						cTipReg := SubStr(AllTrim(oBBW:GetValue("BBW_MATRIC")),15,2)
												
						If oBBW:GetValue("BBW_STATUS") == "2"
						
							if aScan(aMatrics, AllTrim(oBBW:GetValue("BBW_MATRIC"))) == 0
								aAdd(aMatrics, AllTrim(oBBW:GetValue("BBW_MATRIC")) )
							endIf
						
							RecLock("BF4",.T.)
							BF4->BF4_FILIAL := xFilial("BF4")
							BF4->BF4_CODINT := AllTrim(oBBA:GetValue("BBA_CODINT"))
							BF4->BF4_CODEMP := oBBA:GetValue("BBA_CODEMP") 
							BF4->BF4_MATRIC := SubStr(AllTrim(oBBW:GetValue("BBW_MATRIC")),9,6) 
							BF4->BF4_CODPRO := AllTrim(oBBW:GetValue("BBW_CODOPC")) 
							BF4->BF4_VERSAO := oBBW:GetValue("BBW_VEROPC")                                                  
							BF4->BF4_TIPREG := cTipReg
							BF4->BF4_DATBAS := dDataBase
							BF4->BF4_MOTBLO := iif(!empty(oBBW:GetValue("BBW_DATLIM")), GetNewPar("MV_MOTOPC","001"), "")
							BF4->BF4_DATBLO := oBBW:GetValue("BBW_DATLIM")
							BF4->BF4_RGIMP  := "0" 
							BF4->BF4_CLAOPC := ""
							BF4->BF4_A300   := "0"  
							BF4->BF4_TIPVIN := "0"
							BF4->BF4_DATSOL := oBBA:GetValue("BBA_DATSOL")
							MsUnLock()
							
							if !empty(oBBW:GetValue("BBW_DATLIM"))
							
								BGU->(RecLock("BGU", .T.))
								
									BGU->BGU_FILIAL := xFilial("BGU")
									BGU->BGU_MATRIC := SubStr(AllTrim(oBBW:GetValue("BBW_MATRIC")),1,14)
									BGU->BGU_TIPREG := cTipReg
									BGU->BGU_TIPO   := "0"
									BGU->BGU_DATA   := oBBW:GetValue("BBW_DATLIM")
									BGU->BGU_MOTBLO := iif(!empty(oBBW:GetValue("BBW_DATLIM")), GetNewPar("MV_MOTOPC","001"), "")
									BGU->BGU_USUOPE := PLSRtCdUsr()
									BGU->BGU_CODPRO := AllTrim(oBBW:GetValue("BBW_CODOPC")) 
									BGU->BGU_VERSAO := oBBW:GetValue("BBW_VEROPC")  
								
								BGU->(msUnlock())
							
							endIf
						EndIf
					Next nI
					
				If Len(aMatrics) == 1 
					
					BA1->(DbSetOrder(2))		
					
					If BA1->(msSeek(xFilial("BA1")+aMatrics[1])) 
					
						PLSREPDOC("BBA", AllTrim(oBBA:GetValue("BBA_CODSEQ")), "BA1", BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO),,.T.,.F.)
					
					EndIf
				
				ElseIf Len(aMatrics) > 1
					aRetDoc := PLSRETDOCS("BBA", AllTrim(oBBA:GetValue("BBA_CODSEQ")))			
					PLS977Doc(aRetDoc, aMatrics)
				endIf	
				
					
				End Transaction
				oBBA:SetValue("BBA_STATUS","3")
			Else
				oBBA:SetValue("BBA_STATUS","2")
			EndIf	
		EndIf
	Else
		Help( ,, 'HELP',, STR0017, 1, 0)
		lRet := .F.
	EndIf
ElseIf(oBBA:getValue("BBA_STATUS") == "1")
	
	If !lObs //se nao alterou a observa��o
		if !MsgYesNo(STR0013,STR0012)//"Deseja realmente salvar sem alterar o campo de observa��o nos itens?"
			Help( ,, 'HELP',, STR0014, 1, 0)//'Alterar o campo Informa��es nos itens.'
			lRet := .F.		 			
		EndIf	
	EndIf
	
EndIf


Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PLS009DESCON� Autor � F�bio S. dos Santos   � Data �01/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descri��o do contrato.								���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009DESCON()
Local cDescCon	:= IF(INCLUI,"",POSICIONE("BQC",1,XFILIAL("BQC")+PLSINTPAD()+BBA->(BBA_CODEMP+BBA_CONEMP+BBA_VERCON+BBA_SUBCON+BBA_VERSUB),"BQC_DESCRI")) 
Return cDescCon 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PLS009DESCON� Autor � F�bio S. dos Santos   � Data �01/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Tela da legenda.												���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009MNLEG()
Local aLegenda := {} 
aAdd( aLegenda, { "BR_AMARELO"	,      STR0002 }) //"Pendente Documenta��o"
aAdd( aLegenda, { "BR_LARANJA"	,      STR0003 }) //"Em an�lise"
aAdd( aLegenda, { "BR_VERDE"	,      STR0004 }) //"Processado"

BrwLegenda( STR0015, STR0015, aLegenda )//"Legenda"

Return Nil 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PLS009GRV	  � Autor � F�bio S. dos Santos   � Data �14/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os dados do Portal nas tabelas BBA e BBW				���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009GRV(oDados, cUserCod, nTpPortal, cClass)
Local nCont		:= 0
Local cSQL		:= ""
Local cCodFam	:= ""
Local cRet		:= ""
Local cNumProt	:= ""
Local cUrl		:= ""
local cCodTit := getNewPar("MV_PLCDTIT", "T")
If nTpPortal == 3 //Benefici�rio
	cSQL := "SELECT B49_BENEFI "
	cSQL += " FROM " + RetSQLName("B49")
	cSQL += " WHERE B49_CODUSR = '" + cUserCod + "' AND "
	cSQL += " D_E_L_E_T_ = ' '"

	If Select("TRBB49") > 0
		TRBB49->(DbCloseArea())
	EndIf
	
	TCQUERY cSQL New Alias "TRBB49"
	
	TRBB49->(DbGoTop())
	If !TRBB49->(EOF())
		cCodFam := SubStr(TRBB49->B49_BENEFI,1,14)
		
		cSQL := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_NOMUSR, BA1_CODPLA, BA1_VERSAO"
		cSQL += " FROM " + RetSQLName("BA1")
		cSQL += " WHERE (BA1_CODINT || BA1_CODEMP || BA1_MATRIC) = '" + cCodFam + "' "
		cSQL += " AND D_E_L_E_T_ = ' '"
		cSQL += " AND BA1_TIPUSU = '" + cCodTit + "'"
		
		If Select("TRBBA1") > 0
			TRBBA1->(DbCloseArea())
		EndIf
		
		cSQL := ChangeQuery(cSQL)
		
		TCQUERY cSQL New Alias "TRBBA1"
		
		TRBBA1->(DbGoTop())
	EndIf
Else //Empresa
	cSQL := "SELECT B40_CODEMP, B40_NUMCON, B40_VERCON, B40_SUBCON, B40_VERSUB "
	cSQL += " FROM " + RetSQLName("B40")
	cSQL += " WHERE B40_CODUSR = '" + cUserCod + "' AND "
	cSQL += " D_E_L_E_T_ = ' '"
	
	If Select("TRBB40") > 0
		TRBB40->(DbCloseArea())
	EndIf
	
	cSQL := ChangeQuery(cSQL)
		
	TCQUERY cSQL New Alias "TRBB40"
	
	TRBB40->(DbGoTop())
EndIf

BBA->(DbSetOrder(1))
Begin Transaction
	RecLock("BBA",.T.)
	BBA->BBA_FILIAL := xFilial("BBA")
	BBA->BBA_CODSEQ := GetSxeNum("BBA", "BBA_CODSEQ")
	BBA->BBA_TIPSOL := "1"
	BBA->BBA_STATUS := "2"
	BBA->BBA_CODINT := PlsIntPad()
	BBA->BBA_CODEMP := Iif(nTpPortal == 3, TRBBA1->BA1_CODEMP, TRBB40->B40_CODEMP) 
	BBA->BBA_CONEMP := Iif(nTpPortal == 3, TRBBA1->BA1_CONEMP, TRBB40->B40_NUMCON)
	BBA->BBA_VERCON := Iif(nTpPortal == 3, TRBBA1->BA1_VERCON, TRBB40->B40_VERCON)
	BBA->BBA_SUBCON := Iif(nTpPortal == 3, TRBBA1->BA1_SUBCON, TRBB40->B40_SUBCON)
	BBA->BBA_VERSUB := Iif(nTpPortal == 3, TRBBA1->BA1_VERSUB, TRBB40->B40_VERSUB)
	BBA->BBA_MATRIC := Iif(nTpPortal == 3, TRBBA1->BA1_CODINT+TRBBA1->BA1_CODEMP+TRBBA1->BA1_MATRIC+TRBBA1->BA1_TIPREG+TRBBA1->BA1_DIGITO, "")
	BBA->BBA_EMPBEN := Iif(nTpPortal == 3, TRBBA1->BA1_NOMUSR, "")
	BBA->BBA_CODPRO := Iif(nTpPortal == 3, Posicione("BA3",1,xFilial("BA3")+TRBBA1->BA1_CODINT+TRBBA1->BA1_CODEMP+TRBBA1->BA1_MATRIC,"BA3_CODPLA"), "")
	BBA->BBA_VERSAO := Iif(nTpPortal == 3, Posicione("BA3",1,xFilial("BA3")+TRBBA1->BA1_CODINT+TRBBA1->BA1_CODEMP+TRBBA1->BA1_MATRIC,"BA3_VERSAO"), "")
	BBA->BBA_DATSOL := dDataBase
	BBA->BBA_HORSOL := Time()
	BBA->BBA_OBSERV := ""
	//nro protocolo registro ans-ano-mes-dia-codigo
	cNroProt := Posicione("BA0",1,xFilial("BA0")+PLSINTPAD(),"BA0_SUSEP") + Dtos(dDataBase) + BBA->BBA_CODSEQ
	BBA->BBA_NROPRO := cNroProt 
	BBA->BBA_CLASSE := cClass
	MsUnLock()
	
	BBA->(ConfirmSX8())
	
	DbSelectArea("BBW")
	DbSetOrder(1)
	
	For nCont := 1 To Len(oDados:DADOSBENOPC)
		RecLock("BBW",.T.)
		BBW->BBW_FILIAL := xFilial("BBW")
		BBW->BBW_CODSOL := BBA->BBA_CODSEQ
		BBW->BBW_CODOPC := oDados:DADOSBENOPC[nCont]:CODOPC
		BBW->BBW_MATRIC := oDados:DADOSBENOPC[nCont]:CODBEN
		BBW->BBW_DATBAS := oDados:DADOSBENOPC[nCont]:DATADE
		BBW->BBW_DATLIM := oDados:DADOSBENOPC[nCont]:DATLIM
		BBW->BBW_STATUS := "2"
		BBW->BBW_VEROPC := oDados:DADOSBENOPC[nCont]:VEROPC
		MsUnlock()
	Next
	
	cRet := PLS009DOC(BBA->BBA_CODSEQ) //verifica se tem algum documento pra anexar e grava como "Pendente Documenta��o"
	If ExistBlock("PLSFORMOPC")
		cUrl := ExecBlock("PLSFORMOPC",.F.,.F.,{cClass,BBA->(RECNO())})
	EndIf
	If !Empty(cRet) .Or. !Empty(cUrl)
		BBA->(DbSetOrder(1))
		BBA->(DbSeek(xFilial("BBA")+BBA->BBA_CODSEQ))
		RecLock("BBA",.F.)
		BBA->BBA_STATUS := "1"
		MsUnlock()
		BBW->(DbSetOrder(1))
		BBW->(DbSeek(xFilial("BBW")+BBA->BBA_CODSEQ))
		While !BBW->(Eof()) .And. xFilial("BBW") == BBW->BBW_FILIAL .And. BBW->BBW_CODSOL == BBA->BBA_CODSEQ
			RecLock("BBW",.F.)
			BBW->BBW_STATUS := "1"
			MsUnlock()
			BBW->(DbSkip())
		End
	EndIf
End Transaction
cRet := BBA->BBA_STATUS + "|" + BBA->BBA_CODSEQ + "|" + AllTRIM(Str(BBA->(Recno()))) + "|" + cRet + "|" + BBA->BBA_NROPRO + "|" + cUrl

Return cRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PL09AltOpc  � Autor � Karine Riquena Limp   � Data �28/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Altera o status da solicita��o para 2-EM AN��ISE quando h�    ���
���		     �envio de documento pela consulta                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PL09AltOpc(nRecno)
LOCAL lRet := .T.

BBA->(dbGoto(nRecno))
Begin Transaction
	
	BBA->(RecLock("BBA",.F.))
		BBA->BBA_STATUS := "2"
	BBA->(MsUnlock())

End Transaction

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PLS009DOC	  � Autor � Oscar Zanin  		  � Data �17/09/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Busca os documentos necess�rios para solicita��o de opcional.���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PLS009DOC(cCodSeq)
 
Local aOpci:={}
Local aTemp:={}
Local aMotDoc:={}
Local nI          :=1
Local nJ          :=1
Local cCodInt     :=PLSINTPAD()
Local cRet        :=""
 
//O par�metro recebido � o c�digo da solicita��o (Tabela BBA)
//Cabe�alho da rotina.
BBW->(DbSetOrder(1))
BBW->(MsSeek(xFilial("BBW")+cCodSeq))
 
//Buscamos os itens e preenchemos o array com os Opcionais associados
While((BBW->BBW_FILIAL==xFilial("BBW")).AND.(BBW->BBW_CODSOL==cCodSeq))
	Aadd(aTemp,BBW->BBW_CODOPC)
	BBW->(DbSkip())
End
BBW->(DbCloseArea())
 
//Retiramos os opcionais repetidos
For nI:=1 To Len(aTemp)
	If Ascan(aOpci,{|x|x==aTemp[nI]})==0
		Aadd(aOpci,aTemp[nI])
	EndIf
Next
 
//Buscamos os motivos associados aos opcionais
BI3->(DbSelectArea("BI3"))
BI3->(DbSetOrder(5))
 
For nI:=1 To Len(aOpci)
	If BI3->(MSSeek(xFilial("BI3")+cCodInt+aOpci[nI]))
		If !Empty(BI3->BI3_MOTDOC)
			Aadd(aMotDoc,{BI3->BI3_MOTDOC})
		EndIf	
	EndIf
Next
BI3->(DbCloseArea())
 
//Verificamos se existem documentos associados aos motivos do Array
//e criamos uma matriz
B9X->(dbSelectArea("B9X"))
B9X->(DbSetorder(1))
 
For nI:=1 To Len(aMotDoc)
	If(B9X->(MsSeek(xFilial("B9X")+cCodInt+aMotDoc[nI][1])))
		While((B9X->B9X_FILIAL==xFilial("B9X")).AND.(B9X->B9X_CODMOT==aMotDoc[nI][1]))
			Aadd(aMotDoc[nI],B9X->B9X_CODDOC)
			B9X->(DbSkip())
		End
	EndIf
Next
B9X->(DbCloseArea())
 
//Como vamos precisar das descri��es, verificamos os documentos relacionados
// na tabela BD2 e trocamos o c�digo pela descri��o do documento.
If Len(aMotDoc)>0 
	BD2->(DbSelectArea("BD2"))
	BD2->(DbSetOrder(1))
     
	For nI:=1 To Len(aMotDoc)       
		For nJ:=2 To Len(aMotDoc[nI])
			BD2->(MsSeek(xFilial("BD2")+aMotDoc[nI][nJ]))
			aMotDoc[nI][nJ]:=BD2->BD2_DESCRI
		Next
	Next
	BD2->(DbCloseArea())
EndIf
 
//Monta o cRet para o portal
For nI:=1 To Len(aMotDoc)
	//cRet+="@"+aMotDoc[nI][1]
	For nJ:=2 To Len(aMotDoc[nI])
		cRet += iif(nJ == 2, "@", "")
		If Len(AllTrim(cRet)) == 1
			cRet+= aMotdoc[nI][nJ]
		Else
			cRet+=", "+aMotdoc[nI][nJ]
		EndIf
	Next
Next

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS009WEBP
P�s grava��o quando anexar um documento
@author Oscar Zanin
@since 17/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS009WEBP(cCodSol)

BBA->(DbSelectArea("BBA"))
BBA->(DbSetOrder(1))
BBA->(MsSeek(xFilial("BBA")+cCodsol))
	BEGIN TRANSACTION
		BBA->(RecLock("BBA", .F.))
			BBA->BBA_STATUS := "2"
		BBA->(MsUnlock())
	END TRANSACTION
BBA->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBAN009
Banco de conhecimento da rotina. Ir� ser adequado para exibir os documentos cadastrados no Portal.
@author Oscar Zanin
@since 05/06/2015
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSBAN009(oModel) 
Local oBBA 	
Local cCodSeq		:= "" 
Local cMsg			:= STR0016 //"N�o foi anexado nenhum documento, n�o ser� poss�vel utilizar o Banco de Conhecimento"

Private aRotina 	:= {}
Private cCadastro 	:= FunDesc()

If ValType(oModel) == "O"
	oBBA 	 := oModel:GetModel("BBAMASTER")
	cCodSeq := oBBA:GetValue("BBA_CODSEQ")
Else
	cCodSeq := BBA->BBA_CODSEQ
EndIf
	
If !Empty(cCodSeq)

	aRotina := {{"Conhecimento",'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{"Inclus�o R�pida",'PLSDOcs',0,3}}
	
	BBA->(DbSelectArea("BBA"))
	BBA->(DbSetOrder(1))
	
	If BBA->(MsSeek(xFilial("BBA") + cCodSeq)) //Posiciona no registro do Candidato	
		MsDocument( "BBA", BBA->( RecNo() ), 2 )
	EndIf
	
	BBA->(DbCloseArea())
Else
	MsgAlert(cMsg, STR0012)
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLDOPCT
Verifica se o titular possui o opcional solicitado antes de inclu�-lo no dependente
@author Karine Riquena Limp
@since 25/07/2016
@version P12 
/*/
//-------------------------------------------------------------------
function PLSVLDOPCT(cMatTit, cCodOpc, nAcao)
local lRet := .T.
local lAchou := .F.
local cMatFam := ""
BF4->(dbSetOrder(1))
if nAcao == 3

	//verifico se o titular da familia  possui o opcional em vigencia
	//pois com essa valida��o um dependente s� pode ter um opcional se o titular o tiver
	if BF4->(MsSeek(xFilial("BF4")+left(cMatTit, 16)+cCodOpc))
		while( BF4->(!EOF()) .AND. BF4->(BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG+BF4_CODPRO) == (xFilial("BF4")+left(cMatTit, 16)+cCodOpc) .and. !lAchou)

			if( (EMPTY(BF4->BF4_DATBAS) .or. (BF4->BF4_DATBAS <= dDataBase)) .and. (EMPTY(BF4->BF4_DATBLO) .OR. (BF4->BF4_DATBLO >= dDataBase)))
		
				lAchou := .T.
				
			endIf
			
			BF4->(dbSkip())
		endDo
		
		lRet := lAchou
	else
	
		lRet := .F.

	endIf
	
elseif nAcao == 5
	
	cMatFam := left(cMatTit, 14)
	
	if (BF4->(MsSeek(xFilial("BF4")+cMatFam)))
		
		while( BF4->(!EOF()) .AND. BF4->(BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC) == (xFilial("BF4")+cMatFam))
			
			//verifica se n�o � o titular e se � o opcional em vigencia 
			//pois com essa valida��o um dependente s� pode ter um opcional se o titular o tiver
			//n�o � permitido excluir o opcional de um titular se o dependente tiver ele
			if(BF4->(BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG) != left(cMatTit, 16);
			 .and. BF4->BF4_CODPRO == cCodOpc ;
			 .and. (BF4->BF4_DATBAS <= ddatabase .AND. (EMPTY(BF4->BF4_DATBLO) .or. ddatabase <= BF4->BF4_DATBLO) ) ) 
				
				lRet := .F.
				
			endIf
			
			BF4->(dbSkip())
		endDo
		
	endIf
	
endIf

return lRet
