#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FATA620.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FATA620     ³ Autor ³Eduardo Gomes Junior   ³ Data ³ 29/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de modelo(s) - Integracao com WORD.					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum					 									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION FATA620()
Local oMBrowse
			
DEFINE FWMBROWSE oMBrowse ALIAS "AG1" DESCRIPTION STR0001 //"Cadastro de Modelos"
ACTIVATE FWMBROWSE oMBrowse
	
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MenuDef     ³ Autor ³Vendas & CRM           ³ Data ³ 29/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do aRotina (Menu funcional)                      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina                                                     	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina := {}	//Array para opcoes
				
ADD OPTION aRotina Title STR0002 Action 'AxPesqui' OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.FATA620' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FATA620' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.FATA620' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.FATA620' OPERATION 5 ACCESS 0 //"Exclui"
								
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ViewDef     ³ Autor ³Vendas & CRM           ³ Data ³ 16/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Definicao da View                                          	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView                                                       	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ViewDef()
Local oModel 	:= FWLoadModel( 'FATA620' )	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruAG1	:= FWFormStruct( 2, 'AG1')	// Cria as estruturas a serem usadas na View
Local oStructFke:= FWFormStruct( 2, 'AG1',{ |cCampo| !(Trim(cCampo) $ "AG1_CODIGO|AG1_DESCRI|") } )	// Cria as estruturas a serem usadas na View
Local oView									// Interface de visualização construída
Local oStruAG2 	:= FWFormStruct( 2, 'AG2' , { |cCampo| !(Trim(cCampo) $ "AG2_COD|AG2_DESCRI|") } ) // Retira os Campos do Grid.

oStructFke:AddField("AG1_MARK","01",STR0007,"",{} ,"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.) //"Marca/Desmarca Todos?"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
oStruAG2:AddField("AG2_TMARK" ,"01","","",{} ,"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel( oModel )									// Define qual Modelo de dados será utilizado				
oView:AddField('VIEW_AG1' , oStruAG1, 'AG1MASTER' )	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField('VIEW_AG1F', oStructFke,'AG1MASTER' )	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_AG2' , oStruAG2, 'AG2DETAIL' )	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)

oView:AddIncrementField( 'VIEW_AG2', 'AG2_ORDEM' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 15 )
oView:CreateHorizontalBox( 'CENTRO'  , 05 )					
oView:CreateHorizontalBox( 'INFERIOR', 80 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_AG1' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_AG1F', 'CENTRO' )				
oView:SetOwnerView( 'VIEW_AG2' , 'INFERIOR' )

oView:AddUserButton(STR0008,'CLIPS',{|| A620Export()})//"Exporta Modelo" 
oView:AddUserButton(STR0009,'CLIPS',{|| A620Import()})//"Importa Modelo" 				

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ModelDef    ³ Autor ³Vendas & CRM           ³ Data ³ 16/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Definicao do Model                                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oModel                                                      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruAG1 := FWFormStruct( 1, 'AG1' )	// Cria as estruturas a serem usadas na View
Local oStruAG2 := FWFormStruct( 1, 'AG2' ) // Estrutura AG2

Local oModel 									// Modelo de dados construído
Local aAux := {}								// Auxiliar para criar a trigger

oStruAG1:AddField(STR0007,"","AG1_MARK","L",1,0,Nil,Nil,Nil,Nil,{|| .F.},Nil,Nil,.T.)//"Marca/Desmarca Todos?"
oStruAG2:AddField("","","AG2_TMARK","L",1,0,Nil,Nil,Nil,Nil,{|| .F.},Nil,Nil,.T.)

aAux := FwStruTrigger(;
'AG2_COMPPR',;
'AG2_DSCPPR',;
'AG3->AG3_DESCRI',;
.T.,;
'AG3',;
1,;
'xFilial("AG3")+FwFldGet("AG2_COMPPR")')
oStruAG2:AddTrigger( ;
aAux[1] , ; 	// [01] identificador (ID) do campo de origem
aAux[2] , ; 	// [02] identificador (ID) do campo de destino
aAux[3] , ; 	// [03] Bloco de código de validação da execução do gatilho
aAux[4] ) 		// [04] Bloco de código de execução do gatilho

aAux := FwStruTrigger(;
'AG2_COMPAS',;
'AG2_DSCPAS',;
'AG3->AG3_DESCRI',;
.T.,;
'AG3',;
1,;
'xFilial("AG3")+FwFldGet("AG2_COMPAS")')
oStruAG2:AddTrigger( ;
aAux[1] , ; 	// [01] identificador (ID) do campo de origem
aAux[2] , ; 	// [02] identificador (ID) do campo de destino
aAux[3] , ; 	// [03] Bloco de código de validação da execução do gatilho
aAux[4] ) 		// [04] Bloco de código de execução do gatilho


oStruAG1:SetProperty("AG1_MARK" ,MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"A620MkAll()"))
oStruAG1:SetProperty("AG1_MARK" ,MODEL_FIELD_INIT,{|| .F.})

oStruAG2:SetProperty("AG2_TMARK" ,MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"A620Mark()"))
oStruAG2:SetProperty("AG2_ORDEM",MODEL_FIELD_INIT,"")
oStruAG2:SetProperty("AG2_TMARK",MODEL_FIELD_INIT,{|| .F.})

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FATA620')

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'AG1MASTER', /*cOwner*/, oStruAG1 )

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'AG2DETAIL', 'AG1MASTER', oStruAG2,,{ || A620VlIt() }  )
oModel:GetModel( 'AG2DETAIL' ):SetOptional( .T. )
// Utiliza a grid antiga no formato aHeader/aCols.
oModel:GetModel( 'AG2DETAIL' ):SetUseOldGrid( .T. )
// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'AG2DETAIL', { { 'AG2_FILIAL', 'xFilial( "AG2" )' }, { 'AG2_COD', 'AG1_CODIGO' } }   , AG2->( IndexKey( 1 ) ) )
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( STR0001 ) //"Cadastro de Modelo"
// Retorna o Modelo de dados

