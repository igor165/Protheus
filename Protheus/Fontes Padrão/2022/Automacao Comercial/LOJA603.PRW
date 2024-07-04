#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'LOJA603.CH'
#INCLUDE 'FWMVCDEF.CH'               

Static lMsg := .T. //variavel para mostrar a mensagem de preço sugerido apenas uma vez, a validação do campo é chamada diretamente pelo framework          
Static l603Perg := .T. //variavel para pergunta para tela de mix de produtos
Static cCodPlan := "" //variavel de confirmação a alteração da Planilha
Static cCodRev := ""  //variavel de confirmação a alteração da Revisão

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA603()
Esta rotina tem o objetivo de permitir a inclusão e alteração do Mix de Produtos
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function LOJA603() 
Local oBrw := FWMBrowse():New() //objeto FWMBrowse     

oBrw:SetAlias("MFW")
oBrw:SetDescription(STR0001) //"Publicações de Mix"
	       
oBrw:AddLegend( "MFW_ATIVO=='1'", "RED"   , 	STR0002 ) 	//"Ativo"
oBrw:AddLegend( "MFW_ATIVO=='2'", "GREEN" , 	STR0003 ) 	//"Inativo"
oBrw:AddLegend( "MFW_ATIVO=='3'", "YELLOW" , 	STR0004 ) 	//"Em analise"


oBrw:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
oBrw:DisableDetails()
oBrw:Activate()
		
Return Nil   
  
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do menu do browse
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function MenuDef()
Local aRotina := {}         //Declaracao da aRotina

ADD OPTION aRotina TITLE STR0006 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.LOJA603' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.LOJA603' OPERATION 3 ACCESS 0  //'Incluir'
ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.LOJA603' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.LOJA603' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.LOJA603' OPERATION 8 ACCESS 0  //'Imprimir'
ADD OPTION aRotina TITLE STR0038 ACTION 'M603LEGEND' 	  OPERATION 9 ACCESS 0  //'Legenda'

Return aRotina                                                   

       
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do objeto Model  
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oStruMFW := FWFormStruct( 1, "MFW")    //objeto contendo a estrutura da tabela MFW
Local oStruMFU := FWFormStruct( 1, "MFU", { |cCampo| cCampo <> "MFU_CODIGO" }) // objeto contendo a estrutura da tabela MFU                                                             
Local oModel   := MPFormModel():New("LOJA603", , ,{ |oMdl| MFUFILIAL( oMdl ) }) // objeto model contendo xFilial MFU

oModel := MPFormModel():New("LOJA603",,,{|oModel| VARNEW(oModel)})

    
oStruMFU:AddTrigger( "MFU_PRODUT", "MFU_DESCRI", {|| .T.},;
						{|oModel| Padr(Posicione("SB1",1,xFilial("SB1") + oModel:GetValue("MFU_PRODUT"), "B1_DESC"),TamSx3("MFU_DESCRI")[1]) } )


oModel:AddFields("MFWMASTER",,oStruMFW)

oModel:AddGrid("MFUDETAIL","MFWMASTER",oStruMFU )                                    
                                                             
oModel:SetRelation( 'MFUDETAIL', { { 'MFU_FILIAL', 'xFilial( "MFU" )' }, { 'MFU_CODIGO', 'MFW_CODIGO' } }, MFU->( IndexKey(2) ))
                        
oModel:GetModel( 'MFUDETAIL' ):SetUniqueLine( { 'MFU_PRODUT' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0014) //'Publicação de Itens Mix'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'MFWMASTER' ):SetDescription( STR0039 ) // "Empresa x Mix de Produtos"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
oModel:GetModel( 'MFUDETAIL' ):SetDescription( STR0040 ) // "Itens de Produtos Mix"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             

oModel:bActivate := {|oModel| A603Perg(oModel) }
oModel:SetPKIndexOrder(1) 
oModel:SetPrimaryKey({"MFW_CODIGO"})


Return oModel 


// Colocar cabeçalho na função 

Static Function MFUFILIAL(oModel) 

Local oModelGrid := oModel:GetModel("MFUDETAIL")
Local nI := 0		// Contador

oModel:GetModel("MFWMASTER"):LoadValue("MFW_FILIAL",xFilial("MFW"))

For nI := 1 To oModelGrid:Length()
	oModelGrid:Goline(nI)
	oModelGrid:LoadValue("MFU_FILIAL",xFilial("MFU"))
Next nI

FWFormCommit( oModel )

Return (.T.)



//--------------------------------------------------------------------
/*/{Protheus.doc} 
Função para gravar as informações e iniciar processo no Fluig
@since 15/09/2014
@version 1.0
/*/
//--------------------------------------------------------------------

Function VARNEW(oModel)

Local aRetFluig	:= ""
Local cMV_Fluig	:= SuperGetMv( "MV_LJFLMIX", NIL, .T. )	//Verifica se irá usar o Fluig para aprovacao de mix
Local nOperacao := oModel:GetOperation() //Controle de operacao

FwFormCommit(oModel)

// Tratamento para enviar workflow somente quando estiver inserindo dados e parametro do fluig ativo
If nOperacao == 3 .AND. cMV_Fluig

//Insere no Fluig

	aRetFluig := StartProcess("LOJA603",FWWFColleagueId(RetCodUsr()),,,.F.)               
         
Endif

Return (.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc}ViewDef()
Definição do objeto View
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruMFW := FWFormStruct( 2, 'MFW' )  //objeto contendo estrutura da tabela MFW
Local oStruMFU := FWFormStruct( 2, 'MFU', { |cCampo| cCampo<>"MFU_CODIGO" } ) //objeto contendo estrutura da tabela MFU

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'LOJA603' )  //declaração do objeto Model
Local oView    := Nil                       //declaração do objeto View

oStruMFW:RemoveField('MFW_FILIAL') 
oStruMFU:RemoveField('MFU_FILIAL') 

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_MFW', oStruMFW, 'MFWMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_MFU', oStruMFU, 'MFUDETAIL' )

// Define campos que terao Auto Incremento

                                                 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'UP'  , 30 ) //SUPERIOR                                                                           
oView:CreateHorizontalBox( 'DOWN', 70 ) //INFERIOR

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_MFW', 'UP'  )
oView:SetOwnerView( 'VIEW_MFU', 'DOWN' )
oView:AddIncrementField('VIEW_MFU' , 'MFU_ITEM' ) 


// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_MFW', STR0039 ) // "Empresa x Mix de Produtos"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
oView:EnableTitleView( 'VIEW_MFU', STR0040 ) // "Itens de Produtos Mix"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
           
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} GetUltPrc()
Retorna ultimo preço de compra 
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function GetUltPrc(cFil,cPrd)
Local nPrc := 0	 //ultimo preco de compra	        
Local cQry := ""  //Consulta SQL
Local aArea := {} //Armazena a area corrente      
Local dData := ctod(" /  /  ") //data da ultima compra
Local cSGBD := TCGetDB() //Banco de dados que esta sendo utilizado 

