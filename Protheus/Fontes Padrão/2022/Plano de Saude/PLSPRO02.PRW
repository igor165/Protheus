#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "PLSPRO02.ch"
/*/PLSPRO02
Cadastro dos Sinalizadores da Promoção(Promoção à Saúde)

@author Saúde
@since 09/2012
@version P11.5
/*/

//Variavel que vai determinar o carregamento dos campos html
Static cSTACPOHTM := ""

Function PLSPRO02()
Local oBrowse

Private cTipArq 	:= "*.HTML|*.htm|*.html|*.HTM"
Private cRetDArq	:= ""

MPSx2LKOn("SX2PR2","Consulta de Tabela",{"X2_CHAVE","X2_NOME"})

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BOJ' )
oBrowse:SetDescription( STR0001 )//'Sinalizadores/Alertas' 
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { STR0010  , 				'PesqBrw'         , 0, 1, 0, .T. } )//'Pesquisar'
aAdd( aRotina, { STR0004  , 			   	'VIEWDEF.PLSPRO02', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0005  , 				'VIEWDEF.PLSPRO02', 0, 3, 0, NIL } )//'Incluir'
aAdd( aRotina, { STR0006  , 				'VIEWDEF.PLSPRO02', 0, 4, 0, NIL } )//'Alterar'
aAdd( aRotina, { STR0007  , 				'VIEWDEF.PLSPRO02', 0, 5, 0, NIL } )//'Excluir'
aAdd( aRotina, { STR0008  , 				'VIEWDEF.PLSPRO02', 0, 8, 0, NIL } )//'Imprimir'
aAdd( aRotina, { STR0009  , 				'VIEWDEF.PLSPRO02', 0, 9, 0, NIL } )//'Copiar'
aAdd( aRotina, { STR0013  ,               "PLSPROBHTM"     , 0, 3, 0, NIL } ) //Adiciona a opção de Documentação no Browse

Return aRotina
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados construído
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBOJ 	:= FWFormStruct( 1, 'BOJ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOU 	:= FWFormStruct( 1, 'BOU', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruB1P 	:= FWFormStruct( 1, 'B1P', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruB1U 	:= FWFormStruct( 1, 'B1U', /*bAvalCampo*/, /*lViewUsado*/ )
Local aGatB1P 	:= {}
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( STR0001, /*bPreValidacao*/, {|| PLSPRO02OK(oModel) }, /*bCommit*/, {|| PLSPRO02CA() }  ) //'Sinalizadores/Alertas'

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'BOJMASTER', NIL, oStruBOJ )

//Define quais campos do submodelo nao serao copiados no processo de copia.
oModel:GetModel("BOJMASTER"):SetFldNoCopy({'BOJ_CODSIN','BOJ_ASSUNT'})

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'BOUDETAIL', 'BOJMASTER', oStruBOU, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'B1PDETAIL', 'BOJMASTER', oStruB1P, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'B1UDETAIL', 'BOJMASTER', oStruB1U, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'BOUDETAIL', { { 'BOU_FILIAL', 'xFilial( "BOU" ) ' } , { 'BOU_CODSIN', 'BOJ_CODSIN' } } ,  BOU->( IndexKey( 1 ) ) )
oModel:SetRelation( 'B1PDETAIL', { { 'B1P_FILIAL', 'xFilial( "B1P" ) ' } , { 'B1P_CODSIN', 'BOJ_CODSIN' } } ,  B1P->( IndexKey( 1 ) ) )
oModel:SetRelation( 'B1UDETAIL', { { 'B1U_FILIAL', 'xFilial( "B1U" ) ' } , { 'B1U_CODSIN', 'BOJ_CODSIN' } } ,  B1U->( IndexKey( 1 ) ) )
//Define que o preenchimento é opcional para o GRID