oModel:SetPrimaryKey( { "AG1_FILIAL", "AG1_CODIGO" } )

Return oModel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A620Aheader ³ Autor ³Eduardo Gomes Junior   ³ Data ³ 29/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader e aCols.									 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias	- Alias usado para criar o aHeader/aCols			³±±
±±³			 ³ cCampo	- Campo para ser usado na pesquisa					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A620Aheader(cAlias, cCampo)

Local aArea    		:= GetArea()										//Guarda area atual
Local nX       		:= 1												//Usando no For/Next
Local nCOLSCntfor	:= 1												//Usando no For/Next

Private cChave		:= "" 												//Campo chave de pesquisa

Default cCAMPO     	:= IIF( VALTYPE(cCAMPO) != "U" , cCAMPO , "" )		//Campo a ser pesquisado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek( cALIAS )

While ( !EOF() .And. (SX3->X3_ARQUIVO == cALIAS ) )

	If 	X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .AND. !(ALLTRIM(SX3->X3_CAMPO)$ cCAMPO )

		AADD(aHeader,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT,;
						SX3->X3_INIBRW } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aCols baseado no aHeader ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave		:= xFILIAL("AG1") +AG1->AG1_CODIGO
cCompara	:= "AG2->(AG2_FILIAL+AG2_COD) == cChave"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui elemento vazio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF 	INCLUI 
	AADD( aCOLS, ARRAY(LEN(aHEADER)+1) )
	For nCOLSCntFor := 1 To Len(aHeader)
		cCOLSCampo := Alltrim(aHeader[nCOLSCntFor,2])          
		aCols[Len(aCols)][nCOLSCntFor] := CriaVar(cCOLSCampo)
	NEXT nCOLSCntfor
	aCols[Len(aCols)][ Len(aHeader)+1 ] 		:= .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche acols com conteudo gravado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF 	ALTERA .OR. EXCLUI .OR. VISUAL
	dbSelectArea( "AG2" )
	dbSetOrder( 1 )
	MsSeek( cChave )
	
	While &(cCOMPARA) .AND. !EOF() 
		
		AADD(aCols,Array(Len(aHeader)+1))
		
		For nX := 1 to Len(aHeader)
			If 	( aHeader[nX][10] <> "V" )
				aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			Else
				aCols[Len(aCols)][nX] := IIF(!EMPTY(aHeader[nX][11]),&(aHeader[nX][11]),Criavar(aHeader[nX][2],.T.))
			EndIf
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Next nX
		
		dbSelectArea( cAlias )
		dbSkip()
		
	EndDo
	