#IFDEF TOP        
	cQry := " SELECT TOP(1) C7_PRECO"
	Do Case
 		Case cSGBD $ "MSSQL"   
        	cQry := "SELECT TOP(1) C7_PRECO"
   		Case cSGBD $ "ORACLE"
        	cQry := "SELECT C7_PRECO"
         Case cSGBD $ "MYSQL/POSTGRES"
         	cQry := "SELECT C7_PRECO"
         Case cSGBD $ "SYBASE" 
         	cQry := "SET ROWCOUNT 1 "
         	cQry += "SELECT R_E_C_N_O_ " 
         Case cSGBD $ "INFORMIX"
         	cQry := "SELECT FIRST 1 C7_PRECO"
         OtherWise
         	cQry := "SELECT TOP 1 C7_PRECO"
	EndCase
	cQry += " FROM "+RetSqlName("SC7")
	cQry += " WHERE C7_PRODUTO = '"+cPrd+"'"                                 
	cQry += " AND C7_EMISSAO BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"'" 
	cQry += " AND C7_FILIAL = '"+xFilial("SC7",cFil)+"' AND D_E_L_E_T_ = ' '"
	If cSGBD $ "ORACLE"
		cQry += " AND ROWNUM <= 1"
	EndIf
	
	Do Case
 		Case cSGBD $ "MSSQL"   
			cQry += " ORDER BY C7_EMISSAO DESC"        
   		Case cSGBD $ "ORACLE"
            cQry += " ORDER BY C7_EMISSAO DESC"             
        Case cSGBD $ "MYSQL/POSTGRES"
        	cQry += " ORDER BY C7_EMISSAO DESC LIMIT 1 "                            
        Case cSGBD $ "SYBASE" 
         	cQry += " ORDER BY C7_EMISSAO DESC"                             
        Case cSGBD $ "INFORMIX"
        	cQry += " ORDER BY C7_EMISSAO DESC"             
        OtherWise
	EndCase
	cQry := ChangeQuery(cQry)                  
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMP",.T.,.T.)    
	nPrc := TMP->C7_PRECO
	TMP->(dbCloseArea())
#ELSE
	aArea := SC7->(GetArea())	
	SC7->(dbSetOrder(1))
	While SC7->(!EOF()) .And. SC7->C7_FILIAL = cFil .And. RTrim(SC7->C7_PRODUTO) == RTrim(cPrd)   
		If dData < SC7->C7_EMISSAO                  
	    	dData := SC7->C7_EMISSAO
	    	nPrc  := SC7->C7_PRECO 
	    EndIf 
		SC7->(dbSkip())
	EndDo
	RestArea(aArea)
#ENDIF                                               
		                              
Return nPrc

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadPrd()
Retorna o valor do campo especificado pelo parametro
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function GetDadPrd(cFil,cPrd,cCpo,xDef)

Local aAreaSB1 := SB1->(GetArea())       	//Controle de area SB1
Local aAreaSBZ := SBZ->(GetArea())       	//Controle de area SBZ  
Local xRet     := ""                     	//retorno da função
     
DEFAULT xDef := ""                        	//Valor default
          
SB1->(dbSetOrder(1))
SBZ->(dbSetOrder(1))
 	             
If SuperGetMv("MV_ARQPROD",,"SB1") == "SB1" .And. SB1->(FieldPos("B1_"+cCpo)) > 0
	If SB1->(dbSeek(xFilial("SB1")+cPrd)) 
   		xRet := SB1->&("B1_"+cCpo)
	Else
		xRet := CriaVar("B1_"+cCpo)
	EndIf
ElseIf SBZ->(FieldPos("BZ_"+cCpo)) > 0
	If SBZ->(dbSeek(xFilial("SBZ")+cPrd))
   		xRet := SBZ->&("BZ_"+cCpo)
	Else
		xRet := CriaVar("BZ_"+cCpo)
	EndIf
EndIf
    
RestArea(aAreaSB1) 
RestArea(aAreaSBZ)    
    
Return xRet                   

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadSD2()
Retorna o valor do campo especificado pelo parametro  
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function GetDadSD2(cFil,cPrd,nOpc)
Local aDados := {} //Dados do produto
Local cQry   := "" //Consulta SQL    
Local aArea  := {} //Area Corrente
                                           
DEFAULT nOpc := 1 //Opcao padrao

#IFDEF TOP
	cQry := " SELECT SUM(D2_QUANT) AS D2_QUANT, "
	cQry += " SUM(D2_TOTAL) AS D2_TOTAL, "
	cQry += " AVG(D2_PRCVEN) AS D2_PRCVEN " 
	cQry += " FROM "+RetSqlName("SD2")
	cQry += " WHERE D2_TIPO = 'N'"
	cQry += " AND D2_COD = '"+cPrd+"'"
	cQry += " AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"'" 
	cQry += " AND D2_FILIAL = '"+xFilial("SD2",cFil)+"' AND D_E_L_E_T_ = ''"
	cQry := ChangeQuery(cQry)                  
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMP",.T.,.T.)    
	aAdd(aDados, TMP->D2_QUANT  )
	aAdd(aDados, TMP->D2_TOTAL  )
	aAdd(aDados, TMP->D2_PRCVEN )
	TMP->(dbCloseArea())
#ELSE
	aDados := {0,0,0}      
  	aArea  := SD2->(GetArea())  
	SD2->(dbGoTop())
	While SD2->(!EOF())
    	If SD2->D2_FILIAL <> cFil
    		SD2->(dbSkip())
    		Loop
    	ElseIf RTrim(SD2->D2_COD) <> RTrim(cPrd)                 
    		SD2->(dbSkip())
    		Loop  
        ElseIf SD2->D2_TIPO <> 'N'    
            SD2->(dbSkip())
    		Loop    
    	ElseIf SD2->D2_EMISSAO < MV_PAR02 .Or. SD2->D2_EMISSAO > MV_PAR03	
    		SD2->(dbSkip())
    		Loop
    	EndIf
    	
    	aDados[1] += SD2->D2_QUANT		
		aDados[2] += SD2->D2_TOTAL
		aDados[3] += SD2->D2_PRCVEN
		
		SD2->(dbSkip())
	EndDo
	RestArea(aArea)
#ENDIF

Return aDados[nOpc]                       
  
