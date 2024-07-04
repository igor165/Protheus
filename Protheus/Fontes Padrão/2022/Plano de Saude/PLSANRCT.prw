#INCLUDE "PLSANRCT.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "SHELL.CH"   

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSANRCT   �Autor  �Microsiga           � Data �  01/10/2015���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de An�lise de Receitas     				           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SEGMENTO SAUDE VERSAO 12.1.8                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PLSANRCT()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B4F' )
oBrowse:SetDescription(FunDesc())

//Adiciona Legenda
oBrowse:AddLegend( "PANRCTLEGE()=='0'"	, "RED"	, STR0002)//"Solicitado via Portal"
oBrowse:AddLegend( "PANRCTLEGE()=='1'"	, "BLUE"	, STR0003)//"Protocolado"
oBrowse:AddLegend( "PANRCTLEGE()=='2'"	, "YELLOW"	, STR0004)//"Em analise"
oBrowse:AddLegend( "PANRCTLEGE()=='3'"	, "GREEN"	, STR0005)//"Deferido"
oBrowse:AddLegend( "PANRCTLEGE()=='4'"	, "BLACK"	, STR0006)//"Indeferido"
oBrowse:AddLegend( "PANRCTLEGE()=='5'"	, "ORANGE"	, STR0007)//"Deferido Parcialmente"
oBrowse:AddLegend( "PANRCTLEGE()=='6'"	, "BR_PINK", STR0019)//"Pendente Inf. beneficiario"
// Ponto de Entrada para incluir nova legenda
If ExistBlock("PLLEGB4F")
	oBrowse := ExecBlock("PLLEGB4F",.F.,.F.,{oBrowse})
Endif  	

oBrowse:SetFilterDefault( "B4F_STATUS != 'A'" )
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { STR0008,'PesqBrw'         , 0, 1, 0, .T. } )// 'Pesquisar'
aAdd( aRotina, { STR0009,'VIEWDEF.PLSANRCT', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0011,'VIEWDEF.PLSANRCT', 0, 4, 0, NIL } ) //'Analisar'
aAdd( aRotina, { STR0013,'VIEWDEF.PLSANRCT', 0, 8, 0, NIL } ) //'Imprimir'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

Local oStruB4F := FWFormStruct( 1, 'B4F', , )
Local oStruB7D := FWFormStruct( 1, 'B7D', , )
Static oModel


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSANRCTMD',/*bPreValidacao*/,{|oModel|PLSANRCTVal(oModel) }/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'B4FMASTER', NIL, oStruB4F )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'B7DDETAIL', 'B4FMASTER', oStruB7D, , {|| ValAnIntDt()}, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetPrimaryKey({"B4F_FILIAL","B4F_CODREC","B4F_MATRIC"})

//B7D_FILIAL + B7D_CODREC + B7D_CODMED                                                                                                                                                                                                                                       
// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B7DDETAIL', { { 'B7D_FILIAL', 'xFilial( "B4F" ) ' } ,;
	                          		{ 'B7D_CODREC', 'B4F_CODREC' } } ,  "B7D_FILIAL+B7D_CODREC" )

// Indica que � opcional ter dados informados na Grid
oModel:GetModel( 'B7DDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B4FMASTER' ):SetDescription( STR0001 ) //"An�lise de Receitas"

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0001)//"An�lise de Receitas"

//Valida se existem codigos duplicados no aCols
oModel:GetModel('B7DDETAIL'):SetUniqueLine({'B7D_CODREC','B7D_CODMED','B7D_DTVINI'})

//N�o � permitido excluir linha de itens
oModel:getModel('B7DDETAIL' ):SetNoDeleteLine( .T. )
oModel:getModel('B7DDETAIL' ):SetNoInsertLine( .T. )  

oStruB7D:setProperty( 'B7D_DTVINI', MODEL_FIELD_VALID, { || ValDtValA(1) } )
oStruB7D:setProperty( 'B7D_DTFVAL', MODEL_FIELD_VALID, { || ValDtValA(1) } )
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStruB7D := FWFormStruct( 2, 'B7D' )
Local oStruB4F := FWFormStruct( 2, 'B4F' )

Local oModel   := FWLoadModel( 'PLSANRCT' )
Local oView    := FWFormView():New()

//As variaveis Private abaixo s�o necessarias por causa do uso da rotina MsDocument
Private aRotina 		:= {}
Private cCadastro   	:= FunDesc()

