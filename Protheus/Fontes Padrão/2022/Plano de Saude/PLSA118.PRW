#INCLUDE 'PROTHEUS.CH'	 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSA118.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA118   บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que realiza o parcelamento de co-participa็ใo  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA118(lAutoma)
Local oBrowse
Default lAutoma := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B79' )
oBrowse:SetDescription( STR0001) //'Parcelamento de Co-Participa็ใo'
Iif(!lAutoma, oBrowse:Activate(), "")

Return NIL
   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o menu											  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002  	Action 'PesqBrw'          	OPERATION 1 ACCESS 0  //'Pesquisar'
ADD OPTION aRotina Title STR0003 	Action 'VIEWDEF.PLSA118' 	OPERATION 2 ACCESS 0  //'Visualizar'
ADD OPTION aRotina Title STR0004    Action 'PLSA118IN' 	   		OPERATION 3 ACCESS 0  //'Incluir'
ADD OPTION aRotina Title STR0005    Action 'VIEWDEF.PLSA118' 	OPERATION 5 ACCESS 0  //'Excluir'
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine o model										  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()

Local oStruB79 := FWFormStruct( 1, 'B79' )
Local oStruB80 := FWFormStruct( 1, 'B80' )
Local oModel

oModel := MPFormModel():New( 'PLSA118M' )

oModel:AddFields( 'B79MASTER', /*cOwner*/, oStruB79 )

oModel:AddGrid( 'B80DETAIL', 'B79MASTER', oStruB80 )
    
oModel:GetModel( 'B80DETAIL' ):SetMaxLine(999999999)
	
oModel:SetRelation( 'B80DETAIL', { 	{ 'B80_FILIAL', 'xFilial( "B80" )' 	},;
	{ 'B80_CODIGO', 'B79_CODIGO' 		}})

oModel:SetDescription( 'Parcelamento' )

oModel:GetModel( 'B79MASTER' ):SetDescription( 'Parcelamento' )
oModel:GetModel( 'B80DETAIL' ):SetDescription( 'Detalhes'  )

Return oModel
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine a view		 									  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruB79 := FWFormStruct( 2, 'B79' )
Local oStruB80 := FWFormStruct( 2, 'B80' , { |cCampo| !(cCampo $ "B80_ANOBAS/B80_MESBAS") } )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA118' )
Local oView
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// Cria o objeto de View
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B79', oStruB79, 'B79MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B80', oStruB80, 'B80DETAIL' )

// Criar novo botao na barra de botoes
oView:AddUserButton( STR0006, 'CLIPS', { |oView| CargaDet() } )   //'Carregar'

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B79', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_B80', 'INFERIOR' )

Return oView
             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA118IN บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de inclusao dos dados de parcelamento			  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA118IN(xAuxiliar)//xAuxiliar pois estใo vindo valores dentro desse campo que nใo existem e nใo interagem com a fun็ใo. Criado essa variแvel para poder passar a Automa็ใo sem nenhum problema do pergunte, pois configurei os MV_PAR e estแ pegando valores no Pergunte().
Local aCposDet	:= {}
Local aCposCab	:= {}
Local lAutoma	:= .F.
Local xAuxiliar	:= Iif(xAuxiliar == "lAutoma", lAutoma := .T., lAutoma := .F.)

Private cPerg	:= "PLSA118"

If !lAutoma
	cRet := Pergunte(cPerg, .T.) 
Else
	cRet := lAutoma
EndIf

If cRet
	
	DbSelectArea("BA0")
	If !ExistCpo("BA0",MV_PAR01,1)
		MsgAlert(OemtoAnsi(STR0023))//"Preencha a operadora corretamente!"
		Return()
	EndIf
	
	DbSelectArea("BA0")
	If !Empty(MV_PAR02)
		If !ExistCpo("BG9",MV_PAR01+MV_PAR02)
			MsgAlert(OemtoAnsi(STR0023))//"Preencha a empresa inicial corretamente!"
			Return()
		EndIf
	EndIf
	
	If !Empty(MV_PAR03)
		If !(MV_PAR03 == "9999")
			If !ExistCpo("BG9",MV_PAR01+MV_PAR03)
				MsgAlert(OemtoAnsi(STR0024))//"Preencha a empresa final corretamente! ษ aceito '9999' neste parโmetro."
				Return()
			EndIf
		EndIf
	EndIf
	
	MV_PAR05 := StrZero(Val(MV_PAR05),2)
	If !(MV_PAR05 $ '01,02,03,04,05,06,07,08,09,10,11,12' )
		MsgAlert(STR0007 ) //"Preencha o M๊s corretamente."
		Return()
	EndIf
	
	If Len(MV_PAR06 ) != 4
		MsgAlert(STR0008) // "Preencha o Ano corretamente."
		Return()
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณChama a rotina para carregar o array...ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Processa({|lEnd| CargaDet(aCposDet) })
Else
	Return(.T.)
Endif

If Len(aCposDet) > 0
	aAdd( aCposCab, { 'B79_CODINT', MV_PAR01	} )
	aAdd( aCposCab, { 'B79_CODEMP', MV_PAR02 	} )
	aAdd( aCposCab, { 'B79_EMPINI', MV_PAR02 	} )
	aAdd( aCposCab, { 'B79_EMPFIM', MV_PAR03 	} )
	aAdd( aCposCab, { 'B79_MATRIC', MV_PAR04 	} )
	aAdd( aCposCab, { 'B79_MESBAS', MV_PAR05	} )
	aAdd( aCposCab, { 'B79_ANOBAS', MV_PAR06	} )
		
	Processa({|lEnd| Import( 'B79', 'B80', aCposCab, aCposDet, Len(aCposDet))},"Aguarde...")
	
	If !lAutoma
		MsgAlert(STR0010) //"Processamento Realizado com Sucesso!"
	Else 
		Return (.T.)
	EndIf
Else
	If !lAutoma
		MsgAlert(STR0011) //"Nใo hแ Dados para Selecionar!"
	Else
		Return (.F.)
	EndIf	
EndIf

Return
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCargaDet  บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a busca dos dados do ACOLS						  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CargaDet(aCposDet)
Local cSql		:= ""
Local lRet		:= .T.
Local aCampos 	:= {}
Local nTotReg	:= 0
Local nI		:= 0
Local nVlFam  := 0

cSql =  " SELECT	BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1_MATRIC, 	BA1.BA1_TIPREG, "
cSql += "   SUM(BDH.BDH_VLBRPA) BDH_VLBRPA,	SUM(BDH.BDH_VLCOPA) BDH_VLCOPA, SUM(BK2.BK2_SALDO) BK2_SALDO, MAX(BK2.BK2_DATREA) BK2_DATREA, "
cSql += "    MAX(BA3.BA3_VENCTO) BA3_VENCTO, MAX(BDH.BDH_SEQPF) BDH_SEQPF "
cSql += " FROM "+RetSqlName("BA1")+" BA1"
cSql += " INNER JOIN "+RetSqlName("BA3")+" BA3"
cSql += " 	ON	BA1.BA1_FILIAL	= BA3.BA3_FILIAL "
cSql += " 	AND BA1.BA1_CODINT	= BA3.BA3_CODINT "
cSql += " 	AND BA1.BA1_CODEMP	= BA3.BA3_CODEMP "
cSql += " 	AND BA1.BA1_CONEMP	= BA3.BA3_CONEMP "
cSql += " 	AND BA1.BA1_VERCON	= BA3.BA3_VERCON "
cSql += " 	AND BA1.BA1_SUBCON	= BA3.BA3_SUBCON "
cSql += " 	AND BA1.BA1_VERSUB	= BA3.BA3_VERSUB "
cSql += " 	AND BA1.BA1_MATRIC	= BA3.BA3_MATRIC "
cSql += " 	AND BA1.BA1_PACOOK = '0' "
cSql += " 	AND BA3.BA3_PACOOK = '0' "
cSql += " 	AND BA1.D_E_L_E_T_	= ' ' "
cSql += " 	AND BA3.D_E_L_E_T_	= ' ' "
cSql += " LEFT JOIN "+RetSqlName("BDH")+" BDH"
cSql += " 	ON	BA1.BA1_FILIAL	= 	BDH.BDH_FILIAL"
cSql += " 	AND BA1.BA1_CODINT	= 	BDH.BDH_CODINT"
cSql += " 	AND BA1.BA1_CODEMP	= 	BDH.BDH_CODEMP"
cSql += " 	AND BA1.BA1_MATRIC	= 	BDH.BDH_MATRIC"
cSql += " 	AND	BA1.BA1_TIPREG	= 	BDH.BDH_TIPREG"
cSql += " 	AND BDH.D_E_L_E_T_	= 	' '"
cSql += " 	AND BA1.D_E_L_E_T_	= 	' '"
cSql += " 	AND  ( BDH.BDH_ANOFT < '"+MV_PAR06+"' OR ( BDH.BDH_ANOFT = '"+MV_PAR06+"' AND BDH.BDH_MESFT <= '"+MV_PAR05+"' ) )"
cSql += " 	AND BDH.BDH_VLRPAR	= 	'0'"
cSql += " 	AND BDH_STATUS = '1'" //1=Aberto;0=Faturado;2=Gratuidade
cSql += "    AND BDH_MESPRO = '  '" 
cSql += "    AND BDH_NUMFAT = '  '" 
cSql += " LEFT JOIN "+RetSqlName("BK2")+" BK2"
cSql += " 	ON	BA1.BA1_FILIAL	= 	BK2.BK2_FILIAL"
cSql += " 	AND BA1.BA1_CODINT	= 	BK2.BK2_CODINT"
cSql += "    AND BA1.BA1_CODEMP	= 	BK2.BK2_CODEMP"
cSql += " 	AND BA1.BA1_MATRIC	= 	BK2.BK2_MATRIC"
cSql += " 	AND	BA1.BA1_TIPREG	= 	BK2.BK2_TIPREG"
cSql += "    AND BK2.BK2_PLNUCO = ' '"
cSql += " 	AND BK2.D_E_L_E_T_	= 	' '"
cSql += "    AND BK2.BK2_PARCEL = 'N' "
cSql += " 	AND  ( BK2.BK2_ANO < '"+MV_PAR06+"' OR ( BK2.BK2_ANO = '"+MV_PAR06+"' AND BK2.BK2_MES <= '"+MV_PAR05+"' ) )"
cSql += " WHERE"
cSql += " 		BA1.BA1_FILIAL	= 	'"+xFilial("BA1")+"'"
cSql += " 	AND	BA1.BA1_CODINT	= 	'"+MV_PAR01+"'"
cSql += " 	AND	BA1.BA1_CODEMP	BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'
If !Empty(MV_PAR04)
	cSql += " 	AND	BA1.BA1_MATRIC	= 	'"+MV_PAR04+"'"
