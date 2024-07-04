#INCLUDE "FINA685A.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA685
Conferencia das Faturas de prestacao de servico contra o que foi
solicitado na viagem.
Tela de Digitacao da Conferencias

@author Alexandre Circenis
@since 22/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function FINA685A()

Return

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFLQ := FWFormStruct( 1, 'FLQ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFL6 := FWFormStruct( 1, 'FL6', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFLU := FWFormStruct( 1, 'FLU', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FINA685A', /*bPreValidacao*/, /*bPosValidacao*/, {|oObj|FN685ACM( oObj )}/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FLQMASTER', /*cOwner*/, oStruFLQ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
//oModel:AddGrid( 'FL6DETAIL', 'FLQMASTER', oStruFL6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//Exemplo de com Definicao do bloco de Carga
oModel:AddGrid( 'FL6DETAIL', 'FLQMASTER', oStruFL6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/  )

oModel:AddGrid( 'FLUDETAIL', 'FL6DETAIL', oStruFLU, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//Exemplo de com Definicao do bloco de Pre-Validacao
//oModel:AddGrid( 'FLCDETAIL', 'FL6DETAIL', oStruFLC, { |oMdlG,nLine,cAcao,cCampo| COMP023LPRE( oMdlG, nLine, cAcao, cCampo ) }, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FLQMASTER', { { 'FLQ_FILIAL', 'xFilial( "FLQ" )' } } , FLQ->( IndexKey( 1 ) )  )
oModel:SetRelation( 'FL6DETAIL', { { 'FL6_FILIAL', 'xFilial( "FL6" )' } } , FL6->( IndexKey( 1 ) )  )
oModel:SetRelation( 'FLUDETAIL', { { 'FLU_FILIAL', 'xFilial( "FLU" )' },{'FLU_VIAGEM','FL6_VIAGEM'},{'FLU_ITEM','FL6_ITEM'} } , FLU->( IndexKey( 1 ) )  )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'FL6DETAIL' ):SetUniqueLine( { 'FL6_MUSICA' } )
//oModel:GetModel( 'FLCDETAIL' ):SetUniqueLine( { 'FLC_INTER'  } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Modelo de Conferencia de Faturas'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FLQMASTER' ):SetDescription( STR0002 ) //'Dados da Fatura'
oModel:GetModel( 'FL6DETAIL' ):SetDescription( STR0003  ) //'Dados do Pedido'
oModel:GetModel( 'FLUDETAIL' ):SetDescription( STR0004  ) //'Dados dos Passageiros do Pedido'

//Desabilita edicao de campos		aqui kco
oStruFLQ:SetProperty( 'FLQ_FORNEC' , MODEL_FIELD_WHEN, {|| .F. })
oStruFLQ:SetProperty( 'FLQ_LOJA', MODEL_FIELD_WHEN,{|| .F. })

// Nao Permite Incluir, Alterar ou Excluir linhas na formgrid
//oModel:GetModel( 'FLCDETAIL' ):SetNoInsertLine()
//oModel:GetModel( 'FLCDETAIL' ):SetNoUpdateLine()
//oModel:GetModel( 'FLCDETAIL' ):SetNoDeleteLine()

oModel:GetModel( 'FL6DETAIL' ):SetOnlyQuery(.T.)
oModel:GetModel( 'FLUDETAIL' ):SetOnlyQuery(.T.)

oModel:SetActivate( {|oModel| F685ALoad(oModel) } )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruFLQ := FWFormStruct( 2, 'FLQ' )    
// Cria as estruturas dsomente com os campos desejados
Local oStruFL6 := FWFormStruct( 2, 'FL6',{|cCampo| Alltrim(cCampo) $ "FL6_VIAGEM#FL6_ITEM#FL6_IDRESE#FL6_TARPAX#FL6_TAXPAX#FL6_TAXSER#FL6_TOTAL#FL6_VCONFE#FL6_VINFOR#FL6_STATUS"} )
Local oStruFLU := FWFormStruct( 2, 'FLU',{|cCampo| Alltrim(cCampo) $ "FLU_NOME#FLU_PARTIC#FLU_VCONFE#FLU_VINFOR"} )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FINA685A' )
Local oView
Local lCont := .T.
//Define os campos que não devem ser alterados
oStruFL6:SetProperty( 'FL6_VIAGEM' , MVC_VIEW_CANCHANGE,.F.)
oStruFL6:SetProperty( 'FL6_ITEM' , MVC_VIEW_CANCHANGE,.F.)
oStruFL6:SetProperty( 'FL6_IDRESE' , MVC_VIEW_CANCHANGE,.F.)
oStruFL6:SetProperty( 'FL6_TARPAX' , MVC_VIEW_CANCHANGE,.F.)
oStruFL6:SetProperty( 'FL6_TAXPAX' , MVC_VIEW_CANCHANGE,.F.)
oStruFL6:SetProperty( 'FL6_TOTAL' , MVC_VIEW_CANCHANGE,.F.)
oStruFL6:SetProperty( 'FL6_VIAGEM' , MVC_VIEW_CANCHANGE,.F.)

oStruFLU:SetProperty( 'FLU_NOME' , MVC_VIEW_CANCHANGE,.F.)
oStruFLU:SetProperty( 'FLU_PARTIC' , MVC_VIEW_CANCHANGE,.F.)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FLQ', oStruFLQ, 'FLQMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FL6', oStruFL6, 'FL6DETAIL' )
oView:AddGrid(  'VIEW_FLU', oStruFLU, 'FLUDETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' , 40 )
oView:CreateHorizontalBox( 'MEIO'   , 30 )
oView:CreateHorizontalBox( 'EMBAIXO', 30 )

// Criar "box" vertical para receber algum elemento da view
//oView:CreateVerticalBox( 'EMBAIXOESQ', 80, 'EMBAIXO' )
//oView:CreateVerticalBox( 'EMBAIXODIR', 20, 'EMBAIXO' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FLQ', 'EMCIMA'   )
oView:SetOwnerView( 'VIEW_FL6', 'MEIO'     )
oView:SetOwnerView( 'VIEW_FLU', 'EMBAIXO'  )
//oView:SetOwnerView( 'VIEW_FLC', 'EMBAIXOESQ'  )

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_FLQ' )
oView:EnableTitleView( 'VIEW_FL6', STR0005, RGB( 224, 30, 43 )  ) //"Reservas"
oView:EnableTitleView( 'VIEW_FLU', STR0006, 0 ) //"Passageiros"

//oModel:GetModel( 'FL6DETAIL' ):SetNoInsertLine( .T. )
oModel:GetModel( 'FL6DETAIL' ):SetNoDeleteLine( .T. )

//oModel:GetModel( 'FLUDETAIL' ):SetNoInsertLine( .T. )
oModel:GetModel( 'FLUDETAIL' ):SetNoDeleteLine( .T. )

// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_FL6', "ENABLEDGRIDDETAIL", { 60 } )
//oView:SetViewProperty( 'VIEW_FLC', "ENABLEDGRIDDETAIL", { 60 } )

// Acrescenta um objeto externo ao View do MVC
// AddOtherObject(cFormModelID,bBloco)
// cIDObject - Id
// bBloco    - Bloco chamado evera ser usado para se criaros objetos de tela externos ao MVC.

//oView:AddOtherObject("OTHER_PANEL", {|oPanel| COMP23BUT(oPanel)})
//oView:SetOwnerView("OTHER_PANEL",'EMBAIXODIR')

//Remove os campos criados para a conferencia de servicos II (FINA686)
oStruFLQ:RemoveField( 'FLQ_NATUR' )
oStruFLQ:RemoveField( 'FLQ_TIPO'  )
oStruFLQ:RemoveField( 'FLQ_PEDIDO')
oStruFLQ:RemoveField( 'FLQ_TPPGTO')
oStruFLQ:RemoveField( 'FLQ_COND'  )

// Criar novo botao na barra de botoes
oView:AddUserButton( STR0007, 'CLIPS', { |oView| FN685ACOTOT() } ) //'Confirma Total'

oView:BAFTERVIEWACTIVATE := {||lCont := FNA685INFLQ(oModel)}
oView:SetCloseOnOk({||.T.})

Return oView                                           

//-------------------------------------------------------------------
Function FNA685VFL6()

Local lRet 		    := .T.
Local oModel        := FWModelActive()
Local oModelFLQ     := Nil
Local oModelFL6     := oModel:GetModel("FL6DETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX			:= 0
Local oView			:= FWViewActive()
Local nTotal        := 0
Local oModelFLU     := oModel:GetModel("FLUDETAIL")
Local nTotalFLU     := 0

If  oModel:cID $  "FINA685A|FINA686A"
	oModelFLQ     := oModel:GetModel("FLQMASTER")
EndIf

For nX := 1 To oModelFLU:Length()
	oModelFLU:GoLine( nX )
	nTotalFLU += oModelFLU:GetValue("FLU_VINFOR")
Next

if oModelFL6:GetValue("FL6_VINFOR")+oModelFL6:GetValue("FL6_VCONFE") > oModelFL6:GetValue("FL6_TOTAL")
	if !IsBlind() 
		lRet := MsgYesNo(STR0008) //"O Valor informado para o Pedido é maior que o valor previsto. Confirma este Valor ?"
		if !lRet
  			Help( ,, 'Help',, STR0009, 1, 0 )	 //'A Inclusão de Valor informado foi cancelada.'
		endif
	else
		Help( ,, 'Help',, STR0010, 1, 0 )	 //'O Valor informado para o Pedido é maior que o valor previsto.'
	endif	 
endif 
      
if nTotalFLU <> 0 .and. oModelFL6:GetValue("FL6_VINFOR") <> nTotalFLU
	Help( ,, 'Help',, STR0011, 1, 0 ) //'O Valor informado para o Pedido é diferente do total informado nos passageiros.'
	lRet := .F.
endif 

if oModelFL6:GetValue("FL6_VINFOR") >0
	if oModelFL6:GetValue("FL6_VINFOR")+oModelFL6:GetValue("FL6_VCONFE")>= oModelFL6:GetValue("FL6_TOTAL")
		oModelFL6:SetValue( "FL6_STATUS" , '2' )
	else 
		oModelFL6:SetValue( "FL6_STATUS" , '1' )	
	endif
endif

if lRet
	For nX := 1 To oModelFL6:Length()
		oModelFL6:GoLine( nX )
		nTotal += oModelFL6:GetValue("FL6_VINFOR")
	Next

	If oModel:cID $  "FINA685A|FINA686A"
		oModel:GetModel("FLQMASTER"):SetValue( "FLQ_TOTAL" , nTotal  )
	EndIf 
	
endif

FWRestRows(aSaveLines)

If oView != Nil
	oView:Refresh()
EndIf

Return lRet

//-------------------------------------------------------------------
Function FNA685VFLU()

Local lRet 		    := .T.
Local oModel        := FWModelActive()
Local oModelFL6     := oModel:GetModel("FL6DETAIL")
Local oModelFLU     := oModel:GetModel("FLUDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX			:= 0
Local oView			:= FWViewActive()
Local nTotal        := 0

For nX := 1 To oModelFLU:Length()
	oModelFLU:GoLine( nX )
	nTotal += oModelFLU:GetValue("FLU_VINFOR")
Next

lRet := oModelFL6:SetValue( "FL6_VINFOR" , nTotal )


FWRestRows(aSaveLines)

If oView != Nil
	oView:Refresh()
EndIf       

Return lRet

//-------------------------------------------------------------------
Static Function LoadFL6( oGrid, lCopy ) 
Local aArea   := GetArea() 
Local aFields := {}
Local aRet    := {} 
Local cFields := 'FL6.R_E_C_N_O_'
Local cTmp    := ''
Local cQuery  := ''

// Pega campos que fazem parte da estrutura do objeto, para otimizar retorno da query
aFields := oGrid:GetStruct():GetFields()
aEval( aFields, { |aX| IIf( !aX[MODEL_FIELD_VIRTUAL], cFields += ',' + aX[MODEL_FIELD_IDFIELD],) } )

cTmp   := GetNextAlias() 
cQuery := ""
cQuery += "SELECT " + cFields + " FROM " + RetSqlName( 'FL6' ) + " FL6"
if !Empty(MV_PAR04) // Define filtragem por participante
	cQuery += " ," + RetSqlName( 'FLU' ) + " FLU" 
endif	
cQuery += " WHERE FL6_FILIAL='" + xFilial( 'FL6' ) + "'" 
if !Empty(MV_PAR01)
	cQuery += " AND FL6_IDRESE = '"+MV_PAR01+"'"
endif

cQuery += " AND FL6_TIPO = '"+STR(MV_PAR02,1,0)+"'"  

if !Empty(MV_PAR04)
	cQuery += " AND FLU_FILIAL='" + xFilial( 'FLU' ) + "'"
	cQuery += " AND FLU_VIAGEM = FL6_VIAGEM"
	cQuery += " AND FLU_ITEM = FL6_ITEM"
	cQuery += " AND FLU_PARTIC = '"+Alltrim(MV_PAR04)+"'"
	cQuery += " AND FLU.D_E_L_E_T_=' '"
endif	
if !Empty(MV_PAR03) .or. !Empty(MV_PAR05) .or. !Empty(MV_PAR06)

	if MV_PAR02 = 1 // Aereo 
		cQuery += " AND EXISTS ( SELECT FL7_NOME FROM " + RetSqlName( 'FL7' ) + " FL7"    
		cQuery += " WHERE FL7_FILIAL='" + xFilial( 'FL7' ) + "'"
		cQuery += " AND FL7_VIAGEM = FL6_VIAGEM"
		cQuery += " AND FL7_ITEM = FL6_ITEM"
		if !Empty(MV_PAR03)
			cQuery += " AND FL7_NOME = '"+Alltrim(MV_PAR03)+"'"
		endif
		if !Empty(MV_PAR05)
			cQuery += " AND FL7_DSAIDA >= '"+Dtos(MV_PAR05)+"'"
		endif
		if !Empty(MV_PAR03)
			cQuery += " AND FL7_DCHEGA <= '"+Dtos(MV_PAR06)+"'"
		endif
		
		cQuery += " AND FL7.D_E_L_E_T_=' ')"   
		
	elseif MV_PAR02 = 2 // Hotel 
		cQuery += " AND EXISTS ( SELECT FL9_NOME FROM " + RetSqlName( 'FL9' ) + " FL9"  
		cQuery += " WHERE FL9_FILIAL='" + xFilial( 'FL9' ) + "'"
		cQuery += " AND FL9_VIAGEM = FL6_VIAGEM"
		cQuery += " AND FL9_ITEM = FL6_ITEM"
		if !Empty(MV_PAR03)
			cQuery += " AND FL9_NOME = '"+Alltrim(MV_PAR03)+"'"
		endif
		if !Empty(MV_PAR05)
			cQuery += " AND FL9_DCHKIN >= '"+Dtos(MV_PAR05)+"'"
		endif
		if !Empty(MV_PAR03)
			cQuery += " AND FL9_DCHKOU <= '"+Dtos(MV_PAR06)+"'"
		endif
		
		cQuery += " AND FL9.D_E_L_E_T_=' ')"   

	elseif MV_PAR02 = 3 // Carro 
		cQuery += " AND EXISTS ( SELECT FLB_NOME FROM " + RetSqlName( 'FLB' ) + " FLB"  
		cQuery += " WHERE FLB_FILIAL='" + xFilial( 'FLB' ) + "'"
		cQuery += " AND FLB_VIAGEM = FL6_VIAGEM"
		cQuery += " AND FLB_ITEM = FL6_ITEM"
		if !Empty(MV_PAR03)
			cQuery += " AND FLB_NOME   = '"+Alltrim(MV_PAR03)+"'"
		endif
		if !Empty(MV_PAR05)
			cQuery += " AND FLB_DRETIR >= '"+Dtos(MV_PAR05)+"'"
		endif
		if !Empty(MV_PAR03)
			cQuery += " AND FLB_DDEVOL <= '"+Dtos(MV_PAR06)+"'"
		endif
		
		cQuery += " AND FLB.D_E_L_E_T_=' ')"  
	elseif MV_PAR02 = 4 // Rodoviario
		cQuery += " AND EXISTS ( SELECT FL8_NOME FROM " + RetSqlName( 'FL8' ) + " FL8"  
		cQuery += " WHERE FL8_FILIAL='" + xFilial( 'FL8' ) + "'"
		cQuery += " AND FL8_VIAGEM = FL6_VIAGEM"
		cQuery += " AND FL8_ITEM = FL6_ITEM"
		if !Empty(MV_PAR03)
			cQuery += " AND FL8_NOME     = '"+Alltrim(MV_PAR03)+"'"
		endif
		if !Empty(MV_PAR05)
			cQuery += " AND FL8_DSAIDA >= '"+Dtos(MV_PAR05)+"'"
		endif
		if !Empty(MV_PAR03)
			cQuery += " AND FL8_DCHEGA <= '"+Dtos(MV_PAR06)+"'"
		endif
		
		cQuery += " AND FL8.D_E_L_E_T_=' ')"  

	elseif MV_PAR02 = 5 // Seguro 
		cQuery += " AND EXISTS ( SELECT FLA_NOME FROM " + RetSqlName( 'FLA' ) + " FLA"  
		cQuery += " WHERE FLA_FILIAL='" + xFilial( 'FLA' ) + "'"
		cQuery += " AND FLA_VIAGEM = FL6_VIAGEM"
		cQuery += " AND FLA_ITEM = FL6_ITEM"
		if !Empty(MV_PAR03)
			cQuery += " AND FLA_NOME  = '"+Alltrim(MV_PAR03)+"'"
		endif
		if !Empty(MV_PAR05)
			cQuery += " AND FLA_INICIO >= '"+Dtos(MV_PAR05)+"'"
		endif
		if !Empty(MV_PAR03)
			cQuery += " AND FLA_FINAL  <= '"+Dtos(MV_PAR06)+"'"
		endif
		
		cQuery += " AND FLA.D_E_L_E_T_=' ')"  

	endif
endif
cQuery += " AND FL6.FL6_STATUS <> '2'" // Não conferido totalmente
cQuery += " AND FL6.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )
 
aEval( aFields, { |aX| If ( aX[MODEL_FIELD_TIPO]$"NDL", TcSetField(cTmp, aX[MODEL_FIELD_IDFIELD], aX[MODEL_FIELD_TIPO],aX[MODEL_FIELD_TAMANHO],aX[MODEL_FIELD_DECIMAL]),NIL)})

aRet := FWLoadByAlias( oGrid, cTmp ) 

(cTmp)->( dbCloseArea() ) 

RestArea( aArea ) 

Return aRet  

//-------------------------------------------------------------------
Function FNA685INFLQ(oModel)

Local lRet 		    := .T.
Local oModelFL6     := oModel:GetModel("FL6DETAIL")
Local oModelFLU     := oModel:GetModel("FLUDETAIL")
Local oView			:= FWViewActive()
Local aAuxFL6
Local nI := 0
Local nJ := 0
Local nK := 1
Local nItErro := nI                               
//--- Dados do Fornecedor para a Agencia de Viagens
Local cFornec := PADR(SupergetMv("MV_RESCAGE", .T., ""),TAMSX3("A2_COD")[1])
Local cLoja   := PADR(SupergetMv("MV_RESLAGE", .T., ""),TAMSX3("A2_LOJA")[1])
Local cNome   := ""
                                         
                                         
aAuxFL6  := LoadFL6( oModelFL6)

if !Empty(cFornec) .and. !Empty(cLoja)
	cNome   := Posicione("SA2",1,xFilial("SA2")+cFornec+cLoja,"A2_NOME")
	if !Empty(cNome)
		oModel:SetValue('FLQMASTER',"FLQ_FORNEC", cFornec)
		oModel:SetValue('FLQMASTER',"FLQ_LOJA", cLoja)
		oModel:SetValue('FLQMASTER',"FLQ_NOMEFO", cNome)
	endif	
	
endif 
For nI := 1 To Len( aAuxFL6 )
	// Incluímos uma linha nova
	// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
	//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez

	If nI > 1

		// Incluimos uma nova linha de item

		If  ( nItErro := oModelFL6:AddLine() ) <> nI

			// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
			// ele retorna a quantidade de linhas já
			// existem no grid. Se conseguir retorna a quantidade mais 1
			lRet    := .F.
			Exit
		EndIf

	EndIf

	For nJ := 1 To Len( aAuxFL6[NI][2] )
			
		If !( lAux := oModel:SetValue( 'FL6DETAIL', oModelFL6:aHeader[nJ][2], aAuxFL6[nI][2][nJ] ) )

			// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
			// o método SetValue retorna .F.
			lRet    := .F.
			nItErro := nI
			Exit

		EndIf  
	    
	next nJ

	if lRet    
		dbSelectArea("FLU")
		dbSeek(xFilial("FLU")+oModel:GetValue( 'FL6DETAIL','FL6_VIAGEM')+oModel:GetValue( 'FL6DETAIL','FL6_ITEM'))
		while !Eof() .and. FLU->(FLU_FILIAL+FLU_VIAGEM+FLU_ITEM) = ;
			xFilial("FLU")+oModel:GetValue( 'FL6DETAIL','FL6_VIAGEM')+oModel:GetValue( 'FL6DETAIL','FL6_ITEM')
			
			if nK > 1
    	
				// Incluimos uma nova linha de item

				If  ( nItErro := oModelFLU:AddLine() ) <> nk

	   		   		// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
			   		// ele retorna a quantidade de linhas já
			   		// existem no grid. Se conseguir retorna a quantidade mais 1
					lRet    := .F.
					Exit
				endif
			EndIf

			For nJ := 1 To Len( oModelFLU:aHeader )
	
    	   	    If !( lAux := oModel:SetValue( 'FLUDETAIL', oModelFLU:aHeader[nJ][2], FieldGet(FieldPos(oModelFLU:aHeader[nJ][2])) ) )

					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet    := .F.
					nItErro := nI
					Exit
				EndIf  
	    
	    	next nJ
			
			nK++		
			FLU->(dbSkip())
		Enddo
		oModelFLU:GoLine( 1 )	
		nK := 1	
	endif
	
	If !lRet
		Exit
	EndIf

Next                
	
oModelFL6:GoLine( 1 )	

If !lRet

	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()

	// A estrutura do vetor com erro é:
	//  [1] Id do formulário de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulário de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solução
	//  [8] Valor atribuido
	//  [9] Valor anterior

	AutoGrLog( STR0012 + ' [' + AllToChar( aErro[1]  ) + ']' ) //"Id do formulário de origem:"
	AutoGrLog( STR0013 + ' [' + AllToChar( aErro[2]  ) + ']' ) //"Id do campo de origem:     "
	AutoGrLog( STR0014 + ' [' + AllToChar( aErro[3]  ) + ']' ) //"Id do formulário de erro:  "
	AutoGrLog( STR0015 + ' [' + AllToChar( aErro[4]  ) + ']' ) //"Id do campo de erro:       "
	AutoGrLog( STR0016 + ' [' + AllToChar( aErro[5]  ) + ']' ) //"Id do erro:                "
	AutoGrLog( STR0017 + ' [' + AllToChar( aErro[6]  ) + ']' ) //"Mensagem do erro:          "
	AutoGrLog( STR0018 + ' [' + AllToChar( aErro[7]  ) + ']' ) //"Mensagem da solução:       "
	AutoGrLog( STR0019 + ' [' + AllToChar( aErro[8]  ) + ']' ) //"Valor atribuido:           "
	AutoGrLog( STR0020 + ' [' + AllToChar( aErro[9]  ) + ']' ) //"Valor anterior:            "

	If nItErro > 0
		AutoGrLog( STR0021 + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' ) //"Erro no Item:              "
	EndIf

	MostraErro()
	oModel:DeActivate()
	
else
	oModel:GetModel( 'FL6DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FLUDETAIL' ):SetNoInsertLine( .T. )

	If oView != Nil
		oView:Refresh()
	EndIf      

EndIf


Return lRet 


//-------------------------------------------------------------------
Static Function FN685ACM( oModel )

Local aArea      := GetArea()
Local nI         := 0
Local nJ         := 0
Local nOperation := oModel:GetOperation()
Local lOk        := .T.
Local aSaveLines := FWSaveRows()
Local oModelCon
Local cViagemItem := ""
Local nPartic    := 0
Begin Transaction

oModelCon := FWLoadModel( 'FINA685' )
oModelCon:SetOperation( MODEL_OPERATION_INSERT)

oModelFL6 := oModel:GetModel( 'FL6DETAIL' )
oModelFLU := oModel:GetModel( 'FLUDETAIL' )
oModelFLQ := oModel:GetModel( 'FLQMASTER' )

// Ajustar o Valor conferido do Pedido
    
For nI := 1 To oModelFL6:Length()

	oModelFl6:GoLine( nI )  

	if oModelFL6:GetValue( 'FL6_VINFOR', nI, oModel ) > 0
        
        Reclock("FLR",.T.)
        FLR->FLR_FILIAL := xFilial("FLR")
        FLR->FLR_CONFER := oModelFLQ:GetValue( 'FLQ_CONFER')
        FLR->FLR_VIAGEM := oModelFL6:GetValue( 'FL6_VIAGEM', nI, oModel )
        FLR->FLR_ITEMVI := oModelFL6:GetValue( 'FL6_ITEM', nI, oModel ) 
        FLR->FLR_PARTIC := ""
        FLR->FLR_VALOR  := oModelFL6:GetValue( 'FL6_VINFOR', nI, oModel )
        FLR->FLR_DESCRI := STR0022+oModelFL6:GetValue( 'FL6_IDRESE', nI, oModel ) //"Referente a Reserva "
        
	    cViagemItem := oModelFL6:GetValue( 'FL6_VIAGEM', nI, oModel ) + oModelFL6:GetValue( 'FL6_ITEM', nI, oModel ) 
		FL6->( dbSetOrder( 1 ) )
		If FL6->( dbSeek( xFilial( 'FL6' ) + cViagemItem ) )
			RecLock("FL6",.F.)
			FL6->FL6_VCONFE += oModelFL6:GetValue( 'FL6_VINFOR', nI, oModel )
			Fl6->FL6_STATUS  := oModelFL6:GetValue( 'FL6_STATUS', nI, oModel )
			msUnlock()
		Endif    
        

        If FL5->( dbSeek( xFilial( 'FL5' ) + oModelFL6:GetValue( 'FL6_VIAGEM', nI, oModel ) ) )
          	Reclock("FL5",.F.)
           	FL5->FL5_STATUS := FN685STAT(oModelFL6:GetValue( 'FL6_VIAGEM', nI, oModel ))
           	msUnlock()
        endif
		For nJ := 1 To oModelFLU:Length()
	
			oModelFlU:GoLine( nJ )

			if oModelFLU:GetValue( 'FLU_VINFOR', nJ, oModel ) > 0
                if nPartic > 0
                	FLR->(msUnlock())
			        Reclock("FLR",.T.)
			        FLR->FLR_FILIAL := xFilial("FLR")	
			        FLR->FLR_CONFER := oModelFLQ:GetValue( 'FLQ_CONFER')
			        FLR->FLR_VIAGEM := oModelFL6:GetValue( 'FL6_VIAGEM', nI, oModel )
			        FLR->FLR_ITEMVI := oModelFL6:GetValue( 'FL6_ITEM', nI, oModel ) 
			        FLR->FLR_PARTIC := ""
			        FLR->FLR_VALOR  := oModelFL6:GetValue( 'FL6_VINFOR', nI, oModel )
			        FLR->FLR_DESCRI := STR0022+oModelFL6:GetValue( 'FL6_IDRESE', nI, oModel )	 //"Referente a Reserva "
                ENDIF
				FLR->FLR_PARTIC := oModelFLU:GetValue( 'FLU_PARTIC', nJ, oModel )
				FLR->FLR_VALOR  := oModelFLU:GetValue( 'FLU_VINFOR', nJ, oModel )
				
   				FLU->( dbSetOrder( 1 ) )
				If FLU->( dbSeek( xFilial( 'FLU' ) + cViagemItem + oModelFLU:GetValue( 'FLU_PARTIC', nJ, oModel )))
					RecLock("FLU",.F.)
					FLU->FLU_VCONFE += oModelFLU:GetValue( 'FLU_VINFOR', nJ, oModel )
   		    	    msUnlock()
 				Endif 
 				nPartic++
 			endif	
		Next nJ
		FLR->(MsUnlock())
	endif	
Next nI 

if GeraTitPg(oModelFLQ:GetValue( 'FLQ_FORNEC'), oModelFLQ:GetValue( 'FLQ_LOJA'), oModelFLQ:GetValue( 'FLQ_VENCTO'), oModelFLQ:GetValue( 'FLQ_TOTAL'))
	oModelFLQ:SetValue('FLQ_PREFIX',SE2->E2_PREFIXO )
	oModelFLQ:SetValue('FLQ_NUMTIT',SE2->E2_NUM     )
	oModelFLQ:SetValue('FLQ_PARC'  ,SE2->E2_PARCELA )
else

	if !IsBlind()
		MostraErro()
		DisarmTransaction()
	endif	
 	
endif

oModelFLQ:SetValue('FLQ_STATUS'  ,'1' )

FWModelActive( oModel )
FWFormCommit( oModel )

RestArea( aArea )

end Transaction

Return .T.              

//-------------------------------------------------------------------------------------------
Static Function FN685ACOTOT()
Local oModel        := FWModelActive()
Local oModelFL6     := oModel:GetModel("FL6DETAIL")
Local aSaveLines	:= FWSaveRows()
Local oView			:= FWViewActive()

if oModelFL6:GetValue( "FL6_STATUS") = '2'
   if !IsBlind() .and. !MsgYesNo(STR0023+; //"Pedido já confirmado totalmente. "
                       STR0024) //" Deseja reverter ao status anterior?"
		Help( ,, 'Help',, STR0025, 1, 0 )	 //'Operção cancelada.'
   else  

		if oModelFL6:GetValue("FL6_VINFOR") + oModelFL6:GetValue("FL6_VCONFE") = 0
   			oModelFL6:SetValue( "FL6_STATUS" , '0' )
        elseif oModelFL6:GetValue("FL6_VINFOR") + oModelFL6:GetValue("FL6_VCONFE") < oModelFL6:GetValue("FL6_TOTAL")
   			oModelFL6:SetValue( "FL6_STATUS" , '1' )
   		endif	
   endif

else
   if !IsBlind() .and. !MsgYesNo(STR0026+Alltrim(oModelFL6:GetValue( "FL6_IDRESE"))+; //"O Status do Pedido "
                       STR0027) //" será alterado para confirmado total. Confirma está alteraçõa?"
		Help( ,, 'Help',, STR0025, 1, 0 )	 //'Operção cancelada.'
   else
   			oModelFL6:SetValue( "FL6_STATUS" , '2' )
   endif
endif 
 
If oView != Nil
	oView:Refresh()
EndIf      

Return

Static Function GeraTitPg(cCODFOR, cLOJFOR, dVencto, nValor   )

LOCAL aTitulo := {}
Local cPrefixo := SUPERGETMV("MV_RESPRCF",.T.,"CNF")
Local cTipo    := SUPERGETMV("MV_RESTPCF",.T.,"DP")
Local cNatu    := SUPERGETMV("MV_RESNTCF",.T.,"")                    
Local cNatFor  := Posicione("SA2",1,xFilial("SA2")+ cCODFOR + cLOJFOR, "A2_NATUREZ") 
PRIVATE lMSHelpAuto := .f. // para nao mostrar os erro na tela
PRIVATE lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e' que deu erro
					
cNatu := If( Empty(cNatFor), cNatu, cNatFor)

//Será gerado o financeiro se os tres paramtros estaiver preenchidos
if !Empty(cPrefixo) .and. !Empty(cTipo) .and. !Empty(cNatu)
 

	 aTitulo := {	{"E2_PREFIXO"	,cPrefixo	 		,Nil},;      
	  				{"E2_NUM"		,ProxTitulo("SE2",cPrefixo)	,Nil},;      
					{"E2_TIPO"		,cTipo    	     	,Nil},;      
					{"E2_NATUREZ"	,cNatu     	        ,Nil},;
					{"E2_FORNECE"	,cCODFOR           	,Nil},;      
					{"E2_LOJA"		,cLOJFOR			,Nil},;      
					{"E2_EMISSAO"	,dDataBase			,Nil},;
					{"E2_VENCTO"	,dVencto			,Nil},;
					{"E2_VENCREA"	,DataValida(dVencto),Nil},;
					{"E2_VALOR"		,nValor				,Nil},;
					{"E2_ORIGEM"		,"FINA685"				,Nil}}

	MSExecAuto({|x,z,y| FINA050(x,z,y)},aTitulo,,3)

ENDIF

Return !lMSErroAuto



//-------------------------------------------------------------------
/*/{Protheus.doc} F685ALoad
Carrega dados para a Grid dos itens de pedido a serem conferidos

@author Mauricio Pequim Junior
@since  20/05/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F685ALoad(oModel)
Local oModelFLQ	:= oModel:GetModel('FLQMASTER')

oModelFLQ:LoadValue("FLQ_FORNEC" ,  SuperGetMv("MV_RESCAGE",,"") )
oModelFLQ:LoadValue("FLQ_LOJA"   ,  SuperGetMv("MV_RESLAGE",,"") )
oModelFLQ:LoadValue("FLQ_NOMEFO" ,  F685ANomFor()			 )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F685ANomFor
Gatilho que retorna o nome do fornecedor

@author Mauricio Pequim Junior
@since  20/05/2014
@version 12
/*/

//-------------------------------------------------------------------
Function F685ANomFor()

Local oModel	:= FWModelActive()
Local oModelFLQ	:= oModel:GetModel('FLQMASTER')
Local cNomeFor 	:= ""
Local cForn		:= oModelFLQ:GetValue('FLQ_FORNEC')
Local cLoja		:= oModelFLQ:GetValue('FLQ_LOJA')

If !Empty(cForn) .and. !Empty(cLoja)
	SA2->(dbSelectArea("SA2"))
	SA2->(dbSetOrder(1))
	If SA2->(MsSeeK(xFilial("SA2")+cForn+cLoja))
		cNomeFor := SA2->A2_NREDUZ 
	Endif
Endif

Return cNomeFor	