//-------------------------------------------------------------------
/*/{Protheus.doc} A603Perg()
Apresentar pergunta ao usuário 
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function A603Perg(oModel)
Local aPrd  := {} //Vetor de produtos                 
Local cTab  := "" //Mix ativo
Local nOperacao := oModel:GetOperation() //Controle de operacao
Local nLine 	:= oModel:GetModel("MFUDETAIL"):GetLine() //Controle de numero da linha
Local nI,nTotLinhas

Default l603Perg := .T.
Default cCodPlan := ""
Default cCodRev  := ""
If (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4) .And. !(AtIsRotina("BUTTONOKACTION")) //Tela sendo reapresentada apos confirmacao do botao Ok    
   	If Pergunte("LOJA603",l603Perg) .Or. l603Perg == .F.
   		If Empty(MV_PAR02)
   			MV_PAR02 := dDataBase		
   		EndIf
   		If Empty(MV_PAR03)
   			MV_PAR03 := dDataBase		
   		EndIf 	
   		If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4
	   		If MV_PAR04 == 1//"1" $ MV_PAR04
	   		    aPrd := A603Categ()                                                       
	   			
	   			If !Empty(aPrd)
	   				cTab := TabAtiva()
	   				Processa( {|| A603AddPrd(oModel,aPrd,cTab) }, STR0015, STR0016,.F.) //"Aguarde..."###"Adicionando produtos..."
	   			EndIf
	   		ElseIf MV_PAR04 == 2   
				aPrd := A603Categ(.T.)	   		
	   			If !Empty(aPrd)
	   				cTab := TabAtiva()
	   				Processa( {|| A603AddPrd(oModel,aPrd,cTab) }, STR0015, STR0016,.F.) //"Aguarde..."###"Adicionando produtos..."
	   			EndIf	   			
	   		EndIf 
   		EndIf
   	Else
   		MsgInfo(STR0017) //"Utilizando valores padrão para os parametros."
   		MV_PAR01 := ""
   		MV_PAR02 := dDataBase
   		MV_PAR03 := dDataBase
   		MV_PAR04 := 1
   		MV_PAR05 := ""
   		MV_PAR06 := "" 
   		MV_PAR07 := ""
   		MV_PAR08 := ""
   		MV_PAR09 := ""
   	EndIf

	If oModel:GetOperation() == 4 .And. MFW->(FieldPos("MFW_CODPLA")) > 0 
		If Empty(cCodPlan) 
			If FindFunction("GetPlanRev")
				GetPlanRev( MV_PAR01, @cCodPlan, @cCodRev )
			EndIf
			If nOperacao != MODEL_OPERATION_INSERT .And. !Empty(MFW->MFW_CODPLA) .And. cCodPlan+cCodRev != MFW->(MFW_CODPLA+MFW_REVPLA)
				If !ApMsgYesNo(STR0041) // "Confirma a alteração da Planilha/Revisão? Os dados de integração digitados serão perdidos!"
					cCodPlan	:= MFW->MFW_CODPLA
					cCodRev	:= MFW->MFW_REVPLA
				EndIf
			EndIf
		EndIf
		If cCodPlan+cCodRev != MFW->(MFW_CODPLA+MFW_REVPLA)
			nTotLinhas  := oModel:GetModel("MFUDETAIL"):GetQTDLine()
			For nI := 1 To nTotLinhas
				oModel:GetModel("MFUDETAIL"):SetLine(nI)
			Next nI
		EndIf
		oModel:GetModel("MFUDETAIL"):SetLine(nLine)
	EndIf
Else
	MV_PAR01 := ""
	MV_PAR02 := dDataBase
	MV_PAR03 := dDataBase
	MV_PAR04 := 1
	MV_PAR05 := ""
	MV_PAR06 := ""  
	MV_PAR07 := ""
	MV_PAR08 := ""
	MV_PAR09 := ""	
EndIf

Return                                                            

//-------------------------------------------------------------------
/*/{Protheus.doc} A603AddPrd()
Adicionar produtos ao Model   
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function A603AddPrd(oModel,aPrd,cTab,lFornece) 
Local nX				:= 0      //contador
Local aCols			:= oModel:GetModel("MFUDETAIL"):aCols  
Local nOperation	:= oModel:GetOperation() 
Local lSeekLine		:= .F.

Default oModel := nil
Default aPrd := {}
Default cTab := ''
 

ProcRegua(Len(aPrd))

For nX := 1 to Len(aPrd)
	IncProc()                  
            
	If nOperation == 4 .And. aScan(aCols,{|x| RTrim(x[2]) == RTrim(aPrd[nX][1])}) > 0 
		Loop
	EndIf
	
	If !Empty(aPrd[nX][1])
		lSeekLine := oModel:GetModel("MFUDETAIL"):SeekLine({{"MFU_PRODUT",aPrd[nX][1]}})
		If !lSeekLine .AND. oModel:GetModel("MFUDETAIL"):AddLine() > 0 
			oModel:SetValue("MFUDETAIL","MFU_ITEM",nX)
			oModel:SetValue("MFUDETAIL","MFU_PRODUT",aPrd[nX][1])  
		EndIf
	EndIf
Next

Return 
                                                                                         

