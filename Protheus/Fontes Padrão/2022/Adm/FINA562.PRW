#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'FINA562.CH'
#INCLUDE 'FWMVCDEF.CH'


STATIC aValLin	:= {}
STATIC lWhen	:= .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA562
Rateio Juridico do Caixinha
pai/filho/neto em MVC

@author Mauricio Pequim Jr
@since 21/02/2013
@version P10
/*/
//-------------------------------------------------------------------
Function FINA562()
Local oBrowse
Local lIntSJURI := SuperGetMv("MV_JURXFIN",.T.,.F.)  
Local lDefTop 	:= IfDefTopCTB()

__nOper := 0

If !lDefTop
	Help("  ",1,"FIN562TOP",,STR0001,1,0) //"Função disponível apenas para ambientes TopConnect"
	Return
EndIf

If !lIntSJURI
	Help("  ",1,"FIN562INT",,STR0002,1,0)//"Para utilização desta rotina, a integração Financeiro x Jurídico deve estar ativada. Por favor, verifique o parâmetro MV_JURXFIN"
	Return
EndIf

If FWHASMVC()
	dbSelectArea('SEU')
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'SEU' )
	oBrowse:SetDescription( 'Rateio Juridico' )
	oBrowse:AddLegend( "EU_TOTRAT == 0 "							, "GREEN"	, 'Sem Rateio'	)
	oBrowse:AddLegend( "EU_TOTRAT > 0 .AND. EU_TOTRAT < EU_VALOR"	, "YELLOW"	, 'Rateio Parcial'	)
	oBrowse:AddLegend( "EU_TOTRAT == EU_VALOR"						, "RED"	   	, 'Rateio Completo'	)
	oBrowse:SetFilterDefault( "EU_RATJUR == '1'" )		
	oBrowse:Activate()
Else
	Help(" ",1,"FIN562MVC",,STR0003,1,0) //"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "
EndIf

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  Action 'PesqBrw'             	OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.FINA562'	 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Ratear'     Action 'VIEWDEF.FINA562'	 	OPERATION 4 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSEU := FWFormStruct( 1, 'SEU', /*bAvalCampo*/, /*lViewUsado*/ )//AF562Struct('FNU')
Local oStruFJ4 := FWFormStruct( 1, 'FJ4', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

//Gatilhos
oStruFJ4:AddTrigger( "FJ4_VALOR"  	, "FJ4_PERC"  	, {|| .T. }  , {|| FJ4Trig01("FJ4_PERC") }  )
oStruFJ4:AddTrigger( "FJ4_PERC"  	, "FJ4_VALOR"  	, {|| .T. }  , {|| FJ4Trig01("FJ4_VALOR") }  )
oStruFJ4:AddTrigger( "FJ4_FATJUR"  	, "FJ4_FATJUR"  , {|| .T. }  , {|| FJ4Trig02() }  )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FINA562', /*bPreValidacao*/, /*bPosValidacao*/,{|oModel| Fin562GRV(oModel) } /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SEUMASTER', /*cOwner*/, oStruSEU , {|| .F. } /*bPreVal*/)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'FJ4DETAIL', 'SEUMASTER', oStruFJ4, {|oModel| FJ4VlLiPre(oModel)}/*bLinePre*/, {|oModel| Fin562LiOK(oModel)}/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*{|x,y| MyLoadGrid(x,y)}*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FJ4DETAIL', { { 'FJ4_FILIAL', 'xFilial( "FJ4" )' }, { 'FJ4_NUM' , 'EU_NUM'  } } , FJ4->( IndexKey( 1 ) )  )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'FJ4DETAIL' ):SetUniqueLine( { 'FJ4_SEQ' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( AllTrim(STR0016) )//'Caixinha - Rateio Juridico'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'SEUMASTER' ):SetDescription( AllTrim(STR0017) ) //'Caixinha - Dados da Despesa'
oModel:GetModel( 'FJ4DETAIL' ):SetDescription( AllTrim(STR0018) ) //'Caixinha - Dados do Rateio Juridico'

oModel:AddCalc( 'FJ4CALC1', 'SEUMASTER', 'FJ4DETAIL', 'FJ4_VALOR', 'FJ4__TOTRAT', 'SUM',,,AllTrim(STR0019) ) 
oModel:AddCalc( 'FJ4CALC1', 'SEUMASTER', 'FJ4DETAIL', 'FJ4_PERC' , 'FJ4__TOTPER', 'SUM',,,AllTrim(STR0020) ) 

