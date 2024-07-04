#INCLUDE "JURA060.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA060
Valores do Índice

@author Juliana Iwayama Velho
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA060()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) 
oBrowse:SetAlias( "NW6" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NW6" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Juliana Iwayama Velho
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	:= {}
Local aInd    	:= {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } )  //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA060", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA060", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA060", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA060", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.JURA060", 0, 8, 0, NIL } ) //"Imprimir"

	aAdd( aRotina, { STR0012, aInd   , 0, 1, 0, .T. } ) //"Obter atualizações TOTVS"
	aAdd( aInd,    { STR0013, "Processa({|| JA216AtuAut(NW6->NW6_CINDIC) })" , 0, 4, 0, NIL } ) //"Atualiza índice selecionado"
	aAdd( aInd,    { STR0014, "Processa({|| JA216AtuAut() })" , 0, 4, 0, NIL } ) //"Atualiza todos"


Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Valores de Índice

@author Juliana Iwayama Velho
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA060" )
Local oStruct := FWFormStruct( 2, "NW6" )

JurSetAgrp( "NW6",, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA060", oStruct, "NW6MASTER"  )
oView:CreateHorizontalBox( "NW6MASTER" , 100 )
oView:SetOwnerView( "JURA060", "NW6MASTER" )

oView:SetDescription( STR0001 )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Valores de Índice

@author Juliana Iwayama Velho
@since 06/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel  := NIL
Local oStruct := FWFormStruct( 1, "NW6" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA060", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NW6MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) 

oModel:GetModel( "NW6MASTER" ):SetDescription( STR0009 )

JurSetRules( oModel, "NW6MASTER",, "NW6" )

Return oModel 




//-------------------------------------------------------------------
/*/{Protheus.doc} JA060Vlr()
Rotina para validar o campo NW6_PVALOR decimal ponto fixo
A funçao retorna um decimal com separador por virgula

@param cDtValor  Valor do indice 
@author Luciano Pereira dos Santos
@since 12/01/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA060Vlr()           
Local cValor   := ""
Local cVlrAnt  := ""
Local oModel   := FWModelActive()
Local oStru    := oModel:GetModel("JURA060")
Local aValid   := {'-', '0','1','2','3','4','5','6','7','8','9',',','.'}
Local lret     := .T.
Local nContp   := 0 //Contador de pontos
Local nContv   := 0 //Contador de vírgulas
Local nPosv    := 0 //Posição da vígula
Local nPosp    := 0 //Posição da ponto
Local i        := 1

	cVlrAnt:= oModel:GetValue("NW6MASTER","NW6_PVALOR")
	cValor := cVlrAnt

	//verifica se o valor digitado contem apenas numeros , '.' e ','                                                                         
	For i:=1 to len(alltrim(cValor))                                                                   
		If (aScan(aValid,substr(cValor,i,1)) == 0)
			Help( ,, 'HELP',, STR0010, 1, 0)
			lret  := .F.
			Exit
		Endif
	Next

	// faz a validação quanto ao padrão da formatação das casas decimais   
	If lret  == .T.    
		For i:=1 to len(alltrim(cValor))
			Do Case
				Case (substr(cValor,i,1)) == '.'                                             
					If ((nPosp+1) <> i) .and. ((nPosv+1) <> i) .and. !((nContp>=1) .and. (nContv>=1) .and. (nPosv < i))
						nPosp := i
						nContp++
					Else
						Help( ,, 'HELP',, STR0010, 1, 0) //"Informe um número decimal válido!" 
						lret  := .F.
						Exit  
					Endif 
				Case (substr(cValor,i,1)) == ','                          
					If ((nPosv+1) <> i)  .and. ((nPosp+1) <> i) .and. !((nContv>=1) .and. (nContp>=1) .and. (nPosp < i))
						nPosv := i
						nContv++
					Else
						Help( ,, 'HELP',, STR0010, 1, 0) //"Informe um número decimal válido!" 
						lret  := .F.
						Exit  
					Endif 
			EndCase 
		Next

		// faz a converção para gravar corretamente no banco de dados tirando os separadores de milhares
		Do Case
			Case nPosv == len(alltrim(cValor))
				cValor := StrTran ((cValor),',','')
			Case nPosp == len(alltrim(cValor))
				cValor := StrTran ((cValor),'.','')
			Case (nContp <= 1) .and. (nContv <= 1)
				If nPosp < nPosv
					cValor := StrTran ((cValor),'.','')
				EndIf
				If nPosv < nPosp 
					cValor := StrTran ((cValor),',','')
				EndIf
			Case (nContv >1) .and. (nContp <= 1)   
				cValor := StrTran ((cValor),',','')
			Case (nContp >1) .and. (nContv <= 1)   
				cValor := StrTran ((cValor),'.','')
			OtherWise      
				Help( ,, 'HELP',, STR0010, 1, 0) //"Informe um número decimal válido!" 
				lret  := .F.
		EndCase
	
	EndIf

	// faz a validação quanto a precisão das casas decimais
	If (lret  == .T.)
		nPosv   :=0
		nContv  :=0
		For i:=1 to len(alltrim(cValor))                                                                   
			If (substr(cValor,i,1) $ ',|.')
				nPosv := i
			EndIf 
		Next

		If nPosv >0
			For i := 1 to (len(alltrim(cValor)))- nPosv
				nContv++
			Next
		EndIf

		If nContv > 11 
			Help( ,, 'HELP',, STR0011, 1, 0)  
			lret  := .F.
		EndIf  
	EndIf


	// verifica se existe zeros a esquerda e faz o tratamento
	If (lret  == .T.)
		nPosv   :=0
		nContv  :=0
		For i:=1 to len(alltrim(cValor))                                                                   
			If (substr(cValor,i,1) $ ',|.')
				nPosv := i
			EndIf 
		Next
		If (nPosv > 1) .and. ((substr(cValor,1,1))=="0")
			cValor := alltrim(str(val((substr(cValor,1,nPosv-1)))))+(substr(cValor,nPosv,len(cValor)-nPosv-1))
		EndIf

	EndIf

	If (lret  == .T.) .and. (cVlrAnt <> cVAlor)  
		oModel:LoadValue("NW6MASTER","NW6_PVALOR",cVAlor)
	EndIf

Return (lret)