oModel:SetOptional("BOUDETAIL", .T. )
oModel:SetOptional("B1PDETAIL", .T. )
oModel:SetOptional("B1UDETAIL", .T. )
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Sinalizadores/Alertas'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BOJMASTER' ):SetDescription( STR0001 ) //'Sinalizadores/Alertas'
oModel:GetModel( 'BOUDETAIL' ):SetDescription( STR0002 ) //'Cadastro de Email´s'
oModel:GetModel( 'B1PDETAIL' ):SetDescription( STR0011 ) //'Posicionamento dos campos HTML'  
oModel:GetModel( 'B1UDETAIL' ):SetDescription( STR0012 ) //'Campos HTML'  

oModel:SetPrimaryKey( { } )

//Valida se existem codigos duplicados no aCols
oModel:GetModel('BOUDETAIL'):SetUniqueLine({'BOU_EMAIL'})
oModel:GetModel('B1PDETAIL'):SetUniqueLine({'B1P_ALIAS','B1P_INDICE','B1P_CHAVE'})
oModel:GetModel('B1UDETAIL'):SetUniqueLine({'B1U_CAMPO'})

//GATILHO CRIADO AQUI POIS USA O SX2 COMO ALIAS DE PESQUISA E O ATUSX NÃO PERMITE
aGatB1P := FwStruTrigger(;
'B1P_ALIAS',;                   //Campo Domínio
'B1P_DESCRI',;                  //Campo de Contradomínio
'SX2->X2_NOME',;                //Regra de Preenchimento
.T.,;                           //lSeek Se posicionara ou não antes da execução do gatilhos
'SX2' ,;                        //Alias da tabela a ser posicionada
1,;                             //Ordem da tabela a ser posicionada
'PL446ALI("B1P")',;             //Chave de busca da tabela a ser posicionada 
/*condição execuçao gatilho*/)  //Condição execuçao gatilho                     

oStruB1P:AddTrigger( ;
aGatB1P[1] , ; // [01] identificador (ID) do campo de origem
aGatB1P[2] , ; // [02] identificador (ID) do campo de destino
aGatB1P[3] , ; // [03] Bloco de código de validação da execução do gatilho
aGatB1P[4] )   // [04] Bloco de código de execução do gatilho

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruBOJ := FWFormStruct( 2, 'BOJ' )
Local oStruBOU := FWFormStruct( 2, 'BOU' )
Local oStruB1P := FWFormStruct( 2, 'B1P' )
Local oStruB1U := FWFormStruct( 2, 'B1U' )

 // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'PLSPRO02' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BOJ' , oStruBOJ, 'BOJMASTER'   )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_BOU' , oStruBOU, 'BOUDETAIL'   )
oView:AddGrid(  'VIEW_B1P' , oStruB1P, 'B1PDETAIL'   )
oView:AddGrid(  'VIEW_B1U' , oStruB1U, 'B1UDETAIL'   )

//Adiciona Campo incremental na View
oView:AddIncrementField( 'VIEW_B1P' , 'B1P_ORDEM') 

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRID', 50 )

// Cria Folder na view
oView:CreateFolder( 'PASTA', 'GRID' )
oView:CreateFolder( 'PASTA', 'GRID' )
oView:CreateFolder( 'PASTA', 'GRID' )

// Cria pastas nas folders
oView:AddSheet( 'PASTA', "ABABOU", STR0002  ) //'Cadastro de Email´s'
oView:AddSheet( 'PASTA', "ABAB1P", STR0011  ) //'Posicionamento dos campos HTML'
oView:AddSheet( 'PASTA', "ABAB1U", STR0012  ) //'Campos HTML'

//createHorizontalBox(cID,nPercHeight,cIDOwner,lFixPixel,cIDFolder,cIDSheet)
oView:CreateHorizontalBox( 'GRIDBOU', 100,,, 'PASTA', "ABABOU" )
oView:CreateHorizontalBox( 'GRIDB1P', 100,,, 'PASTA', "ABAB1P" )
oView:CreateHorizontalBox( 'GRIDB1U', 100,,, 'PASTA', "ABAB1U" )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_BOJ' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_BOU' , 'GRIDBOU'  )
oView:SetOwnerView( 'VIEW_B1P' , 'GRIDB1P'  )
oView:SetOwnerView( 'VIEW_B1U' , 'GRIDB1U'  )