aRotina := {{STR0017,'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{STR0018,'PLSDOcs',0,3}}//"Anexos"##"Inclus�o R�pida"

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B4F' , oStruB4F, 'B4FMASTER'   )     

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B7D' , oStruB7D, 'B7DDETAIL'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRID', 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B4F' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_B7D' , 'GRID'  )

oView:EnableTitleView( 'VIEW_B7D' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_B7D', 'B7D_SEQUEN' )   

//Adiciona bot�o de conhecimento
oView:AddUserButton(STR0017, "CLIPS", {|| PLSANRCTANEXO(oModel)  } )//"Anexos"

//Preenche os campos abaixo automaticamente
oView:SetFieldAction('B4F_DATINI'   , { |oModel| PANRCTDTV(oModel, 1)}) 
oView:SetFieldAction('B4F_DATFIN'   , { |oModel| PANRCTDTV(oModel, 2)}) 
oView:SetFieldAction('B4F_MATRIC'   , { |oModel| PANRCTMAT(oModel, 2)}) 

Return oView  


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSANRCTVal
Valida a inclus�o do Registro
@author TOTVS
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSANRCTVal(oModel)

Local lRet		:= .T.
Local aDados	:= {}
Local oB4F		:= oModel:getmodel("B4FMASTER")
Local oB7D		:= oModel:getmodel("B7DDETAIL")
Local nTamB7D	:= oB7D:length()
local nI		:= 1
Local nReg		:= 0
Local nPos		:= 0
Local nContDef   := 0
Local nContIndef := 0
Local cStatus    := ""
Local lVal       := .F.
Local nOperation := oModel:getOperation()
Local cStatAlter := GETNEWPAR("MV_PLSALTS",'0,1,2,3,4,6') //Status que podem ser alterados na tela Analise Solicita��o   

//Status atual da analise
cStatus := oB4F:GetValue("B4F_STATUS")

IF nOperation == 3 .OR. nOperation == 4
	//A logica abaixo esta baseado na rotina de Protocolos
	//Permite mudar para "Em analise" apenas se o status anterior for "Protocolado"
	If B4F->B4F_STATUS == '1' .And. !(cStatus $'2,3,4,5,6') 
	    Help( ,, 'HELP',," Receita protocolada, para alterar � necess�rio mudar o status para '2', '3', '4', '5' ou '6' ", 1, 0)
	    lRet := .F.
	
	ElseIf B4F->B4F_STATUS == '2' .And. !(cStatus $'3,4,5,6')
	    Help( ,, 'HELP',," Receita em an�lise, para alterar � necess�rio mudar o status para '3', '4', '5' ou '6' ", 1, 0)
	    lRet := .F.
	
	ElseIf B4F->B4F_STATUS $ '3,4,5' .And. (cStatus <> '2')//B4F->B4F_STATUS
	    Help( ,, 'HELP',," Receita com an�lise j� conclu�da, para alterar � necess�rio retornar o status para 'Em an�lise' ", 1, 0)
	    //Help("",1,"PLBOW016")
	    lRet := .F.
	
	ElseIf B4F->B4F_STATUS == '6' .And. !(cStatus $'2,3,4,5')
	    Help( ,, 'HELP',," Receita Aguardando informa��o do benefici�rio, para alterar � necess�rio mudar o status para '2', '3', '4' ou '5' ", 1, 0)
	    lRet := .F.
	EndIf 
	
	//N�o permite selecionar as demais op��es
	If lRet .AND. !(cStatus $ cStatAlter)
		Help( ,, 'HELP',," O status selecionado n�o est� configurado no par�metro MV_PLSALTS ", 1, 0)
		lRet := .F.
	EndIf
	
	If lRet
		//Valida se existe algum item indeferido sem motivo padr�o de justificativa, porem nao bloqueia a grava��o, s� alerta!
		For nI := 1 To nTamB7D
			oB7D:goLine(nI)
			If (oB7D:GetValue('B7D_OK')== .F.) 
				If Empty(oB7D:GetValue('B7D_MOTIVO')) .AND. (cStatus $ '3,4,5')
					lVal := .T.
				Endif
			Else
				oB7D:SetValue('B7D_MOTIVO', Space(TamSx3('B7D_MOTIVO')[1]))
				oB7D:SetValue('B7D_OBS', Space(TamSx3('B7D_OBS')[1]))
			Endif 		
		Next
		
		If lVal 
			If (MsgYesNo(STR0020,STR0021 ))// "Existe item(s) indeferido(s) sem motivo de justificativa. Deseja inform�-lo no campo Motivo agora ?"
		   		lRet := .F.
		   		If lVal
		   			Help( ,, 'HELP',,STR0032, 1, 0)//"Na grid de Itens informe o(s) motivo(s) do(s) indeferimento(s)"
		          lVal := .F.   		
		   		Endif	
		   Endif
		Endif
	Endif
	
	If lRet
		//Analise dos status:0=Solicitado (Portal);1=Protocolado;2=Em analise;3=Deferido;4=Indeferido; 5="Deferido Parcialmente";6="Pendente Inf. beneficiario"   
		//Contagem de Deferidos e Indeferidos
		For nI := 1 To nTamB7D
			oB7D:goLine(nI)
		
			If ( oB7D:GetValue("B7D_OK") == .F.)
				nContInDef++
			Else
		   		nContDef++	 
			EndIf
		Next
		
		If (nContDef == 1) .And. (nContIndef == 1) .Or. (nContDef == nContIndef )
			If (cStatus == "3")//Deferido
				If (MsgYesNo(STR0022,STR0021))//"Deseja realmente Deferir mesmo contendo 1 item aprovado e 1 item reprovado. "#"Aten��o"
				  oB4F:SetValue('B4F_STATUS', "3")//Deferido 
			    Else
			      oB4F:SetValue('B4F_STATUS', "5")//Deferido Parcialmente
			    Endif
			Endif	
			
			If (cStatus == "4")//Indeferido
				If (MsgYesNo(STR0023,STR0021))//"Deseja realmente Indeferir mesmo contendo 1 item aprovado e 1 item reprovado "# "Aten��o"
				  oB4F:SetValue('B4F_STATUS', "4")//Indeferido 
			    Else
			    	oB4F:SetValue('B4F_STATUS', "5")//Deferido Parcialmente
			    Endif
			Endif
			
		Else
			If (nContDef == 0) .And. (nContIndef >= 1)
				
				If (cStatus == "3") 
					If (MsgYesNo(STR0024,STR0021))//"Deseja realmente Deferir mesmo contendo todos itens reprovado "# "Aten��o"
						oB4F:SetValue('B4F_STATUS', "3")//Deferido 
				    Else
				    	oB4F:SetValue('B4F_STATUS', "4")//InDeferido
				    Endif
				Endif	
				
		   Else    	      	
			  	If (nContDef >= 1) .And. (nContIndef == 0)
					If (cStatus == "4") 
						If (MsgYesNo(STR0025,STR0021))//"Deseja realmente Indeferir mesmo contendo todos os itens aprovado "# "Aten��o"
							oB4F:SetValue('B4F_STATUS', "4")//InDeferido 
					    Else
					    	oB4F:SetValue('B4F_STATUS', "3")//Deferido 
					    Endif
					Endif	
				Endif
			Endif		
		Endif
	Endif   	
	
	If lRet
		//Verifico o status para envio de e-mail
		IF ( (oB4F:GetValue("B4F_STATUS") $ "3, 4, 5, 6") )
		  PLSPREPREC("B4F","B7D", oB4F:GetValue("B4F_CODREC"), oB4F:GetValue("B4F_STATUS"))
		ENDIF
	Endif    
EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PANRCTLEGE
Defini��o da Legenda a ser apresentada
@author TOTVS
@since 06-10-2015
@version P12
/*/
//-------------------------------------------------------------------
Function PANRCTLEGE()

Local cRet

cRet := B4F_STATUS

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBAN814
Banco de conhecimento da rotina. 
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSANRCTANEXO(oModel) 
Local oModel 	:= FwModelActive()
Local oB4F		:= oModel:getmodel("B4FMASTER")
Local cCodSeq := oB4F:GetValue('B4F_CODREC')
Local cCodMat := oB4F:GetValue('B4F_MATRIC')
Local aArea		:= getArea()
Private aRotina 		:= {}
PRIVATE cCadastro   	:= FunDesc()

aRotina := {{STR0017,'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{STR0018,'PLSDOcs',0,3}}//"Anexo"##"Inclus�o R�pida"

B4F->(DbSelectArea("B4F"))
B4F->(DbSetOrder(1))	

If B4F->(MsSeek(xFilial("B4F") + cCodSeq+cCodMat )) //Posiciona no registro do Candidato
	MsDocument( "B4F", B4F->( RecNo() ), 2 )
Else
	MsgAlert( STR0033 /*"Op��o n�o dispon�vel na inclus�o. Na inclus�o, ao finalizar o cadastro ser� apresentada a op��o de cadastrar anexos"*/, STR0021 /*"Aten��o"*/)
Endif	


RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSANRCTok
Banco de conhecimento da rotina. 
@author TOTVS
@since 07/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSANRCTok
Local oModel 	:= FwModelActive()
Local oB4F		:= oModel:getmodel("B4FMASTER")
Local oB7D		:= oModel:getmodel("B7DDETAIL")
Local cDtIni  := oB4F:GetValue("B4F_DATINI")

If Empty(oB7D:GetValue('B7D_DTVINI')) .And. !Empty(cDtIni)
	oB7D:SetValue('B7DDETAIL','B7D_DTVINI', cDtIni)
Endif

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} PANRCTDTV
Preenche os campos correspondentes a Data Inicial e Final Sugerida.
@author Roberto Vanderlei de Arruda
@since 01/10/2015
@version P12
/*/
//-------------------------------------------------------------------

Function PANRCTDTV(oView, nCpoDt)

Local oB7D	:= oView:GetModel("B7DDETAIL")
Local oB4F	:= oView:GetModel("B4FMASTER")


If(alltrim(DTOC(oB7D:GetValue("B7D_DTVINI"))) = "/  /")
	oB7D:GoLine( 1 ) //posiciona no primeiro registro
	oB7D:LoadValue("B7D_DTVINI" , oB4F:GetValue("B4F_DATINI"))	
endif
	
If(alltrim(DTOC(oB7D:GetValue("B7D_DTFVAL"))) = "/  /")
	oB7D:GoLine( 1 ) //posiciona no primeiro registro
	oB7D:LoadValue("B7D_DTFVAL" , oB4F:GetValue("B4F_DATFIN"))
endif

oB7D:GoLine( 1 ) 
oB7D:LoadValue("B7D_BENEFI" , oB4F:GetValue("B4F_MATRIC"))

oView:Refresh()

return



/*�������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �PANRCTMAT �Autor  � TOTVS              � Data � 16/10/2015      ���
�����������������������������������������������������������������������������͹��
���Fun��o para carregar a matricula do beneficiario                         �͹��
�������������������������������������������������������������������������������*/
Function PANRCTMAT(oView, nCpoDt)