oModel:SetVldActivate({|oModel| FJ4VlPre(oModel)})

Return oModel                                   


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruSEU := FWFormStruct( 2, 'SEU' )
Local oStruFJ4 := FWFormStruct( 2, 'FJ4' )

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FINA562' )
Local oView                               
Local oCalc1 

// Remove campos da estrutura
oStruFJ4:RemoveField( 'FJ4_NUM' )
oStruFJ4:RemoveField( 'FJ4_SEQJUR' )

// Cria o objeto de View
oView := FWFormView():New()

// Cria o objeto de Estrutura
oCalc1 := FWCalcStruct( oModel:GetModel('FJ4CALC1') )
//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddField( 'VIEW_CALC', oCalc1, 'FJ4CALC1' )

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_SEU', oStruSEU, 'SEUMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FJ4', oStruFJ4, 'FJ4DETAIL' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_FJ4', 'FJ4_SEQ' 	)

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 35 )
oView:CreateHorizontalBox( 'INFERIOR' , 55 )
oView:CreateHorizontalBox( 'TOTAL'    , 10 )

// Cria Folder na view
oView:CreateFolder( 'PASTA_SUPERIOR' ,'SUPERIOR' )
oView:CreateFolder( 'PASTA_INFERIOR','INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'PASTA_SUPERIOR'    , 'ABA_CAIXINHA'    , AllTrim(STR0017) )
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_JURIDICO'    , AllTrim(STR0018) )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'DESPESA' , 100,,, 'PASTA_SUPERIOR', 'ABA_CAIXINHA' )
oView:CreateHorizontalBox( 'RATEIO'  , 100,,, 'PASTA_INFERIOR', 'ABA_JURIDICO' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SEU', 'DESPESA'   )
oView:SetOwnerView( 'VIEW_FJ4', 'RATEIO'    )
oView:SetOwnerView( 'VIEW_CALC', 'TOTAL' )


// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_SEU' )
oView:EnableTitleView( 'VIEW_FJ4' )

Return oView


/*
Valida Cliente
*/
Function FIN562Cli()

Local lRet 			:= .F.
Local aAreaSA1 		:= SA1->(GetArea())
Local oModel  		:= FWModelActive()
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local cCliente 		:= oModelFJ4:GetValue("FJ4_CLIENT")
Local cLoja 		:= oModelFJ4:GetValue("FJ4_LOJA")
Local cCaso 		:= oModelFJ4:GetValue("FJ4_CASO")

If !Empty(cCliente) 
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+cCliente+IIf(!Empty(cLoja),cLoja,"")))
		lRet := .T.
	Endif
Endif 

If lRet 
	lRet := JAEXECPLAN('FJ4DETAIL', '', 'FJ4_CLIENT', 'FJ4_LOJA', 'FJ4_CASO', 'FJ4_CLIENT')
	Help(" ",1,"F562VLCAS",,STR0005,1,1)//'Cliente inválido' 
EndIf

If lRet .And. (!Empty(cCliente) .and. !Empty(cLoja) .and. !Empty(cCaso))
	lRet := JAVLDCPLAN("FJ4DETAIL", "FJ4_CLIENT", "FJ4_LOJA", "FJ4_CASO", cCampo,"NVE_LANDSP")
	Help(" ",1,"F562VLCAS",,STR0006,1,1)//'Cliente inválido para este Caso' 
EndIf

RestArea(aAreaSA1)

Return lRet


/*
Controle de edição de campos 
*/
Function Fin562When(cCampo)

Local lRet 			:= .F.
Local lIntSJURI 	:= SuperGetMv("MV_JURXFIN",.T.,.F.)  
Local oModel  		:= FWModelActive()
Local oModelSEU		:= oModel:GetModel("SEUMASTER")
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local cFaturaJur 	:= oModelFJ4:GetValue("FJ4_FATJUR")
Local cNatureza		:= oModelSEU:GetValue("EU_NATUREZ")
Local lNatureza 	:= .F.

Default cCampo := ""

If !lWhen //Desativa bloqueio para edição do sistema
	Return .T.	
EndIf