//Adiciona botão na barra de botões "ações relacionadas"
oView:AddUserButton( STR0013, '', {|| PLSPROEHTM(oModel)} )//'Gerar HTML'
//Adiciona ação no campo para carregar campos na grid
oView:SetFieldAction('BOJ_DIRECT', { |oView| PLSPROLHTM(oView, oModel)}) //Carrega grids

oView:EnableTitleView( 'VIEW_BOJ' )

// REGRA para não alterar os códigos sequenciais 
oStruB1P:SetProperty( 'B1P_ORDEM'  , MVC_VIEW_CANCHANGE, .F. )
oStruB1P:SetProperty( 'B1P_ALIAS'  , MVC_VIEW_LOOKUP, "SX2PR2"  )

Return oView 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSPRODIR ³ Autor ³ Saude              ³ Data ³ 20.09.2012  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta diretorio do servidor                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPRODIR()
 
Local aArea   := getArea()
Local cTipo	:= ""
Local cDirArq	:= ""
Local cCpoVld := ReadVar()

If Type("cTipArq") # "U"
	cTipo := cTipArq
EndIf
cDirArq := cGetFile(cTipo,STR0003,1 ,"c:\",.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE) //"Selecione o Arquivo"
If !Empty(cCpoVld)
	&(cCpoVld) := cDirArq
EndIf
If Type("cRetDArq") # "U"
	cRetDArq := cDirArq
Endif
                                  
RestArea(aArea)
Return(.T.) 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSPRO02OK ³ Autor ³ Karine Riquena Limp³ Data ³ 02.03.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pos validação do model                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPRO02OK(oModel)
LOCAL lRet := .T.
LOCAL oBOJ := oModel:GetModel('BOJMASTER')
LOCAL oB1P := oModel:GetModel('B1PDETAIL')
LOCAL oB1U := oModel:GetModel('B1UDETAIL')
LOCAL nOpc := oModel:GetOperation()
LOCAL nTamNi
LOCAL cAlias
LOCAL cIndice
LOCAL cMsg     := ""
LOCAL cCampo   := ""
LOCAL nHandle	 := 0
LOCAL cArquivo
Local nI 

//percorre a grid de posicionamentos para verificar os indices informados
nTamNi := oB1P:Length()

For nI := 1 To nTamNi
	oB1P:Goline(nI)
	cAlias  := AllTrim(oB1P:GetValue('B1P_ALIAS'))
	cIndice := AllTrim(oB1P:GetValue('B1P_INDICE'))
	If !(Empty(cAlias)) .AND. !(Empty(cIndice))	
		lRet := PLSPROIND(cAlias, cIndice)
		If !lRet
			cMsg += STR0014 /*"Para o alias "*/+ " " + cAlias + ", " + STR0015 /*"não existe o indice informado "*/ + chr(13)   
		EndIf		
	EndIf
Next

If cMsg <> ""
	Help( ,, 'HELP',, cMsg, 1, 0)
ElseIf nOpc == 3 .AND. Empty(Alltrim(oBOJ:GetValue('BOJ_DIRECT')))
	If MsgYesNo(STR0016) // 'Deseja gerar o HTML dos campos informados na grade de Campos Html ?'
		PLSPROEHTM(oModel)
	EndIf
EndIf

cSTACPOHTM := ""

Return cMsg == ""
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSPROIND ³ Autor ³ Karine Riquena Limp³ Data ³ 02.03.2015  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida indice informado                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPROIND(cAlias, cInd)
LOCAL aArea := GetArea()
LOCAL lRet  := .T.

If Empty(Alltrim(cAlias))
	lRet := .F.
Else
	SIX->(DbSelectArea("SIX"))
	SIX->(DbSetOrder(1))
	If !(SIX->(MsSeek(cAlias+cInd)))
		lRet := .F.
	EndIf
EndIf
SIX->(DbCloseArea())
RestArea(aArea)
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSPROLHTM ³ Autor ³ Karine Riquena Limp³ Data ³ 03.03.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida carregamento da grid de campos html - LE HTML -     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPROLHTM(oView, oModel)
LOCAL oBOJ := oModel:GetModel('BOJMASTER')
LOCAL oBOU := oModel:GetModel('BOUDETAIL')
LOCAL oB1P := oModel:GetModel('B1PDETAIL')
LOCAL oB1U := oModel:GetModel('B1UDETAIL')
LOCAL cArquivo := Alltrim(oBOJ:GetValue('BOJ_DIRECT'))
LOCAL nLast     := 0
LOCAL cLine     := ""
LOCAL aCpos     := {}
LOCAL nPos      := 0   
LOCAL nPos2     := 0
LOCAL cCampo    := ""
LOCAL nCountBOU := 1
LOCAL nCountB1P := 1
LOCAL nCountB1U := 1
LOCAL aCamposBOJ := {}
LOCAL aValBOJ    := {}
LOCAL aCamposBOU := {}
LOCAL aValBOU    := {}
LOCAL aAuxBOU    := {}
LOCAL nTamInU
LOCAL aCamposB1P := {}
LOCAL aValB1P    := {}
LOCAL aAuxB1P    := {}
LOCAL nTamInP
LOCAL lCarrega := .F.
Local nI := 1
Local nJ := 1

If cSTACPOHTM <> cArquivo

	//Verifico se foi inserido algo na grid e alerto o usuario
	oB1U:Goline(1)
	If oB1U:Length() > 1 .OR. !(Empty(Alltrim(oB1U:GetValue('B1U_CAMPO'))))
		lCarrega := MsgYesNo( STR0017 ) //'Deseja mesmo recarregar os campos da grade "Campos Html" carregando um arquivo html ?'
	Else
		lCarrega := .T.
	EndIf
	
	If !lCarrega	
			oBOJ:SetValue('BOJ_DIRECT', cSTACPOHTM)
			oView:Refresh()
	Else

		//Salvo os valores dos campos do cabecalho para não perde-los no DeActivate do model
		aCamposBOJ := oBOJ:GetStruct():GetFields()
		aEval( aCamposBOJ, { |aX| Aadd(aValBOJ, {aX[3], oBOJ:GetValue(aX[3])} ) } ) 
		
		//Pego a estrutura dos campos das grid de copia de email
		aCamposBOU := oBOU:GetStruct():GetFields()
		//Percorro a grid de posicionamentos para salvar suas linhas
		For nI := 1 To oBOU:Length()
				//Posiciono a linha
		    	oBOU:Goline(nI)
		       //Pego os campos e os valores dos campos da linha usando um array auxiliar 
				aEval( aCamposBOU, { |aX| Aadd(aAuxBOU, {aX[3], oBOU:GetValue(aX[3])} ) } )
				//Adiciono o array auxiliar para separar cada linha com seus campos e valores
				aAdd(aValBOU, aAuxBOU)
				aAuxBOU := {}
		Next
		
		//Pego a estrutura dos campos da grid de posicionamento
		aCamposB1P := oB1P:GetStruct():GetFields()		
		//Percorro a grid de posicionamentos para salvar suas linhas
		For nI := 1 To oB1P:Length()
				//Posiciono a linha
		    	oB1P:Goline(nI)
		       //Pego os campos e os valores dos campos da linha usando um array auxiliar 
				aEval( aCamposB1P, { |aX| Aadd(aAuxB1P, {aX[3], oB1P:GetValue(aX[3])} ) } )
				//Adiciono o array auxiliar para separar cada linha com seus campos e valores
				aAdd(aValB1P, aAuxB1P)
				aAuxB1P := {}
		Next
		
		//Geração do arquivo
		If file(cArquivo)
			FT_FUse( cArquivo )
			FT_FGoTop()
			nLast := FT_FLastRec()
			If nLast >= 1
				While !FT_FEOF() 
					cLine := FT_FReadLn()
					If !Empty(cLine)
							
						 While (nPos := at("%", cLine)) > 0
					 		If (at(" ", Substr(cLine, nPos+1,  Len(cLine)))) == 1
					 		    cLine := Substr(cLine, nPos+1, Len(cLine))
					 		Else
					 			nPos2 := (at("%", Substr(cLine, nPos+1, Len(cLine)))) + nPos
					 			cCampo := Substr(cLine, nPos,  nPos2-nPos+1)
					 			cLine :=  Substr(cLine, nPos2+1, Len(cLine))
					 		
					 			If Len(aCpos) > 0			 				
					 				If aScan(aCpos, { |x| UPPER(x) == cCampo }) == 0
					 					aAdd(aCpos, cCampo)
					 				EndIf
					 			Else
					 				aAdd(aCpos, cCampo)
					 			EndIf
					 		EndIf			 		
						 EndDo
					EndIf
					FT_FSKIP()
				EndDo	
			EndIf
			// Fecha o Arquivo
			FT_FUSE()
		EndIf
		
		//Devolver os campos na model pois no Deactivate perde tudo
		oModel:DeActivate()
		oModel:Activate()
		
		aEval( aValBOJ, { |aX| oBOJ:SetValue(aX[1], aX[2]) } )
		
		For nI := 1 to Len(aValBOU)	
			If(nCountBOU > 1)
				oBOU:AddLine()
			EndIf
		
			oBOU:Goline( nCountBOU )
			nTamInU := Len(aValBOU[nI])
			For nJ := 1 To nTamInU
				oBOU:SetValue(aValBOU[nI][nJ][1], aValBOU[nI][nJ][2])
			Next
			nCountBOU++			
		Next
		
		For nI := 1 to Len(aValB1P)	
			If(nCountB1P > 1)
				oB1P:AddLine()
			EndIf
		
			oB1P:Goline( nCountB1P )
			nTamInP := Len(aValB1P[nI])
			For nJ := 1 To nTamInP
				oB1P:SetValue(aValB1P[nI][nJ][1], aValB1P[nI][nJ][2])
			Next
			nCountB1P++			
		Next
		
		nTamNi := Len(aCpos)
		For nI := 1 to nTamNi
			If(nCountB1U > 1)
				oB1U:AddLine()
			EndIf
			//Seto os valores no model
			oB1U:Goline( nCountB1U )
			oB1U:SetValue("B1U_FILIAL" , xFilial("B1U"))
			oB1U:SetValue("B1U_CAMPO"  , aCpos[nI])
			oB1U:SetValue("B1U_DADO"   , "''")
			nCountB1U++
		Next
		
		//Posicionamento das grids
		oBOU:Goline(1)
		oB1P:Goline(1)
		oB1U:Goline(1)

		oView:Refresh()
	EndIf
EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSPRO02CA ³ Autor ³ Karine Riquena Limp³ Data ³ 03.03.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Zera static                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPRO02CA()
	cSTACPOHTM := ""
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSPROEHTM ³ Autor ³ Karine Riquena Limp³ Data ³ 04.03.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera html a partir do model                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPROEHTM(oModel)
LOCAL oBOJ := oModel:GetModel('BOJMASTER')
LOCAL oB1P := oModel:GetModel('B1PDETAIL')
LOCAL oB1U := oModel:GetModel('B1UDETAIL')
LOCAL nOpc := oModel:GetOperation()
LOCAL nTamNi
LOCAL lCria := .T.
Local nI := 1

If nOpc <> 5 .AND. nOpc <> 1
    //percorre a grid de campos do html para gerar o arquivo
	nTamNi := oB1U:Length()
	cArquivo := "\workflow\WF" + oBOJ:GetValue('BOJ_CODSIN') + ".htm"
	If file(cArquivo)
		lCria := MsgYesNo(STR0018) //'Já existe um arquivo gerado a partir desse alerta, deseja sobrepor?'
	EndIf
	
	If lCria	
		nHandle := FCREATE(cArquivo)
		oBOJ:SetValue('BOJ_DIRECT',cArquivo)
		//se ocorrer erro na geração do arquivo nHandle = -1
		If nHandle = -1
			cMsg := STR0019 + chr(13) + "Nº Erro: " + Str(Ferror()) //'Erro ao gerar arquivo html'
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsg , 0, 0, {})
			MsgStop( cMsg )
		Else
			cHtml := "<html><head></head><body>"
			FWrite(nHandle, cHtml + chr(13))
			If !(Empty(AllTrim(oBOJ:GetValue('BOJ_TEXTO'))))
				FWrite(nHandle, "%TEXTO%" + chr(13))
			EndIf
			For nI := 1 To nTamNi
				oB1U:Goline(nI)
				cCampo  := AllTrim(oB1U:GetValue('B1U_CAMPO'))
				FWrite(nHandle, cCampo + chr(13))
			Next
			cHtml := "</body></html>"
			FWrite(nHandle, cHtml + chr(13))
			FClose(nHandle)
			
			MsgAlert(STR0020 /*"Foi gerado o arquivo*/ + " WF"+ oBOJ:GetValue('BOJ_CODSIN') + ".htm " + STR0021 /*'no servidor, caminho: '*/ + cArquivo + CHR(13) + STR0022 /*"Personalize o layout do arquivo se desejar."*/)
		EndIf
	EndIf