Local oB7D	:= oView:GetModel("B7DDETAIL")
Local oB4F	:= oView:GetModel("B4FMASTER")

oB7D:GoLine( 1 ) 
oB7D:LoadValue("B7D_BENEFI" , oB4F:GetValue("B4F_MATRIC"))

oView:Refresh()

return



/*�������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �PLSPREPREC �Autor  � Renan Martins      � Data � 10/2015        ���
�����������������������������������������������������������������������������͹��
���Fun��o para organizar dados para envio de email baseado no status        �͹��
�������������������������������������������������������������������������������*/
FUNCTION PLSPREPREC(cAlias,cAliasIte, cProtocolo, cStatusID, cStatusDesc)
	
Local cChave := ""
Local linha
Local aCampos := {}
Local aItens  := {}
Local nVlrPagPro := 0
Local cMotItem := ""
Local nIndice
Local linha
Local oModel	:= FwModelActive()
Local oB7D		:= oModel:getmodel("B7DDETAIL")
Local nTamB7D	:= oB7D:length()
local nI		:= 1
Local oB4F		:= oModel:getmodel("B4FMASTER")
Default cStatusDesc = ""
	
//***** Prepara dos campos
IF (cStatusID == "3") //aPROVADO
  cStatusDesc = STR0028//"Aprovado"