If !Empty(cCampo)
	SED->(DbSetOrder(1))
	If SED->(MsSeek(xFilial("SED")+cNatureza))
		lNatureza := .T.
	Endif
	
	If lIntSJuri 
		If cFaturaJur == '1'
			If Alltrim(cCampo) $ "FJ4_CLIENT|FJ4_LOJA|FJ4_CASO"
				lRet := .T.
			Endif
		ElseIf cFaturaJur == '2'
			If Alltrim(cCampo) == "FJ4_PARTIC" .and. SED->ED_PARTIC == '1'
				lRet := .T.
			ElseIf Alltrim(cCampo) == "FJ4_ESCRIT" .and. SED->ED_ESCRIT == '1'
				lRet := .T.
			ElseIf Alltrim(cCampo) == "FJ4_GRPJUR" .and. SED->ED_GRPJUR == '1'
				lRet := .T.
			Endif
		Endif
	Endif
Endif

Return lRet


/*
Valida Valor do Rateio
*/    
Function Fin562Vlr()

Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local oModelSEU		:= oModel:GetModel("SEUMASTER")
Local nTotalDesp	:= oModelSEU:GetValue("EU_VALOR")
Local nI 			:= 0
Local nTotRat 		:= 0
Local lRet			:= .T.


For nI := 1 To oModelFJ4:Length()
	oModelFJ4:GoLine( nI )
	If !oModelFJ4:IsDeleted()
		nTotRat += oModelFJ4:GetValue("FJ4_VALOR")		
	EndIf
Next

If nTotRat > nTotalDesp
	lRet := .F.
	Help(" ",1,"FIN562VLR",,STR0007,1,0)//"Rateio maior que o valor da despesa."
EndIf

FWRestRows( aSaveLines )

Return lRet

/*
Valida Percentual do Rateio
*/
Function Fin562Per()

Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local nI 			:= 0
Local nTotPer 		:= 0
Local lRet			:= .T.


For nI := 1 To oModelFJ4:Length()
	oModelFJ4:GoLine( nI )
	If !oModelFJ4:IsDeleted()
		nTotPer += oModelFJ4:GetValue("FJ4_PERC")		
	EndIf
Next

If nTotPer > 100
	lRet := .F.
	Help(" ",1,"FIN562VLR",,STR0008,1,0)//"Percentual do Rateio ultrapassou 100%."
EndIf

FWRestRows( aSaveLines )

Return lRet


/*
Atualizacao apos a gravacao do formulario
*/
Function Fin562GRV()

Local oModel 		:= FWModelActive()
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local nI 			:= 0
Local nTotValor 	:= 0
Local cCodFat		:= ""

For nI := 1 To oModelFJ4:Length()
	oModelFJ4:GoLine( nI )
	If oModelFJ4:IsDeleted() .Or. (oModelFJ4:GetValue("FJ4_FATJUR")<>'1' .And. !Empty(oModelFJ4:GetValue("FJ4_SEQJUR")))
		ExcluiPFS(oModelFJ4:GetValue("FJ4_SEQJUR")) 
	EndIf
Next

//Realiza a gravação do Modelo
FWFormCommit( oModel )


DbSelectArea("FJ4")
FJ4->(DbSetOrder(1))
FJ4->(MsSeek(xFilial("FJ4")+SEU->EU_NUM))
While FJ4->(!Eof()) .And. FJ4->(FJ4_FILIAL+FJ4_NUM) == xFilial("FJ4")+SEU->EU_NUM
	
	nTotValor += FJ4->FJ4_VALOR
	If FJ4->FJ4_FATJUR == '1'
		If !Empty(FJ4->FJ4_SEQJUR)
			dbselectArea("NVY")
			NVY->(dbSetOrder(1))
			If NVY->(dbSeek(xFilial('NVY')+FJ4->FJ4_SEQJUR))
				If !(NVY->NVY_SITUAC == '2'  .Or. !Empty(NVY->NVY_CPREFT))
					GeraPFS(4,FJ4->FJ4_NUM,FJ4->FJ4_SEQ,FJ4->FJ4_CLIENT,FJ4->FJ4_LOJA,FJ4->FJ4_CASO,FJ4->FJ4_PROFIS,NVY->NVY_DATA,NVY->NVY_CMOEDA,FJ4->FJ4_VALOR,FJ4->FJ4_TIPDSP,FJ4->FJ4_DESCRI)
				EndIf
			EndIf
		Else
			cCodFat := GeraPFS(3,FJ4->FJ4_NUM,FJ4->FJ4_SEQ,FJ4->FJ4_CLIENT,FJ4->FJ4_LOJA,FJ4->FJ4_CASO,FJ4->FJ4_PROFIS,,,FJ4->FJ4_VALOR,FJ4->FJ4_TIPDSP,FJ4->FJ4_DESCRI)
			If !Empty(cCodFat)
				RecLock("FJ4",.F.)
				FJ4->FJ4_SEQJUR := cCodFat
				FJ4->(MsUnLock()) 
			EndIf
		EndIf
	EndIf
	FJ4->(DbSkip())	