EndIf
			// Valida se ja foi parcelado neste mes
cSql += " 	AND	(	SELECT COUNT(*)"
cSql += " 			FROM "+RetSqlName("B79")+" B79"
cSql += " 			INNER JOIN "+RetSqlName("B80")+" B80"
cSql += " 				ON	B79.B79_CODIGO	=	B80.B80_CODIGO "
cSql += " 				AND B79.D_E_L_E_T_	= 	' '"
cSql += " 				AND B80.D_E_L_E_T_	= 	' '"
cSql += " 			WHERE"
cSql += " 					BA1.BA1_CODINT	= 	B80.B80_CODINT"
cSql += " 				AND BA1.BA1_CODEMP	= 	B80.B80_CODEMP"
cSql += " 				AND BA1.BA1_MATRIC	= 	B80.B80_MATRIC"
cSql += " 				AND BA1.BA1_TIPREG	= 	B80.B80_TIPREG"
cSql += " 				AND B79.B79_MESBAS	=	'"+MV_PAR05+"'"
cSql += " 				AND B79.B79_ANOBAS	=	'"+MV_PAR06+"'"
cSql += " 				AND BA1.D_E_L_E_T_	= 	' '"
cSql += " 		) = 0"
cSql += " 	AND (BDH.BDH_VLBRPA > 0	OR	BDH.BDH_VLCOPA > 0	OR	BK2.BK2_SALDO > 0)"
cSql += " GROUP BY BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1_MATRIC, 	BA1.BA1_TIPREG"
cSql += " ORDER BY BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1_MATRIC, BA1.BA1_TIPREG "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TEMP",.F.,.T.)

TEMP->( dbEval( { || nTotReg++ } ) )

TEMP->(DBGoTop())

If nTotReg > 0
	
	ProcRegua(nTotReg)
	
	While !TEMP->(EoF())
	
		// Carregando os registros
		aCampos := {}
		aAdd( aCampos, 	{ 'B80_CODINT', TEMP->BA1_CODINT  	} )
		aAdd( aCampos, 	{ 'B80_CODEMP', TEMP->BA1_CODEMP 	} )
		aAdd( aCampos, 	{ 'B80_MATRIC', TEMP->BA1_MATRIC 	} )
		aAdd( aCampos, 	{ 'B80_TIPREG', TEMP->BA1_TIPREG 	} )
		aAdd( aCampos, 	{ 'B80_VALCOP', TEMP->BDH_VLBRPA } )
		aAdd( aCampos, 	{ 'B80_VALCOL', TEMP->BDH_VLCOPA  	} )
		aAdd( aCampos, 	{ 'B80_VALSAL', TEMP->BK2_SALDO 	} )
		aAdd( aCampos,	{ 'B80_MESBAS', MV_PAR05			} )
		aAdd( aCampos,	{ 'B80_ANOBAS', MV_PAR06			} )
		aAdd( aCampos, 	{ 'B80_DATREA', Iif(Empty(TEMP->BK2_DATREA),StoD(MV_PAR06+MV_PAR05+StrZero(TEMP->BA3_VENCTO,2)),STOD(TEMP->BK2_DATREA))} )
		aAdd( aCampos, 	{ 'B80_VALSAL', TEMP->BK2_SALDO 	} )
		aAdd( aCampos, 	{ 'cSEQPF', TEMP->BDH_SEQPF 	} )
				
		aAdd( aCposDet, aCampos )
		TEMP->(DbSkip())
		
		nI ++
		IncProc(STR0012+StrZero(nI,6)+STR0013+StrZero(nTotReg,6)) //"Calculando "###" de "
	
	EndDo

Else

	lRet := .F.

EndIf

TEMP->(DbCloseArea())

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImport    บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a importacao dos dados para o HEADER e ACOLS			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Import(  cMaster, cDetail, aCpoMaster, aCpoDetail )
Local oModel, oAux, oStruct
Local nI       	:= 0
Local nJ       	:= 0
Local nPos     	:= 0
Local nTotVal	:= 0
Local nTotSeg	:= 0
Local nTotVlm	:= 0
Local nCount	:= 0
Local lRet     	:= .T.
Local aAux	   	:= {}
Local aC  	   	:= {}
Local aH       	:= {}
Local nItErro  	:= 0
Local lAux     	:= .T.
Local nLote		:= ""
Local nTotFam		:= 0
Local nTotSalFam := 0
Local cChaveFam  := ""
Local nTotSegFam := 0
Local nTotVlmFam := 0
Local cChaveBK2  := ""
Local cChaveBDH  := ""
Local nDif       := 0
Local nCalDif    := 0
Local nDifBk2    := 0
Local nTotFamArred := 0
Local lBK2Fim		:= .F.
Local cMesBDH :=  ""
Local lBDHFim  := .F.

dbSelectArea( cDetail )
dbSetOrder( 1 )

dbSelectArea( cMaster )
dbSetOrder( 1 )

// Aqui ocorre o instanciamento do modelo de dados (Model)
oModel := FWLoadModel( 'PLSA118' )

// Temos que definir qual a opera็ใo deseja: 3 – Inclusใo / 4 – Altera็ใo / 5 - Exclusใo
oModel:SetOperation( 3 )

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
oModel:Activate()

// Instanciamos apenas a parte do modelo referente aos dados de cabe็alho
oAux    := oModel:GetModel( cMaster + 'MASTER' )

// Obtemos a estrutura de dados do cabe็alho
oStruct := oAux:GetStruct()
aAux	:= oStruct:GetFields()

If lRet
	For nI := 1 To Len( aCpoMaster )

		// Verifica se os campos passados existem na estrutura do cabe็alho
		If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

			// ศ feita a atribuicao do dado aos campo do Model do cabe็alho
			If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )

				// Caso a atribui็ใo nใo possa ser feita, por algum motivo (valida็ใo, por exemplo)
				// o m้todo SetValue retorna .F.
				lRet    := .F.
				Exit

			EndIf
		EndIf
	Next
EndIf
	