//-------------------------------------------------------------------
/*/{Protheus.doc} A603EMFW()
Adicionar produtos ao Model    
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

                                                                                        
Function A603EMFW(cAlias,nRecno,nOpc,cLote,cFil) 
Local aGrpFil 		:= {}		//-- Vetor com as filiais do grupo de filiais
Local nX				:= 0 		//-- Contador     
Local lRet 			:= .T. 	//-- Retorno indicando se a função foi realizada com sucesso      
Local aDA0 			:= {} 	//-- Registros do DA0                      
Local aDA1 			:= {} 	//-- Registros do DA1
Local aAreaMFW 	:= {}		//-- Controle de area MFW
Local aAreaSAZ 	:= {}		//-- Controle de area SAZ  
Local aTabsAtiv	:= {}		//-- Array com Tabelas Ativas 

Local cCod 			:= ""		//-- Código da publicação
	
//-- Verifica o tamanho dos campos MFU_PRCSUG e DA1_PRCVEN
If !VldTamCpos()                                    
	Help(" ",1,"A603TDIF")
	lRet := .F.
EndIf

If lRet
	aAreaMFW := MFW->(GetArea())
	aAreaSAZ := SAZ->(GetArea())  
     
	MFW->(dbSetOrder(1))
	SAZ->(dbSetOrder(2))      
    	
	If SAZ->(dbSeek(xFilial("SAZ",cFil) + cFil + cLote) ) 
    	cCod := SAZ->AZ_CODIGO
    	If SAZ->AZ_EFETIVO <> "1"		
			aDA0 := MFWtoDA0(cFil,SAZ->AZ_CODIGO)
			aDA1 := MFUtoDA1(cFil,SAZ->AZ_CODIGO)       
			
			A603EFET(cFil,aDA0,aDA1)       
			   
			RecLock("SAZ",.F.)
			SAZ->AZ_EFETIVO := "1"
			SAZ->(MsUnlock())
			
			A603AtuSts(cFil,cCod)
		Else
    		lRet := .F.
    		Alert(STR0018) //"Lote já efetivado para esta filial"
		EndIf			
	Else
    	lRet := .F.
    	Alert(STR0019) //"Lote não encontrado para esta filial"
	EndIf
	RestArea(aAreaMFW)
    RestArea(aAreaSAZ)
 Else
	aGrpFil := FWAllFilial(MFW->MFW_GRUPFIL)    
	If MFW->MFW_EFETIV == "3" .OR. Empty(MFW->MFW_EFETIV)
		If ApMsgYesNo(STR0020) //"Deseja efetivar a tabela de mix?"
			
			//Tratamento caso o campo Grupo de Filiais esteja vazio
			If ( Len(aGrpFil) == 0 )
				AAdd( aGrpFil, xFilial("MFW") )
			EndIf
			
			If Empty(xFilial("DA0")) //Tabela compartilhada
				aDA0 := MFWtoDA0(aGrpFil[1],MFW->MFW_CODIGO)
				aDA1 := MFUtoDA1(aGrpFil[1],MFW->MFW_CODIGO)
				A603EFET(aGrpFil[1],aDA0,aDA1)
				MFW->(dbGoTo(nRecno))
				RecLock("MFW",.F.) 
				MFW->MFW_EFETIV := "1"
				MFW->(MsUnlock())     
			Else
				For nX := 1 To Len(aGrpFil)
					aDA0 := MFWtoDA0(aGrpFil[nX],MFW->MFW_CODIGO)
					aDA1 := MFUtoDA1(aGrpFil[nX],MFW->MFW_CODIGO)
					A603EFET(aGrpFil[nX],aDA0,aDA1)
				Next

				MFW->(dbGoTo(nRecno))
				RecLock("MFW",.F.) 
				MFW->MFW_EFETIV := "1"
				MFW->(MsUnlock())     
			EndIf
		EndIf	   
	Else
		Alert(STR0021) //"Registro já efetivado."
	EndIf	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A603EFET()
Efetivar tabela de mix
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function A603EFET(cFil,aDA0,aDA1,cTabAtiva) 
Local cNewTab   := ""                 //código da nova tabela de preço
Local cFilBak   := ""                 //Backup da filial logada no sistema
Local lTpOper   := DA1->(FieldPos("DA1_TPOPER")) > 0
                         
Local nX		    := 0          //contador
Local nY        := 0          //contador
Local lNovaTab  := .T.	      // Flag para indicar se o sistema irá criar uma nova tabela de preço                 
Local nItens	 := 0				//Armazena a quantidade de itens que já estão na tabela de preço               

Default cTabAtiva := TabAtiva(cFil,.F.,aDA0) //tabela de preço ativa

DA0->(dbSetOrder(1)) 
DA1->(dbSetOrder(1))
	             
BEGIN TRANSACTION
	If !Empty(cTabAtiva)
		lNovaTab := .F.
		If DA0->(dbSeek(xFilial("DA0",cFil)+cTabAtiva))
			If SuperGetMV("MV_TPEFETP",,"1") == "2" .Or. DA0->DA0_DATDE <> MFW->MFW_DATAIN
				lNovaTab := .T.
				RecLock("DA0",.F.)
				If DA0->DA0_DATDE < aDA0[2,2] - 1
					DA0->DA0_DATATE := aDA0[2,2] - 1
				Else
					DA0->DA0_DATATE := DA0->DA0_DATDE
				EndIf
				DA0->(MsUnlock())
			EndIf
		EndIf
		If SuperGetMV("MV_TPEFETP",,"1") == "1" .And. DA1->(dbSeek(xFilial("DA1",cFil)+cTabAtiva))
			While DA1->(!EOF()) .And. RTrim(DA1->DA1_CODTAB) == RTrim(cTabAtiva) .And. DA1->DA1_FILIAL == xFilial("DA1",cFil)
				If aScan(aDA1, {|x| RTrim(x[1,2]) == RTrim(DA1->DA1_CODPRO)}) == 0
					If lTpOper
						aAdd(aDA1, {{"DA1_CODPRO"	, DA1->DA1_CODPRO },;
										{"DA1_PRCVEN"	, DA1->DA1_PRCVEN },;
										{"DA1_ATIVO" 	, "1"},;
										{"DA1_TPOPER" 	, "4"},;
										{"DA1_QTDLOTE"	, DA1->DA1_QTDLOTE},;
										{"DA1_MOEDA" 	, 1  } })
					Else
						aAdd(aDA1, {{"DA1_CODPRO"	,DA1->DA1_CODPRO },;
										{"DA1_PRCVEN"	,DA1->DA1_PRCVEN },;
										{"DA1_ATIVO" 	,"1"},;
										{"DA1_QTDLOTE"	,DA1->DA1_QTDLOTE},;
										{"DA1_MOEDA" 	,1  } })
					EndIf
					nItens++
				EndIf
				DA1->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	If lNovaTab
		cFilBak := cFilAnt
		cFilAnt := cFil
		cNewTab := GETSXENUM("DA0","DA0_CODTAB")
		cFilAnt := cFilBak
		
		RecLock("DA0",.T.)
		DA0->DA0_CODTAB := cNewTab
		DA0->DA0_FILIAL := xFilial("DA0",cFil)
		DA0->DA0_HORATE := "23:59"
		For nX := 1 to Len(aDA0)
			DA0->(FieldPut(FieldPos(aDA0[nX,1]),aDA0[nX,2]))
		Next
		DA0->(MsUnlock())
		ConfirmSX8()
	Else
		cNewTab := cTabAtiva
	EndIf
	
	DA1->(dbSetOrder(1))
	nPosPrd := aScan(aDA1,{|x| RTrim(x[1,1]) == "DA1_CODPRO" })
	
	For nX := 1 to Len(aDA1)
		DA1->(dbSeek(xFilial("DA1",cFil)+PadR(cNewTab,3)+aDA1[nX,nPosPrd,2] ))
		RecLock("DA1",DA1->(!Found()))
		DA1->DA1_CODTAB := cNewTab
		DA1->DA1_FILIAL := xFilial("DA1",cFil)
		If DA1->(!Found())
			nItens++
			DA1->DA1_ITEM := StrZero(nItens,4)
		EndIf
		For nY := 1 to Len(aDA1[nX])
			DA1->(FieldPut(FieldPos(aDA1[nX,nY,1]),aDA1[nX,nY,2]))
		Next nY
		DA1->(MsUnlock())
	Next nX
	
END TRANSACTION

                            
//-------------------------------------------------------------------
/*/{Protheus.doc} MFWtoDA0()
Adicionar a um vetor dados da tabela MFW  
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
                            
Static Function MFWtoDA0(cFil,cCod)
Local aAux := {}     //Controle de retorno auxiliar

MFW->(dbSetOrder(1))	
MFW->(dbSeek(xFilial("MFW",cFil)+cCod))     

aAdd(aAux,{"DA0_DESCRI",MFW->MFW_DESCRI})       
aAdd(aAux,{"DA0_DATDE" ,MFW->MFW_DATAIN})
aAdd(aAux,{"DA0_HORADE",MFW->MFW_HORAIN})
aAdd(aAux,{"DA0_HORAATE","23:59"})
aAdd(aAux,{"DA0_ATIVO" ,MFW->MFW_ATIVO}) 
aAdd(aAux,{"DA0_TPHORA","1"})

If DA0->(FieldPos("DA0_FILPUB")) > 0  .And. DA0->(FieldPos("DA0_CODPUB")) > 0
	aAdd(aAux,{"DA0_FILPUB",MFW->MFW_FILIAL})       
	aAdd(aAux,{"DA0_CODPUB",MFW->MFW_CODIGO})       
EndIf

Return aClone(aAux)
                                                