ELSEIF (cStatusID == "5")  
  cStatusID = "C"  //Aprovado parcialmente
  cStatusDesc = STR0029//"Aprovado Parcialmente"
ELSEIF (cStatusID == "6") //Pendente
  cStatusID = "B"
  cStatusDesc = STR0027//"Pendente de Informa��o Benefici�rio"
Else
  cStatusDesc = STR0006//"Indeferido" // Para indeferido n�o precisa, bate o c�digo 4
ENDIF

BBP->(dbSetOrder(1))

//Analise dos status,0=Solicitado (Portal);1=Protocolado;2=Em analise;3=Deferido;4=Indeferido;    
For nI := 1 To nTamB7D
	oB7D:goLine(nI)

	IF ( !Empty(oB7D:GetValue("B7D_MOTIVO")) )
	  If BBP->( dbSeek(xFilial("BBP")+oB7D:GetValue("B7D_MOTIVO")) )
		 cMotItem := alltrim(BBP->BBP_DESMOT)
	  endif
	ENDIF
	
	aadd(aItens, {Posicione("BR8",1,xFilial("BR8")+B7D->(oB7D:GetValue("B7D_CODPAD")+oB7D:GetValue("B7D_CODMED")),"BR8_DESCRI"), IIF(oB7D:GetValue("B7D_OK") == .T., "Aprovado", "Reprovado") , .F., .F., iif(cMotItem = NIL, "", cMotItem)})
