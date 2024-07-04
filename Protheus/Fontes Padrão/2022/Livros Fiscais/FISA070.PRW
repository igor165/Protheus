#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA070.CH"
#INCLUDE "FILEIO.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA070
 
@author Erick G. Dias
@since 26/09/2013
@version 11.90

/*/
//-------------------------------------------------------------------
Function FISA070
Local	oBrw	:= FWmBrowse():New()

IF  AliasIndic("CGA") .AND. AliasIndic("CGB") 
	oBrw:SetDescription(STR0001)
	oBrw:SetAlias( 'CGA')
	oBrw:SetMenuDef( STR0002 ) //FISA070
	oBrw:AddLegend( "CGA_TPREG=='1'", "GREEN"	, STR0003 ) // "Mercadorias
	oBrw:AddLegend( "CGA_TPREG=='2'", "YELLOW", STR0004 ) // "Serviço"
	oBrw:Activate()  
Else
	Help("",1,"Help","Help",STR0004,1,0) // Tabelas CGA e/ou CGB não encontradas no sistema
EndIF	                            

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 26/09/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := FWMVCMenu( STR0002 )
 
Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 26/09/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCGA 	:= 	FWFormStruct( 1, 'CGA')
Local oStruCGB	:=	FWFormStruct( 1, 'CGB' ,{ |cCampo| CMPCGB(cCampo) } )
Local oModel 		

oModel	:=	MPFormModel():New('FISA070',,{|oModel| ValidForm(oModel)},{|oModel| RecalPerc(oModel, .T.)}, /*bCancel*/)

//Campos que fazem relação com chave da tabela pai não serão exibidos.
oStruCGB:RemoveField('CGB_UF')

//Adiciona a estrutura da CGA
oModel:AddFields( 'MODEL_CGA' , /*cOwner*/ , oStruCGA )

//Adiciona um grid com estrutura da CGB
oModel:AddGrid( 'MODEL_CGB', 'MODEL_CGA', oStruCGB) 

oModel:GetModel( 'MODEL_CGB' ):SetUniqueLine( { 'CGB_TPTRIB','CGB_DTINIV'} )         

//Relação dos campos da tabela CGA com CGB.
oModel:SetRelation( 'MODEL_CGB', { { 'CGB_FILIAL', 'xFilial( "CGB" )' },;
									 { 'CGB_NCM', 'CGA_NCM' },;
									 { 'CGB_EXNCM', 'CGA_EXNCM' },;									 
									 { 'CGB_CODISS', 'CGA_CODISS' },;									 									 
									 {'CGB_UF','CGA_UF'},;
									 {'CGB_CODMUN','CGA_CODMUN'},;
									 {'CGB_CODPRO','CGA_CODPRO'} },;
									 CGB->( IndexKey( 1 ) ) )