Begin Transaction
	If lRet
		// Instanciamos apenas a parte do modelo referente aos dados do item
		oAux     := oModel:GetModel( cDetail + 'DETAIL' )
	
		// Obtemos a estrutura de dados do item
		oStruct  := oAux:GetStruct()
		aAux	 := oStruct:GetFields()
	
		nItErro  := 0
	
		ProcRegua(Len(aCpoDetail))
		
		For nI := 1 To Len( aCpoDetail )
			// Incluํmos uma linha nova
			// ATENCAO: O itens sใo criados em uma estrura de grid (FORMGRID), portanto jแ ้ criada uma primeira linha
			//branco automaticamente, desta forma come็amos a inserir novas linhas a partir da 2ช vez
	        
			IncProc(STR0012+StrZero(nI,6)+STR0013+StrZero(Len(aCpoDetail),6)) //"Calculando "###" de "
				
			If nI > 1
	
				// Incluimos uma nova linha de item
	
				If  ( nItErro := oAux:AddLine() ) <> nI
	
					// Se por algum motivo o metodo AddLine() nใo consegue incluir a linha,
					// ele retorna a quantidade de linhas jแ
					// existem no grid. Se conseguir retorna a quantidade mais 1
					lRet    := .F.
					Exit
	
				EndIf
	
			EndIf
								
			For nJ := 1 To Len( aCpoDetail[nI] )
		
						// Verifica se os campos passados existem na estrutura de item
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
		
					If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
		
							// Caso a atribui็ใo nใo possa ser feita, por algum motivo (valida็ใo, por exemplo)
							// o m้todo SetValue retorna .F.
						lRet    := .F.
						nItErro := nI
						Exit
					EndIf
				EndIf
			Next
	           	 
			If !lRet
				Exit
			EndIf
			
			cChaveFam := ""
			// Realiza o parcelamento
			DbSelectArea("BA1")
			BA1->(DbSetOrder(2))//BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO
				
			cChave := FwFldGet( 'B80_CODINT',nI)+FwFldGet( 'B80_CODEMP',nI)+FwFldGet( 'B80_MATRIC',nI)+FwFldGet( 'B80_TIPREG',nI)
			
			If BA1->(MsSeek(xFilial("BA1")+cChave))
			
				cChaveFam := FwFldGet( 'B80_CODINT',nI)+FwFldGet( 'B80_CODEMP',nI)+FwFldGet( 'B80_MATRIC',nI)
					//nTotFam := 0
				nTotVlm := 0
				nTotSeg := 0
				lBK2Fim := .F.
					//nTotSalFam := 0
		       		
		       		//Zero o Saldo apenas se mudar a matricula e Cod Empresa para evitar de buscar a mesma informa็ใo varias vezes para a mesma familia.
					
				lChaveDif := .F.
				If Substr(cChaveFam,5,10)<> cChaveBK2
					nTotSalFam := 0
					cChaveBK2  := ""
					nDifBK2    := 0
					nDif       := 0
					lBDHFim    := .F.
					lChaveDif  := .T.
				Endif
		    	    
		    		//Pego o valor da BK2 por TIPREG da Familia para realizar a proporcionalidade da Parcela Calculada.			    				    	       			    		    
				DbSelectArea("BK2")
				BK2->(DbSetOrder(5))
				BK2->(MsSeek(xFilial("BK2")+ cChaveFam + MV_PAR06 + MV_PAR05))
					
				If lChaveDif
					cChaveBK2 := BK2->BK2_CODEMP + BK2->BK2_MATRIC
				Endif
					
				While !BK2->(EoF()) .AND. Empty(BK2->BK2_PLNUCO) .AND. BK2->BK2_MATRIC == Substr(cChaveFam,9,6)
						
					If lChaveDif
						If BK2->BK2_MES == MV_PAR05 .AND. BK2->BK2_ANO == MV_PAR06 .AND. BK2->BK2_CODEMP == MV_PAR02
							nTotSalFam += BK2->BK2_SALDO
							lBK2Fim    := .T.
						EndIf
					Endif
							
					If BK2->BK2_PARCEL == 'N' .AND. BK2->BK2_TIPREG == FwFldGet( 'B80_TIPREG',nI) .AND. EMPTY(BK2->BK2_NUMTIT);
							.AND. BK2->BK2_CODEMP == MV_PAR02 .AND. BK2->BK2_MES == MV_PAR05 .AND. BK2->BK2_ANO == MV_PAR06
												
						cRegra := Posicione("BA1",2,BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_TIPREG+BK2_DIGITO),"BA1->BA1_TREGRA" )
						If 	cRegra == "0" .And. BA1->BA1_PACOOK == "0"
							nTotSeg += Iif(BK2->BK2_SALANT == 0,BK2->BK2_SALDO,BK2->BK2_SALANT)
						EndIf
						nTotVlm += BK2->BK2_SALDO
					EndIf
					BK2->(DbSkip())
				EndDo
				  
			 	//Pego o valor total da BDH da Familia caso nใo exista BK2			     	
			    If nTotSalFam = 0 .AND. cChaveBDH <> cChaveFam
					nTotFam := 0
					DbSelectArea("BDH")
					BDH->(DbSetOrder(1))
					BDH->(MsSeek(xFilial("BDH")+ cChaveFam))
					While !BDH->(EoF()).AND. BDH->BDH_MATRIC == Substr(cChaveFam,9,6) .AND. BDH->BDH_CODEMP == MV_PAR02
						If BDH->BDH_ANOFT <= MV_PAR06 .AND. BDH->BDH_MESFT <= MV_PAR05 .AND. EMPTY(BDH->BDH_NUMFAT) .AND.;
							BDH->BDH_VLRPAR = 0
									
							nTotFam += BDH->BDH_VLCOPA  //Valor de Copart. + Franquia
							cChaveBDH := BDH->BDH_CODINT + BDH->BDH_CODEMP + BDH->BDH_MATRIC
						EndIf
						BDH->(DbSkip())
					EndDo
				EndIf
									
				// Pego o valor da BDH por TIPREG da familia, para realizar a proporcionalidade da Parcela Calculada, caso nao possua BK2.						
				DbSelectArea("BA1")
				BA1->(DbSetOrder(2))//BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO
				cChave := FwFldGet( 'B80_CODINT',nI)+FwFldGet( 'B80_CODEMP',nI)+FwFldGet( 'B80_MATRIC',nI)+FwFldGet( 'B80_TIPREG',nI)
				cMesBDH := ""
				DbSelectArea("BDH")
				BDH->(DbSetOrder(1))
				If BDH->(MsSeek(xFilial("BDH")+cChaveFam +FwFldGet( 'B80_TIPREG',nI)))
					While !BDH->(EoF()) .AND. BDH->BDH_MATRIC == Substr(cChaveFam,9,6)
						If BDH->BDH_STATUS == "1" .AND. BDH->BDH_ANOFT <= MV_PAR06 .AND. BDH->BDH_MESFT <= MV_PAR05 .AND.;
								BDH->BDH_TIPREG == BA1->BA1_TIPREG .AND. EMPTY(BDH->BDH_NUMFAT).AND. BDH->BDH_VLRPAR == 0
									
							nTotVlm += BDH->BDH_VLCOPA 
							cMesBDH := BDH->BDH_MESFT
							If BA1->BA1_TREGRA  == "0"  .And. BA1->BA1_PACOOK == "0"
								nTotSeg += BDH->BDH_VLCOPA 
							EndIf
						EndIf
						BDH->(DbSkip())
					EndDo
				EndIf
			   		
			   	//Preciso verificar agora, se nใo apareceu um novo BDH depois do primeiro parcelamento, 
			   	//pois em caso positivo, devo acrescentar este valor a BK2.
				If nTotSalFam > 0 .AND. !lBDHFim
					DbSelectArea("BDH")
					BDH->(DbSetOrder(1))
					If BDH->(MsSeek(xFilial("BDH")+cChaveFam)) //.and. nTotSalFam > 0
						While !BDH->(EoF()).AND. BDH->BDH_MATRIC == Substr(cChaveFam,9,6) .AND. BDH->BDH_CODEMP == MV_PAR02
							If BDH->BDH_STATUS == "1" .AND. BDH->BDH_ANOFT <= MV_PAR06 .AND. BDH->BDH_MESFT <= MV_PAR05 .AND.;
									BDH->BDH_VLRPAR == 0 .AND. EMPTY(BDH->BDH_NUMFAT) .AND. EMPTY(BDH->BDH_MESPRO)
								nTotSalFam += BDH->BDH_VLCOPA
								lBDHFim := .T.
							EndIf
							BDH->(DbSkip())
						EndDo
					EndIf
				EndIf
			   			   				
				//Caso eu possua saldo na BK2, utilizarei este valor para realizar o parcelamento
				nTotFam := Iif(nTotSalFam == 0, nTotFam, nTotSalFam)
				
				nTotVal := nTotVlm //FwFldGet( 'B80_VALCOL',nI) + FwFldGet( 'B80_VALSAL',nI)
				
				//Calculo a Parcela			   																			
				aRet := PLSVLRCOP(	MV_PAR06,			   		MV_PAR05,	FwFldGet( 'B80_VALCOL',nI),	nTotVal,;
					0,		   					nTotFam,	nTotFam,					nTotFam,;
					FwFldGet( 'B80_DATREA',nI),	FwFldGet( 'B80_VALCOP',nI) - FwFldGet( 'B80_VALCOL',nI))
				   //Calculo a parcela de forma proporcional
				If aRet[1][1] > 0 .and. aRet[1][2] > 0
					aRet[1][1] := aRet[1][1] * (Round((nTotVlm / nTotFam) * 100,2))/100
					nDif       += aRet[1][1]
						 //Calculo o valor restante para o pr๓ximo periodo.						
					aRet[1][2] := Round(nTotVlm - aRet[1][1],2)
					nDifBK2    += aRet[1][2]
						 
						 //Arredondo caso nใo a proporcionalidade nใo de exatos 100						 						 
					If aRet[1][6] - nDif < 1 .and. nDif - aRet[1][6] > 0
						nCalDif := nDif - aRet[1][6]
						If nCalDif > 0
							aRet[1][1] := aRet[1][1] - nCalDif
						EndIf
					   		
						If nCalDif < 0
							aRet[1][1] := aRet[1][1] + nCalDif
						EndIf
					EndIf
				EndIf
 					//Arredondo Saldo 	
				If aRet[1][2] > 0
					nTotFamArred := nTotFam - aRet[1][6]
					If (nTotFamArred - nDifBK2 < 1 .or. nDifBK2 - nTotFamArred > 0) .and. (nDifBK2 - nTotFamArred > 0 .or. nTotFamArred - nDifBK2 > 0)
						If (nTotFamArred - nDifBK2) > 0
							aRet[1][2] := aRet[1][2] + (nTotFamArred - nDifBK2)
						EndIf
 						 	 						  
						If (nTotFamArred - nDifBK2) < 0
							aRet[1][2] := aRet[1][2] - (nTotFamArred - nDifBK2)
						EndIf
					EndIf
				EndIf
					
															
 					// Altero o valor de co-participacao 
				cChave := FwFldGet( 'B80_CODINT',nI)+FwFldGet( 'B80_CODEMP',nI)+FwFldGet( 'B80_MATRIC',nI)+FwFldGet( 'B80_TIPREG',nI)+MV_PAR06+cMesBDH
				DbSelectArea("BDH")
				BDH->(DbSetOrder(3))// BDH_FILIAL, BDH_CODINT, BDH_CODEMP, BDH_MATRIC, BDH_TIPREG, BDH_ANOFT, BDH_MESFT
				lBDH := .F.
				If BDH->(MsSeek(xFilial("BDH")+cChave + aCpoDetail[nI,12,2])) .And. !Empty(aRet)
					BDH->(RecLock("BDH",.F.))
					BDH->BDH_VLRPAR := aRet[1][1]
					BDH->BDH_MESPRO := MV_PAR05
					lBDH := .T.
					BDH->(MsUnLock())
				EndIf
					
				cChave := 	FwFldGet( 'B80_CODINT',nI)+FwFldGet( 'B80_CODEMP',nI)+FwFldGet( 'B80_MATRIC',nI)+FwFldGet( 'B80_TIPREG',nI)+MV_PAR06
				DbSelectArea("BDH")
				BDH->(DbSetOrder(3))// BDH_FILIAL, BDH_CODINT, BDH_CODEMP, BDH_MATRIC, BDH_TIPREG, BDH_ANOFT, BDH_MESFT
				BDH->(MsSeek(xFilial("BDH")+cChave ))
				While !BDH->(EoF()) .AND. BDH->BDH_CODINT == FwFldGet( 'B80_CODINT',nI) .AND. BDH->BDH_CODEMP == FwFldGet( 'B80_CODEMP',nI);
						.AND. BDH->BDH_MATRIC == FwFldGet( 'B80_MATRIC',nI) .AND. BDH->BDH_TIPREG == FwFldGet( 'B80_TIPREG',nI)
					If BDH->BDH_VLRPAR == 0 .AND. BDH->BDH_ANOFT <= MV_PAR06 .AND. BDH->BDH_MESFT <= cMesBDH
					   		 
						BDH->(RecLock("BDH",.F.))
						BDH->BDH_STATUS := "0"
						BDH->BDH_MESPRO := MV_PAR05
						BDH->(MsUnLock())
					EndIf
					BDH->(DbSkip())
				EndDo
													
			 	//Altero o Saldo
				cChave := FwFldGet( 'B80_CODINT',nI)+FwFldGet( 'B80_CODEMP',nI)+FwFldGet( 'B80_MATRIC',nI)+FwFldGet( 'B80_TIPREG',nI)+MV_PAR06+MV_PAR05
				DbSelectArea("BK2")
				BK2->(DbSetOrder(6)) //BK2_FILIAL, BK2_CODINT, BK2_CODEMP, BK2_MATRIC, BK2_TIPREG, BK2_ANO, BK2_MES
				If  !Empty(aRet)
					If BK2->(MsSeek(xFilial("BK2")+cChave))
						BK2->(RecLock("BK2",.F.))
						BK2->BK2_SALANT := BK2->BK2_SALDO
						BK2->BK2_SALDO  := Iif(lBDH, 0, aRet[1][1]) //valor do saldo a ser cobrado
						BK2->BK2_PARCEL := "S"
						BK2->BK2_DATREA := StoD(MV_PAR06+MV_PAR05+StrZero(BA3->BA3_VENCTO,2))
						BK2->(MsUnLocK())
					EndIf
				EndIf
				// Se tiver valor para o proximo mes eu adiciono mais saldo
				If  !Empty(aRet) .and. aRet[1][2] > 0
				   
					//cCodLan := RetTipCop( BK2->(BK2_PROPRI+BK2_CODLAN),cChave )
					//cProPri	:= SubStr(cCodLan,1,1)
					//cCodLan := SubStr(cCodLan,2,2)

					BK2->(RecLock("BK2",.T.))
					BK2->BK2_FILIAL := xFilial("BK2")
					BK2->BK2_CODINT := MV_PAR01
					BK2->BK2_CODEMP := BA1->BA1_CODEMP
					BK2->BK2_MATRIC := BA1->BA1_MATRIC
					BK2->BK2_TIPREG := BA1->BA1_TIPREG
					BK2->BK2_DIGITO := BA1->BA1_DIGITO
					BK2->BK2_ANO    := Iif(Soma1(MV_PAR05,2) == "13", Soma1(MV_PAR06,4), MV_PAR06 )
					BK2->BK2_MES    := Iif(Soma1(MV_PAR05,2) == "13", "01", Soma1(MV_PAR05,2) )
					BK2->BK2_SALDO  := aRet[1][2]
					BK2->BK2_SALDO2 := 0
					BK2->BK2_PROPRI := "1" //cProPri
					BK2->BK2_CODLAN := "51"//cCodLan
					BK2->BK2_DATREA := StoD(MV_PAR06+MV_PAR05+StrZero(BA3->BA3_VENCTO,2))
					BK2->BK2_PARCEL := "N"
					BK2->(MsUnlock())
					
				EndIf
				
				If  !Empty(aRet) .and. aRet[1][2] == 0
				   
					//cCodLan := RetTipCop( BK2->(BK2_PROPRI+BK2_CODLAN),cChave )
					//cProPri	:= SubStr(cCodLan,1,1)
					//cCodLan := SubStr(cCodLan,2,2)

					BK2->(RecLock("BK2",.T.))
					BK2->BK2_FILIAL := xFilial("BK2")
					BK2->BK2_CODINT := MV_PAR01
					BK2->BK2_CODEMP := BA1->BA1_CODEMP
					BK2->BK2_MATRIC := BA1->BA1_MATRIC
					BK2->BK2_TIPREG := BA1->BA1_TIPREG
					BK2->BK2_DIGITO := BA1->BA1_DIGITO
					BK2->BK2_ANO    := Iif(Soma1(MV_PAR05,2) == "13", Soma1(MV_PAR06,4), MV_PAR06 )
					BK2->BK2_MES    := Iif(Soma1(MV_PAR05,2) == "13", "01", Soma1(MV_PAR05,2) )
					BK2->BK2_SALDO  := 0
					BK2->BK2_SALDO2 := 0
					BK2->BK2_PROPRI := "1" //cProPri
					BK2->BK2_CODLAN := "51"//cCodLan
					BK2->BK2_DATREA := StoD(MV_PAR06+MV_PAR05+StrZero(BA3->BA3_VENCTO,2))
					BK2->BK2_PARCEL := "N"
					BK2->(MsUnlock())
					
				EndIf
				
				//Informo os valores do parcelamento
				If !empty(aRet) .AND. aRet[1][1] > 0
					FWFldPut('B80_VALCOP',aRet[1][1],nI,oModel,.F.,.T.)
					FWFldPut('B80_VALCOL',aRet[1][1],nI,oModel,.F.,.T.)
					FWFldPut('B80_VALSAL',aRet[1][2],nI,oModel,.F.,.T.)
				EndIf
				
				// Insiro o historico 
				If !empty(aRet) .And. (aRet[1][2] > 0 .Or. FwFldGet( 'B80_VALSAL',nI) > 0) .AND. aRet[1][1] > 0
					DbSelectArea("B78")
				
					//Seleciona o maior Lote
					cSQL := "SELECT MAX(B78_NUMLOT) B78_NUMLOT"
					cSQL += " FROM " + RetSqlName("B78")
					cSQL += " WHERE B78_FILIAL = '" + xFilial("B78") + "' "
					cSQL += " AND D_E_L_E_T_ = ' '"

					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"B78MAX",.F.,.T.)

					DbSelectArea("B78MAX")
			       
					nLote := B78MAX ->B78_NUMLOT
			
					if Empty(nLote)
						nLote = "0"
					endif
					 
					nLote := soma1(StrZero(Val(nLote), 8))
	       
					B78MAX->(DbCloseArea())

					B78->(DbSetOrder(1))
					If !B78->(MsSeek(xFilial("B78") + BA1->BA1_CODINT + BA1->BA1_CODEMP + BA1->BA1_MATRIC + BA1->BA1_TIPREG + MV_PAR05 + MV_PAR06 ) )

						B78->(RecLock("B78",.T.))
		    				// Gero o historico deste lancamento
						B78->B78_FILIAL	:= 	xFilial("B78")
						B78->B78_CODINT	:=	BA1->BA1_CODINT
						B78->B78_CODEMP	:=	BA1->BA1_CODEMP
						B78->B78_MATRIC	:=	BA1->BA1_MATRIC
						B78->B78_TIPREG	:=	BA1->BA1_TIPREG
						B78->B78_MESBAS	:=	MV_PAR05
						B78->B78_ANOBAS	:=	MV_PAR06
						B78->B78_TIPOPE	:= 	"1"
						B78->B78_VALCOP	:= 	FwFldGet( 'B80_VALCOP',nI)
						B78->B78_VALCOL	:= 	FwFldGet( 'B80_VALCOL',nI)
						B78->B78_VALSAL	:= 	FwFldGet( 'B80_VALSAL',nI)
						B78->B78_VALREA	:= 	aRet[1][4]
						B78->B78_QTDPAR	:= 	aRet[1][5]
						B78->B78_VALACU	:= 	aRet[1][2]
						B78->B78_VALPAR	:= 	aRet[1][1]
						B78->B78_NUMLOT	:= nLote
							
						B78->(MsUnlock())
					Else
						
						B78->(RecLock("B78",.F.))
							// Altero o historico deste lancamento
						B78->B78_VALCOP	+= 	FwFldGet( 'B80_VALCOP',nI)
						B78->B78_VALCOL	+= 	FwFldGet( 'B80_VALCOL',nI)
						B78->B78_VALSAL	+= 	FwFldGet( 'B80_VALSAL',nI)
						B78->B78_VALREA	+= 	aRet[1][4]
						B78->B78_QTDPAR	+= 	aRet[1][5]
						B78->B78_VALACU	+= 	aRet[1][2]
						B78->B78_VALPAR	+= 	aRet[1][1]
						
						B78->(MsUnlock())
					
					EndIf
					
				Endif
				
				If empty(aRet)
					oAux:GoLine( nI )
					oAux:DeleteLine()
				else
					nCount ++
				EndIf
			Else
				oAux:GoLine( nI )
				oAux:DeleteLine()
			EndIf
	
		Next
	
	EndIf
	
	If lRet
	
		// Faz-se a valida็ใo dos dados, note que diferentemente das tradicionais "rotinas automแticas"
		// neste momento os dados nใo sใo gravados, sใo somente validados.
		If ( lRet := oModel:VldData() )
	
			// Se o dados foram validados faz-se a grava็ใo efetiva dos dados (commit)
			oModel:CommitData()
	
		EndIf
	EndIf
	
	If !lRet
		
		DisarmTransaction()
	    
		If nCount > 0
			// Se os dados nใo foram validados obtemos a descri็ใo do erro para gerar LOG ou mensagem de aviso
			aErro   := oModel:GetErrorMessage()
		
			// A estrutura do vetor com erro ้:
			//  [1] Id do formulแrio de origem
			//  [2] Id do campo de origem
			//  [3] Id do formulแrio de erro
			//  [4] Id do campo de erro
			//  [5] Id do erro
			//  [6] mensagem do erro
			//  [7] mensagem da solu็ใo
			//  [8] Valor atribuido
			//  [9] Valor anterior
		
			AutoGrLog( OemtoAnsi(STR0026) + ' [' + AllToChar( aErro[1]  ) + ']' ) //"Id do formulแrio de origem:"
			AutoGrLog( OemtoAnsi(STR0027) + ' [' + AllToChar( aErro[2]  ) + ']' ) //"Id do campo de origem:     "
			AutoGrLog( OemtoAnsi(STR0028) + ' [' + AllToChar( aErro[3]  ) + ']' ) //"Id do formulแrio de erro:  "
			AutoGrLog( OemtoAnsi(STR0029) + ' [' + AllToChar( aErro[4]  ) + ']' ) //"Id do campo de erro:       "
			AutoGrLog( OemtoAnsi(STR0030) + ' [' + AllToChar( aErro[5]  ) + ']' ) //"Id do erro:                "
			AutoGrLog( OemtoAnsi(STR0031) + ' [' + AllToChar( aErro[6]  ) + ']' ) //"Mensagem do erro:          "
			AutoGrLog( OemtoAnsi(STR0032) + ' [' + AllToChar( aErro[7]  ) + ']' ) //"Mensagem da solu็ใo:       "
			AutoGrLog( OemtoAnsi(STR0033) + ' [' + AllToChar( aErro[8]  ) + ']' ) //"Valor atribuido:           "
			AutoGrLog( OemtoAnsi(STR0034) + ' [' + AllToChar( aErro[9]  ) + ']' ) //"Valor anterior:            "
		
			If nItErro > 0
				AutoGrLog( OemtoAnsi(STR0035) + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' ) //"Erro no Item:              "
			EndIf
		
			MostraErro()
		Else
			
			MsgAlert(OemtoAnsi(STR0036))//"De acordo com os parโmtros selecionados nใo hแ regra de parcelamento vแlida!"
		
		EndIf
	
	
	
	EndIf

End Transaction
cChave    := ""
// Desativamos o Model
oModel:DeActivate()

Return lRet
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSVLRCOP บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para valorizar o acumulado e co-participacao...	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSVLRCOP(	cAno,		cMes,		nUtiliza, 	nAcumu1,;
		nAcumu2,	nTotVal,	nTotSeg,	nTotVlm,;
		dDataAnt,	nValDif)

Local nSalario 	:=0
Local nVlrPag  	:= 0
Local nVlrAc1	:= 0
Local nVlrAc2	:= 0
Local nValPar	:= 0
Local nValRea	:= 0
LOCAL nMes		:= 0
Local nNumPar	:= 0
Local lPodePar	:= .F.
Local lAchou	:= .F.
Local aMatRet	:= {}
Local aAreaBA1	:= {}
Local cRegra 	:= ""
Local cMesLiq 	:= ""
Local cAnoLiq	:= ""
Local cTipReg	:= GetNewPar("MV_PLTRTIT","00")
Local nValPar2     := 0

Default nUtiliza 	:= 0 //B80_VALCOL
Default nAcumu1   	:= 0 //B80_VALSAL
Default nAcumu2		:= 0
Default nTotVal		:= 0 //B80_VALCOL+B80_VALSAL
// Caso nao tenha data do ultimo reajuste considero 30 dias atras
Default dDataAnt	:= CtoD("")
Default	nValDif		:= 0

Default nTotSeg		:= 0
Default nTotVlm		:= 0



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona as tabelas.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("BA3")
BA3->(DbSetOrder(1))
If BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
	DbSelectArea("BQC")
	BQC->(DbSetOrder(1))
	If BQC->(MsSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
		DbSelectArea("B81")
		B81->(DbSetOrder(1))
		If B81->(MsSeek(xFilial("B81")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
			While 	!B81->(EoF()) .And.;
					xFilial("B81")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) ==;
					B81->(B81_FILIAL+B81_CODINT+B81_CODEMP+B81_CONEMP+B81_VERCON+B81_SUBCON+B81_VERSUB)
  		        
				If dDataBase >= B81->B81_VIGPA .And. (dDataBase <= B81_VIGFIM .Or. Empty(B81_VIGFIM))
					lAchou := .T.
					Exit
				EndIf
				B81->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIF

// Pego o salario
nSalario := RetSalPar( cAno,	cMes )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPara realizar parcelamento a regra e a seguinte:                                                              ณ
//ณ- Primeiramente verifico se pode parcelar no nivel de operadora, familia ou usuario.                          ณ
//ณ- Verifico se preciso ver o valor limite.                                                                     ณ
//ณ- Caso tenha que ver, verifico qual o maior entre os dois e vejo se o valor a pagar e maior que o selecionado.ณ
//ณ- E considerado o valor de todos os usuarios da familia														 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	B81->B81_PACOOK == "0"	.And.;
		BA3->BA3_PACOOK == "0"	.And.;
		BA1->BA1_PACOOK == "0"
	
	If B81->B81_VERLIM == "1"
		lPodePar := .T.
	Else
		If B81->B81_VLRMIN > B81->B81_PERMIN/100*nSalario
			If nTotVlm > B81->B81_VLRMIN
				lPodePar := .T.
			EndIf
		ElseIf nTotVlm > B81->B81_PERMIN/100*nSalario //BK2_SALDO
			lPodePar := .T.
		ElseIf !BA1->BA1_TREGRA $ ' ,0'
			lPodePar := .T.
		EndIF
	EndIf
ElseIf Empty(BA3->BA3_CONEMP)			.And.;
		BA3->BA3_PACOOK == "0"	.And.;
		BA1->BA1_PACOOK == "0"
	lPodePar := .T.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual a regra do titular.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAreaBA1 := BA1->(GetArea())
cChave	:= BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
BA1->(DbSetOrder(2))
If BA1->(MsSeek(xFilial("BA1")+cChave+cTipReg))
	cRegra  := AllTrim(BA1->BA1_TREGRA)
	cMesLiq := BA1->BA1_MESLIQ
	cAnoLiq := BA1->BA1_ANOLIQ
	nValPar := BA1->BA1_VLRFIX
EndIf
	
  //lPodePar := .T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso a regra do titular nao seja 'Subcontrato', os dependentes devem acatar a regra dele.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cRegra $ "1,2" //cRegra != "0"
	If 	cRegra == "1"
		nMes 	:= PLSDIFANOS(cAno, cMes, cAnoLiq, cMesLiq, "M")//+1
		nValPar := nTotVal/nMes
		lPodePar := .T.
	ElseIf	cRegra == "2"
		nValPar := nValPar*(nTotVal/nTotVlm)
		lPodePar := .T.
	EndIf
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica o valor da parcela, e verificado antes de saber se pode parcelar, para realizar o reajusteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Segue regra do SubContrato.	
	Do Case
		
	Case BA1->BA1_TREGRA $ " ,0" // SubContrato
			// Valor maior e o valor da parcela
		If nTotVal >= B81->B81_VLRPAR .or. (nSalario*(B81->B81_PERPAR/100)) > 0
			lPodePar := .T.
			If 		B81->B81_VLRPAR >= nSalario*(B81->B81_PERPAR/100) .And.;
					B81->B81_VLRPAR >= nTotVal/B81->B81_QTSMES
				
				nValPar := B81->B81_VLRPAR
			
			// Valor maior e o percenual sobre o salario
			ElseIf	nSalario*(B81->B81_PERPAR/100) >= B81->B81_VLRPAR .And.;
					nSalario*(B81->B81_PERPAR/100) >= nTotVal/B81->B81_QTSMES
				
				nValPar := nSalario*(B81->B81_PERPAR/100)
			
			// Valor maior e o valor dividido pela quantidade de meses
			ElseIf	nTotVal/B81->B81_QTSMES >= B81->B81_VLRPAR .And.;
					nTotVal/B81->B81_QTSMES >= nSalario*(B81->B81_PERPAR/100)
				
				nValPar := nTotVal/B81->B81_QTSMES
			
			EndIf
		EndIf
			//Este trecho foi comentado, pois estava afetando o calculo da parcela e o Saldo.
	        
	Case BA1->BA1_TREGRA == "1" // Prazo
		nMes := PLSDIFANOS(cAno, cMes, BA1->BA1_ANOLIQ, BA1->BA1_MESLIQ, "M")//+1
		nValPar := nTotVal/nMes
		
	Case BA1->BA1_TREGRA == "2" // Valor Fixo
		nValPar :=	BA1->BA1_VLRFIX
	
	EndCase
EndIf
  
If ExistBlock("PLS118VL")
	ExecBlock("PLS118VL",.F.,.F.)
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAplica o reajuste sobre o acumulado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nVlrAc1 := nAcumu1
// Caso nao tenha data do ultimo reajuste considero 30 dias atras
dDataAnt := Iif( EmPty(dDataAnt), DaySub(dDataBase,30), dDataAnt )

CalJurSa(	@nNumPar,			@nVlrAc1,  		nAcumu1,			@nValRea,;
	nTotVal,			nSalario,  		B81->B81_PERPAR,	B81->B81_VLRPAR,;
	B81->B81_QTSMES,	dDataAnt,		BA1->BA1_TREGRA,	nValPar,;
	BA1->BA1_VLRFIX,	BA1->BA1_ANOLIQ,BA1->BA1_MESLIQ)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico se pode parcelarณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  

If lPodePar .AND. nValPar > 0
	// Verifia se o valor da co participacao e maior que o valor da parcela	
	If nTotVlm > nValPar
		// Lanco o valor a ser cobrado neste mes  
		nVlrPag := nValPar
		// Guardo o acumulado para o proximo mes, ja reajustado			
		nVlrAc1 := nTotVal - nVlrPag
	Else
		nVlrPag := nVlrAc1+nValDif
		nVlrAc1 := nTotVal - nVlrPag
			//Caso o valor total da familia seja menor que a parcela, significa que estou cobrando tudo
			//e o BK2 serแ zerado
		If nTotVlm <= nValPar
			nVlrAc1 := 0
		EndIf
	EndIf
Else
	// Caso nao possa parcelar eu cobro a parcela referente ao saldo e a PF completa  
	nVlrPag := nUtiliza+nValDif+Iif(nVlrAc1 > nValPar, nValPar, nVlrAc1)
	nVlrAc1 := nTotVal - nVlrPag
EndIf

// Aliemnta a matriz de retorno           
aadd(aMatRet,{nVlrPag,nVlrAc1,nVlrAc2,nValRea,nNumPar,nVlrPag})
//[1] valor que estou pagando no mes
//[2] valor que estou acumlando no mes
//[3] valor que estou acumlando no mes 
//[4] valor de reajuste
//[5] numero de parcelas restante

If Len(aAreaBA1) > 0
	RestArea(aAreaBA1)
	EndIf

Return(aMatRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalJurSa  บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o calculo de juros sobre o valor do saldo				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CalJurSa(	nNumPar,	nVlrAc1,	nAcumu1,	nValRea,;
		nVlBase,	nValSal,	nPerSal,	nVlrMin,;
		nQtdMes,	dDataAnt,	cRegra,		nValPar,;
		nValFix,	cAnoLin, 	cMesLiq,	dDataVencto)    	  
Local 	nVlBaseAux			:= 0
Local	nValReaAux			:= 0
Local	lAcabou			:= .T.

Default	nNumPar		:= 0
Default	nVlrAc1		:= 0
Default	nValRea		:= 0
Default	nVlBase		:= 0
Default	nValSal		:= 0
Default	nPerSal		:= 0
Default	nVlrMin		:= 0
Default	nQtdMes		:= 0
Default dDataAnt			:= CtoD("")
Default cRegra			:= ""
Default nValPar			:= 0
Default nValFix			:= 0
Default cAnoLin			:= ""
Default cMesLiq			:= ""
Default dDataVencto		:= CtoD(" / / ")

nVlBaseAux	:= nVlBase-nValPar
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAcho a quantidade de parcelas...ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While lAcabou

	If nVlBaseAux > 0
		If cRegra != "1"
			nValPar	:= CalParCo(nValSal,	nPerSal,	nVlrMin,	nQtdMes,;
				nVlBaseAux,	cRegra,		nValFix,	cAnoLin,;
				cMesLiq,	nVlBase)
			If nVlBaseAux >= nValPar .And. nValPar > 0
				nNumPar++
				nVlBaseAux := nVlBaseAux - nValPar
			Else
				If	nVlBaseAux > 0
					nNumPar++
					lAcabou := .F.
				Else
					lAcabou := .F.
				EndIf
			EndIf
		Else
			nMes 	:= PLSDIFANOS(MV_PAR06, MV_PAR05, cAnoLin, cMesLiq, "M")//+1
			nNumPar	:= nMes-1
			lAcabou := .F.
		EndIf
	Else
		lAcabou := .F.
	EndIf

EndDo
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAplica o reajuste sobre o acumulado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	 

B77->( DbSetOrder(1) ) // B77_CODINT, B77_CODEMP, B77_CONEMP, B77_VERCON, B77_SUBCON, B77_VERSUB
If B77->( DbSeek( xFilial("B77")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERSUB ) )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPasso em todos os dias desde o ultimo reajuste ate a data atual,ณ
	//ณpara aplicar o percenttual do dia...                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	cMes	:= StrZero(Month(dDataAnt),2)
	cAno    := StrZero(Year(dDataAnt),4)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณA data ้ a data de vencimento da familia de acordo com o parcelamento
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	If 	Empty(dDataVencto)
		dDataVencto := StoD(MV_PAR06+MV_PAR05+StrZero(BA3->BA3_VENCTO,2))
	EndIf
	
	If 	Day(dDataVencto) != Day(dDataAnt)

		While dDataVencto >= dDataAnt
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifico se ha percentual do dia para esta data...ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If B77->( DbSeek( xFilial("B77") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)+cAno+cMes ) )
				While !B77->(EoF()) .And. 	xFilial("B77")+B77->(B77_CODINT+B77_CODEMP+B77_CONEMP+B77_VERCON+B77_SUBCON+B77_VERSUB+B77_ANOBAS+B77_MESBAS) == xFilial("BA1")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)+cAno+cMes
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					//ณVerifica se esta dentro do periodo na tabela de reajuste
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					If 	nNumPar >= B77->B77_PARDE .And. nNumPar <= B77->B77_PARATE
						
						nValReaAux	:= nAcumu1*B77->B77_PERDIA/100
						nValRea		+= nValReaAux
						nVlrAc1		+= nValReaAux
						Exit
				   		 
					EndIf
					
					B77->(DbSkip())
				EndDo
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				//ณPulo o dia
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				dDataAnt := DaySum( dDataAnt , 1 )
				cMes	 := StrZero(Month(dDataAnt),2)
				cAno     := StrZero(Year(dDataAnt),4)
			Else
				Exit
			EndIf
		EndDo
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณVerifico se ha percentual do dia para esta data...
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		If B77->( DbSeek( xFilial("B77")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB )+cAno+cMes ) )
			While !B77->(EoF()) .And. 	xFilial("B77")+B77->(B77_CODINT+B77_CODEMP+B77_CONEMP+B77_VERCON+B77_SUBCON+B77_VERSUB+B77_ANOBAS+B77_MESBAS) == xFilial("BA1")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)+cAno+cMes
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				//ณVerifica se esta dentro do periodo na tabela de reajuste
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				If 	nNumPar >= B77->B77_PARDE .And. nNumPar <= B77->B77_PARATE
					Exit
				EndIf
				
				B77->(DbSkip())
			EndDo
	
			While dDataVencto >= dDataAnt
			    
				nValReaAux	:= nAcumu1*B77->B77_PERDIA/100
				nValRea		+= nValReaAux
				nVlrAc1		+= nValReaAux
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				//ณPulo o dia
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				dDataAnt := DaySum( dDataAnt , 1 )
				cMes	 := StrZero(Month(dDataAnt),2)
				cAno     := StrZero(Year(dDataAnt),4)
				
			EndDo
		EndIf
	EndIf
	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalParCo  บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o numero de parcelas para o reajuste.				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CalParCo(	nValSal,	nPerSal,	nVlrMin,	nQtdMes,;
		nVlBase,	cRegra,		nValFix,	cAnoLin,;
		cMesLiq,	nVlBaseAux)