EndIf
	
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A620GravaMod³ Autor ³Eduardo Gomes Junior   ³ Data ³ 29/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do modelo 											³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum					 									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A620GravaMod()

Local nX 	//Usado no FOR/NEXT
Local ny 	//Usado no FOR/NEXT 

IF 	INCLUI

	dbSelectArea("AG1")
	dbSetOrder(1)

	RecLock("AG1",.T.)
		AG1->AG1_FILIAL		:= 	xFILIAL("AG1")
		AG1->AG1_CODIGO		:= 	M->AG1_CODIGO
		AG1->AG1_DESCRI		:= 	M->AG1_DESCRI
	MsUnlock()
	
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Remove itens existentes no cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	EXCLUI 

	dbSelectArea("AG1")
	dbSetOrder( 1 ) 
	msSeek( xFilial("AG1") + M->AG1_CODIGO ) 

	RecLock("AG1")
		dbDelete()
	msUnlock()
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Remove itens existentes nos itens   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	EXCLUI .OR. ALTERA

	dbSelectArea("AG2")
	dbSetOrder( 1 ) 
	msSeek( xFilial("AG2") + M->AG1_CODIGO ) 
	WHILE AG2->(AG2_FILIAL+AG2_COD) == xFILIAL("AG2")+ M->AG1_CODIGO .AND. !EOF()
		RecLock("AG2")
		dbDelete()
		msUnlock()
		dbSkip()
	ENDdo
	
EndIf 
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui itens disponiveis no Acols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	INCLUI .OR. ALTERA            

	FOR nX := 1 TO LEN( aCOLS ) 
	
		IF 	( aCols[nx][Len(aHeader)+1] ) 
			Loop
		ENDif
	
		dbSelectArea('AG2')
		RecLock('AG2',.T.)
		AG2->AG2_FILIAL		:= xFILIAL("AG2") 
		AG2->AG2_COD   		:= M->AG1_CODIGO
		AG2->AG2_DESCRI		:= M->AG1_DESCRI

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os dados contidos na GetDados                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny := 1 to Len(aHeader)
			If 	aHeader[ny][10] # "V"
				AG2->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
			Endif
		Next
		msUnlock()
		
	NEXT nX

EndIf
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A620SeqNum  ³ Autor ³Eduardo Gomes Junior   ³ Data ³ 29/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca o proximo numero sequencial.						 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cProxNum - Numero sequencial                                	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias		- Alias da tabela em uso                       	³±±
±±³			 ³ cCampo 		- Campo usado para sequencia                   	³±±
±±³			 ³ nQualIndex   - Index da tabela 								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A620NumSeq(cAlias, cCampo, nQualIndex)

Local aArea		:= GetArea()	//Guarda area atual
Local cProxNum					//Proximo numero do SX8

Default nQualIndex := 1
          
cProxNum 	:= GetSx8Num(cAlias, cCampo,, nQualIndex)
	
dbSelectArea(cAlias)
dbSetOrder(nQualIndex)
			
While dbSeek( xFilial( cAlias ) + cProxNum )
	ConfirmSX8()
	cProxNum := GetSx8Num(cAlias, cCampo,, nQualIndex)
End

RestArea(aArea)

Return(cProxNum)