EndDo

dbSelectArea("SEU")
RecLock("SEU",.F.)
SEU->EU_TOTRAT := nTotValor
SEU->(MsUnLock()) 

Return .T.
                                   

/*
Valida linha de rateio
*/
Function Fin562LiOK()

Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local oModelSEU		:= oModel:GetModel("SEUMASTER")
Local cDespCli 		:= oModelFJ4:GetValue("FJ4_FATJUR")
Local cCliente 		:= oModelFJ4:GetValue("FJ4_CLIENT")
Local cLoja 		:= oModelFJ4:GetValue("FJ4_LOJA")
Local cCaso 		:= oModelFJ4:GetValue("FJ4_CASO")
Local cEscritorio	:= oModelFJ4:GetValue("FJ4_ESCRIT")
Local cGrpJuri		:= oModelFJ4:GetValue("FJ4_GRPJUR")
Local cNatureza		:= oModelSEU:GetValue("EU_NATUREZ")
Local cProfis		:= oModelFJ4:GetValue("FJ4_PROFIS")
Local cTpDesp		:= oModelFJ4:GetValue("FJ4_TIPDSP")
Local cDescri		:= oModelFJ4:GetValue("FJ4_DESCRI")
Local lRet 			:= .T.
If cDespCli == '1' 
	If Empty(cCliente) .OR. Empty(cLoja) .OR. Empty(cCaso) .OR. Empty(cProfis) .OR. Empty(cTpDesp) .OR. Empty(cDescri)
		Help(" ",1,"F562DJUR1",,STR0009+CRLF+;
 	 		    STR0021+CRLF+STR0022+CRLF+STR0023+CRLF+STR0024+CRLF+STR0025+CRLF+STR0028,1,1) //'Quando a despesa juridica for reembolsável do cliente, é obrigatório o preenchimento dos campos abaixo:'
			//'Cliente Jur.' //'Loja Cliente' //'Caso'  //'Tipo Despesa' //'Prof. Favorec'  //Descrição
		lRet := .F.						 	 	 	
	Endif
Else
	dbSelectArea("SED")
	SED->(dbSetOrder(1))
	If MsSeek(xFilial("SED")+cNatureza)
		If SED->ED_ESCRIT == '1'
			If Empty(cEscritorio)		
				Help(" ",1,"F562DJUR2",,STR0010+CRLF+STR0026,1,1)//'Devido a configuração da Natureza o campo abaixo tem seu preenchimento como obrigatório.' //'Escritório'
				lRet := .F.
    		ElseIf SED->ED_GRPJUR == '1' .and. Empty(cGrpJuri)
				Help(" ",1,"F562DJUR3",,STR0010+CRLF+STR0027,1,1)//'Devido a configuração da Natureza o campo abaixo tem seu preenchimento como obrigatório.' //'Grupo Jurid.'
				lRet := .F.
			Endif
		Endif
	Endif
Endif


FWRestRows( aSaveLines )

Return lRet


/*
Gatilho de Valor e Percentual de Rateio
*/
Function FJ4Trig01(cCampo)

Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local oModelSEU		:= oModel:GetModel("SEUMASTER")
Local nTotalDesp	:= oModelSEU:GetValue("EU_VALOR")
Local nValorRat 	:= oModelFJ4:GetValue("FJ4_VALOR")
Local nPercRat  	:= oModelFJ4:GetValue("FJ4_PERC")
Local nRet

If nTotalDesp <> 0		
	If cCampo == "FJ4_VALOR"
		nValorRat := nPercRat / 100 * nTotalDesp
		nRet := nValorRat 
	ElseIf cCampo == "FJ4_PERC" 
		nPercRat := nValorRat / nTotalDesp * 100
		nRet := nPercRat		
	EndIf