//-------------------------------------------------------------------
/*/{Protheus.doc} A603AtuSts()
Atualizar Status das tabelas MFW e SAZ 
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function A603AtuSts(cFil,cCod) 
Local lAllEfet := .T. //Flag para verificar se todos os registros de uma publicação na SAZ foram efetivados

SAZ->(dbSetOrder(1))
SAZ->(dbSeek(xFilial("SAZ")+cCod))
                                 
While SAZ->(!EOF()) .And. RTrim(SAZ->AZ_CODIGO) == RTrim(cCod) .And. SAZ->AZ_FILIAL == xFilial("SAZ",cFil)
	If SAZ->AZ_EFETIVO <> "1"
		lAllEfet := .F.
	EndIf
	SAZ->(dbSkip()) 	
EndDo

MFW->(dbSetOrder(1))
MFW->(dbSeek(xFilial("MFW",cFil)+cCod))

RecLock("MFW",.F.)
If lAllEfet
	MFW->MFW_EFETIV := "1"
Else
	MFW->MFW_EFETIV := "2"
EndIf

MFW->(MsUnlock())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MFUtoDA1()
Adicionar a um vetor dados da tabela MFU  
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
                            
Static Function MFUtoDA1(cFil,cCod)
Local aAux := {} //Controle de retorno auxiliar
Local lTpOper := DA1->(FieldPos("DA1_TPOPER")) > 0

MFU->(dbSetOrder(1))	
MFU->(dbSeek(xFilial("MFU",cFil)+cCod))     

While MFU->(!EOF()) .AND. RTrim(MFU->MFU_CODIGO) == RTrim(cCod) .And. MFU->MFU_FILIAL == xFilial("MFU",cFil)
	If lTpOper
		aAdd(aAux, { {"DA1_CODPRO",MFU->MFU_PRODUT},;
	                 {"DA1_PRCVEN",MFU->MFU_PRCSUG },;
	                 {"DA1_QTDLOT",999999.99},;
	                 {"DA1_ATIVO" ,"1"},;
	                 {"DA1_TPOPER" ,"4"},;
	                 {"DA1_MOEDA" ,1  } })
	Else
		aAdd(aAux, { {"DA1_CODPRO",MFU->MFU_PRODUT},;
	                 {"DA1_PRCVEN",MFU->MFU_PRCSUG },;
	                 {"DA1_QTDLOT",999999.99},;
	                 {"DA1_ATIVO" ,"1"},;
	                 {"DA1_MOEDA" ,1  } })
	EndIf
	MFU->(dbSkip())
EndDo   
	                                                                     
Return aClone(aAux)

//-------------------------------------------------------------------
/*/{Protheus.doc} TabAtiva()
Retornar a tabela de preço ativa
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

                         
Static Function TabAtiva(cFil,lAlerta,aMFW)
Local cTab := MV_PAR09//MV_PAR05 //-- Tabela de preço       
Local nPos := 0 //Posicao do campo DA0_DATDE
DEFAULT lAlerta := .T.
DEFAULT cFil := xFilial("DA0",cFil)
DEFAULT aMFW := {}               

cFil := xFilial("DA0",cFil)

If !Empty(aMFW)
	nPos := aScan(aMFW,{|x| RTrim(x[1]) == "DA0_DATDE" })
	If nPos > 0
		DA0->(dbGoTop())
		While DA0->(!EOF()) .And. Empty(cTab)
			If DA0->DA0_DATDE == aMFW[nPos,2] .And. DA0->DA0_FILIAL == cFil
				cTab := DA0->DA0_CODTAB
			EndIf
			DA0->(dbSkip())
		EndDo
	EndIf
EndIf

If Empty(cTab)
	DA0->(dbGoTop())
	While DA0->(!EOF()) .And. Empty(cTab)
		If dDataBase >= DA0->DA0_DATDE .And. (Empty(DA0->DA0_DATATE) .Or. dDataBase <= DA0->DA0_DATATE ) .And. DA0->DA0_FILIAL == cFil
			If DA0->DA0_ATIVO == "1"
				cTab := DA0->DA0_CODTAB
			EndIf
		EndIf
		DA0->(dbSkip())
	EndDo
	
	If Empty(cTab) .And. lAlerta
		Alert(STR0023) //"Sem tabela ativa no momento."
	EndIf
EndIf

Return cTab


//-------------------------------------------------------------------
/*/{Protheus.doc} GetPrcAtu()
Retornar o preço atual do produto 
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

                       
Static Function GetPrcAtu(cTab,cCod)
Local nPrcAtu  //preço atual

If !Empty(cTab)
	DA1->(dbSetOrder(2))
	If DA1->(dbSeek(xFilial("DA1")+PADR(cCod,TAMSX3("B1_COD")[1])+cTab))
    	nPrcAtu := DA1->DA1_PRCVEN  
	Else
		nPrcAtu := 0.00
	EndIf      
Else
	nPrcAtu := 0.00
EndIf	

Return nPrcAtu


//-------------------------------------------------------------------
/*/{Protheus.doc} A603Categ()
Apresentar arvore para seleção de produtos através das categorias
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Function A603Categ(lFornece)

Local oDlgCat 		:= Nil   //objeto dialog
Local oLayer  		:= FWLayer():new() // objeto FwLayer
   
Local nRight  		:= oMainWnd:nRight - 200 //posição fina da dialog
Local nBottom 		:= oMainWnd:nBottom - 200//posição fina da dialog     
              
Local oWinL			:= Nil //container window esquerdo da dialog
Local oWinR			:= Nil //container window direito da dialog
Local oPnLUP		:= Nil //painel superior
Local oPnLDown		:= Nil //painel inferior
Local oPnRUP		:= Nil //painel superior direito
Local oPnRMiddle	:= Nil //painel intermediario direito
Local oPnRDown		:= Nil   //painel inferior direito
Local oGetL			:= Nil  //objeto get esquerdo
Local oGetR			:= Nil  //objeto get direito                              
Local oSayL			:= Nil  //objeto say esquerdo
Local oSayR			:= Nil  //objeto say direito
Local oSayPrd		:= Nil  //objeto say inferior esquerdo
Local oSayTot		:= Nil  //objeto say total inferior esquerdo       
Local oButL			:= Nil    //botão lado esquerdo
Local oButR			:= Nil    //botão lado direto
Local cPesqL 		:= space(TAMSX3("B1_COD")[1]) //variavel para armazenar conteudo get lado esquerdo
Local cPesqR 		:= space(TAMSX3("B1_COD")[1]) //variavel para armazenar conteudo get lado direito           
Local oPnlBottom	:= Nil //painel inferior    
Local oSayAtalho	:= Nil //Say utilizado para informar os atalhos da tela 
Local oBtnOk		:= Nil     //botão Ok
Local oBtnCancel	:= Nil //botão cancelar
Local oTree  		:= Nil //objeto tree  
Local aTree  		:= {}  //vetor com itens para a tree
Local oBrw   		:= Nil //objeto TWBrowse
Local aBrw   		:= {STR0024,STR0025,STR0026} //cabeçalho TWBrowse //"Código"###"Descrição"###"Categoria"
Local aDados 		:= {{"","",""}}  //dados da TWBrowse
Local lOk    		:= .F. //variavel de controle botão OK            
Local aPrd   		:= {}  //Vetor com produtos selecionados
Local nX			:= 0  //contador
Local nTam			:= 95 //tamanho que a linha do Layer ira ocupar da tela	

Default lFornece:= .F.	
         
aBrw:= {STR0024,STR0025,Iif(lFornece,STR0044,STR0026)} //"Código"###"Descrição"###"Fornecedor###"Categoria"

aTree:= IIf(lFornece ,{} ,RetCatPro()) 

DEFINE MSDIALOG oDlgCat TITLE Iif(lFornece,STR0027,STR0043) FROM 000,000 TO nBottom, nRight  Pixel of oMainWnd PIXEL //"Categoria de produtos"//"Fornecedores"

oLayer:init(oDlgCat,.T.)
oLayer:addLine ('UP',nTam, .T. )          
oLayer:addCollumn('Left' ,50,.F.,'UP')     
oLayer:addWindow('Left', 'WLeft',Iif(lFornece,STR0043,STR0028) , 100, .F., .F., , 'UP' )        //"Fornecedores"###"Categorias"
	     
oWinL := oLayer:getWinPanel ( 'Left', 'WLeft', 'UP' ) 
oPnLUP := TPanel():New( 0,0, , oWinL, , , , , RGB(230,230,230), 0, 30, .F., .F. ) 
oPnLUP:Align := CONTROL_ALIGN_TOP                        
	