//------------------------------------------------------------------------------
/*/{Protheus.doc} A620Mark 

Verifica se todos os modelos estao marcados

Marca todos os modelos

@sample		A620Mark()

@return		.T. - Validação OK

@author		Aline Sebrian Damasceno
@since		19/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function A620Mark()
Local oModel	:= FWModelActive()
Local oView		:= FwViewActive()

Local oMdlAG1   := oModel:GetModel("AG1MASTER")
Local oMdlAG2   := oModel:GetModel("AG2DETAIL")

Local nLinAtu	:= 1
Local nCount    := 0
Local nX		:= 0

For nX := 1 To oMdlAG2:Length()
	oMdlAG2:GoLine(nX)
	If oMdlAG2:GetValue("AG2_TMARK")
		nCount++
	EndIf
Next nX


If nCount == oMdlAG2:Length()
	oMdlAG1:LoadValue("AG1_MARK",.T.)
Else
	oMdlAG1:LoadValue("AG1_MARK",.F.)
EndIf

oView:Refresh()

Return  .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} A620MkAll 

Marca todos os modelos

@sample		A620MkAll()

@return		.T. - Validação OK

@author		Aline Sebrian Damasceno
@since		19/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function A620MkAll()
Local oModel	:= FWModelActive()
Local oView		:= FwViewActive()

Local oMdlAG1   := oModel:GetModel("AG1MASTER")
Local oMdlAG2   := oModel:GetModel("AG2DETAIL")

Local nLinAtu	:= oMdlAG2:GetLine()  
Local lMark	 	:= oMdlAG1:GetValue("AG1_MARK")
Local nX		:= 0

For nX := 1 To oMdlAG2:Length()
	oMdlAG2:GoLine(nX)
	If lMark
		oMdlAG2:LoadValue("AG2_TMARK",.T.)
	Else
		oMdlAG2:LoadValue("AG2_TMARK",.F.)
	EndIf
Next nX

oMdlAG2:GoLine(nLinAtu)

oView:Refresh()

Return  .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} A620Export 

Exportação dos modelos selecionados

@sample		A620Export()

@author		Aline Sebrian Damasceno
@since		19/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function A620Export()
Local oModel		:= FWModelActive()
Local oView		:= FwViewActive()

Local oMdlAG1   	:= oModel:GetModel("AG1MASTER")
Local oMdlAG2   	:= oModel:GetModel("AG2DETAIL")

Local aDots		:= {}

Local cExtens  	:= STR0012 //"Arquivo  ( *.* ) |*.*|"
Local cDes 		:= '' 
Local cPath 		:= SuperGetMV("MV_DOCAR",,"\System\WORD\DOC_AR\")
Local lErr			:= .f.
Local lContinua 	:= .T.
Local nI,lCpy
Local lInsert 	:= .F.
Local nX			:= 0
Local nZ   		:= 0
Local nLinAtu		:= oMdlAG2:GetLine()  

//Verifica se existe uma linha adicionada na grid
If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	For nZ := 1 to oMdlAG2:Length()
		oMdlAG2:Goline(nZ)
		If !oMdlAG2:IsDeleted() 
			If oMdlAG2:GetValue("AG2_TMARK") .And. oMdlAG2:IsInserted()
				lInsert := .T.
				Exit
			EndIf		
		EndIf
	Next nZ	
EndIf

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. lInsert
	MSGALERT(STR0023)
	lContinua := .F.
EndIf
	
If lContinua 
	aDots := DMItens(oMdlAG1,oMdlAG2,nLinAtu)
	
	If Empty(aDots)	
		MSGALERT(STR0011) //"Não existem itens marcados para exportação"
		lContinua := .F.
	EndIf
EndIf

	
If lContinua	
	cDes 		:= Alltrim(cGetFile( cExtens, STR0010,,, .f., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ) )) //"Selecione Pasta Destino" 
	ProcRegua(Len(aDots))
	
	If !Empty(cDes)
		For nI := 1 to Len(aDots)
			
			IncProc(STR0013) //"Copiando Dots..."  
			
			lCpy	:= .t.
			
			If !(File(cPath+Alltrim(aDots[nI,1])))
				MsgAlert(STR0014+cPath+Alltrim(aDots[nI,1])+STR0015)  //"O arquivo de origem "
			 	lErr := .T.
			EndIf
			 		
			If !lErr .And. File(cDes+Alltrim(aDots[nI,1]))
				lCpy := MsgYesNo(STR0016+cDes+Alltrim(aDots[nI,1])+" ?") //"Sobrescreve arquivo "
			Endif
			
			If lCpy .and. File(cPath+Alltrim(aDots[nI,1]))
				If ! __CopyFile( cPath+Alltrim(aDots[nI,1]) , cDes+Alltrim(aDots[nI,1]) )
					MsgAlert(STR0017+cPath+Alltrim(aDots[nI,1])) //"Falha na Copia... "  
					lErr := .t.
					Exit
				Endif
			Endif
			
		Next
			
		If !lErr .And. lCpy
			MSGALERT(STR0018)//"Modelos Exportados!"
		Endif
		
		
		oMdlAG2:GoLine(nLinAtu)
		
		oView:Refresh()
	EndIf
EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} A620Import 

Importação dos modelos selecionados

@sample		A620Import()

@author		Aline Sebrian Damasceno
@since		19/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function A620Import()
Local oModel	:= FWModelActive()
Local oView		:= FwViewActive()

Local oMdlAG1   := oModel:GetModel("AG1MASTER")
Local oMdlAG2   := oModel:GetModel("AG2DETAIL")

Local aDots		:= {}

Local cExtens   	:= STR0012 //"Arquivo  ( *.* ) |*.*|"
Local cExt			:= "000"
Local cOri   		:= '' 
Local cPath 		:= SuperGetMV("MV_DOCAR",,"\System\WORD\DOC_AR\")
Local cPathBkp	:= "BkpDot\"
Local cFileBkp	:= ""
Local lBkp			:= .t.
Local lErr			:= .f.
Local lContinua 	:= .T.
Local lCpy      	:= .T.
Local lInsert    :=  .F.
Local nI       	:= 0
Local nX			:= 0
Local nZ          := 0
Local nLinAtu	 	:= oMdlAG2:GetLine()  
Local nItUp   	:= 0


//Verifica se existe uma linha adicionada na grid
If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	For nZ := 1 to oMdlAG2:Length()
		oMdlAG2:Goline(nZ)
		If !oMdlAG2:IsDeleted() 
			If oMdlAG2:GetValue("AG2_TMARK") .And. oMdlAG2:IsInserted()
				lInsert := .T.
				Exit
			EndIf
		EndIf		
	Next nZ	
EndIf

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. lInsert
	MSGALERT(STR0024)
	lContinua := .F.
EndIf

If lContinua 
	aDots := DMItens(oMdlAG1,oMdlAG2,nLinAtu)
	
	If Empty(aDots)	
		MSGALERT(STR0020)
		lContinua := .F.
	EndIf

EndIf


	
If lContinua	
	cOri   	:= Alltrim(cGetFile( cExtens, STR0019,,, .f., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ) )) //"Selecione Pasta Origem" 
	
	ProcRegua(Len(aDots))
	
	For nI := 1 to Len(aDots)
		
		IncProc(STR0013)
		
		lCpy	:= .t.
			
		 If !(File(cOri+Alltrim(aDots[nI,1])))
		 	MsgAlert(STR0014+cOri+Alltrim(aDots[nI,1])+STR0015) //"O arquivo de origem "
		 	lErr := .t.
		 EndIf
		 
		 If !lErr .And. File(cPath+Alltrim(aDots[nI,1]))
			lCpy := MsgYesNo(STR0016+cPath+Alltrim(aDots[nI,1])+" ?") //"Sobrescreve arquivo " 
		Endif
		
		
		If !lErr .And. lCpy 
			lBkp := .t.
			makedir(cpath+cpathbkp)  // cria pasta de backup
			Do While lBkp
				cFileBkp := StrTran(Upper(Alltrim(aDots[nI,1])),".DOT","."+cExt)
				If File(cPath+cPathBkp+cFileBkp)
					cExt := Soma1(cExt)
				Else
					lBkp := .f.
			  	EndIf
			Enddo
		   	If !__CopyFile( cOri+Alltrim(aDots[nI,1]) , cPath+cPathBkp+cFileBkp )		
				MsgAlert(STR0021+cOri+Alltrim(aDots[nI,1])) //"Falha no Backup... "          
	   			lErr := .t.
	   			Exit
	   		EndIf
			
			If !__CopyFile( cOri+Alltrim(aDots[nI,1]) , cPath+Alltrim(aDots[nI,1]) )
				MsgAlert(STR0017+cOri+Alltrim(aDots[nI,1])) //"Falha na Copia... " 
				lErr := .t.
				Exit
			Else
				nItUp++
			Endif
		Endif
			
	Next
	
	
	If !lErr .And. lCpy .And. nItUp>0
		MSGALERT(STR0022)//"Modelos Importados!"
	Endif
	
	
	oMdlAG2:GoLine(nLinAtu)
	
	oView:Refresh()
EndIf


Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} DMItens 

Seleciona os modelos marcados

@sample		DMItens()

@param 		oModel - Model da rotina AG1
@param 		oModel - Model da rotina AG2

@return		aDots - Modelos .dot marcados

@author		Aline Sebrian Damasceno
@since		19/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function DMItens(oMdlAG1,oMdlAG2,nLinAtu)

Local aArea 	:= GetArea()
Local aDots     := {}
Local cQuery	:= ""
Local nQts		:= 0
Local cMod      := oMdlAG1:GetValue("AG1_CODIGO")
Local cOrdem    := oMdlAG2:GetValue("AG2_ORDEM")
Local cCompPr   := oMdlAG2:GetValue("AG2_COMPPR")
Local cOrdem    := oMdlAG2:GetValue("AG2_ORDEM")


BeginSQL Alias "TITENS"

	 SELECT AG4_CODIGO, 
	        AG2_ORDEM, 
	        AG4_DOCWOR, 
	        AG4_PAIS,
	        AG4_IDIOMA 
	        AG3_DESCRI, 
	        AG4.R_E_C_N_O_ NUMREG, 
	        AG2.R_E_C_N_O_ REGITS 
	From   %Table:AG2%  AG2
	Left Join %Table:AG3% AG3 ON AG3.AG3_FILIAL =   %xFilial:AG3%
							  And AG3.AG3_CODIGO = AG2.AG2_COMPAS
					     	  And AG3.%NotDel% 
	Left Join %Table:AG4% AG4 On AG4.AG4_FILIAL =   %xFilial:AG4%
	                         And AG4.%NotDel% 
	                         And AG4_CODIGO = AG3.AG3_CODIGO 
	Where AG2.AG2_FILIAL =  %xFilial:AG2% 
	And AG2.AG2_COD    =  %Exp:cMod%
	And AG2.%NotDel% 
	Group by 
	 AG4_CODIGO, 
	 AG2_ORDEM, 
	 AG4_DOCWOR, 
	 AG4_PAIS,
	 AG4_IDIOMA, 
	 AG3_DESCRI, 
	 AG4.R_E_C_N_O_ ,
	 AG2.R_E_C_N_O_
	ORDER BY AG2_ORDEM,REGITS

EndSql

dbSelectArea("TITENS")
Count to nQts
dbGoTop()

aDots 	:= {}

Do While !TITENS->(EoF())
	If oMdlAG2:SeekLine( { {'AG2_ORDEM', TITENS->AG2_ORDEM} } ) 
		If oMdlAG2:GetValue("AG2_TMARK") 
			aAdd(aDots,{Alltrim(TITENS->AG4_DOCWOR)+".DOT",TITENS->NUMREG})
		EndIf
	EndIf
	TITENS->(dbSkip())
			
Enddo

TITENS->(dbCloseArea())

Return aDots

//-----------------------------------------------------------------------------
/*/{Protheus.doc} A620VlIt 

Valida grid com os modelos

@sample		A620VlIt()

@return		lRet - .T. - continua, .f.- não continua

@author		Aline Sebrian Damasceno
@since		14/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function A620VlIt()
Local lRet			:= .T.
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FWModelActive()
Local oMdlAG2		:= oModel:GetModel("AG2DETAIL")
Local cCompAs    := oMdlAG2:GetValue("AG2_COMPAS")
Local cCompPr    := oMdlAG2:GetValue("AG2_COMPPR")

If !oMdlAG2:IsDeleted() 
	If lRet .And. Empty(cCompAs)
		Help(" ",1,"OBRIGAT",,RetTitle(cCompAs),4)
		lRet := .F.
	EndIf
	
	If lRet .And. Empty(cCompPr)
		Help(" ",1,"OBRIGAT",,RetTitle(cCompPr),4)
		lRet := .F.
	EndIf
EndIf

FWRestRows( aSaveLines )

Return lRet