//Quando for operação de edição os campos que fazem parte da chave na
oStruCGA:SetProperty( 'CGA_TPREG' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCGA:SetProperty( 'CGA_NCM' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCGA:SetProperty( 'CGA_EXNCM' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCGA:SetProperty( 'CGA_CODISS' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCGA:SetProperty( 'CGA_CODMUN' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCGA:SetProperty( 'CGA_CODPRO' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCGA:SetProperty( 'CGA_UF'	 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })

oStruCGA:SetProperty( 'CGA_CODISS'	 , MODEL_FIELD_WHEN, { ||HabCmpo('CGA_CODISS') })
oStruCGA:SetProperty( 'CGA_NCM'	 , MODEL_FIELD_WHEN, { ||HabCmpo('CGA_NCM') })
oStruCGA:SetProperty( 'CGA_EXNCM'	 , MODEL_FIELD_WHEN, { ||HabCmpo('CGA_EXNCM') })

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 26/09/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= 	FWLoadModel( 'FISA070' )
Local oStruCGA 	:= 	FWFormStruct( 2, 'CGA' )
Local oStruCGB 	:= 	FWFormStruct( 2, 'CGB' ,{ |cCampo| CMPCGB(cCampo) })
Local oView 		:= 	FWFormView():New()

oStruCGB:RemoveField('CGB_UF')
oStruCGB:RemoveField('CGB_NCM')
oStruCGB:RemoveField('CGB_EXNCM')
oStruCGB:RemoveField('CGB_CODISS')

oView:SetModel( oModel )

oView:AddField( 'VIEW_CGA', oStruCGA, 'MODEL_CGA' )
oView:AddGrid( 'VIEW_CGB', oStruCGB, 'MODEL_CGB' )

oView:CreateHorizontalBox( 'SUPERIOR', 18 )
oView:CreateHorizontalBox( 'INFERIOR1', 82 )

oView:SetOwnerView( 'VIEW_CGA', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CGB', 'INFERIOR1' )

oView:EnableTitleView( 'VIEW_CGA', STR0006 )	//"Carga de Tributos"
oView:EnableTitleView( 'VIEW_CGB', STR0007 )	//"Percentuais por Tributo"

oView:AddUserButton(STR0013,"",{|| RecalPerc(oModel, .F.)},"",,{MODEL_OPERATION_UPDATE}) //"Recalculo"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CMPCGBd
Funcao generica MVC do View

@return lRet - Indica se o campo será considerado ou não na estrutura

@author Erick G. Dias
@since 26/09/2013
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function CMPCGB(cCampo)                                       	

Local lRet	:= .T.

If cCampo $ "/CGB_NCM/CGB_EXNCM/CGB_CODISS/CGB_CODMUN/CGB_CODPRO/CGB_UF/"
	lRet	:= .F.
EndIF 


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Função para validação do formulário.

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 26/09/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local lRet			:=	.T.
Local cNCM			:= oModel:GetValue ('MODEL_CGA','CGA_NCM') 
Local cExNCM		:= oModel:GetValue ('MODEL_CGA','CGA_EXNCM') 
Local cCodISS		:= oModel:GetValue ('MODEL_CGA','CGA_CODISS') 
Local cUfA			:= oModel:GetValue ('MODEL_CGA','CGA_UF')
Local cCodMunA		:= oModel:GetValue ('MODEL_CGA','CGA_CODMUN')
Local cCodProA		:= oModel:GetValue ('MODEL_CGA','CGA_CODPRO')
Local cTpReg		:= oModel:GetValue ('MODEL_CGA','CGA_TPREG')
Local cChave		:= ""
Local nOperation	:=	oModel:GetOperation()

IF cTpReg == "1" .AND. Empty(cNCM) .AND. nOperation <> 5
	Help(,,"A070",,STR0009,1,0)
	lRet := .F.
ElseIf  cTpReg == "2" .AND. Empty(cCodISS)  .AND. nOperation <> 5
	Help(,,"A070",,STR0012,1,0)
	lRet := .F.
ElseIF nOperation == 	3 // Inclusão irei verificar se já existe registro da CGA gravado
	dbSelectArea("CGA")	
	If cTpReg == "1"
		cChave	:=	xFilial("CGA")+cNCM+cExNCM+cUfA+cCodMunA+cCodProA
		DbSetOrder(1)
	Else
		cChave	:=xFilial("CGA")+cCodISS+cUfA+cCodMunA+cCodProA
		DbSetOrder(2)
	EndIF
	
	If CGA->(dbSeek(cChave))		
		Help(,,"A070",,STR0010,1,0)
		lRet := .F.
	EndIF
EndIF

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaPerc
Função utilizada para habiliar e desabilitar os campos da tela.

@return lRet - Indica se irá ou não habilitar o campo

@author Erick G. Dias
@since 26/09/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function HabCmpo(cCampo)
Local	oModel	:= 	FWModelActive()
Local lRet		:= .F.
Local cTpReg	:= oModel:GetValue ('MODEL_CGA','CGA_TPREG') 

Do Case   		
	Case oModel:GetOperation() <> 3 //Se não for inclusão o campo não estará disponível para edição
		lRet		:= .F.
	Case EmpTy(cTpReg)	
		lRet		:= .T.
	Case cCampo $ "CGA_NCM/CGA_EXNCM"
		IF cTpReg == "1" // Mercadoria
			lRet		:= .T.
		EndIF	
	Case cCampo $ "CGA_CODISS"
		IF cTpReg == "2" // Serviço
			lRet		:= .T.
		EndIF	
EndCase 
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuPercCGA
Função de atualização geral dos totais da tabela CGA. Esta funcao deve
ser chamada via JOB (scheduler).

@return lRet - Indica se o processamento foi executado

@author Joao Victor Pellegrini
@since 10/02/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function AtuPercCGA(aParam)

Local lRet := .T.
Local lJob := .F.
Local cChaveCGB := ""
Local aProdAlt := {}
Local dDataAtual := Date()

Local nTotPerc := 0
Local nPercFed := 0
Local nPercEst := 0
Local nPercMun := 0

Local lFedAliq := CGA->(FieldPos("CGA_TOTFED"))>0
Local lEstAliq := CGA->(FieldPos("CGA_TOTEST"))>0
Local lMunAliq := CGA->(FieldPos("CGA_TOTMUN"))>0

DEFAULT aParam := {}

// Indica Processamento via JOB.
lJob :=  Len(aParam) > 0

If lJob
	Conout("INICIO DE PROCESSAMENTO - AtuPercCGA")
	Conout("PREPARANDO AMBIENTE  - Empresa: " + aParam[1] + " Filial: " + aParam[2])
	RpcSetType(3) // Não consumir licença
	RpcSetEnv(aParam[1] , aParam[2]) // Alternativa p/ SET ENVIRONMENT

	If AliasIndic("CGA") .And. AliasIndic("CGB") 				
		dbSelectArea("CGA")
		CGA->(dbSetOrder(1))
		CGA->(dbGoTop())
		
		dbSelectArea("CGB")
	
		While !CGA->(EOF()) .And. !CGA->(Deleted())	
			
			nTotPerc	:= 0
			nPercFed	:= 0
			nPercEst	:= 0
			nPercMun	:= 0
			
			Do Case 
				// Mercadoria
				Case CGA->CGA_TPREG == "1"
					cChaveCGB := xFilial("CGB")+CGA->CGA_NCM+CGA->CGA_EXNCM+CGA->CGA_UF+CGA->CGA_CODMUN+CGA->CGA_CODPRO   
					CGB->(dbSetOrder(1))
				// Servico
				Case CGA->CGA_TPREG == "2"   
					cChaveCGB := xFilial("CGB")+CGA->CGA_CODISS+CGA->CGA_UF+CGA->CGA_CODMUN+CGA->CGA_CODPRO				
					CGB->(dbSetOrder(2))
			EndCase
					
			If CGB->(MsSeek(cChaveCGB))
				While (!CGB->(Eof()) .And. !CGB->(Deleted()) .And.; 
						 CGB->CGB_FILIAL == xFilial("CGB") .And.;
						 CGB->CGB_NCM == CGA->CGA_NCM .And.;
						 CGB->CGB_EXNCM == CGA->CGA_EXNCM .And.;
						 CGB->CGB_CODISS == CGA->CGA_CODISS .And.;
						 CGB->CGB_UF == CGA->CGA_UF .And.;
						 CGB->CGB_CODMUN == CGA->CGA_CODMUN .And.;
						 CGB->CGB_CODPRO == CGA->CGA_CODPRO)
					
					// Serão somados os registros cuja data inicial seja anterior a data atual e a data final seja vazia ou posterior a atual
					If (CGB->CGB_DTINIV <= dDataAtual .And. (CGB->CGB_DTFIMV >= dDataAtual .Or. Empty(CGB->CGB_DTFIMV)))					
						nTotPerc += CGB->CGB_TOTPER		
						
						//Tratamento para pegar valor por ente de tributação - Federal / Estadual / Municipal
						
						Do Case
							Case Alltrim(CGB->CGB_TPTRIB) $ "IPI#IOF#PIS#PISIMP#COFINS#COFIMP#$CIDE#II"
								nPercFed += CGB->CGB_TOTPER
							Case Alltrim(CGB->CGB_TPTRIB) $ "ICMS"
								nPercEst += CGB->CGB_TOTPER
							Case Alltrim(CGB->CGB_TPTRIB) $ "ISS"
								nPercMun += CGB->CGB_TOTPER
						EndCase
								
					EndIf
						
					CGB->(dbSkip())
				EndDo
			EndIf
			
			If nTotPerc <> CGA->CGA_TOTPER .Or. ((lFedAliq .And. lPercEst .And. lPercMun) .And. (nPercFed <> CGA->CGA_TOTFED .Or. ;
			   nPercEst <> CGA->CGA_TOTEST .Or. nPercMun <> CGA->CGA_TOTMUN))
					
				cChaveCGA := CGA->CGA_NCM+CGA->CGA_EXNCM+CGA->CGA_CODISS+CGA->CGA_UF+CGA->CGA_CODMUN+CGA->CGA_CODPRO
				aAdd(aProdAlt, {cChaveCGA, CGA->CGA_TOTPER, nTotPerc})				 
						
				RecLock("CGA", .F.)
					CGA->CGA_TOTPER	:= nTotPerc 
					If lFedAliq .And. lPercEst .And. lPercMun
						CGA->CGA_TOTFED	:= nPercFed
						CGA->CGA_TOTEST	:= nPercEst
						CGA->CGA_TOTMUN	:= nPercMun
					EndIf
					
				MsUnlock("CGA")
			EndIf
			
			CGA->(dbSkip())
		EndDo
		
		GrvArqLog(aProdAlt)
	EndIf
	Conout("FIM DE PROCESSAMENTO - AtuPercCGA")
	RpcClearEnv()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvArqLog
Função para gravar o arquivo de Log de execucao da AtuPercCGA.

@author Joao Victor Pellegrini
@since 11/02/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function GrvArqLog(aProdAlt) 

Local nArq := 0
Local nCont := 0
Local cLinha := ""
Local cCamArq := "AtuPercCGAlog.txt"
Local cData := DtoS(Date()) 
Local nTamChave := 0
	
// Verifico se o arquivo existe. se não existir, criar.
If File(cCamArq) 
	nArq := fOpen(cCamArq, FO_READWRITE) 
Else
	nArq := fCreate(cCamArq) 
Endif

If nArq <= 0 
	Return
Else
	fSeek(nArq, 0, FS_END) // Posiciona no fim do arquivo 
Endif

// Pegando tamanho da chave unica da CGA p/ alinhar o LOG.
nTamChave := TamSX3("CGA_NCM")[1] + TamSX3("CGA_EXNCM")[1] + TamSX3("CGA_CODISS")[1] +; 
			   TamSX3("CGA_UF")[1] + TamSX3("CGA_CODMUN")[1] + TamSX3("CGA_CODPRO")[1]

cLinha := "Processamento ATUPERCCGA - Data: " + SubStr(cData, 7, 2) + "/"+ SubStr(cData, 5, 2) + "/" + SubStr(cData, 1, 4) +chr(13)+chr(10)+chr(13)+chr(10)
fWrite(nArq, cLinha, Len(cLinha)) 

cLinha :=  PadR("Chave CGA", nTamChave) + " | " + PadL("Perc.Ant.",TamSX3("CGA_TOTPER")[1]) + " | " + PadL("Perc.Atu",TamSX3("CGA_TOTPER")[1]) + chr(13) + chr(10)
fWrite(nArq, cLinha, Len(cLinha)) 

For nCont := 1 to Len(aProdAlt)
	cLinha := aProdAlt[nCont][1] + " | " + PadL(cValToChar(aProdAlt[nCont][2]), TamSX3("CGA_TOTPER")[1]) + " | " + PadL(cValToChar(aProdAlt[nCont][3]), TamSX3("CGA_TOTPER")[1]) + chr(13) + chr(10) 
   fWrite(nArq, cLinha, Len(cLinha)) 
Next nCont

cLinha := "/" + Replicate("*", Len(cLinha) - 2) + "/"
fWrite(nArq, cLinha, Len(cLinha))

cLinha := chr(13) + chr(10)
fWrite(nArq, cLinha, Len(cLinha))  
   
FClose(nArq) 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RecalPerc
Função para recalcular o percentual total da CGA. Esta função é chamada
ao incluir/alterar/excluir tributos na CGB e pelo botão "recálculo".  

@author Joao Victor Pellegrini
@since 12/02/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RecalPerc(oModel, lCommit)

Local lRet := .T.
Local oGrid := oModel:GetModel("MODEL_CGB")
Local nX := 1
Local dVigIni := ""
Local dVigFim := ""
Local dDataAtu := ddatabase
Local cImposto :=""

Local nTotPer := 0
Local nPercFed := 0
Local nPercEst := 0
Local nPercMun := 0

For nX := 1 to oGrid:Length(.T.) // o .T. desconsidera as linhas deletadas.
	oGrid:GoLine(nX)

	dVigIni := oGrid:GetValue("CGB_DTINIV",nX) 
	dVigFim := oGrid:GetValue("CGB_DTFIMV",nX)
	cImposto:= Alltrim(oGrid:GetValue("CGB_TPTRIB",nX))
	
	If (dVigIni <= dDataAtu .And. (dVigFim >= dDataAtu .Or. AllTrim(dToS(dVigFim)) == ""))    
		
		nTotPer += oGrid:GetValue("CGB_TOTPER",nX)
	
		//Tratamento para pegar valor por ente de tributação - Federal / Estadual / Municipal
		Do Case
			Case cImposto$ "IPI#IOF#PIS#PISIMP#COFINS#COFIMP#$CIDE#II"
				nPercFed += oGrid:GetValue("CGB_TOTPER",nX)
			Case cImposto $ "ICMS"
				nPercEst += oGrid:GetValue("CGB_TOTPER",nX) 
			Case cImposto $ "ISS"
				nPercMun += oGrid:GetValue("CGB_TOTPER",nX) 
		EndCase	
	EndIf
Next nX

If oModel:getOperation() <> 5
	oModel:LoadValue("MODEL_CGA", "CGA_TOTPER" , nTotPer)
	oModel:LoadValue("MODEL_CGA", "CGA_TOTFED" , nPercFed)
	oModel:LoadValue("MODEL_CGA", "CGA_TOTEST" , nPercEst)
	oModel:LoadValue("MODEL_CGA", "CGA_TOTMUN" , nPercMun)
EndIf

oGrid:GoLine(1)

If lCommit
	FWFormCommit(oModel)
Else
	ApMsgAlert(STR0014 + chr(13)+chr(10) + STR0015) // "Recálculo Efetuado com Sucesso." - "Confirme a alteração para efetivar os valores." 
EndIf

Return lRet