Else
	MsgAlert(STR0023) //"Ação não permitida nesta operação!"
EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSPROBHTM ³ Autor ³ Karine Riquena Limp³ Data ³ 19.03.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera html a partir do browse                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPROBHTM()
LOCAL cArquivo := "\workflow\WF" + BOJ->BOJ_CODSIN + ".htm"
LOCAL lCria := .T.
LOCAL aArea := GetArea()
LOCAL cCampo
LOCAL nHandle
LOCAL cHtml

If file(cArquivo) .OR. !(Empty(BOJ->BOJ_DIRECT))
		lCria  := MsgYesNo(STR0018) //'Já existe um arquivo gerado a partir desse alerta, deseja sobrepor?'
EndIf

If lCria	

		nHandle := FCREATE(cArquivo)
		//oBOJ:SetValue('BOJ_DIRECT',cArquivo)
		//se ocorrer erro na geração do arquivo nHandle = -1
		If nHandle = -1
			cMsg := STR0019 + chr(13) + "Nº Erro: " + Str(Ferror()) //'Erro ao gerar arquivo html'
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsg , 0, 0, {})
			MsgStop( cMsg )
		Else
			cHtml := "<html><head></head><body>"
			FWrite(nHandle, cHtml + chr(13))
			If !(Empty(AllTrim(BOJ->BOJ_TEXTO)))
				FWrite(nHandle, "%TEXTO%" + chr(13))
			EndIf
			
			B1U->(dbSelectArea("B1U"))
			B1U->(dbSetOrder(1))
			If B1U->(MsSeek(xFilial("B1U") + BOJ->BOJ_CODSIN))
				While (B1U->(!Eof()) .AND. B1U->B1U_FILIAL == xFilial("B1U") .AND. B1U->B1U_CODSIN == BOJ->BOJ_CODSIN)
					cCampo  := AllTrim(B1U->B1U_CAMPO)
					FWrite(nHandle, cCampo + chr(13))
					B1U->(dbSkip())
				EndDo
			EndIf
			cHtml := "</body></html>"
			FWrite(nHandle, cHtml + chr(13))
			FClose(nHandle)
			
			MsgAlert(STR0020 /*"Foi gerado o arquivo*/ + " WF"+ BOJ->BOJ_CODSIN + ".htm " + STR0021 /*'no servidor, caminho: '*/ + cArquivo + CHR(13) + STR0022 /*"Personalize o layout do arquivo se desejar."*/)
		EndIf
		
		//ALTERO O CAMPO REFERENCIA DO ARQUIVO HTM PARA O HTM GERADO
		BOJ->(dbSelectArea("BOJ"))
		BOJ->(dbSetOrder(1))
		BOJ->(MsSeek(xFilial("BOJ") + BOJ->BOJ_CODSIN))
		If FOUND()    // Avalia o retorno da pesquisa realizada
			Begin Transaction
          		BOJ->(RecLock("BOJ", .F.))
          		BOJ->BOJ_DIRECT := cArquivo
          		BOJ->(MsUnlock())
          	End Transaction
		EndIf


EndIf
RestArea(aArea)
Return