Local nValRet	:= 0

Default nValSal	:= 0
Default nPerSal	:= 0
Default nVlrMin	:= 0
Default nQtdMes	:= 0
Default nVlBase	:= 0

Do Case
Case cRegra == "0"
		// Valor maior e o valor fixo
	If 		nVlrMin >= 	nValSal*(nPerSal/100) .And.;
			nVlrMin >= 	nVlBase/nQtdMes
						
		nValRet := nVlrMin
		// Valor maior e o percenual sobre o salario
	ElseIf	nValSal*(nPerSal/100) >= nVlrMin .And.;
			nValSal*(nPerSal/100) >= nVlBase/nQtdMes
			
		nValRet := nValSal*(nPerSal/100)
		// Valor maior e o valor dividido pela quantidade de meses
	ElseIf	nVlBase/nQtdMes >= nVlrMin .And.;
			nVlBase/nQtdMes >= nValSal*(nPerSal/100)
			
		nValRet := nVlBase/nQtdMes
	EndIf
Case cRegra == "2" // Valor Fixo
	nValRet :=	nValFix
	EndCase

Return( Round(nValRet,2) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA118M  บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada para validar a exclusao					  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PLSA118M()
Local aParam     	:= PARAMIXB
Local xRet       	:= .T.
Local oObj       	:= aParam[1]
Local cIdPonto   	:= aParam[2]
Local nI	     	:= 0
Local nOperation	:= 0
Local cClasse    	:= oObj:ClassName()
Local oModel		:= Nil
Local cChvAnt		:= ""
Local cChave		:= ""
Local lBK2			:= .F. //S๓ posso realizar altera็ใo na BDH caso nใo tenha mais registros na BK2
Local cSql2 		:= ""
Local cChaveB80	:= ""

// Valida a exclusao
If cIdPonto ==  'MODELPOS'
	oModel     	:= oObj:GetModel("B80DETAIL")
	nOperation 	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_DELETE
		// Verifico se jแ foi faturado
		cSql := " SELECT	B80.B80_CODIGO"
		cSql += " FROM "+RetSqlName("B80")+" B80"
		cSql += " LEFT JOIN "+RetSqlName("BDH")+" BDH"
		cSql += " 	ON	BDH.BDH_FILIAL	= 	B80.B80_FILIAL"
		cSql += " 	AND BDH.BDH_CODINT	= 	B80.B80_CODINT"
		cSql += " 	AND BDH.BDH_CODEMP	= 	B80.B80_CODEMP"
		cSql += " 	AND BDH.BDH_MATRIC	= 	B80.B80_MATRIC"
		cSql += " 	AND	BDH.BDH_TIPREG	= 	B80.B80_TIPREG"
		cSql += " 	AND BDH.BDH_MESFT	   = 	B80.B80_MESBAS"
		cSql += " 	AND BDH.BDH_ANOFT	   =   B80.B80_ANOBAS"
		cSql += " 	AND BDH.D_E_L_E_T_	= 	' '"
		cSql += " 	AND B80.D_E_L_E_T_	= 	' '"
		cSql += " LEFT JOIN "+RetSqlName("BK2")+" BK2"
		cSql += " 	ON	BK2.BK2_FILIAL	= 	B80.B80_FILIAL"
		cSql += " 	AND BK2.BK2_CODINT	= 	B80.B80_CODINT"
		cSql += " 	AND BK2.BK2_CODEMP	= 	B80.B80_CODEMP"
		cSql += " 	AND BK2.BK2_MATRIC	= 	B80.B80_MATRIC"
		cSql += " 	AND	BK2.BK2_TIPREG	= 	B80.B80_TIPREG"
		cSql += " 	AND BK2.BK2_MES		= 	B80.B80_MESBAS"
		cSql += " 	AND BK2.BK2_ANO		= 	B80.B80_ANOBAS"
		cSql += " 	AND BK2.D_E_L_E_T_	= 	' '"
		cSql += " WHERE"
		cSql += " 		B80.B80_FILIAL	= 	'"+xFilial("B80")+"'"
		cSql += " 	AND (BK2.BK2_PLNUCO <> '' OR BDH.BDH_STATUS <> '1' ) "
		cSql += "	AND (BDH.BDH_VLRPAR > 0)"
		cSql += " 	AND B80.B80_CODIGO = '"+B79->B79_CODIGO+"'"
		
		cSQL := ChangeQuery(cSQL)
		
		If Select("TRB80") > 0
			TRB80->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB80",.F.,.T.)
		
		If TRB80->(!EOF())
			xRet := .F.
			Help(,,"HELP",,"Existe Faturamento Gerado!",1,0)
		EndIf
		
		// Valido se hแ abatimento ou transfer๊ncia de saldo
		cSql := " SELECT	B80.B80_CODIGO"
		cSql += " FROM "+RetSqlName("B80")+" B80"
		cSql += " LEFT JOIN "+RetSqlName("B78")+" B78"
		cSql += " 	ON	B78.B78_FILIAL	= 	B80.B80_FILIAL"
		cSql += " 	AND B78.B78_CODINT	= 	B80.B80_CODINT"
		cSql += " 	AND B78.B78_CODEMP	= 	B80.B80_CODEMP"
		cSql += " 	AND B78.B78_MATRIC	= 	B80.B80_MATRIC"
		cSql += " 	AND	B78.B78_TIPREG	= 	B80.B80_TIPREG"
		cSql += " 	AND B78.B78_MESBAS	= 	B80.B80_MESBAS"
		cSql += " 	AND B78.B78_ANOBAS	= 	B80.B80_ANOBAS"
		cSql += " 	AND B78.D_E_L_E_T_	= 	' '"
		cSql += " 	AND B80.D_E_L_E_T_	= 	' '"
		cSql += " WHERE"
		cSql += " 		B80.B80_FILIAL	= 	'"+xFilial("B80")+"'"
		cSql += " 	AND B78.B78_TIPOPE <> '1' "
		cSql += " 	AND B80.B80_CODIGO = '"+B79->B79_CODIGO+"'"
		
		cSQL := ChangeQuery(cSQL)
		
		If Select("TRB80") > 0
			TRB80->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB80",.F.,.T.)
		
		If TRB80->(!EOF())
			xRet := .F.
			Help(,,"HELP",,OemtoAnsi(STR0037),1,0)//"Existe Abatimento/Transfer๊ncia de saldo!"
		EndIf
		
			                           
	EndIf
	
	    //Nใo permito excluir um m๊s, se existirem parcelamentos posteriores, a fim de manter a integridade dos dados.
		//Este select nใo funciona caso a matricula nใo seja informada nos parametros iniciais para o parcelamento		
	cSql := 'SELECT B80_CODIGO,B80_CODINT,B80_CODEMP,B80_MATRIC,B80_TIPREG,B80_ANOBAS,B80_MESBAS '
	cSql += " FROM "+RetSqlName("B80")+" B80"
	cSql += " WHERE"
	cSql += " B80.B80_FILIAL	= 	'"+xFilial("B78")+"'"
	cSql += " AND B80_ANOBAS = '"+B79->B79_ANOBAS+"'"
	cSql += " AND B80_MESBAS > '"+B79->B79_MESBASE+"'"
	cSql += " AND B80_CODEMP = '" +B78->B78_CODEMP+"'"
	cSql += " AND B80_MATRIC = '" +B78->B78_MATRIC+"'"
	cSql += " AND B80.D_E_L_E_T_	= 	' '"
	cSql := ChangeQuery(cSql)
	  
	If Select("TRB80Del") > 0
		TRB80Del->(dbCloseArea())
	EndIf
	  
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB80Del",.F.,.T.)
	If TRB80Del->(!EOF())
		xRet := .F.
		 //Help(,,"HELP",,OemtoAnsi(STR0037),1,0)		 
		Help( ,, 'HELP',," Nใo ้ possivel apagar o registro. Delete os parcelamentos posteriores para prosseguir ",1,0)
	EndIf
				
						
		 //Help(,,"HELP",,OemtoAnsi(STR0037),1,0)		 
			
		//EndIf
	
ElseIf cIdPonto ==  'FORMCOMMITTTSPRE'  .And. cClasse == 'FWFORMGRID'
	
	nI			:= oObj:nLine
	oModel     	:= oObj:GetModel("B80DETAIL")
	nOperation 	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_DELETE
	    // Apago o parcelamento do saldo
			DbSelectArea("BK2")
			BK2->(DbSetOrder(6))
			cChvAnt := FwFldGet( 'B80_CODINT',nI,oModel)+FwFldGet( 'B80_CODEMP',nI,oModel)+FwFldGet( 'B80_MATRIC',nI,oModel)+FwFldGet( 'B80_TIPREG',nI,oModel)+FwFldGet( 'B79_ANOBAS',nI,oModel)+FwFldGet( 'B79_MESBAS',nI,oModel)
			If 	BK2->(MsSeek(xFilial("BK2")+cChvAnt))
				BK2->(RecLock("BK2",.F.))
				BK2->BK2_PARCEL := "N"
				BK2->BK2_SALDO 	:= FwFldGet( 'B80_VALSAL',nI,oModel)+FwFldGet( 'B80_VALCOP',nI,oModel)
				BK2->BK2_DATREA	:= FwFldGet( 'B80_DATREA',nI,oModel)
				//Limpo os campos de cobran็a caso estejam preenchidos
				BK2->BK2_NUMTIT	:= "  "  
				BK2->BK2_TIPTIT	:= "  "
				BK2->BK2_PREFIX	:= "  "
				BK2->BK2_PLNUCO	:= "  "   				
				BK2->(MsUnLocK())
			EndIf
		// Deleto o saldo do mes seguinte
		cChave := FwFldGet( 'B80_CODINT',nI,oModel)+FwFldGet( 'B80_CODEMP',nI,oModel)+FwFldGet( 'B80_MATRIC',nI,oModel)+FwFldGet( 'B80_TIPREG',nI,oModel)
		cChave += Iif(Soma1(FwFldGet( 'B79_MESBAS',nI,oModel),2) == "13", Soma1(FwFldGet( 'B79_ANOBAS',nI,oModel),4)	, FwFldGet( 'B79_ANOBAS',nI,oModel) )
		cChave += Iif(Soma1(FwFldGet( 'B79_MESBAS',nI,oModel),2) == "13", "01"											, Soma1(FwFldGet( 'B79_MESBAS',nI,oModel),2) )
		BK2->(DbSetOrder(6))

		If BK2->(MsSeek(xFilial("BK2")+cChave))
			BK2->(RecLock("BK2",.F.))
			BK2->(DbDelete())
			BK2->(MsUnLocK())
		EndIf
		
		DbSelectArea("BDH")
		BDH->(DbSetOrder(13))// BDH_FILIAL, BDH_CODINT, BDH_CODEMP, BDH_MATRIC, BDH_TIPREG, BDH_ANOFT, BDH_MESFT
		cChave := FwFldGet( 'B80_CODINT',nI,oModel)+FwFldGet( 'B80_CODEMP',nI,oModel)+FwFldGet( 'B80_MATRIC',nI,oModel)+FwFldGet( 'B80_TIPREG',nI,oModel)+FwFldGet( 'B79_ANOBAS',nI,oModel) + (FwFldGet( 'B79_MESBAS',nI,oModel))
		    //Se nใo encontrou BK2, s๓ entใo aํ que eu posso voltar as altera็๕es da BDH
		If !BK2->(MsSeek(xFilial("BK2")+cChave))
			lBK2 := .T.
		EndIf
		If BDH->(MsSeek(xFilial("BDH")+cChave))
			While !BDH->(EoF()) .AND. lBK2
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				//ณVerifica se esta dentro do periodo na tabela de reajuste
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				BDH->(RecLock("BDH",.F.))
				BDH->BDH_VLRPAR := 0
				BDH->BDH_MESPRO := "  "
				BDH->BDH_STATUS := "1"
				BDH->(MsUnLock())
				BDH->(DbSkip())
			EndDo
		EndIf
		
		// Deleto o historico
		DbSelectArea("B78")
		B78->(DbSetOrder(1))
		cChave := FwFldGet( 'B80_CODINT',nI,oModel)+FwFldGet( 'B80_CODEMP',nI,oModel)+FwFldGet( 'B80_MATRIC',nI,oModel)+FwFldGet( 'B80_TIPREG',nI,oModel)+FwFldGet( 'B79_ANOBAS',nI,oModel)+FwFldGet( 'B79_MESBAS',nI,oModel)
		If B78->(MsSeek(xFilial("B78")+cChave))
			B78->(RecLock("B78",.F.))
			B78->(DbDelete())
			B78->(MsUnLock())
		EndIf
	EndIf
	EndIf

Return(xRet)
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetIpCop  บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o salario para parcelamento por cliente. 			  บฑฑ
ฑฑบ	         ณBA3 DEVE ESTAR POSICIONADO								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetSalPar( cAno, cMes )
Local aAreaBA3 := BA3->(GetArea())
Local nSalario := 0
Local lFouSRA  := .F.
Local lCalcula := .F.

// Pesquiso o salario por cliente  
cChaveBA3Aux := BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)
cChaveBA3 := xFilial("BA3")+BA3->(BA3_CODCLI+BA3_LOJA)
// Reordeno para cliente 
BA3->(DbCloseArea())
DbSelectArea("BA3")
BA3->(DbSetOrder(3))//BA3_FILIAL, BA3_CODCLI, BA3_LOJA, BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, R_E_C_N_O_, D_E_L_E_T_
BA3->(MsSeek(cChaveBA3))
While 	!BA3->(EoF()) .And.;
		cChaveBA3 == xFilial("BA3")+BA3->(BA3_CODCLI+BA3_LOJA) .And.;
		nSalario == 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Posiciona no funcionario e busca o salario no mes                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	DbSelectArea("B76")
	DbSetOrder(1)// B76_FILIAL+B76_CODCLI+B76_LOJA+B76_ANOBAS+B76_MESBAS
	If B76->(MsSeek(xFilial("B76")+BA3->(BA3_CODCLI+BA3_LOJA)+cAno+cMes))
		nSalario :=  B76->B76_VALSAL
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso nao encontre, buso o ultimo salario.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	If nSalario == 0
		DbSelectArea("B76")
		DbSetOrder(1)// B76_FILIAL+B76_CODCLI+B76_LOJA+B76_ANOBAS+B76_MESBAS
		If B76->(MsSeek(xFilial("B76")+BA3->(BA3_CODCLI+BA3_LOJA)))
			While B76->(!EoF()) .And. 	xFilial("B76")+BA3->(BA3_CODCLI+BA3_LOJA) == ;
					B76->(B76_FILIAL+B76_CODCLI+B76_LOJA)
				
				nSalario :=  B76->B76_VALSAL
				B76->(DbSkip())
			EndDo
		EndIf
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso ainda nao tenha encontrado, busco na familia.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nSalario == 0
		If Empty(BA3->(BA3_AGFTFU+BA3_AGMTFU))
			lFouSRA  := .F.
			lCalcula := .F.
		Endif
		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(BA3->BA3_AGFTFU+BA3->BA3_AGMTFU))
			lFouSRA := .T.
		Endif
		If (BA3->(FieldPos("BA3_VALSAL")) > 0 .And. BA3->BA3_VALSAL > 0) .Or. ExistBlock("PLS118SL")
			If ExistBlock("PLS118SL")
				nSalario := ExecBlock("PLS118SL",.F.,.F.,{BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
			Else
				nSalario := BA3->BA3_VALSAL
			EndIf
		Else
			If lFouSRA
				nSalario := &(GetNewPar("MV_PLCOMSA",'0'))
			Endif
		Endif
	EndIf
	
	BA3->(DbSkip())
EndDo

BA3->(DbCloseArea())
DbSelectArea("BA3")
BA3->(DbSetOrder(1))
	BA3->(MsSeek(cChaveBA3Aux))

Return(nSalario)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetIpCop  บAutor  ณDiogo Ximenes       บ Data ณ 01/01/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o codigo de participacao.							  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetTipCop(cCodigo,cChave)
Default cCodigo := cCodigo
	 
//Posiciono a tabela BDH
DbSelectArea("BDH")
BDH->(DbSetOrder(3))
BDH->(MsSeek(xFilial("BDH")+cChave))
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fator moderador / co-participacao...                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If BDH->BDH_VALOR > 0

	cCodigo := "116"

EndIf

If BDH->(FieldPos("BDH_VALOR1")) > 0 .AND. BDH->BDH_VALOR1 > 0

	cCodigo := "147"

EndIf

If BDH->(FieldPos("BDH_VALOR2")) > 0 .AND. BDH->BDH_VALOR2 > 0

	cCodigo := "148"

EndIf

If BDH->(FieldPos("BDH_VALOR3")) > 0 .AND. BDH->BDH_VALOR3 > 0

	cCodigo := "149"
	
EndIf

If BDH->(FieldPos("BDH_VALOR4")) > 0 .AND. BDH->BDH_VALOR4 > 0

	cCodigo := "150"

EndIf

If BDH->(FieldPos("BDH_VALOR5")) > 0 .AND. BDH->BDH_VALOR5 > 0

	cCodigo := "151"

EndIf

If BDH->(FieldPos("BDH_VALOR6")) > 0 .AND. BDH->BDH_VALOR6 > 0

	cCodigo := "152"

EndIf

If BDH->(FieldPos("BDH_VALOR7")) > 0 .AND. BDH->BDH_VALOR7 > 0

	cCodigo := "153"
    
EndIf

If BDH->(FieldPos("BDH_VALOR8")) > 0 .AND. BDH->BDH_VALOR8 > 0

	cCodigo := "154"

EndIf

If BDH->(FieldPos("BDH_VALOR9")) > 0 .AND. BDH->BDH_VALOR9 > 0

	cCodigo := "155"

EndIf

If BDH->(FieldPos("BDH_VLRT21")) > 0 .AND. BDH->BDH_VLRT21 > 0

	cCodigo := "168"

EndIf

If BDH->(FieldPos("BDH_VLRT24")) > 0 .AND. BDH->BDH_VLRT24 > 0

	cCodigo := "169"
	
EndIf

If BDH->(FieldPos("BDH_VLRT25")) > 0 .AND. BDH->BDH_VLRT25 > 0

	cCodigo := "170"

EndIf

If BDH->(FieldPos("BDH_VLRT26")) > 0 .AND. BDH->BDH_VLRT26 > 0

	cCodigo := "171"
	
EndIf

If BDH->(FieldPos("BDH_VLRT27")) > 0 .AND. BDH->BDH_VLRT27 > 0

	cCodigo := "172"

EndIf

If BDH->(FieldPos("BDH_VLRT28")) > 0 .AND. BDH->BDH_VLRT28 > 0

	cCodigo := "173"

EndIf

If BDH->(FieldPos("BDH_VLRT29")) > 0 .AND. BDH->BDH_VLRT29 > 0
	
	cCodigo := "174"
	
EndIf

If BDH->(FieldPos("BDH_VLRT2A")) > 0 .AND. BDH->BDH_VLRT2A > 0

	cCodigo := "175"

EndIf

If BDH->(FieldPos("BDH_VLRT2B")) > 0 .AND. BDH->BDH_VLRT2B > 0

	cCodigo := "176"

EndIf

If BDH->(FieldPos("BDH_VLRT2C")) > 0 .AND. BDH->BDH_VLRT2C > 0

	cCodigo := "177"

EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Custo Operacional...                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If BDH->BDH_VLRCOP > 0

	cCodigo := "104"

EndIf

If BDH->BDH_VLRTAX > 0

	cCodigo := "117"

EndIf

If BDH->BDH_VALCPF > 0

	cCodigo := "124"

EndIf

If BDH->BDH_VALCOF > 0

	cCodigo := "123"

EndIf

If BDH->BDH_VALTCF > 0

	cCodigo := "125"

EndIf

If BDH->(FieldPos("BDH_VLRCP2")) > 0 .And. BDH->BDH_VLRCP2 > 0

	cCodigo := "127"

EndIf

If BDH->(FieldPos("BDH_VLRCP3")) > 0 .And. BDH->BDH_VLRCP3 > 0

	cCodigo := "134"

EndIf

If BDH->(FieldPos("BDH_VLRCP4")) > 0 .And. BDH->BDH_VLRCP4 > 0

	cCodigo := "137"

EndIf

If BDH->(FieldPos("BDH_VLRCP5")) > 0 .And. BDH->BDH_VLRCP5 > 0

	cCodigo := "138"

EndIf

If BDH->(FieldPos("BDH_VLRCP6")) > 0 .And. BDH->BDH_VLRCP6 > 0

	cCodigo := "139"

EndIf

If BDH->(FieldPos("BDH_VLRCP7")) > 0 .And. BDH->BDH_VLRCP7 > 0

	cCodigo := "140"

EndIf

If BDH->(FieldPos("BDH_VLRCP8")) > 0 .And. BDH->BDH_VLRCP8 > 0

	cCodigo := "141"

EndIf

If BDH->(FieldPos("BDH_VLRCP9")) > 0 .And. BDH->BDH_VLRCP9 > 0

	cCodigo := "142"

EndIf

If BDH->(FieldPos("BDH_VLRCPA")) > 0 .And. BDH->BDH_VLRCPA > 0

	cCodigo := "143"

EndIf

If BDH->(FieldPos("BDH_VLRCPB")) > 0 .And. BDH->BDH_VLRCPB > 0

	cCodigo := "144"

EndIf

If BDH->(FieldPos("BDH_VLRCPC")) > 0 .And. BDH->BDH_VLRCPC > 0

	cCodigo := "145"

EndIf

If BDH->(FieldPos("BDH_VLRT11")) > 0 .And. BDH->BDH_VLRT11 > 0

	cCodigo := "156"
	
EndIf

If BDH->(FieldPos("BDH_VLRT12")) > 0 .And. BDH->BDH_VLRT12 > 0

	cCodigo := "157"

EndIf

If BDH->(FieldPos("BDH_VLRT13")) > 0 .And. BDH->BDH_VLRT13 > 0

	cCodigo := "158"

EndIf

If BDH->(FieldPos("BDH_VLRT14")) > 0 .And. BDH->BDH_VLRT14 > 0

	cCodigo := "159"

EndIf

If BDH->(FieldPos("BDH_VLRT15")) > 0 .And. BDH->BDH_VLRT15 > 0

	cCodigo := "160"

EndIf

If BDH->(FieldPos("BDH_VLRT16")) > 0 .And. BDH->BDH_VLRT16 > 0

	cCodigo := "161"

EndIf

If BDH->(FieldPos("BDH_VLRT17")) > 0 .And. BDH->BDH_VLRT17 > 0

	cCodigo := "162"

EndIf

If BDH->(FieldPos("BDH_VLRT18")) > 0 .And. BDH->BDH_VLRT18 > 0

	cCodigo := "163"

EndIf

If BDH->(FieldPos("BDH_VLRT19")) > 0 .And. BDH->BDH_VLRT19 > 0

	cCodigo := "164"

EndIf

If BDH->(FieldPos("BDH_VLRT1A")) > 0 .And. BDH->BDH_VLRT1A > 0

	cCodigo := "165"

EndIf

If BDH->(FieldPos("BDH_VLRT1B")) > 0 .And. BDH->BDH_VLRT1B > 0

	cCodigo := "166"

EndIf

If BDH->(FieldPos("BDH_VLRT1C")) > 0 .And. BDH->BDH_VLRT1C > 0

	cCodigo := "167"

EndIf

If BDH->(FieldPos("BDH_VLRTIM")) > 0 .And. BDH->BDH_VLRTIM > 0 .And. cPaisLoc == "URU"

	cCodigo := "182"

EndIf

If BDH->(FieldPos("BDH_VLRPES")) > 0 .And. BDH->BDH_VLRPES > 0 .And. cPaisLoc == "URU"

	cCodigo := "183"

EndIf

Return(cCodigo)