oSayL := TSay():New( 5 , 5,{|| Iif(lFornece,STR0042,STR0029) },oPnLUP,,,,,,.T.)  //"Produto/Fornecedor"###Produto/Categoria
oGetL := TGet():New( 15, 5,{|u| if(PCount()>0,cPesqL:=u,cPesqL)} , oPnLUP, (oPnLUP:nClientWidth/2) - 80, 10, , , , , , , , .T., , , /*bWhen*/, , , , , , , , , , , , )                                            
oButL := TButton():New( 15, (oPnLUP:nClientWidth/2) - 70, STR0030, oPnLUP, {|| TreeSeek(oTree,RTrim(cPesqL))}, 60, 10, , , , .T. )  //"Pesquisar"
	      
oPnLDown := TPanel():New( 0,0, , oWinL, , , , , , 0, 0, .F., .F. ) 
oPnLDown:Align := CONTROL_ALIGN_ALLCLIENT                      
                                         
oTree := Xtree():New(0, 0, 0, 0, oPnLDown)
oTree:Align := CONTROL_ALIGN_ALLCLIENT
                 
oLayer:addCollumn('Right',50,.F.,'UP')  
oLayer:addWindow('Right', 'WRight', STR0031, 100, .F., .F., , 'UP' ) //"Produtos selecionados"

oWinR := oLayer:getWinPanel ( 'Right', 'WRight', 'UP' )

oPnRUP := TPanel():New( 0,0, , oWinR, , , , , RGB(230,230,230), 0, 30, .T., .T. ) 
oPnRUP:Align := CONTROL_ALIGN_TOP                        
      
oSayR := TSay():New( 5 , 5,{|| STR0032},oPnRUP,,,,,,.T.) //"Produto:"
oGetR := TGet():New( 15, 5,{|u| if(PCount()>0,cPesqR:=u,cPesqR)} , oPnRUP, (oPnRUP:nClientWidth/2) - 80, 10, , , , , , , , .T., , , /*bWhen*/, , , , , , , , , , , , )                                            
oButR := TButton():New( 15, (oPnRUP:nClientWidth/2) - 70, STR0030, oPnRUP, {|| FindPrd(oBrw,cPesqR)}, 60, 10, , , , .T. )  //"Pesquisar"
                                          
oPnRMiddle := TPanel():New( 0,0, , oWinR, , , , , , 0, 0, .F., .F. ) 
oPnRMiddle:Align := CONTROL_ALIGN_ALLCLIENT                      
                                                                
oBrw := TwBrowse():New(0,0,0,0,,aBrw,,oPnRMiddle,,,,,,,,,,,,,,.T.)
oBrw:lHScroll := .F.
oBrw:Align := CONTROL_ALIGN_ALLCLIENT
oBrw:setArray(aDados)		       

oBrw:bLine := {||{ aDados[oBrw:nAt,1],;
	                aDados[oBrw:nAt,2],;
	                aDados[oBrw:nAt,3] } }
	                 	        
oPnRDown := TPanel():New( 0,0, , oWinR, , , , , RGB(230,230,230), 0, 15, .T., .T. ) 
oPnRDown:Align := CONTROL_ALIGN_BOTTOM                               
	
oSayPrd := TSay():New(05,05,{|| STR0031},oPnRDown,,,,,,.T.) //"Produtos selecionados:"
oSayTot := TSay():New(05,80,{|| "0"},oPnRDown,"@E 99999",,,,,.T.)//,,,50,20)                  
 
If !lFornece
	addNode(oTree,aTree,oBrw,oSayTot)
Else	
	AdiForn(oTree,oBrw,oSayTot)
EndIf	
oTree:Refresh()                 
                                             
oLayer:addLine ("DOWN",10, .T. )
oPnlBottom := oLayer:getLinePanel("DOWN") 

oSayR      := TSay():New( 5 , 5,{|| "F4 | F5"},oPnlBottom,,,,,,.T.)
oBtnOk     := TButton():New( 2, (oPnlBottom:nClientWidth/2) - 120, STR0033      , oPnlBottom, {|| lOk := .T., oDlgCat:End()}, 50, 12, , , , .T. )  //"OK"
oBtnCancel := TButton():New( 2, (oPnlBottom:nClientWidth/2) - 60 , STR0034, oPnlBottom, {|| oDlgCat:End()}, 50, 12, , , , .T. )  //"Cancelar"
                                      
//Teclas de atalho
SetKEY(VK_F4,{|| MarkAll(oTree,oBrw,oSayTot,1)})
SetKEY(VK_F5,{|| MarkAll(oTree,oBrw,oSayTot,2)})

ACTIVATE MSDIALOG oDlgCat Centered
	
If lOk    
	aPrd := aClone(aDados)
EndIf                   

SetKEY(VK_F4,Nil)
SetKEY(VK_F5,Nil)       
Return aClone(aPrd)                                                                                                                   
                                                 
//-------------------------------------------------------------------
/*/{Protheus.doc} addNode()
Chamada da função recursiva addItem   
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

          
Static Function addNode(oTree,aAux,oBrw,oSayTot)
Local nX := 1 //contador

If ValType(aAux[3]) == "A" .And. Len(aAux[3]) > 0
	For nX := 1 to Len(aAux[3])                                   
		addItem(oTree,aAux[3,nX],oBrw,oSayTot)                                                                 
	Next     
EndIf 
Return                                                                                                   
         

//-------------------------------------------------------------------
/*/{Protheus.doc} addItem()
Função recursiva para adicionar o nó e seus filhos  
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

           
Static Function addItem(oTree,aAux,oBrw,oSayTot)
Local nX := 0  //contador                                                                          
Local nY := 0//contador

If ValType(aAux[3]) == "A" .And. Len(aAux[3]) > 0     
	//Adiciona Categoria "Pai"
	oTree:addTree( aAux[2], "LBNO", "LBNO", aAux[1],, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} )
	For nX := 1 to Len(aAux[3])		
		//Adiciona produtos filhos, que possuem nós abaixo dele
		addItem(oTree,aAux[3,nX],oBrw,oSayTot)
	Next nX      
 	addPrdTree(oTree,aAux[1],oBrw,oSayTot) 
 	oTree:EndTree() 
ElseIf ValType(aAux[3]) == "A"
	//adiciona produtos filhos
	oTree:addTree( aAux[2], "LBNO", "LBNO", aAux[1],, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} ) 
	addPrdTree(oTree,aAux[1],oBrw,oSayTot)
	oTree:EndTree()
EndIf
	                 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} dblClick()
Função de ação de dois cliques marca/desmarca um item 
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

              
Static Function dblClick(oTree,oBrw,oSayTot)
Local cCargo := oTree:GetCargo()   //ID do nó selecionado
Local nPos	 := aScan(oTree:aCargo,{|x| RTrim(x[1]) == RTrim(cCargo)}) //posicão do nó no vetor
Local cResource := '' //imagem a ser adicionada no nó                    
Local bCode := Nil     //Utilizado para informar se o nó está com flag ou não
Local cPai := ''      //ID do produto pai
               