EndIf

FWRestRows( aSaveLines )

Return nRet


/*
Gatilho de Valor e Percentual de Rateio
*/
Function FJ4Trig02()
                                     	
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local cDespCli 		:= oModelFJ4:GetValue("FJ4_FATJUR")

lWhen	:= .F.

If cDespCli == '1' 
	oModelFJ4:LoadValue( "FJ4_ESCRIT" , "" )
	oModelFJ4:LoadValue( "FJ4_GRPJUR" , "" )  
ElseIf cDespCli == '2'
 	oModelFJ4:LoadValue( "FJ4_CLIENT" , "" )
	oModelFJ4:LoadValue( "FJ4_LOJA"   , "" )      
	oModelFJ4:LoadValue( "FJ4_CASO"   , "" )   
EndIf

lWhen := .T.

FWRestRows( aSaveLines )

Return .T.    


/*
Validação do Caso
*/
Function Fin562Caso()

Local lRet    	:= .T.
Local oModel  	:= FWModelActive()
Local oModelFJ4	:= oModel:GetModel("FJ4DETAIL")
Local cClient 	:= oModelFJ4:GetValue("FJ4_CLIENT")
Local cLoja	  	:= oModelFJ4:GetValue("FJ4_LOJA")
Local cCaso   	:= oModelFJ4:GetValue("FJ4_CASO")


If lRet 
	lRet := JAEXECPLAN('FJ4DETAIL', '', 'FJ4_CLIENT', 'FJ4_LOJA', 'FJ4_CASO', 'FJ4_CASO')
	Help(" ",1,"F562VLCAS",,STR0011,1,1)//'Caso inválido.'
EndIf

If lRet .And. (!Empty(cClient) .and. !Empty(cLoja) .and. !Empty(cCaso))
	lRet := JAVLDCPLAN("FJ4DETAIL", "FJ4_CLIENT", "FJ4_LOJA", "FJ4_CASO", "FJ4_CASO","NVE_LANDSP")
	Help(" ",1,"F562VLCAS",,STR0011,1,1)
EndIf

Return lRet


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fin562Rd0

Validaç]ão do campo FJ4_PROFIS

@author    Mauricio Pequim Jr
@version   11.80
@since     12/03/13

@return ExpL1 = Retorno lógico para as validações realizadas

/*/
//-----------------------------------------------------------------------------------------------------

Function Fin562Rd0()

Local lRet	:= .F.
Local oModel  	:= FWModelActive()
Local oModelFJ4	:= oModel:GetModel("FJ4DETAIL")
Local cCodigo 	:= oModelFJ4:GetValue("FJ4_PROFIS")

RD0->(dbSetOrder(9))

If !Empty(cCodigo) .and. RD0->(MsSeek(xFilial("RD0")+cCodigo)) .and. Empty(RD0->RD0_DTADEM)
	lRet := .T.
Else
	Help(" ",1,"F560PRFJUR",,STR0012+CRLF+STR0013,1,0)	//'Código do profissional favorecido inválido.'###'Verifique o cadastro de participantes.'
Endif

Return lRet




/*
Valida se pode alterar a linha
*/
Function FJ4VlPre()

aValLin := {}

Return .T.  


/*
Valida se pode alterar a linha
*/
Function FJ4VlLiPre()

Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local oModelFJ4		:= oModel:GetModel("FJ4DETAIL")
Local nOperation 	:= oModel:GetOperation()
Local cSeq 			:= oModelFJ4:GetValue("FJ4_SEQ")
Local cSeqJur 		:= oModelFJ4:GetValue("FJ4_SEQJUR")
Local aDesp			:= {}
Local nPos
Local lRet			:= .T.			


If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE
	
	nPos := aScan( aValLin, {|x| x[ 1 ] ==  cSeq } ) 
	If nPos <= 0
		If !Empty(cSeqJur)
			aDesp := GetAdvFVal("NVY",{"NVY_SITUAC", "NVY_CPREFT"},xFilial("NVY")+cSeqJur,1,{"",""})
			If (aDesp[1] == '2'  .Or. !Empty(aDesp[2]))
				aAdd(aValLin,{cSeq,.F.})
			Else
				aAdd(aValLin,{cSeq,.T.})
			EndIf
		Else
			aAdd(aValLin,{cSeq,.T.})
		EndIf
		nPos := Len(aValLin)
	EndIf    
	
	If !aValLin[nPos,2] 
		Help(" ",1,"F562FTJUR",,STR0014,1,1)//'Não é permitida a alteração de item que já possui pré-fatura.'
		If !IsBlind()
			MsgAlert(STR0014)
		EndIf
	EndIf
    
	lRet := aValLin[nPos,2]  