cMotItem := ""																																
																																				
Next


	aadd(aCampos, {"cProtoc", oB4F:GetValue("B4F_CODREC")})
	aadd(aCampos, {"cTipoSolicitacao", STR0030})//"Receitas - Medicamentos"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	aadd(aCampos, {"cNomBen", capital(POSICIONE("BA1",2,XFILIAL("BA1")+oB4F:GetValue("B4F_MATRIC"),"BA1_NOMUSR"))}) 
	aadd(aCampos, {"cDtProvPagto", ""})
	aadd(aCampos, {"cValTot", ""})
	aadd(aCampos, {"cMotiv", ""})//Motivo da Capa do Protocolo
	aadd(aCampos, {"cDatPar", DATE()})
	aadd(aCampos, {"cStatusAut", cStatusDesc})
	PLRMBMAIL(aCampos, aItens, alltrim(BA1->BA1_EMAIL), "PLSA001A", cStatusID )
return



/*�������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �PValUnid �Autor  � TOTVS              � Data � 16/10/2015      ���
�����������������������������������������������������������������������������͹��
���Fun��o para validar se a unidade digitada existe na                      �͹��
�������������������������������������������������������������������������������*/
Function PValUnid()

oModel	:= FwModelActive()
oB4F	:= oModel:getmodel("B4FMASTER")
oB7D	:= oModel:getmodel("B7DDETAIL")
cUnid  := alltrim(upper(oB7D:GetValue("B7D_UNICON")))
lRet   := .F.

BTQ->(DbSelectArea("BTQ"))
BTQ->(DbSetOrder(1))	//BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM  
BTQ->(dBgOTOP())                                                                                                                              
If BTQ->(MsSeek(xFilial("BTQ") + "60" )) //Posiciona 
 While !BTQ->(EOF()) .And. xFilial("BTQ")+BTQ->BTQ_CODTAB == xFilial("BTQ")+ "60"
	 If alltrim(UPPER(BTQ->BTQ_DESTER)) == cUnid
 		lRet := .T.
 		exit
 	 Endif
  	BTQ->(DBSkip())
  Enddo
Endif
BTQ->(DbCloseArea())
return lRet

/*�������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �PDesSol �Autor  � TOTVS              � Data � 16/10/2015      ���
�����������������������������������������������������������������������������͹��
���Fun��o para retornar o nome do solicitante                               �͹��
�������������������������������������������������������������������������������*/  
Function PDesSol()  
Local cRet := ""  
Local oModel 	:= FwModelActive()
Local oB4F		:= oModel:getmodel("B4FMASTER")
Local cRet    := ""

BB0->(DbSelectArea("BB0"))
BB0->(DbSetOrder(7))	//BB0_FILIAL+BB0_NUMCR                                                                                                                                                                                                                                                                     
If BB0->(MsSeek(xFilial("BB0") + alltrim(oB4F:GetValue("B4F_REGSOL")) )) //Posiciona   
	cRet := BB0->BB0_NOME
Endif  
                                                                                           
return cRet      


/*���������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLStatusBox  �Autor  �TOTVS           � Data �  14/09/15   ���
�������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������*/
Function PLStRct()
Return(STR0031)


/*�������������������������������������������������������������������������ͻ��
���Programa  �ValDtValA()   �Autor  �Thiago Guilherme   � Data �  28/05/15���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o dos campos de validade do medicamento		  ���
nCpoDt: 1 - data inicial|| 2 - Data final
cTipoVal: 1 - Item || 2 - Cabecalho
����������������������������������������������������������������������������*/
FUNCTION ValDtValA(nCpoDt)