If nPos > 0	                            
	If Eval(oTree:aCargo[nPos,3]) //o Flag do checkBox será desmarcado                 
	    cResource := "LBNO"                                     
		bCode	  := {|| .F.}
		oTree:aCargo[nPos,3] := {|| .F.}              
		
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.F.)
	
		//Adiciona produtos selecionados	
	Else //o Flag do checkBox será marcado
		cResource := "LBTIK"                                    
		bCode	  := {|| .T.}
		oTree:aCargo[nPos,3] := {|| .T.}
		
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.T.)
		//Remove produtos selecionados
	EndIf
	oTree:ChangeBmp(cResource,cResource,cCargo)       
	cPai := oTree:aNodes[nPos,2]
	MarkAllSon(oTree,cPai,cResource,bCode,oBrw,oSayTot)
EndIf  
    
oBrw:Refresh()

Return                                                                 


//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAllSon()
Marca todos os filhos de um nó 
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function MarkAllSon(oTree,cPai,cResource,bCode,oBrw,oSayTot)
Local aFilhos := {} //Vetor com nós filhos
Local nPos 	  := 0  //posicão do nó na arvore  
Local nX 	  := 0    //contador               
Local cCargo  := '' //ID do nó
	
aEval(oTree:aNodes, {|x| If(RTrim(x[1]) == RTrim(cPai),aAdd(aFilhos,x[2]) , ) } )

For nX := 1 to Len(aFilhos)
	nPos   := aScan(oTree:aNodes, {|x| RTrim(x[2]) == RTrim(aFilhos[nX]) } )
	cCargo := oTree:aCargo[nPos,1]                   
	oTree:aCargo[nPos,3] := bCode         
	oTree:ChangeBmp(cResource,cResource,cCargo)       
	If Eval(bCode)
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.T.) 
	Else
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.F.)	
	EndIf	
	MarkAllSon(oTree,aFilhos[nX],cResource,bCode,oBrw,oSayTot)
Next

Return         

//-------------------------------------------------------------------
/*/{Protheus.doc} addPrdTree()
Adiciona um produto a arvore 
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function addPrdTree(oTree,cID,oBrw,oSayTot) 
Local cFil := xFilial("ACV") //Filial      
                        
ACV->(dbSetOrder(1))
ACV->(dbSeek(xFilial("ACV")+cID))
                                     
While ACV->(!EOF()) .And. RTrim(ACV->ACV_CATEGO) == RTrim(cID) .And. ACV->ACV_FILIAL == cFil
	If !Empty(ACV->ACV_CODPRO)
		SB1->(dbSetOrder(1))                            
		SB1->(dbSeek(xFilial("SB1")+ACV->ACV_CODPRO))		
		oTree:addTreeItem( RTrim(SB1->B1_COD)+"-"+SB1->B1_DESC, "LBNO", "CAT"+ACV->ACV_CATEGO+"_PRD"+RTrim(SB1->B1_COD),, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} ) 	           	
	ElseIf !Empty(ACV->ACV_GRUPO)
		SB1->(dbSetOrder(4))                            
		SB1->(dbSeek(xFilial("SB1")+ACV->ACV_GRUPO))		
		While SB1->(!EOF()) .And. ACV->ACV_GRUPO == SB1->B1_GRUPO
			oTree:addTreeItem( RTrim(SB1->B1_COD)+"-"+SB1->B1_DESC, "LBNO", "CAT"+ACV->ACV_CATEGO+"_PRD"+RTrim(SB1->B1_COD),, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)})		
			SB1->(dbSkip())
		EndDo
	EndIf
	ACV->(dbSkip())
EndDo   
	
Return           

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuPrdBrw()
Adiciona um produto a arvore  
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function AtuPrdBrw(oTree,oBrw,oSayTot,nPos,lAdd)
Local aBrw		:= oBrw:aArray //Vetor do objeto TWBrowse com produtos selecionados
Local cPrd		:= "" //Produto selecionado
Local cCateg	:= "" // Categoria do produto selecionado
Local cFornece  := "" // Fornecedor do produto selecionado
Local aArea		:= SB1->( GetArea()) // Guardar e restaurar a area     
//Verifica se é produto, e se ele existe
If Len(oTree:aCargo[nPos,1]) > Len(ACV->ACV_CATEGO) .And. Left(oTree:aCargo[nPos,1],3) == "CAT"
	cCateg	:= Substr( oTree:aCargo[nPos,1], 4, Len(ACV->ACV_CATEGO) )
	cPrd		:= Substr( oTree:aCargo[nPos,1], 3 + Len(ACV->ACV_CATEGO) + 4 + 1 )
	If SB1->(DbSeek(xFilial("SB1")+cPrd)) 
		If lAdd
	    	If Len(aBrw) == 1 .And. Empty(aBrw[1,1])	
	   		aBrw[1,1] := SB1->B1_COD
	   		aBrw[1,2] := SB1->B1_DESC
	   		aBrw[1,3] := cCateg
	    	ElseIf aScan(aBrw,{|x| RTrim(x[1]) == RTrim(cPrd)}) == 0
   			aAdd(aBrw,{SB1->B1_COD,SB1->B1_DESC,cCateg})	
	    	EndIf
		Else
	    	nPos := aScan(aBrw,{|x| RTrim(x[1]) == RTrim(cPrd)})
	    	If nPos > 0                      
		    	aDel(aBrw,nPos)
	    		aSize(aBrw,Len(aBrw)-1)
			EndIf
		EndIf
		oSayTot:SetText(AllTrim(Str(Len(aBrw))))
		If Len(aBrw) == 0
			aAdd(aBrw,{"","",""})
		EndIf                                   
	 	aSort(aBrw,,,{|x,y| x[1] < y[1]})
	EndIf                       

ElseIf Len(oTree:aCargo[nPos,1]) > Len(SA5->A5_FORNECE+SA5->A5_LOJA) .And. Left(oTree:aCargo[nPos,1],3) == "FOR"
	cFornece	:= Substr( oTree:aCargo[nPos,1], 4, Len(SA5->A5_FORNECE+SA5->A5_LOJA) )
	cPrd		:= Substr( oTree:aCargo[nPos,1], 3 + Len(SA5->A5_FORNECE+SA5->A5_LOJA) + 4 + 1 )
	If SB1->(DbSeek(xFilial("SB1")+cPrd)) 
		If lAdd
	    	If Len(aBrw) == 1 .And. Empty(aBrw[1,1])	
	   		aBrw[1,1] := SB1->B1_COD
	   		aBrw[1,2] := SB1->B1_DESC
	   		aBrw[1,3] := cFornece
	    	ElseIf aScan(aBrw,{|x| RTrim(x[1]) == RTrim(cPrd)}) == 0
   				aAdd(aBrw,{SB1->B1_COD,SB1->B1_DESC,cFornece})	
	    	EndIf
		Else
	    	nPos := aScan(aBrw,{|x| RTrim(x[1]) == RTrim(cPrd)})
	    	If nPos > 0                      
		    	aDel(aBrw,nPos)
	    		aSize(aBrw,Len(aBrw)-1)
			EndIf
		EndIf
		oSayTot:SetText(AllTrim(Str(Len(aBrw))))
		If Len(aBrw) == 0
			aAdd(aBrw,{"","",""})
		EndIf                                   
	 	aSort(aBrw,,,{|x,y| x[1] < y[1]})
	EndIf    	
EndIf                       

RestArea(aArea)

oBrw:nAt := 1
oBrw:Refresh()

Return                    


//-------------------------------------------------------------------
/*/{Protheus.doc} TreeSeek()
Procura um nó na arvore    
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function TreeSeek(oTree,cPesq)
	