EndIf 
	
Return lRet


/*
Valida campo
*/
Function F562VLCLI(cCampo)
Local lRet    	:= .T.
Local oModel  	:= FWModelActive()
Local oModelFJ4	:= oModel:GetModel("FJ4DETAIL")
Local cClient 	:= oModelFJ4:GetValue("FJ4_CLIENT")
Local cLoja	  	:= oModelFJ4:GetValue("FJ4_LOJA")
Local cCaso   	:= oModelFJ4:GetValue("FJ4_CASO")

If !Empty(cClient) .and. !Empty(cLoja) .and. !Empty(cCaso)
	lRet := JAVLDCPLAN("FJ4DETAIL", "FJ4_CLIENT", "FJ4_LOJA", "FJ4_CASO", cCampo,"NVE_LANDSP")
EndIf

If !lRet
	Help(" ",1,"F562FTJUR",,STR0015,1,1) //'Informação inválida.'
EndIf

Return lRet 
                        

/*
Grava Despesa no SIGAPFS
*/
Function GeraPFS(nOper,cNum,cSeq,cCli,cLoja,cCaso,cProf,dData,cMoeda,nValor,cTpDesp,cDescri) 

Local cCodRet := ""
Local aCampos := {}
Local cDcDesp := GetAdvFVal("NRH","NRH_DESC",xFilial("NRH")+cTpDesp,1,'')
//Local cSigla  := GetAdvFVal("RD0","RD0_SIGLA",xFilial("RD0")+cProf,1,'') 
Local cCobrar := FinCobrar(cCli, cLoja, cCaso, cTpDesp)

DEFAULT dData  := dDataBase
DEFAULT cMoeda := '01'
DEFAULT cSeq   := ""
DEFAULT cDescri:= "."

aAdd( aCampos, { 'NVY_CCLIEN'	, cCli 			} ) 			//Cliente
aAdd( aCampos, { 'NVY_CLOJA' 	, cLoja 		} )				//Loja
aAdd( aCampos, { 'NVY_CCASO' 	, cCaso 		} )				//Caso
aAdd( aCampos, { 'NVY_SIGLA' 	, cProf 		} )				//Sigla
aAdd( aCampos, { 'NVY_DATA' 	, dData 		} )				//Data
aAdd( aCampos, { 'NVY_CMOEDA' 	, cMoeda 		} )				//Moeda???
aAdd( aCampos, { 'NVY_VALOR' 	, nValor 		} )				//Valor
aAdd( aCampos, { 'NVY_CTPDSP' 	, cTpDesp 		} )				//Tp. Despesa
aAdd( aCampos, { 'NVY_DTPDSP' 	, cDcDesp 		} )				//Desc. Tp. Despesa
aAdd( aCampos, { 'NVY_COBRAR' 	, cCobrar 		} )				//Cobrar - Sim
aAdd( aCampos, { 'NVY_SITUAC' 	, '1' 			} )             //Sitacao - Pendente
aAdd( aCampos, { 'NVY_QTD' 		, 1 			} )             //Quantidade - Um 
aAdd( aCampos, { 'NVY_DESDIV' 	, '2' 			} )             //Desp. Dividida  - Nao
aAdd( aCampos, { 'NVY_DESCRI' 	, cDescri 		} )  		 	//Descricao 
If cCobrar == '2'
	aAdd( aCampos, { 'NVY_OBSCOB' 	, "Não será cobrado" } )  		 	//Descricao 
EndIf

If GravaDesp( 'NVY', aCampos, nOper )
	cCodRet := NVY->NVY_COD
EndIf

Return cCodRet


//-------------------------------------------------------------------
// Grava Despesa
//-------------------------------------------------------------------
Static Function GravaDesp( cAlias, aCampos, nOper )
Local oModel, oAux, oStruct
Local nI 	:= 0
Local nPos 	:= 0
Local lRet 	:= .T.
Local aAux 	:= {}