Local lRet := .F.
Local dDtIni := STOD("") 
Local dDtFin := STOD("") 
Local oModel := FwModelActive()
 
//oModelDados	:= oModelAct:getmodel("B7DDETAIL")
dDtIni := oModel:GetValue( 'B7DDETAIL', 'B7D_DTVINI' )
dDtFin := oModel:GetValue( 'B7DDETAIL', 'B7D_DTFVAL' )
 
if nCpoDt == 1
	                                                         
	If EMPTY(dDtFin) .OR. dDtIni <= dDtFin
		lRet := .T.
	EndIf
ElseIf nCpoDt == 2

	If EMPTY(dDtIni) .OR. dDtIni <= dDtFin
		lRet := .T.
	EndIf
EndIf

Return lRet

/*�������������������������������������������������������������������������ͻ��
���Programa  �ValAnIntDt()   �Autor  �Roberto Arruda   � Data �  22 /05/15���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o dos campos de data do medicamento		  		  ���
����������������������������������������������������������������������������*/
Function ValAnIntDt()

	Local oB7D	  := oModel:GetModel('B7DDETAIL')
	Local nLinhaAtual := oB7D:GetLine()
	Local lRet := .T.
	Local nI
	Local nTamB7D := oB7D:Length()
	Local cCodPad
	Local cCodPro 
	Local dDtIni
	Local dDtFim
	
	if oModel <> nil
		//Armazenando os valores que est�o sendo inseridos
		cCodPad  := oB7D:GetValue("B7D_CODPAD")
		cCodPro  := oB7D:GetValue("B7D_CODMED") 
		dDtIni   := oB7D:GetValue("B7D_DTVINI")
		dDtFim   := oB7D:GetValue("B7D_DTFVAL")
		
		for nI := 1 to nTamB7D
			if nI <> nLinhaAtual .and. lRet
			
				oB7D:GoLine(nI)
				
				if alltrim(oB7D:GetValue("B7D_CODPAD")) = alltrim(cCodPad) .and. alltrim(oB7D:GetValue("B7D_CODMED")) = alltrim(cCodPro)
					if oB7D:GetValue("B7D_DTVINI") <= dDtIni .and. dDtIni <= oB7D:GetValue("B7D_DTFVAL") // Validando data Inicial
						Help( ,, 'Help',, STR0034/*"O per�odo informado cont�m dias em conflito com o registro na "*/ + cvaltochar(nI) + STR0035/*"� linha."*/, 1, 0 )
						lRet := .F.
					elseif dDtIni <= oB7D:GetValue("B7D_DTVINI") .and. dDtFim >= oB7D:GetValue("B7D_DTVINI")
						Help( ,, 'Help',, STR0034/*"O per�odo informado cont�m dias em conflito com o registro na "*/ + cvaltochar(nI) + STR0035/*"� linha."*/, 1, 0 )
						lRet := .F.
					elseif dDtFim >= oB7D:GetValue("B7D_DTVINI") .and. dDtFim <= oB7D:GetValue("B7D_DTFVAL")
						Help( ,, 'Help',, STR0034/*"O per�odo informado cont�m dias em conflito com o registro na "*/ + cvaltochar(nI) + STR0035/*"� linha."*/, 1, 0 )
						lRet := .F. 
					endif
				endif				
			endif			
		next
				
		oB7D:GoLine(nLinhaAtual) //Posicionando na Linha Atual 
	endif
return lRet                          


//-------------------------------------------------------------------
/*{Protheus.doc} PLSANRCTCOMMI
antes do commit
@since 10/11/2015
@version P11.8
*/
//-------------------------------------------------------------------
Function PLSANRCTCOMMI(oModel)
Local lRet	:= .T.
Local nOperation	:= oModel:GetOperation()

If nOperation ==  MODEL_OPERATION_DELETE		
	lRet	:= .F.
	Help( ,, 'Help',, STR0026, 1, 0 )//"N�o � poss�vel excluir."
EndIf 

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSDELUSOC
@author Karine Riquena Limp
@since 05/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSDELUSOC(cAlias, nRecno)
Local lRet	:= .T.

	&(cAlias)->(DbGoTop())
	&(cAlias)->(DbGoTo(nRecno))
	
	&(cAlias)->(RecLock(cAlias,.F.))
	&(cAlias)->(DbDelete())
	&(cAlias)->( MsUnlock() )


Return(lRet)