Local nPos	:= 0 //posição do produto no vetor          

If !Empty(cPesq)			
	//Procura pelo produto
	nPos := aScan(oTree:aNodes,{|x| Upper(RTrim(cPesq)) ==  Upper(subStr(x[4],1,at("-",x[4] ) - 1)) } )
	 
	//Procura pela categoria
	If nPos == 0
		nPos := aScan(oTree:aNodes,{|x| Upper(RTrim(cPesq)) $  Upper(RTrim(x[4])) } )	
	EndIf
	
	If nPos > 0
		oTree:TreeSeek(oTree:aCargo[nPos,1])
	Else
		Alert(STR0035)  //"Digite o código do produto ou categoria para pesquisar."
	EndIf	
Else
	Alert(STR0036) // "Produto ou categoria não encontrado"
EndIf

Return              

//-------------------------------------------------------------------
/*/{Protheus.doc} FindPrd()
Procura um produto no TwBrowse	    
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function FindPrd(oBrw,cPesq)
Local nPos := 0 //posição do produto no TwBrose

nPos := aScan(oBrw:aArray,{|x| RTrim(x[1]) == RTrim(cPesq)})               

If nPos == 0
	nPos := aScan(oBrw:aArray,{|x|  RTrim(cPesq) $ RTrim(x[2]) })               
EndIf

If nPos > 0
	oBrw:nAt := nPos
	oBrw:Refresh()
Else
	Alert(STR0037) //"Produto não encontrado"
EndIf
	
Return            

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll()
Marca/Desmarca todos os nós da arvore   
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Static Function MarkAll(oTree,oBrw,oSayTot,nOpc)
Local nX := 0     //contador            
Local lMarca := .F. //verifica se o nó está marcado ou não                      
Local bCode := Nil  //irá informar a nova situação do nó
            
If nOpc == 1
	lMarca := !(eval(oTree:aCargo[1,3]))
	
	If lMarca
		bCode := {|| .T.}
		cResource := "LBTIK"
	Else
		bCode := {|| .F.}
		cResource := "LBNO"
	EndIf
	
	For nX := 1 to Len(oTree:aCargo)
		oTree:aCargo[nX,3] := bCode
		oTree:ChangeBmp(cResource,cResource,oTree:aCargo[nX,1])    
		AtuPrdBrw(oTree,oBrw,oSayTot,nX,lMarca)
	Next nX
Else
	For nX := 1 to Len(oTree:aCargo)
		lMarca := !(eval(oTree:aCargo[nX,3]))
	
		If lMarca
			bCode := {|| .T.}
			cResource := "LBTIK"
		Else
			bCode := {|| .F.}
			cResource := "LBNO"
		EndIf
	
		oTree:aCargo[nX,3] := bCode
		oTree:ChangeBmp(cResource,cResource,oTree:aCargo[nX,1])    
		AtuPrdBrw(oTree,oBrw,oSayTot,nX,lMarca)
	Next nX	
EndIf

oTree:Refresh()
Return                      

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCatPro()
Retorna todos os produtos abaixo do nó pai 	    
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Function RetCatPro(cCodPai)                 
Local aTree := {} //vetor com itens para a arvore                                             
Local aOrd  := ACU->(GetArea()) //armazena ordem atual da tabela   

DEFAULT cCodPai := ""                     

If Empty(cCodPai)
	aTree := {"","",{}}
Else      
    ACU->(dbSetOrder(1))
    ACU->(dbSeek(xFilial("ACU")+cCodPai))
    aTree := {ACU->ACU_COD,ACU->ACU_DESC,{}}	                  
EndIf                       
    
ACU->(dbSetOrder(2))
addNodeTree(aTree[3],cCodPai)               
                     
RestArea(aOrd) 

Return aClone(aTree)

//-------------------------------------------------------------------
/*/{Protheus.doc} addNodeTree()
Função recursiva que adiciona todos os itens no vetor   	    
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function addNodeTree(aTree,cCodPai)
Local aOrd := ACU->(GetArea()) //armazena ordem atual da tabela

If (ACU->(dbSeek(xFilial("ACU")+cCodPai)))
	While !ACU->(EOF()) .AND. RTrim(ACU->ACU_CODPAI) == RTrim(cCodPai) 
    	aAdd(aTree,{ACU->ACU_COD,ACU->ACU_DESC,{}})
     	addNodeTree(aTree[Len(aTree)][3],ACU->ACU_COD)                 
     	ACU->(dbSkip())
	EndDo	
EndIf      
   
RestArea(aOrd)

Return                       
     
   
//-------------------------------------------------------------------
/*/{Protheus.doc} M603LEGEND()
Exibe a janela de legenda		    
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Function M603LEGEND()


Local aLegenda := {	{"BR_VERMELHO"	,	STR0002},;		//"Ativo"
                   	{"BR_VERDE"		,	STR0003},;		//"Inativo"
                   	{"BR_AMARELO"	,	STR0004}} 		//"Em analise"
                   	
			   		

BrwLegenda(STR0001,STR0038,aLegenda)//"Mix de Produtos" - "Legenda"
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AdiForn()
Retorna todos os produtos abaixo do nó pai por fornecedor    
@author Varejo
@since 28/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------


Function AdiForn(oTree,oBrw,oSayTot)
Local aArea:= GetArea() // salva area atual
Local cFornece:= '' // codigo do fornecedor+loja
DbSelectArea("SA5")
DbSetOrder(1)
DbSeek("",.T.)

While SA5->(!EOF() ) .AND. SA5->A5_FORNECE+SA5->A5_LOJA >= MV_PAR05+MV_PAR06 .AND. SA5->A5_FORNECE+SA5->A5_FORNECE+SA5->A5_LOJA <= MV_PAR07+MV_PAR08
    If AllTrim(cFornece) <> AllTrim(SA5->A5_FORNECE+SA5->A5_LOJA) 
		oTree:addTree( SA5->A5_NOMEFOR , "LBNO", "LBNO", SA5->A5_FORNECE+SA5->A5_LOJA,, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} )	    
		cFornece := SA5->A5_FORNECE+SA5->A5_LOJA
	Else
		oTree:addTreeItem( RTrim(SA5->A5_PRODUTO)+"-"+SA5->A5_NOMPROD, "LBNO", "FOR"+cFornece+"_PRD"+RTrim(SA5->A5_PRODUTO),, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} )
		SA5->(DbSkip()) 	           		
	EndIf

	If cFornece <> SA5->A5_FORNECE+SA5->A5_LOJA
		oTree:EndTree()
	EndIf	
EndDo

RestArea(aArea)

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldTamCpos
Verifica o tamanho dos campos DA1_PRCVEN e MFU_PRCSUG para efetivação da tabela

@author  	Varejo
@version 	1.0
@Since		03/02/2021
@return   	.T./.F.
/*/
//------------------------------------------------------------------------------
Static Function VldTamCpos()

Local lCposDiv as Logical
Local aTamDA1  as Array
Local aTamMFU  as Array

lCposDiv := .T. //Flag para informar se os campos estão diferentes
aTamDA1  := TamSX3("DA1_PRCVEN")
aTamMFU	 := TamSX3("MFU_PRCSUG")  

If aTamDA1[1] <> aTamMFU[1] .Or. aTamDA1[2] <> aTamMFU[2]     
	lCposDiv := .F.	                                                              
EndIf 
	
Return lCposDiv