dbSelectArea( cAlias )
dbSetOrder( 1 )

oModel := FWLoadModel( "JURA049" )

// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
oModel:SetOperation( nOper )

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
oModel:Activate()

If nOper == 5
	
	lRet := oModel:CommitData()
	
Else
	
	// Instanciamos apenas referentes às dados
	oAux := oModel:GetModel( cAlias + 'MASTER' )
	
	// Obtemos a estrutura de dados
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	For nI := 1 To Len( aCampos )
		// Verifica se os campos passados existem na estrutura do modelo
		If ( nPos := aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(aCampos[nI][1]) } ) ) > 0
			// È feita a atribuição do dado ao campo do Model
			If !( lAux := oModel:SetValue( cAlias + 'MASTER', aCampos[nI][1], aCampos[nI][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
				// o método SetValue retorna .F.
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nI
	If lRet
		// Faz-se a validação dos dados, note que diferentemente das tradicionais
		// "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If ( lRet := oModel:VldData() )
			// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
			oModel:CommitData()
		EndIf
	EndIf
EndIf

If !lRet
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()
	// A estrutura do vetor com erro é:
	// [1] identificador (ID) do formulário de origem
	// [2] identificador (ID) do campo de origem
	// [3] identificador (ID) do formulário de erro
	// [4] identificador (ID) do campo de erro
	// [5] identificador (ID) do erro
	// [6] mensagem do erro
	// [7] mensagem da solução
	// [8] Valor atribuído
	// [9] Valor anterior
	AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
	AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
	AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
	AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
	AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
	AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
	AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
	AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
	AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )
	MostraErro()
EndIf

// Desativamos o Model
oModel:DeActivate()

Return lRet 

/*
Exclui Despesa no SIGAPFS
*/
Function ExcluiPFS(cCodDesp) 

Local aCampos := {}
Local lRet

dbselectArea("NVY")
NVY->(dbSetOrder(1))
If NVY->(dbSeek(xFilial('NVY')+cCodDesp)) 	

	lRet := GravaDesp( 'NVY', aCampos, 5 )
	
EndIf

Return lRet 

/*
Verifica se a despesa será cobrada
*/
Static Function FinCobrar(cClient, cLoja, cCaso, cCtpDsp)

Local cContrato := ''
Local xValue	:= '2'
Local aArea 	:= GetArea()
Local aAreaNTK	:= NTK->(GetArea())
Local aAreaNUC	:= NUC->(GetArea())
Local aAreaNRH	:= NRH->(GetArea())
Local aNUT      := {}
Local nNUT      := 0  
Local lAchou    := .F.


//Verifica todos os contratos amarrados ao caso
NUT->(DbSetOrder(2))   //NUT_FILIAL+NUT_CCLIEN+NUT_CLOJA+NUT_CCASO
NUT->(DbSeek(xFilial("NUT") + cClient + cLoja + cCaso))

While NUT->(  NUT_CCLIEN+NUT_CLOJA+NUT_CCASO ) ==   cClient + cLoja + cCaso   .and. ! NUT->(eof() )
	aadd(aNUT,NUT->NUT_CCONTR)
	NUT->(dbskip())
Enddo

If !Empty(aNUT)
	for nNUT := 1 to len(aNUT)
		cContrato := aNUT[nNUT]
		//Varre todos os contrato vinculados ao caso e verifica se cobra a despesa
		NT0->(DbSetOrder(1))   //CONTRATO
		NT0->(DbSeek(xFilial("NT0")+ cContrato ))
		
		If NT0->NT0_DESPES == '1'   //COBRAR DESPESA
			NTK->(DbSetOrder(1)) // NTK_FILIAL+NTK_CCONTR+NTK_CTPDSP
			lAchou   := NTK->(DbSeek(xFilial("NTK")+ cContrato + cCtpDsp))

			if lachou
				xValue   := "2" // Nao Cobravel
			Else
				NRH->(DbSetOrder(1))   
				NRH->(DbSeek(xFilial("NRH") + cCtpDsp))
				xValue := NRH->NRH_COBRAR
			Endif
			Exit
		Endif
		
	Next
	
EndIf


RestArea(aAreaNTK)
RestArea(aAreaNUC)
RestArea(aAreaNRH)
RestArea(aArea)

Return xValue



