#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "dbtree.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "PLSA99B.ch"            
#INCLUDE "PLSMGER.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA99B

Cadastro de Solicitacao de Cancelamento de Planos
@author  Renan Sakai
@version P11 
@since   20/03/17
/*/
//-------------------------------------------------------------------
Function PLSA99B(lAutoma)   

Local cFiltro  := " B5J_FILIAL = '"+xFilial("B5J")+"' "
Local cPerg    := "PLSA99B"
Local cOpeSol  := ""
Local cEmpDe   := ""
Local cEmpAte  := ""
Local nStatus  := 0
Local oBrowse
Local dDatDe
Local dDatAte
Local bKeyF12 := SetKey(VK_F12, {|| filtroF12(oBrowse) })
Local lGerProRat  := GetNewPar("MV_PL9BPRA","0") == "1"

Default lAutoma := .F.

If !PLSALIASEX("B5J") .Or. !PLSALIASEX("B5K") 
	Aviso( STR0015,STR0052,{ "OK" }, 2 )//"É necessário executar o compatibilizador 'UPDCANPLA' para iniciar a rotina."
	Return
EndIf

If Pergunte(cPerg,.T.)
	cOpeSol   := mv_par01 
	dDatDe    := mv_par02
	dDatAte   := mv_par03  
	cEmpDe    := mv_par04
	cEmpAte   := mv_par05  
	nStatus   := mv_par06

	If !Empty(cOpeSol)
		cFiltro += " .AND. B5J_OPESOL = '"+cOpeSol+"' "
	EndIf     

	If !Empty(dDatDe)
		
		cFiltro += " .AND. Dtos(B5J_DATSOL) >= '"+ Dtos(dDatDe) +"' "
	EndIf
	If !Empty(dDatAte)
		
		cFiltro += " .AND. Dtos(B5J_DATSOL) <= '"+ Dtos(dDatAte) +"' "
	EndIf      

	If !Empty(cEmpDe)
		cFiltro += " .AND. B5J_CODEMP >= '"+ cEmpDe +"' "
	EndIf
	If !Empty(cEmpAte)
		cFiltro += " .AND. B5J_CODEMP <= '"+ cEmpAte +"' "
	EndIf
	
	If cValtoChar(nStatus) $ "123"
		cFiltro += " .AND. B5J_STATUS = '"+cValtoChar(nStatus-1)+"' "
	EndIf

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	// Definição da tabela do Browse
	oBrowse:SetAlias('B5J')
	//Definicao de filtro de tela
	oBrowse:SetFilterDefault(cFiltro)
	// Titulo da Browse
	oBrowse:SetDescription(STR0001)//"Solicitação Cancelamento de Planos"
	// Ativação da Classe
	Iif(!lAutoma,oBrowse:Activate(),"")
	
	//Tecla para refazer o filtro
	SetKey(VK_F12, bKeyF12)
EndIf

Return Iif(!lAutoma,Nil,.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu da aplicação 

@author  Renan Sakai
@version P11
@since   13/03/17
/*/
//------------------------------------------------------------------- 

Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.PLSA99B' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 	Action 'VIEWDEF.PLSA99B' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 	Action 'AltPL99B()'	 	 OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.PLSA99B' OPERATION 5 ACCESS 0  //'Excluir'
ADD OPTION aRotina Title STR0006    Action 'PL99BRelat(.F.)'         OPERATION 6 ACCESS 0     //'Impressão Solicitação'
ADD OPTION aRotina Title STR0007    Action 'PL99BRelat(.F.,nil,.T.)' OPERATION 6 ACCESS 0    //'E-mail Solicitação'
ADD OPTION aRotina Title STR0008    Action 'PL99BRelat(.F.,nil,nil,"C")' OPERATION 6 ACCESS 0      //'Impressão Confirmação'
ADD OPTION aRotina Title STR0009     Action 'PL99BRelat(.F.,nil,.T.,"C")' OPERATION 6 ACCESS 0 //'E-mail Confirmação' 
ADD OPTION aRotina Title STR0010      Action 'PL99BBloq()'     OPERATION 7 ACCESS 0  //'Processa Bloqueio'
ADD OPTION aRotina Title STR0011     Action 'PL99BBCDoc()'     OPERATION 9 ACCESS 0 //'Banco de Conhecimento'

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados da aplicação   

@author  Renan Sakai
@version P11
@since   13/03/17
/*/
//------------------------------------------------------------------- 

Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruB5J 		:= FWFormStruct( 1, 'B5J' )
Local oStruB5K 		:= FWFormStruct( 1, 'B5K' )

Local oModel // Modelo de dados construído
Local aAux   := {}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA99B',, {|oModel| PL99BPosValid(oModel)}, { |oModel| PLGrv99B( oModel ) } ) 

//Adiciona gatilhos
aAux := FwStruTrigger(;
		'B5J_MATSOL' ,;
		'B5J_NOMSOL' ,;
		'BA1->BA1_NOMUSR',;
		.T.            ,;
		'BA1'          ,;
		2              ,;
		'xFilial("BA1")+M->B5J_MATSOL',;
		'!Empty(M->B5J_MATSOL)' )
		
		oStruB5J:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )	 
		
//Adiciona gatilhos
aAux := FwStruTrigger(;
		'B5J_MATSOL' ,;
		'B5J_OPESOL' ,;
		'BA1->BA1_CODINT',;
		.T.            ,;
		'BA1'          ,;
		2              ,;
		'xFilial("BA1")+M->B5J_MATSOL',;
		'!Empty(M->B5J_MATSOL)' )
		
		oStruB5J:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )	
		

//Adiciona gatilhos
aAux := FwStruTrigger(;
		'B5J_MATSOL' ,;
		'B5J_CODEMP' ,;
		'BA1->BA1_CODEMP',;
		.T.            ,;
		'BA1'          ,;
		2              ,;
		'xFilial("BA1")+M->B5J_MATSOL',;
		'!Empty(M->B5J_MATSOL)' )
		
		oStruB5J:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )	
						

//Adiciona gatilhos
aAux := FwStruTrigger(;
		'B5J_MATSOL' ,;
		'B5J_MATRIC' ,;
		'BA1->BA1_MATRIC',;
		.T.            ,;
		'BA1'          ,;
		2              ,;
		'xFilial("BA1")+M->B5J_MATSOL',;
		'!Empty(M->B5J_MATSOL)' )
		
		oStruB5J:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )	
		

//Adiciona gatilhos
aAux := FwStruTrigger(;
		'B5J_MATSOL' ,;
		'B5J_EMAIL' ,;
		'BA1->BA1_EMAIL',;
		.T.            ,;
		'BA1'          ,;
		2              ,;
		'xFilial("BA1")+M->B5J_MATSOL',;
		'!Empty(M->B5J_MATSOL)' )
		
		oStruB5J:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )	 
		
				
aAux := FwStruTrigger(;
		'B5K_MATUSU' ,;
		'B5K_NOMBEN' ,;
		'BA1->BA1_NOMUSR',;
		.T.            ,;
		'BA1'          ,;
		2              ,;
		'xFilial("BA1")+M->B5K_MATUSU',;
		'!Empty(M->B5K_MATUSU)' )
		
		oStruB5K:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )	


aAux := FwStruTrigger(;
		'B5K_MATUSU' ,;
		'B5K_CPFUSR' ,;
		'BA1->BA1_CPFUSR',;
		.T.            ,;
		'BA1'          ,;
		2              ,;
		'xFilial("BA1")+M->B5K_MATUSU',;
		'!Empty(M->B5K_MATUSU)' )
		
		oStruB5K:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )	


aAux := FwStruTrigger(;
		'B5K_MATUSU' ,;
		'B5K_DATINC' ,;
		'BA1->BA1_DATINC',;
		.T.            ,;
		'BA1'          ,;
		2              ,;
		'xFilial("BA1")+M->B5K_MATUSU',;
		'!Empty(M->B5K_MATUSU)' )
		
		oStruB5K:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )	
		
				
				
// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'B5JMASTER', /*cOwner*/, oStruB5J )  

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'B5KDETAIL', 'B5JMASTER', oStruB5K, { |oModelGrid, nLine, cAction, cField| vldGridB5K(oModelGrid, nLine, cAction, cField) } )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'B5KDETAIL', { { 'B5K_FILIAL', 'xFilial( "B5K" )'},;
       								{ 'B5K_CODIGO', 'B5J_CODIGO' } }, B5K->( IndexKey( 1 ) ) )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( STR0053 ) //"Solicitação de Cancelamento de Planos"

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'B5JMASTER' ):SetDescription( STR0012 ) //"Solicitação"

//Seta Chaves primarias
oModel:SetPrimaryKey({})

//Indica chave unica na grid                                      
oModel:GetModel( 'B5KDETAIL' ):SetUniqueLine( { 'B5K_MATUSU' } )     


// Retorna o Modelo de dados
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 

@author  Renan Sakai
@version P11
@since   13/03/17
/*/
//------------------------------------------------------------------- 

Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSA99B' )

// Cria as estruturas a serem usadas na View
Local oStruB5J 			:= FWFormStruct( 2, 'B5J' )
Local oStruB5K 			:= FWFormStruct( 2, 'B5K' )

//Interface de visualização construída
Local oView
		
//Retira o campo código da tela       
oStruB5J:RemoveField('B5J_OPESOL')
oStruB5J:RemoveField('B5J_CODEMP')
oStruB5J:RemoveField('B5J_MATRIC')
oStruB5K:RemoveField('B5K_CODIGO')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_B5J', oStruB5J, 'B5JMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_B5K', oStruB5K, 'B5KDETAIL' )

//Nao deixa duplicar o campo B5K_CAMPO
//oModel:GetModel( 'B5KDETAIL' ):SetUniqueLine( { "B5K_FILIAL","B5K_TIPGUI","B5K_SEQUEN"} )
//oModel:GetModel( 'B7BDETAIL' ):SetUniqueLine( { "B7B_FILIAL","B7B_TIPGUI","B7B_ORDEM"} )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

//Cria as Folders           
oView:CreateFolder( 'PASTA_SUPERIOR' ,'SUPERIOR' )
oView:CreateFolder( 'PASTA_INFERIOR' ,'INFERIOR' )

//Cria as pastas   
oView:AddSheet( 'PASTA_SUPERIOR'    , 'ABA_SOLIC'    , STR0013 ) //"Dados Solicitação"
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_BENEF'    , STR0014 ) //"Beneficiarios"

oView:CreateVerticalBox( 'BOX_SOLIC', 100,,, 'PASTA_SUPERIOR', 'ABA_SOLIC' )
oView:CreateVerticalBox( 'BOX_BENEF', 100,,, 'PASTA_INFERIOR', 'ABA_BENEF' )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_B5J', 'BOX_SOLIC' )
oView:SetOwnerView( 'VIEW_B5K', 'BOX_BENEF' )
                                                     
//Carrega familia automaticamente
oView:SetFieldAction( 'B5J_MATSOL', { |oView, cIDView, cField, xValue| IncMatProc( oModel, oView, cIDView, cField, xValue ) } )

//Adiciona campo incremental
//oView:AddIncrementField( 'VIEW_B5J', 'B5J_CODIGO' )
//oView:AddIncrementField( 'VIEW_B7BPOR', 'B7B_ORDEM' )
//oView:AddIncrementField( 'VIEW_B7C', 'B7C_ORDEM' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BVldFi
Funcao padrao de valid de campos  

@author  Renan Sakai
@version P11
@since   13/03/17
/*/
//-------------------------------------------------------------------     
Function PL99BVldFi()
Local lRet := .T.
LOCAL cTitular    := GetNewPar("MV_PLCDTIT","T")
Local cNumProto   := Space(20)
Local aAreaA      := {}        
Local aAreaB      := {}     
Local cMatric     := ""
local lAutoma :=  IIf(type('lAutXXXR')=='U', .F., lAutXXXR)

Do Case
	Case ReadVar() == "M->B5J_MATSOL" .And. (FunName() <> "RPC" .Or. lAutoma)
		BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		
		If Empty(M->B5J_MATSOL)
			Aviso( STR0015,STR0063,{ "OK" }, 2 )//"É necessário informar o solicitante."
			lRet := .F.       
		ElseIf !Empty(M->B5J_NOMSOL)  
	    	Aviso( STR0015,STR0062,{ "OK" }, 2 )//"Não é possível trocar o solicitante depois de selecionado."
			lRet := .F. 
	    	
		ElseIf BA1->(MsSeek(xFilial("BA1")+M->B5J_MATSOL))
			//Verifica se e dependente maior de idade
			If BA1->BA1_TIPUSU != cTitular .And. (Calc_Idade(dDataBase,BA1->BA1_DATNAS) < 18 )
				Aviso( STR0015,STR0016,{ "OK" }, 2 )//"Beneficiário dependente deve ser maior para realizar a solicitação."
				lRet := .F. 
		    EndIf  
		    
		    //Verifica se e dependente com solicitacao pendente
			aAreaA := B5K->(GetArea())
			aAreaB := B5J->(GetArea())   
			B5K->(DbSetOrder(2))//B5K_FILIAL+B5K_MATUSU
			If lRet .And. BA1->BA1_TIPUSU != cTitular .And. B5K->(MsSeek(xFilial("B5K")+M->B5J_MATSOL))
			    
			  	If !Empty(BA1->BA1_MOTBLO)  
			  		Aviso( STR0015,STR0020,{ "OK" }, 2 )//"Beneficiário informado já está bloqueado."
			   		lRet := .F.  
			  	Else
					While B5K->(B5K_FILIAL+B5K_MATUSU) == xFilial("B5K")+M->B5J_MATSOL .And. !B5K->(Eof())
						B5J->(DbSetOrder(1))//B5J_FILIAL+B5J_CODIGO
					    If B5J->(MsSeek(xFilial("B5J")+B5K->B5K_CODIGO)) .And. B5J->B5J_STATUS == "0"
					   	 	Aviso( STR0015,STR0054,{ "OK" }, 2 )//"O beneficiário informado já tem uma solicitação pendente."
				 	  		lRet := .F.   
				 	  		Exit
					    EndIf   
					    
					    B5K->(DbSkip())
					EndDo
				EndIf    
			EndIf
			RestArea(aAreaA)
			RestArea(aAreaB)  
			
		    //Nao permite usuario de intercambio 
		    If BA1->BA1_CODEMP == GetNewPar("MV_PLSGEIN","0050")
		    	Aviso( STR0015,STR0017,{ "OK" }, 2 )//"A solicitação de cancelamento não pode ser realizada para beneficiários de intercâmbio."
				lRet := .F. 
			EndIf	  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Necessario gerar protocolo de atendimento		                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			If FunName() <> "TMKA271" .And. lRet
 				Iif(!lAutoma,P773AutInc("B5J",@cNumProto ,nil ,.F.,nil,nil,.F.,nil,M->B5J_MATSOL,nil,.T.),cNumProto := "41750520200415000026")   
				M->B5J_PROTOC := cNumProto
   				If Empty(cNumProto)
   					Aviso( STR0015,STR0018,{ "OK" }, 2 ) //"É necessário gerar um protocolo de atendimento."
	   				lRet := .F. 	
   				EndIf
  			EndIf
	        
		Else
			Aviso( STR0015,STR0019,{ "OK" }, 2 )//"Matrícula informada não foi encontrada."
			lRet := .F. 
		EndIf  
		
	Case ReadVar() == "M->B5K_MATUSU" .And. !Empty(M->B5K_MATUSU) .And. (FunName() <> "RPC" .Or. lAutoma)
		BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If BA1->(MsSeek(xFilial("BA1")+M->B5K_MATUSU))  
			//Valida usuario bloqueio
			If !Empty(BA1->BA1_MOTBLO)     
				Aviso( STR0015,STR0020,{ "OK" }, 2 )//"Beneficiário informado já está bloqueado."
		 		lRet := .F. 
			Endif                    
			
			If Substr(M->B5K_MATUSU,1,14) <> Substr(M->B5J_MATSOL,1,14)
 				Aviso( STR0015,STR0061,{ "OK" }, 2 )//"O beneficiário solicitado é de uma família diferente do solicitante."
		 		lRet := .F. 
			EndIf
			
			//Valida solicitacao pendente
			aAreaA := B5K->(GetArea())
			aAreaB := B5J->(GetArea())   
			B5K->(DbSetOrder(2))//B5K_FILIAL+B5K_MATUSU
			If lRet .And. B5K->(MsSeek(xFilial("B5K")+M->B5K_MATUSU))
				cMatric := M->B5K_MATUSU    
				
				While B5K->(B5K_FILIAL+B5K_MATUSU) == xFilial("B5K")+cMatric .And. !B5K->(Eof())
					B5J->(DbSetOrder(1))//B5J_FILIAL+B5J_CODIGO
				    If B5J->(MsSeek(xFilial("B5J")+B5K->B5K_CODIGO)) .And. B5J->B5J_STATUS == "0"
				   	 	Aviso( STR0015,STR0054,{ "OK" }, 2 )//"O beneficiário informado já tem uma solicitação pendente."
			 	  		lRet := .F. 
				    EndIf 
					B5K->(DbSkip())
				EndDo
				    
			EndIf
			RestArea(aAreaA)
			RestArea(aAreaB)  
			
			//Usuario dependente so permite ele na solicitacao 
			BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
			If lRet .And. BA1->(MsSeek(xFilial("BA1")+M->B5J_MATSOL)) .And. (BA1->BA1_TIPUSU <> cTitular) .And. (M->B5J_MATSOL <> M->B5K_MATUSU )
		    	Aviso( STR0015,STR0055,{ "OK" }, 2 )//"Beneficiário dependente só pode realizar a solicitação para ele mesmo."
		 		lRet := .F. 
			Endif
		Else
			Aviso( STR0015,STR0019,{ "OK" }, 2 )//"Matrícula informada não foi encontrada."
			lRet := .F. 
		EndIf
EndCase

Return lRet     


//-------------------------------------------------------------------
/*/{Protheus.doc} IncMatProc
Processo ao inclusao da matricula do solicitante

@author  Renan Sakai
@version P11
@since   13/03/17
/*/
//-------------------------------------------------------------------  
Static Function IncMatProc(oModel, oView, cIDView, cField, xValue, lAutoma)
Local lBenef      := .F.
Local lRet        := .F.   
Local lIncluiUsu  := .T.
Local lFindUsu    := .F.
Local oModelB5K   := oModel:GetModel( 'B5KDETAIL' )   
Local aAreaA      := {}
Local aAreaB      := {}
Local cTitular    := GetNewPar("MV_PLCDTIT","T")
Local nI          := 0
Local nLenGrid    := 0

Default lAutoma   := .F.

BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
If !Empty(xValue) .And. BA1->(MsSeek(xFilial("BA1")+xValue))     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo titular, permite carregar toda a familia                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BA1->BA1_TIPUSU == cTitular   
		nLenGrid   := oModelB5K:Length()     
		
		If nLenGrid == 1
	   		oModelB5K:GoLine(1)  
			cMatAux := oModelB5K:GetValue("B5K_MATUSU") 
		    If BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) == cMatAux
		    	lIncluiUsu := .F.
		    EndIf
		Else
			lIncluiUsu := .F.
		EndIf	

		If (lIncluiUsu .And. Iif(!lAutoma,MsgYesNo(STR0021),"")) .Or. lAutoma//"Deseja carregar todos os beneficiários da família?"
	
			While BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+Substr(xValue,1,14) .And. !BA1->(Eof())
	
				lBenef := .T.  
				
				If Empty(BA1->BA1_MOTBLO)
					aAreaA := B5K->(GetArea())
					aAreaB := B5J->(GetArea())   
					B5K->(DbSetOrder(2))//B5K_FILIAL+B5K_MATUSU
					If B5K->(MsSeek(xFilial("B5K")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ))    
						While B5K->(B5K_FILIAL+B5K_MATUSU) == xFilial("B5K")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) .And. !B5K->(Eof())
							B5J->(DbSetOrder(1))//B5J_FILIAL+B5J_CODIGO
						    If B5J->(MsSeek(xFilial("B5J")+B5K->B5K_CODIGO)) .And. B5J->B5J_STATUS == "0"
						   	 	Aviso( STR0015,STR0056+Alltrim(BA1->BA1_NOMUSR)+STR0057,{ "OK" }, 2 ) //"O beneficiário "###" já tem uma solicitação pendente."
					 	  		lBenef := .F.    
					 	  		Exit
						    EndIf   
							
							B5K->(DbSkip())
						EndDo    
					EndIf
					RestArea(aAreaA)
					RestArea(aAreaB)
				Else
					lBenef := .F.
				EndIf
	
				If lBenef
					Iif(!lAutoma,oModelB5K:AddLine(.T.),"")
					Iif(!lAutoma,FwFldPut("B5K_MATUSU",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)),"")
					Iif(!lAutoma,FwFldPut("B5K_NOMBEN",BA1->BA1_NOMUSR),"")
					lFindUsu := .T.
				EndIf        	
			
				BA1->(DbSkip())
			EndDo
	    
	    	If lFindUsu
	    		Iif(!lAutoma,oModelB5K:GoLine(1),"")
				Iif(!lAutoma, oView:Refresh( 'VIEW_B5K' ),"")
				Iif(!lAutoma,oView:Refresh( 'VIEW_B5J' ),"")
			Else
				Iif(!lAutoma,Aviso( STR0015,STR0022,{ "OK" }, 2 ),"")	//"Não foram encontrados beneficiários ativos na família selecionada."
			EndIf	
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo dependente, carrega somente o solicitante                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else   
		oModelB5K:GoLine(1)   
		nLenGrid  := oModelB5K:Length()   
	  	
	  	For nI := 1 to nLenGrid
			If !oModelB5K:IsDeleted(nI)
				oModelB5K:GoLine(nI)  
				cMatAux := oModelB5K:GetValue("B5K_MATUSU") 
			    If BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) == cMatAux
			    	lIncluiUsu := .F.
			    EndIf
			EndIf
 		Next nI
		
		If lIncluiUsu
			oModelB5K:AddLine(.T.)
			FwFldPut("B5K_MATUSU",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
			FwFldPut("B5K_NOMBEN",BA1->BA1_NOMUSR) 
			
			oView:Refresh( 'VIEW_B5K' )	 
			oView:Refresh( 'VIEW_B5J' )	
		EndIf	
	EndIf
		
	lRet := .T.
EndIf

Return lRet  
                       

//-------------------------------------------------------------------
/*/{Protheus.doc} IncMatProc
Processo ao inclusao da matricula do solicitante

@author  Renan Sakai
@version P11
@since   13/03/17
/*/
//------------------------------------------------------------------- 
Static Function PLGrv99B(oModel)  
Local lRet := .T.                    
Local oModelB5J   := oModel:GetModel( 'B5JMASTER' )  
Local oModelB5K   := oModel:GetModel( 'B5KDETAIL' )
Local nOpca    := 0      
Local nX       := 0                     
Local bConfirm  := {|| nOpca := 1, oDlg:End() }
Local bCancel   := {|| nOpca := 0, oDlg:End() }   
Local nOperation	:= oModel:GetOperation()

Local cMatric := oModelB5J:GetValue("B5J_MATSOL")
Local cProtoc := oModelB5J:GetValue("B5J_PROTOC")
Local cCodigo := oModelB5J:GetValue("B5J_CODIGO")
Local cOrigem := oModelB5J:GetValue("B5J_ORISOL")
Local cStatus := oModelB5J:GetValue("B5J_STATUS")
Local cObserv := oModelB5J:GetValue("B5J_OBSERV")
Local cEmail  := oModelB5J:GetValue("B5J_EMAIL")   
local lAutoma :=  IIf(type('lAutXXXR')=='U', .F., lAutXXXR)

If nOperation == MODEL_OPERATION_INSERT
	oModel:SetValue( 'B5JMASTER', 'B5J_HORSOL', Time() )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do Portal                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                     
If nOperation == MODEL_OPERATION_INSERT .And. FunName() == "RPC"
	gerRegB00(cProtoc,nil,"",nil,nil,cMatric,.F.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.)
	P773CPCon(cProtoc,cCodigo,cOrigem,cStatus,cObserv,cEmail)  
	FWFormCommit( oModel )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de registro call center                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nOperation == MODEL_OPERATION_INSERT .And. FunName() == "TMKA271"
	P773CPCon(cProtoc,cCodigo,cOrigem,cStatus,cObserv,cEmail)  
	FWFormCommit( oModel )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de registro remote                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nOperation == MODEL_OPERATION_INSERT
   
  		DEFINE MSDIALOG oDlg TITLE STR0023 FROM 000,000 TO 012,050//"Confirmação Solicitacao Cancelamento de Plano"
   
  		@ 020,015 SAY oSay PROMPT STR0024  SIZE 150,010 OF oDlg PIXEL //"Imprime relatório com a Solicitação de Cancelamento"
    	@ 018,150 BUTTON STR0027  SIZE 36,13 PIXEL ACTION PL99BRelat(.T.,oModel)  //"Imprimir"
	    
	   	@ 040,015 SAY oSay PROMPT STR0025  SIZE 150,010 OF oDlg PIXEL //"Confirma a inclusão da Solicitação de Cancelamento"
   		@ 038,150 BUTTON STR0028 SIZE 36,13 PIXEL ACTION Eval(bConfirm)    //"Confirmar"
	   	
	   	@ 060,015 SAY oSay PROMPT STR0026  SIZE 150,010 OF oDlg PIXEL //"Cancela a inclusão da Solicitação de Cancelamento"
   		@ 058,150 BUTTON STR0029  SIZE 36,13 PIXEL ACTION Eval(bCancel)//"Cancelar"
	
		//Ativa dialogo
		ACTIVATE MSDIALOG oDlg CENTERED 

	//Confirma gravacao da solicitacao
	If nOpca == 1
		P773CPCon(cProtoc,cCodigo,cOrigem,cStatus,cObserv,cEmail)  
		FWFormCommit( oModel )
	ElseIf nOpca == 0		
		lRet := .F.
		Iif(!lAutoma,Help( ,, 'Help',, 'Solicitação Cancelada.', 1, 0 ),"")
		
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracao de registro                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nOperation == MODEL_OPERATION_UPDATE
	FWFormCommit( oModel )
	//Aviso( STR0015,"Atualização da solicitação realizada com sucesso.",{ "OK" }, 2 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclusao de registro                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
ElseIf nOperation == MODEL_OPERATION_DELETE
	If M->B5J_STATUS <> "0"
		Iif(!lAutoma,Aviso( STR0015,STR0030,{ "OK" }, 2 ),"")	//"Não é possível realizar a exclusão, o bloqueio já foi efetuado."
	Else
		FWFormCommit( oModel )  
		B00->(DbSetOrder(1))
		If B00->(FieldPos("B00_CANCEL")) > 0 .And. B00->(MsSeek(xFilial("B00")+M->B5J_PROTOC))
			B00->(RecLock("B00",.F.))
			B00->B00_CANCEL := "1"
			B00->(MsUnLock())
		EndIf   
		Iif(!lAutoma,Aviso( STR0015,STR0031,{ "OK" }, 2 ),"")	//"Exclusão da solicitação realizada com sucesso."
	Endif	
EndIf 

Return lRet   



//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BRelat

Imprime relatório de solicitacao de Cancelamento do Plano

@author  PLS TEAM
@version P11
@since   15/03/16
/*/
//-------------------------------------------------------------------   
Function PL99BRelat(lPreGrav,oModel,lImpEmail,cTipRel,lBloqueio,lPortalWeb,cFileWeb, lAutoma)

Local aRet := {}
Local aDados := {}
Local aOperadora := {}
Local aBene := {}
Local aFamilia := {}
Local aCampos := {}	  
Local cTelCen := GetNewPar( "MV_PLSRTCA" , "" )	// Define o Telefone da Central de Atendimento a ser utilizado na impressão de cartas do SIGAPLS
Local nLenGrid := 0
Local nI := 0

Local cPathServ	:= GetNewPar( "MV_PLDIDOT" , "\dot" )
Local cSubPasta := PLSMUDSIS("pdf_email\")   
Local cEmailTo := ""
Local lRetMail := .F.
Local lRet := .T.

Local oModelB5J    
Local oModelB5K
Local cProtoc := ""
Local cCodigo := ""
Local cOrigem := ""
Local cStatus := ""
Local cObserv := ""
Local cData := "" 
Local cMatric := ""    
Local cMatAux := ""
Local cMsg := ""
Local oMulta := Nil
Local aBeneficiarios := {}
Local lBenefBloqueado := .F.
Local nPosBenef := 0
Local nX := 0

Default lPreGrav := .F.
Default oModel := nil     
Default lImpEmail := .F.      
Default cTipRel := "S" //"S"-Soliciticao / "C"-Conclusão      
Default lBloqueio := .F.
Default lPortalWeb := .F.
Default cFileWeb := ''
Default lAutoma := .F.

If cTipRel == "C" .And. !B5J->B5J_STATUS $ "12"
	If !lPortalWeb
		Aviso( STR0015, STR0032 , {"OK"} ) //"Para gerar o relatório de Confirmação de Cancelamento de Plano, é necessário efetuar o bloqueio solicitado."
	EndIf
	Return 
EndIf     

If lImpEmail .And. Empty(B5J->B5J_EMAIL)
	Aviso( STR0015, STR0033 , {"OK"} ) //"O e-mail para envio não foi informado."
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados da impresso pre-gravacao da solicitacao                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPreGrav
	oModelB5J := oModel:GetModel( 'B5JMASTER' )  
	oModelB5K := oModel:GetModel( 'B5KDETAIL' )  
	cProtoc   := oModelB5J:GetValue("B5J_PROTOC")
	cCodigo   := oModelB5J:GetValue("B5J_CODIGO")
	cOrigem   := oModelB5J:GetValue("B5J_ORISOL")
	cStatus   := oModelB5J:GetValue("B5J_STATUS")
	cObserv   := oModelB5J:GetValue("B5J_OBSERV")  
	dData     := oModelB5J:GetValue("B5J_DATSOL")    
	cMatric   := oModelB5J:GetValue("B5J_MATSOL") 
	cEmailTo  := Alltrim(Lower(oModelB5J:GetValue("B5J_EMAIL")))

	nLenGrid  := oModelB5K:Length()
    
	For nI := 1 to nLenGrid
		If !oModelB5K:IsDeleted(nI)
			oModelB5K:GoLine(nI)  
			cMatAux := oModelB5K:GetValue("B5K_MATUSU") 
		    Aadd(aFamilia,InfBenRel(cMatAux,cTipRel))
			aAdd(aBeneficiarios, cMatAux)
		EndIf
	Next nI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados da impresso de solicitacao ja gravada                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	cProtoc   := B5J->B5J_PROTOC
	cCodigo   := B5J->B5J_CODIGO
	cOrigem   := B5J->B5J_ORISOL
	cStatus   := B5J->B5J_STATUS
	cObserv   := B5J->B5J_OBSERV  
	dData     := B5J->B5J_DATSOL    
	cMatric   := B5J->B5J_MATSOL     
	cEmailTo  := Alltrim(Lower(B5J->B5J_EMAIL))
	
	B5K->(DbSetOrder(1))//B5K_FILIAL+B5K_CODIGO+B5K_MATUSU
	If B5K->(MsSeek(xFilial("B5K")+B5J->B5J_CODIGO)) 
		While B5K->(B5K_FILIAL+B5K_CODIGO) == xFilial("B5K")+B5J->B5J_CODIGO .And. !B5J->(Eof())
			Aadd(aFamilia,InfBenRel(B5K->B5K_MATUSU,cTipRel))
			aAdd(aBeneficiarios, B5K->B5K_MATUSU)
			B5K->(DbSkip())
		EndDo
	EndIf
EndIf	
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Array aDados                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDados[01] -> Municipio Operadora
aDados[02] -> UF Municipio Operadora      
aDados[03] -> Data Impressao
aDados[04] -> Nome Beneficiario  
aDados[05] -> Data Atendimento/Protocolo
aDados[06] -> CPF
aDados[07] -> Matricula Beneficiario
aDados[08] -> Telefone Central
aDados[09] -> Nome Operadora
aDados[10] -> Numero Protocolo
aDados[11] -> Observacao (somente Guias de Atendimento)
aDados[12] -> Array com a familia
*/ 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com dados para impressao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BA0")
BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0") + PlsIntPad()))
	aOperadora := { BA0->(BA0_NOMINT),BA0->(BA0_CIDADE),BA0->(BA0_EST) }   
EndIf

BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
If BA1->(MsSeek(xFilial("BA1")+cMatric)) 
	aBene := { Alltrim(BA1->BA1_NOMUSR),BA1->BA1_CPFUSR,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) }

	If !Empty(BA1->BA1_MOTBLO)
		lBenefBloqueado := .T.
	EndIf
EndIf	

aDados	:= Array(13) //Se criar mais itens no array, adicionar aqui o tamanho da estruttura
aDados[01] := IIf( Empty(aOperadora[02]) ,"[Mun. Operadora não infornado]"	,AllTrim(aOperadora[02]) )
aDados[02] := IIf( Empty(aOperadora[03]) ,"[UF. Operadora não infornado]" 	,AllTrim(aOperadora[03]) )
aDados[03] := StrZero(Day(Date()),2) +" de "+ MesExtenso( Month(Date()))  +" de "+  Str(Year(Date()),4)
aDados[04] := IIf( Empty(aBene[01])      ,"[Beneficiário não infornado]"  	,AllTrim(aBene[01]) )
aDados[05] := StrZero(Day(dData),2) +" de "+ MesExtenso( Month(dData))  +" de "+  Str(Year(dData),4)
aDados[06] := IIf( Empty(aBene[02])          ,"[CPF não informado]"           	,Transform(AllTrim(aBene[02]), "@R 999.999.999-99") )
aDados[07] := IIf( Empty(aBene[03])          ,"[Matricula não infornado]"     	,Transform(AllTrim(aBene[03]), "@R !!!!.!!!!.!!!!!!-!!-!") )
aDados[08] := IIf( Empty(cTelCen)            ,"0800-000.0000"                 	,AllTrim(cTelCen) )
aDados[09] := IIf( Empty(aOperadora[01])     ,"[Operadora não infornado]"     	,AllTrim(aOperadora[01]) )
aDados[10] := cProtoc
aDados[11] := cObserv 
aDados[12] := aFamilia

If FindClass("PLBenefMulta") .And. cTipRel == "S"
	oMulta := PLBenefMulta():New()

	If oMulta:SetBeneficiarios(aBeneficiarios, dDataBase)
		If lBenefBloqueado
			If oMulta:CheckDadosCobranca(BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC)
				aDados[13] := oMulta:GetDetalhe()
			EndIf
		Else
			If oMulta:Calcular() > 0
				aDados[13] := oMulta:GetDetalhe()					
			EndIf
		EndIf

		If ValType(aDados[13]) == "J"
			For nX := 1 To Len(aBeneficiarios)

				nPosBenef := aScan(aDados[13]["beneficiarios"], {|x| x["idMatricula"] == aBeneficiarios[nX]})

				If nPosBenef > 0
					aAdd(aFamilia[nX], {STR0070, "R$ "+Alltrim(Transform(aDados[13]["beneficiarios"][nPosBenef]["valorMulta"], "@E 9,999,999,999,999.99"))}) // "Valor da Multa:"
				EndIf
			Next
		EndIf
	EndIf
EndIf
	
//Verifica existencia do Rdmake do relatorio  
If cTipRel == "S"
	If !ExistBlock("PL99BSol") .And. !lAutoma
		Aviso( STR0015, STR0034 , {"OK"} )//"Não foi encontrado o arquivo de modelo de relatório. Contate o administrador do sistema."
		Return 
	EndIf                                                            
ElseIf cTipRel == "C"
	If !ExistBlock("PL99BCon") .And. !lAutoma
		Aviso( STR0015, STR0034 , {"OK"} )//"Não foi encontrado o arquivo de modelo de relatório. Contate o administrador do sistema."
		Return 
	EndIf
	
	If B5J->B5J_STATUS == "0" .And. !lAutoma
		Aviso( STR0015, STR0035 , {"OK"} )//"Para gerar o relatório de Conclusão, é necessário realizar o bloqueio solicitado."
		Return 
	EndIf      
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao com o corpo do relatorio								        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If cTipRel == "S"
	If !lAutoma
		aRet := ExecBlock( "PL99BSol", .F., .F., {aDados,lImpEmail,lPortalWeb} )   
	Else
		aRet := {.T., "",""}
	EndIf
ElseIf cTipRel == "C"
	If !lAutoma
		aRet := ExecBlock( "PL99BCon", .F., .F., {aDados,lImpEmail,lPortalWeb} )   
	Else
		aRet := {.T., "",""}
	EndIf
EndIf
	
lRet     := aRet[1]
cFileWeb := aRet[3]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o envio de email             								        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpEmail .And. lRet .And. !lPortalWeb .And. !lAutoma
	aRet[2] := PLSMUDSIS(aRet[2])

	If !Empty(cEmailTo)
		
		If !(Substr(cPathServ,len(cPathServ),1) == "\" .Or. Substr(cPathServ,len(cPathServ),1) == "/")
			cPathServ += "\"
		EndIF
		cPathServ  := PLSMUDSIS(cPathServ+cSubPasta)
		cEmailTo   := ALLTRIM(Lower(B5J->B5J_EMAIL))
		
		lRet := CpyT2S( aRet[2]+aRet[3], cPathServ, .F. )
		
		If (lRet .And. lBloqueio) .Or. (lRet .And. MsgYesNo(STR0036 +CRLF+ cEmailTo) )//"Deseja enviar o comprovante para o email: "
			lRetMail := A99BMail(cEmailTo, ;
			cProtoc, ;
			cPathServ+aRet[3],;
			lAutoma,;
			cTipRel)
			
			If lRetMail  
				cMsg := STR0037 //"E-mail com Comprovante enviado com sucesso."
			Else   
				cMsg := STR0038 //"Problemas ao enviar o e-mail ao Usuário. Entre em contato com o administrador."
			EndIf  

		EndIf
	Else 
		cMsg := STR0039//"E-mail não encontrado no registro de Protocolos"
	EndIf
EndIf   

If !lPortalWeb  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe mensagem caso nao seja um bloqueio                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMsg) .And. !lBloqueio
		Aviso( STR0015 , cMsg , {"Ok"} )
	EndIf        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza status da solicitacao bloqueio automatico                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lBloqueio .And. lRetMail
		aadd( aCampos,{ "B5J_STATUS"	,"2" } )
		GrvDad99B( 4,aCampos,'B5JMASTER','PLSA99B' ) 
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza status da solicitacao manual                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipRel == "C" .And. B5J->B5J_STATUS <> "2" .And. !lBloqueio .And. ;
		Iif(!lAutoma,MsgYesNo(STR0058),lAutoma) //"Deseja alterar o Status da solicitação para 'Confim. Emitida'?"
		
		aadd( aCampos,{ "B5J_STATUS"	,"2" } )
		GrvDad99B( 4,aCampos,'B5JMASTER','PLSA99B' ) 
	EndIf
EndIf

Return lRet    
   
 
//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BRelat

Imprime relatório de solicitacao de Cancelamento do Plano

@author  PLS TEAM
@version P11
@since   15/03/16
/*/
//-------------------------------------------------------------------   
Static Function A99BMail(cTo,cProtocolo,cPathServ, lAutoma,cTipRel)

LOCAL cNomeProg := "PLSA99B"
LOCAL cBody     := GetNewPar("MV_RELBODY" , "Não responda este e-mail. Esta mensagem é automática e não deve ser respondida.") // Determina a mensagem padrão que orá no corpo do e-mail.
LOCAL cSubject  := ""
LOCAL lOkEnvio  := .F.
LOCAL aRet      := {}
LOCAL cSubPasta := PLSMUDSIS("pdf_email\")
LOCAL cWFID     := ""
LOCAL cPathHtml := PLSMUDSIS("\workflow\"+cNomeProg+".htm")
LOCAL nHandle   := 0     
LOCAL cHtml     := ""
DEFAULT cPathServ  := ""
DEFAULT lAutoma    := .F.

cSubject := "Comprovante " + cProtocolo //"Protocolo de Atendimento ao Beneficiário - "      

If MakeDir(PLSMUDSIS("\workflow")) == 3
	Aviso(STR0015, STR0040, {"Ok"},2 ) //"Não foi possível criar a pastas 'WorkFlow' no Rootpath"
	Return(lOkEnvio)
EndIf

cHtml := "<html>" + CHR(13) + ;
	"<body>" + CHR(13) + ;
	"<h1>" + cBody + "</h1>" + CHR(13) + ;
	"</body>" + CHR(13) + ;
	"</html>"

//Ponto de Entrada para customização da mensagem do E-Mail 
If ExistBlock( "PL99BMAI" )
	aHtml := ExecBlock( "PL99BMAI", .F., .F., {@cSubject, @cHtml, cBody, cTipRel} )

	cSubject:=aHtml[1]
	cHtml 	:=aHtml[2]
EndIf


If (nHandle := FCREATE(cPathHtml)) < 0
	Aviso(STR0015,STR0041 + cPathHtml, {"Ok"},2 )    //"Erro criando arquivo "
Else
	Iif(!lAutoma,FWrite(nHandle, cHtml),"")
	Iif(!lAutoma,FClose(nHandle),"")

	cWFID := Iif(!lAutoma,PlsWFProc(cNomeProg, STR0042, cSubject, cBody, cTo, , , cPathHtml, , cPathServ, ,),"") //"Envio de Comprovante"
	lOkEnvio := !EMPTY(cWFID)
	If ! lOkEnvio
		If !lAutoma	
			GET MAIL ERROR cErrorMsg
		EndIf
		Iif(!lAutoma, FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cNomeProg + STR0043 + cErrorMsg , 0, 0, {}),"") //": Erro na tentativa de enviar email: "
	EndIf
EndIf

Return (lOkEnvio)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BRelat

Imprime relatório de solicitacao de Cancelamento do Plano

@author  PLS TEAM
@version P11
@since   15/03/16
/*/
//-------------------------------------------------------------------  
Static Function InfBenRel(cMatric,cTipRel)
Local aRet      := {}         
Local cKeyPla   := ""
Local lOk       := .T.
Default cTipRel := "S"

BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO            

If BA1->(MsSeek(xFilial("BA1")+cMatric)) 
   	//Se conclusao, traz somente os usuarios bloqueados
   	If cTipRel == "C" .And. Empty(BA1->BA1_MOTBLO)
   		lOk := .F.
   	Endif	
   	
   	If lOk
		Aadd(aRet,{"Matrícula:",Transform(AllTrim(cMatric), "@R !!!!.!!!!.!!!!!!-!!-!")})   
		Aadd(aRet,{"Nome:",Alltrim(BA1->BA1_NOMUSR)})  
		Aadd(aRet,{"CPF:",IIF(!Empty(BA1->BA1_CPFUSR),Transform(AllTrim(BA1->BA1_CPFUSR), "@R 999.999.999-99"),"Não informado")  })
		Aadd(aRet,{"Data Nascimento:" ,Substr(Dtos(BA1->BA1_DATNAS),7,2)+"/"+Substr(Dtos(BA1->BA1_DATNAS),5,2)+"/"+Substr(Dtos(BA1->BA1_DATNAS),1,4)})
		Aadd(aRet,{"Data de Inclusão:",Substr(Dtos(BA1->BA1_DATINC),7,2)+"/"+Substr(Dtos(BA1->BA1_DATINC),5,2)+"/"+Substr(Dtos(BA1->BA1_DATINC),1,4) })
		
		If cTipRel == "C"
			Aadd(aRet,{"Data Bloqueio:" ,Substr(Dtos(BA1->BA1_DATBLO),7,2)+"/"+Substr(Dtos(BA1->BA1_DATBLO),5,2)+"/"+Substr(Dtos(BA1->BA1_DATBLO),1,4)})	
		EndIf
		
		If !Empty(BA1->BA1_CODPLA)
			cKeyPla := BA1->(BA1_CODPLA+BA1_VERSAO)
		Else
			BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB	
			If BA3->(MsSeek(xFilial("BA3")+Substr(cMatric,1,14))) .And. !Empty(BA3->BA3_CODPLA)
				cKeyPla :=  BA3->(BA3_CODPLA+BA3_VERSAO)   
			EndIf
		EndIf               
		
		BI3->(DbSetOrder(1))//BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
		If BI3->(MsSeek(xFilial("BI3")+PlsIntPad()+cKeyPla))
			Aadd(aRet,{"Produto:",BI3->BI3_CODIGO+" - "+Alltrim(BI3->BI3_DESCRI)})
		EndIf
	EndIf	
EndIf
			
Return(aRet)   
    

//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BBloq

Efetua o bloqueio da solicitacao 

@author  PLS TEAM
@version P11
@since   15/03/16
/*/
//-------------------------------------------------------------------  
Function PL99BBloq(lAutoma) 

	Local oDlg
	Local nOpca := Iif(!lAutoma .Or. lAutoma == NIL,0,1)     
	Local nQtdeFam := 0 
	Local nX := 0
	Local cMotBlo := Iif(!lAutoma .Or. lAutoma == NIL,Space(3),"001")  
	Local dData := dDataBase
	Local bConfirm := {|| iif(Empty(cMotBlo) .Or. Empty(dData),(MsgInfo(STR0044)),(nOpca := 1, oDlg:End())) } //"É necessário informar o motivo e a data do bloqueio."
	Local bCancel := {|| nOpca := 0, oDlg:End() }   
	Local aMatBloq := {}     
	Local aCampos := {}
	Local lBloFam := .F.
	Local lBloUsu := .F.
	Local lAtuOk := .F.
	Local lRetEmail := .F.  
	LOCAL cTitular := GetNewPar("MV_PLCDTIT","T")
	Local lTitular := .F.                                          
	Local lGerProRat := GetNewPar("MV_PL9BPRA","0") == "1"
	Local aAblf	:= {}
	Local oMulta := Nil
	Local nValorMulta := 0
	Local lGravaMulta := .F.

	Default lAutoma := .F.

	If B5J->B5J_STATUS <> "0"
		Aviso( STR0015,STR0045,{ "OK" }, 2 )   //"O bloqueio desta solicitação já foi efetuado."
		Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se sera bloqueio familiar ou de usuario					        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                          
	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If BA1->(MsSeek(xFilial("BA1")+Substr(B5J->B5J_MATSOL,1,14)))
		//Verifico quantas pessoas ha na familia desbloqueadas
		While BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+Substr(B5J->B5J_MATSOL,1,14) .And. !BA1->(Eof())
			If Empty(BA1->BA1_MOTBLO)
				nQtdeFam ++     
			EndIf
			BA1->(DbSkip())
		EndDo
		//Verifico quantas pessoas foram solicitadas para realizar o bloqueio
		B5K->(DbSetOrder(1))//B5K_FILIAL+B5K_CODIGO+B5K_MATUSU
		If B5K->(MsSeek(xFilial("B5K")+B5J->B5J_CODIGO))
			While B5K->(B5K_FILIAL+B5K_CODIGO) == xFilial("B5K")+B5J->B5J_CODIGO .And. !B5K->(Eof())
				If BA1->(MsSeek(xFilial("BA1")+B5K->B5K_MATUSU)) .And. Empty(BA1->BA1_MOTBLO)
					Aadd(aMatBloq,B5K->B5K_MATUSU)  
					If BA1->BA1_TIPUSU == cTitular
						lTitular := .T.
					EndIf
				EndIf
				B5K->(DbSkip())
			EndDo
		EndIf
		
		If nQtdeFam == 0
			Aviso( STR0015,STR0046,{ "OK" }, 2 ) //"Não foi possível realizar o bloqueio: todos os beneficiários já estão bloqueados."
			Return
		ElseIf (nQtdeFam >= 2) .And. (len(aMatBloq) == nQtdeFam ) .And. lTitular
			lBloFam := .T.
		ElseIf (nQtdeFam == 1) .And. (len(aMatBloq) == 1) .And. lTitular
			lBloFam := .T.
		Else
			lBloUsu := .T.
		EndIf
		
	EndIf

	If !lAutoma	
		DEFINE MSDIALOG oDlg TITLE STR0047 FROM 000,000 TO 009,035 //"Bloqueio de Planos"
		
		@ 010,010 SAY oSay PROMPT STR0048  SIZE 070,010  PIXEL OF oDlg  //"Motivo Bloqueio"
		If lBloFam  
			cMotBlo := GetNewPar("MV_PL412FM",Space(3))
			@ 010,060 MSGET cMotBlo  PICTURE "@" SIZE 030,007 F3 'BG199B' PIXEL OF oDlg VALID vldMotBlo(cMotBlo,lBloFam,lBloUsu)
		Else
			cMotBlo := GetNewPar("MV_PL412US",Space(3))
			@ 010,060 MSGET cMotBlo  PICTURE "@" SIZE 030,007 F3 'BG399B' PIXEL OF oDlg VALID vldMotBlo(cMotBlo,lBloFam,lBloUsu) 
		EndIf
		@ 025,010 SAY oSay PROMPT STR0049  SIZE 070,010 PIXEL OF oDlg  //"Data Bloqueio"
		@ 025,060 MSGET dData  PICTURE "D" SIZE 050,007 PIXEL OF oDlg
		
		@ 045,040 BUTTON STR0028 SIZE 36,13 PIXEL ACTION Eval(bConfirm) //Confirmar   
		@ 045,080 BUTTON STR0029  SIZE 36,13 PIXEL ACTION Eval(bCancel) //Cancelar         

		//Ativa dialogo
		ACTIVATE MSDIALOG oDlg CENTERED  
	EndIf

	If nOpca == 1	
		If lBloFam   
			BG1->(DbSetOrder(1))//BG1_FILIAL+BG1_CODBLO
			If BG1->(MsSeek(xFilial("BG1")+cMotBlo)) .And. BA1->(MsSeek(xFilial("BA1")+aMatBloq[1]))

				If FindClass("PLBenefMulta")
					oMulta := PLBenefMulta():New()

					If oMulta:SetFamilia(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC), dData)
						FwMsgRun(Nil, {|| nValorMulta := oMulta:Calcular(cMotBlo, "2")}, Nil, STR0065) // "Verificando multa rescisória de contrato do(s) beneficiário(s) ..."
					EndIf
				EndIf

				PL260BLOCO("BA1",BA1->(Recno()),4,.T.,cMotBlo,dData,BG1->BG1_BLOFAT,nil,nil,nil,.F.,.F.,.T., @aAblf)

				If ExistBlock("PL260ABF") .And. !Empty(aAblf) .And. !aAblf[1]
					Return
				Else
					If nValorMulta > 0
						FwMsgRun(Nil, {|| lGravaMulta := oMulta:Gravar()}, Nil, STR0066) // "Gerando cobrança da multa rescisória do(s) beneficiário(s) ..."

						If lGravaMulta
							FWAlertSuccess(oMulta:GetHtmlCobranca(), STR0067) // "Título gerado com sucesso!"
						EndIf
					EndIf

					If lGerProRat .And. BG1->BG1_BLOFAT == "1" .And. IIF(BG1->(Fieldpos("BG1_PRORAT")) > 0,IIF(BG1->BG1_PRORAT == "0",.F.,.T.),.T.) // Se o campo Pro Rata no motivo estiver com "0 = Não", não gera NCC
						PL99BProRt(dData,aMatBloq,.F.)            
					EndIf
					
					Aviso( STR0015,STR0050,{ "OK" }, 2 )//"Bloqueio efetuado com sucesso."	
					lAtuOk := .T.
				EndIf
				//Gera credito na pro-rata de saida
			EndIf
		
		ElseIf lBloUsu  
			BG3->(DbSetOrder(1))//BG1_FILIAL+BG1_CODBLO 
			If BG3->(MsSeek(xFilial("BG3")+cMotBlo))

				If FindClass("PLBenefMulta")
					oMulta := PLBenefMulta():New()

					If oMulta:SetBeneficiarios(aMatBloq, dData)
						FwMsgRun(Nil, {|| nValorMulta := oMulta:Calcular(cMotBlo, "1")}, Nil, STR0065) // "Verificando multa rescisória de contrato do(s) beneficiário(s) ..."
					EndIf
				EndIf  

				For nX := 1 to len(aMatBloq)
					If BA1->(MsSeek(xFilial("BA1")+aMatBloq[nX]))
						PL260BLOUS("BA1",BA1->(Recno()),4,.T.,cMotBlo,dData,BG3->BG3_BLOFAT,nil,nil,nil,.F.,.F.,.T.)
					EndIf	
				Next

				If nValorMulta > 0
					FwMsgRun(Nil, {|| lGravaMulta := oMulta:Gravar(aMatBloq)}, Nil, STR0066) // "Gerando cobrança da multa rescisória do(s) beneficiário(s) ..."
				
					If lGravaMulta
						FWAlertSuccess(oMulta:GetHtmlCobranca(), STR0067) // "Título gerado com sucesso!"	
					EndIf
				EndIf
							
				//Gera credito na pro-rata de saida
				If lGerProRat .And. BG3->BG3_BLOFAT == "1" .And. IIF(BG3->(Fieldpos("BG3_PRORAT")) > 0,IIF(BG3->BG3_PRORAT == "0",.F.,.T.),.T.) // Se o campo Pro Rata no motivo estiver com "0 = Não", não gera NCC
					PL99BProRt(dData,aMatBloq,.F.)
				EndIf

				Iif(!lAutoma,Aviso( STR0015,STR0050,{ "OK" }, 2 ),"") //"Bloqueio efetuado com sucesso."	 
				lAtuOk := .T.
			EndIf	
		EndIf 
		
		If lAtuOk
			aCampos := { }

			aadd( aCampos,{ "B5J_STATUS"	,"1" } )       
			aadd( aCampos,{ "B5J_DATBLO"	,dDataBase } )
			aadd( aCampos,{ "B5J_HORBLO"	,Time() } )
		
			GrvDad99B( 4,aCampos,'B5JMASTER','PLSA99B' ) 
			If !Empty(B5J->B5J_EMAIL)
				PL99BRelat(.F.,nil,.T.,"C",.T.,,,lAutoma)  
			EndIf
		EndIf			
	EndIf
	  
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldMotBlo
Valida preenchimento do codigo de bloqueio

@author    Renan Sakai
@version   1.xx
@since     16/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function vldMotBlo(cMotBlo,lBloFam,lBloUsu) 
Local lRet := .F.

If lBloUsu 
	BG3->(DbSetOrder(1))//BG3_FILIAL+BG3_CODBLO
	If BG3->(MsSeek(xFilial("BG3")+cMotBlo)) .And. BG3->BG3_TIPBLO == "0"
		lRet := .T.
	EndIf          
ElseIf lBloFam
	BG1->(DbSetOrder(1))//BG1_FILIAL+BG1_CODBLO
	If BG1->(MsSeek(xFilial("BG1")+cMotBlo)) .And. BG1->BG1_TIPBLO == "0"
		lRet := .T.
	EndIf          
EndIf

If Empty(cMotBlo)
	lRet := .T.
EndIf

If !lRet
	Aviso( STR0015,STR0059,{ "OK" }, 2 )//"Motivo de bloqueio informado inválido."
EndIf	

Return lRet
       

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvDad99B
Grava dados na rotina de Monitoramento

@author    Renan Sakai
@version   1.xx
@since     16/08/2016
/*/
//------------------------------------------------------------------------------------------
Function GrvDad99B( nOpc,aCampos,cModel,cLoadModel )
local oAux
local oStruct
local oModel
local aAux
local aErro

local nI
local nPos

local lRet := .T.
local lAux

oModel := FWLoadModel( cLoadModel )
oModel:setOperation( nOpc )
oModel:activate()

oAux	:= oModel:getModel( cModel )
oStruct	:= oAux:getStruct()
aAux	:= oStruct:getFields()

if( nOpc <> MODEL_OPERATION_DELETE )
	begin Transaction
	for nI := 1 to len( aCampos )
		if( nPos := aScan( aAux,{| x | allTrim( x[ 3 ] ) == allTrim( aCampos[ nI,1 ] ) } ) ) > 0
			if !( lRet := oModel:setValue( cModel,aCampos[ nI,1 ],aCampos[ nI,2 ] ) )
				aErro := oModel:getErrorMessage()
				
				autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
				autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
				autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
				autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
				autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
				autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
				
				mostraErro()
				disarmTransaction()
				exit
			endif
		endIf
	next nI
	end Transaction
endIf

if( lRet := oModel:vldData() )
	oModel:commitData()
endif

oModel:deActivate()
oModel:destroy()
freeObj( oModel )
oModel := nil
delClassInf()

return lRet  
         

//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BUplo

Realiza o upload de arquivo 
@author  PLS TEAM
@version P11
@since   01/07/16
/*/
//-------------------------------------------------------------------
Function PL99BUplo(lAutoma)                               
LOCAL cFileInc	  := Iif(lAutoma == NIL .Or. !lAutoma,cGetFile("*.*",STR0051 ,0,"",.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.),"") //"Selecione o Arquivo"
LOCAL cChaveUn
LOCAL cSlvAlias  := Alias()

If ! Empty(cFileInc)
   cChaveUn := &(AllTrim(FWX2Unico("B5J"))) 
   If Empty(cChaveUn)
   		DbSetOrder(1)
   		cChaveUn:= &(&(cAlias+"->(IndexKey())"))
   EndIf

	PLSINCONH(cFileInc, "B5J", cChaveUn,.F.,.F.,.T.,.T.,.T.)
Endif

If ! Empty(cSlvAlias)
   DbSelectArea(cSlvAlias)
Endif
 
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BBCDoc

Rotina padrao de Banco de Conhecimento
@author  PLS TEAM
@version P11
@since   01/07/16
/*/
//-------------------------------------------------------------------
Function PL99BBCDoc(lAutoma)    
Private aRotina   := {}
Private cCadastro := STR0001 //"Solicitação de Cancelamento de Planos"

Default lAutoma   := .F.

aadd(aRotina,{ STR0011,'MsDocument',0,1	,0,nil}) //"Banco do Conhecimento"
Iif(!lAutoma,MsDocument("B5J",B5J->(Recno()),1),"")

Return
      
//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BGRVRP

Realiza a gravacao de uma solicitacao de cancelamento realizada pelo Portal do Prestador
@author  PLS TEAM
@version P11
@since   01/07/16
/*/
//-------------------------------------------------------------------     
Function PL99BGRVRP(cMatSol,aRecnos, lAutoma)
Local cProtoc     := ''
Local oModel      := FwLoadModel('PLSA99B') 
Local oModelB5J   := oModel:GetModel( 'B5JMASTER' )
Local oModelB5K   := oModel:GetModel( 'B5KDETAIL' )   
Local oView
Local nX := 0
Local cCodigo    := ""
Local lExistePe	:= .F.

Default lAutoma := .F.

BA1->(DbSetOrder(2))////BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
If BA1->(MsSeek(xFilial("BA1")+cMatSol))      
	DbSelectArea("B5J")
	DbSelectArea("B5K")
	cProtoc := P773GerPro()	
	oModel:setOperation(3)
	oModel:activate()
    
    cCodigo := GetSX8Num("B5J","B5J_CODIGO")    
    
	oModel:SetValue( 'B5JMASTER', 'B5J_FILIAL', xFilial("B5J") )
	oModel:SetValue( 'B5JMASTER', 'B5J_CODIGO', cCodigo )
	
	oModel:SetValue( 'B5JMASTER', 'B5J_MATSOL', cMatSol )
	oModel:SetValue( 'B5JMASTER', 'B5J_DATSOL', dDataBase )
	oModel:SetValue( 'B5JMASTER', 'B5J_STATUS', "0" )
	oModel:SetValue( 'B5JMASTER', 'B5J_ORISOL', "3" )  
	oModel:SetValue( 'B5JMASTER', 'B5J_PROTOC', cProtoc )   
	
	B49->(DbSetOrder(2))//B49_FILIAL+B49_BENEFI
	If B49->(MsSeek(xFilial("B49")+cMatSol))   
		BSW->(DbSetOrder(5))//BSW_FILIAL+BSW_CODUSR
		If BSW->(MsSeek(xFilial("BSW")+B49->B49_CODUSR))
			oModel:SetValue( 'B5JMASTER', 'B5J_EMAIL', Alltrim(BSW->BSW_EMAIL) )
		Endif
	EndIf
	//Adiciona beneficiarios                                                  
	For nX := 1 to len(aRecnos)
		If nX > 1
			oModelB5K:AddLine(.T.)
		EndIf	
		BA1->(DbGoTo(aRecnos[nX]))
		oModel:SetValue( 'B5KDETAIL', 'B5K_FILIAL', xFilial("B5K") )
		oModel:SetValue( 'B5KDETAIL', 'B5K_MATUSU', BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )
	

	Next
	
	If oModel:VldData()
		oModel:CommitData()
		lRet := .T.
	Else
		aErro := oModel:GetErrorMessage()
	EndIf

	oModel:deActivate()
	oModel:destroy()
	freeObj( oModel )
	oModel := nil
	delClassInf()	 
	
	B5J->( ConfirmSx8() )


	lExistePe	:=  ExistBlock("PL99GRVSOL")

	aAreaBA1 := BA1->(GetArea())  
	For nX := 1 to len(aRecnos)
		BA1->(DbGoTo(aRecnos[nX]))

		// Ponto de Entrada para manipulação da solicitação de cancelamento de beneficiario                                                     
		If lExistePe
			ExecBlock("PL99GRVSOL",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),B49->B49_CODUSR})
		EndIf

	Next nX

	RestArea(aAreaBA1) 
EndIf	

Return "true|"+cProtoc  

//-------------------------------------------------------------------
/*/{Protheus.doc} PP99BSol

Rotina para geracao de relatorio de Solicitacao de Cancelamento pelo Portal
@author  PLS TEAM
@version P11
@since   01/07/16
/*/
//-------------------------------------------------------------------
User Function PP99BSol(lAutoma)  
Local cRelName := ""    
Local cMsg     := ""
Default lAutoma  := .F.

DbSelectArea("B5J")
Iif(!lAutoma, B5J->(DbGoTo(PARAMIXB[1]:RECNO)), "")
 
Iif(!lAutoma, PL99BRelat(.F.,nil,.F.,"S",.F.,.T.,@cRelName), "")

Return{cRelName,cMsg}                


//-------------------------------------------------------------------
/*/{Protheus.doc} PP99BCon

Rotina para geracao de relatorio de Confirmacao de Cancelamento pelo Portal
@author  PLS TEAM
@version P11
@since   01/07/16
/*/
//-------------------------------------------------------------------
User Function PP99BCon(lAutoma)  
Local cRelName := ""    
Local cMsg     := ""
Default lAutoma := .F.

DbSelectArea("B5J")
Iif(!lAutoma,B5J->(DbGoTo(PARAMIXB[1]:RECNO)),"")

Iif(!lAutoma,PL99BRelat(.F.,nil,.F.,"C",.F.,.T.,@cRelName),"")

Return{cRelName,cMsg}
                           

//-------------------------------------------------------------------
/*/{Protheus.doc} vldGridB5K

Realiza validacoes na manipulacao do Grid B5K
@author  PLS TEAM
@version P11
@since   01/07/16
/*/
//-------------------------------------------------------------------
Static Function vldGridB5K( oModelGrid, nLinha, cAcao, cCampo )
Local lRet := .T.
Local oModel := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()

If (cAcao == 'DELETE' .AND. nOperation == MODEL_OPERATION_UPDATE) .Or. ;
	(cAcao == 'SETVALUE' .AND. nOperation == MODEL_OPERATION_UPDATE)
	lRet := .F.    
	Help( ,,STR0015,,STR0060, 1, 0 )//"Não permitido manipular os registros do grid de beneficiários."
EndIf

Return lRet      


//-------------------------------------------------------------------
/*/{Protheus.doc} filtroF12

Refaz filtro com tecla f12
@author  PLS TEAM
@version P11
@since   01/07/16
/*/
//-------------------------------------------------------------------
Static Function filtroF12(oBrowse, lAutoma)    
Local cFiltro  := " B5J_FILIAL = '"+xFilial("B5J")+"' "
Local cPerg    := "PLSA99B"
Local cOpeSol  := ""
Local cEmpDe   := ""
Local cEmpAte  := ""
Local nStatus  := 0
Local oBrowse
Local dDatDe
Local dDatAte

Default lAutoma := .F.

If Pergunte(cPerg,.T.)
	cOpeSol   := mv_par01 
	dDatDe    := mv_par02
	dDatAte   := mv_par03  
	cEmpDe    := mv_par04
	cEmpAte   := mv_par05  
	nStatus   := mv_par06
	
	
	

	If !Empty(cOpeSol)
		cFiltro += " .AND. B5J_OPESOL = '"+cOpeSol+"' "
	EndIf     

	If !Empty(dDatDe)
		cFiltro += " .AND. Dtos(B5J_DATSOL) >= '"+ Dtos(dDatDe) +"' "
		
	EndIf
	If !Empty(dDatAte)
		cFiltro += " .AND. Dtos(B5J_DATSOL) <= '"+ Dtos(dDatAte) +"' "
		
	EndIf      

	If !Empty(cEmpDe)
		cFiltro += " .AND. B5J_CODEMP >= '"+ cEmpDe +"' "
	EndIf
	If !Empty(cEmpAte)
		cFiltro += " .AND. B5J_CODEMP <= '"+ cEmpAte +"' "
	EndIf
	
	If cValtoChar(nStatus) $ "123"
		cFiltro += " .AND. B5J_STATUS = '"+cValtoChar(nStatus-1)+"' "
	EndIf  
	
	Iif(!lAutoma,oBrowse:SetFilterDefault(cFiltro),"")
EndIf 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BProRt

Realiza a pro-rata de saida criando um credito para o beneficiario
@author  Renan Sakai
@version P11
@since   04/05/17
@history Vinicius.Queiros 21/12/2019
		 Feito ajuste para a função verificar quando estiver saldo 
		 em meses posterior ao da data de bloqueio, e com isso o 
		 sistema não irá calcular somente o valor crediado do mes 
		 do bloqueio.
/*/
//-------------------------------------------------------------------
Function PL99BProRt(dData,aUsuBloq,lRpc)    
Local cCodSeq 	:= ""   
Local cMes     	:= Substr(Dtos(dData),5,2)
Local cAno     	:= Substr(Dtos(dData),1,4)
Local cDia     	:= Substr(Dtos(dData),7,2)
Local cValorNCC	:= ""
Local aRetNiv  	:= {}
Local nVlrMens 	:= 0
Local nVlrCred 	:= 0
Local nPercMes 	:= 0
Local nValorFim	:= 0
Local nX       	:= 0
Local nTaxaCM	:= 0
Local aVlrCob  	:= {}
Local cFinal   	:= ""
Local nResult  	:= 0     
Local lTitGer  	:= .F.
Local lContabiliza := .F.
Local lAglutina := .F. 
Local lDigita   := .F.
Local cLanc    	:= GetNewPar("MV_PL9BLAN","101/102")
Local aRecSE1  	:= {}
Local aRecNCC  	:= {}
Local lPL99BVAL := ExistBlock( "PL99BVAL" )
Local lConsDtCanc   := GetNewPar("MV_PRODTCA",.F.)
Local cMsgNCC   := "" 
Local cEmpDe	:= "" 
Local cEmpAte	:= "" 
Local cSQL		
Local aVlrMens	:= {}
Local nNx
Local nPosCob
Local nPosMes
Local aMesVlrCob:= {}
Local aTempCob	:= {}
Local nRecNCC	

Default lRpc  	:= .F.

//Cria/posiciona lancamento da faturamento
BFQ->( dbSetorder(1) )//BFQ_FILIAL+BFQ_CODINT+BFQ_PROPRI+BFQ_CODLAN
SE1->( dbSetorder(1) )//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
If !BFQ->(MsSeek(xFilial("BFQ")+PlsIntPad()+"197"))
	PLSCRIABFQ()  
	BFQ->(MsSeek(xFilial("BFQ")+PlsIntPad()+"197"))
EndIf
		
For nX := 1 to len(aUsuBloq)
    
	BA1->(DbSetOrder(2))
	If BA1->(MsSeek(xFilial("BA1")+aUsuBloq[nX]))
		nVlrMens := 0  
		nVlrCred := 0 
		aVlrMens := {}
		cMatric  := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

		// Busca em Query para verificar se a dados na BM1 referente aos proximos meses, da data de bloqueio
		// Para calcular o valor caso o beneficiario tenha pago o mês seguinte em relação ao bloqueio 
		
		cSQL := " SELECT * FROM "+BM1->( RetSQLName("BM1") )
		cSQL += " WHERE BM1_FILIAL = '"+xFilial("BM1") + "'"
		cSQL += " AND BM1_MATUSU = '" + cMatric + "'"
		cSQL += " AND ((BM1_MES >= '" + cMes + "' AND BM1_ANO = '" + cAno +"')"
		cSQL += " OR BM1_ANO > '" + cAno + "')"
		cSQL += " AND D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY BM1_ANO, BM1_MES"

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBM1",.F.,.T.)

		If !TrbBM1->( Eof() )
			While !TrbBM1->( Eof() )

				If TrbBM1->BM1_CODTIP $ cLanc
	    			If TrbBM1->BM1_TIPO == "1"

						nPosMes := ASCAN(aVlrMens,{|x| x[1] == TrbBM1->BM1_MES .And. x[2] == TrbBM1->BM1_ANO})// Verifico se o mes ja esta no array
						If nPosMes > 0 // Se for maior que zero e pq ja tem, então só acrescenta a valor
							aVlrMens[nPosMes,3] += TrbBM1->BM1_VALOR 									
						Else // Caso seja 0 e porque não tem, então adiciona o mes no array
							aAdd(aVlrMens,{TrbBM1->BM1_MES,TrbBM1->BM1_ANO,TrbBM1->BM1_VALOR,0})
						EndIf

	    			ElseIf TrbBM1->BM1_TIPO == "2"

						nPosMes := ASCAN(aVlrMens,{|x| x[1] == TrbBM1->BM1_MES .And. x[2] == TrbBM1->BM1_ANO})// Verifico se o mes ja esta no array
						If nPosMes > 0 // Se for maior que zero e pq ja tem, então só acrescenta o valor
							aVlrMens[nPosMes,3] := aVlrMens[nPosMes,3] - TrbBM1->BM1_VALOR 									
						Else // Caso seja 0 e porque não tem, então adiciona o mes no array
							aAdd(aVlrMens,{TrbBM1->BM1_MES,TrbBM1->BM1_ANO,0 - TrbBM1->BM1_VALOR,0})
						EndIf

	    			EndIf	

					If SE1->(MsSeek(xFilial("SE1")+ TrbBM1->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT) )) .And. aScan(aRecSE1,SE1->(Recno())) <= 0 
						aAdd(aRecSE1,SE1->(Recno()))
					EndIf
	    		EndIf

				TrbBM1->(DbSkip())
			EndDo
		EndIf

		TrbBM1->(DbCloseArea())

		/*aVlrMens:
			Posição 1 = Mês
			Posição 2 = Ano
			Posição 3 = Valor do Mês
			Posição 4 = Valor Crediado do mês
		*/
		// Percorre todos os meses encontrado do beneficiario
		For nNx := 1 To Len(aVlrMens) 
			//Verifica a quantidade de dias no mes
			If aVlrMens[nNx,1] $ "01/03/05/07/08/10/12" //  aVlrMens[nNx,1] = Mes
				nDiasMes := 31
			ElseIf aVlrMens[nNx,1] $ "04/06/09/11"	//aVlrMens[nNx,1] = Mes
				nDiasMes := 30
			ElseIf aVlrMens[nNx,1] == "02"    // aVlrMens[nNx,1] = Mes 
				cFinal     := SubStr(aVlrMens[nNx,2],3,2) // aVlrMens[nNx,2] = Ano
				nResult    := 0
			
				If cFinal == "00"
					nResult := Mod(Val(aVlrMens[nNx,2]),400) // aVlrMens[nNx,2] = Ano
				Else
					nResult := Mod(Val(aVlrMens[nNx,2]),4) // aVlrMens[nNx,2] = Ano
				EndIf
			
				IIf(nResult == 0,nDiasMes := 29,nDiasMes := 28)
			EndIf
			
			//Verifica o valor do credito a ser gerado se houver valor de matricula/opcional emitido
			If aVlrMens[nNx,3] > 0			
				// Ponto de Entrada para realizar o calculo do percutal e dias utilizados do Pro-rata
				If ExistBlock("PLPRORAT") .And. FindFunction("PLDayVencCob")
					If aVlrMens[nNx, 1] == cMes .And. aVlrMens[nNx, 2] == cAno
						nPercMes := 100 - ExecBlock("PLPRORAT", .F., .F., {dData, PLDayVencCob(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)), .T.})[1]
					Else
						nPercMes := 100 - (0 * 100 / nDiasMes) // O dia é igual a 0, porque o mes não foi utilizado nenhum dia
					EndIf
				Else
					If lConsDtCanc .And. aVlrMens[nNx,1] == cMes .And. aVlrMens[nNx,2] == cAno  // Se o mes corrente que esta calculando for o mes do bloqueio verifica o restante de dias
						nPercMes := 100 - ((Val(cDia) - 1)  * 100 / nDiasMes) 
					ElseIf aVlrMens[nNx,1] == cMes .And. aVlrMens[nNx,2] == cAno
						nPercMes := 100 - (Val(cDia) * 100 / nDiasMes)
					Else // Quando o mes corrente não é o do bloqueio, é um mês posterior
						nPercMes := 100 - (0 * 100 / nDiasMes) // O dia é igual a 0, porque o mes não foi utilizado nenhum dia
					EndIf
				EndIf
			
				aVlrMens[nNx,4] := Round(aVlrMens[nNx,3] * (nPercMes/100),2) 
			EndIf			                     	
			//Verifica nivel de cobranca da familia
			aRetNiv := PLSRETNCB(Substr(cMatric,1,4),Substr(cMatric,5,4),Substr(cMatric,9,6),/*cOpeOri*/,/*lChkFam*/)
		
			PLSDADUSR(cMatric,"1",.F.,dData) //Posiciona nos dados do beneficiario      
			BA1->(MsSeek(xFilial("BA1")+aUsuBloq[nX]))//Reposiciona no beneficiario
			BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON
			BA3->(MsSeek(xFilial("BA3")+Substr(cMatric,1,14)))//Reposiciona na familia 
			
			If ! Empty(BQC->BQC_CODTES)
				cCodTes := BQC->BQC_CODTES
			Else
				cCodTes := BFQ->BFQ_CODTES
			Endif
		
			cCodSB1 := BFQ->BFQ_CODSB1
							
			//Caso nao localizar nos niveis acima, retorna a informacao do produto (mais especifico)
			If empty(cCodTes)
				cCodTes := BI3->BI3_CODTES
			Endif
					
			If empty(cCodSB1)
				cCodSB1 := BI3->BI3_CODSB1
			Endif
		
			If lPL99BVAL
				aVlrMens[nNx,4] := ExecBlock( "PL99BVAL", .F., .F., {cMatric,aVlrMens[nNx,2],aVlrMens[nNx,1],aVlrMens[nNx,4],dData} ) // Matric,Ano,Mes,VlrCred,Data
			EndIf
			
			If aVlrMens[nNx,4] > 0     
				// grava em um array temporaria pra saber se ira adicionar ao mes existente ou criar um novo
				// Criado essa logica com a necessidade quando tiver mais de um beneficiario, porque se houver mais de um usuario,
				// precisará gravar apenas um NCC por mes
				
				aAdd(aTempCob,{	BFQ->BFQ_DEBCRE,;	    	    							//01
								aVlrMens[nNx,4],;	            		 					//02
								BFQ->(BFQ_PROPRI + BFQ_CODLAN),;							//03
								BI3->BI3_CODIGO,;      	           							//04
								Alltrim(BI3->BI3_DESCRI),;         							//05
								"",;     				        							//06
								aUsuBloq[nX],;				       							//07
								BA1->BA1_NOMUSR,;		        							//08
								.F.,;				            							//09
								BA1->BA1_SEXO,;		      	    							//10
								BA1->BA1_GRAUPA,;		  	    							//11
								"",;				    	    							//12
								"",;			    	        							//13
								"",;			 	            							//14
								BA1->BA1_TIPUSU,;		        							//15
								"",;				            							//16
								"",;				            							//17
								0,;				                							//18
								StrZero(1,4),;		            							//19
								0,;				                							//20
								0,;				                							//21
								BFQ->BFQ_VERBA,;		        							//22
								aVlrMens[nNx,4],;		        			  				//23
								0,;				                							//24
								0,;				                							//25
								0,;				                							//26
								0,;				                							//27
								0,;				                							//28
								0,;				                							//29
								"",;				            							//30
								"",;				            							//31
								"",;				            							//32
								0,;		        				  							//33
								BA3->BA3_CODPLA,;		        							//34 - Codigo do plano
								BA3->BA3_VERSAO,;		        							//35 - Versao do plano
								BI3->BI3_DESCRI,;		        							//36 - Descricao do plano
								cCodSB1,;	   	                							//37 - Codigo do Produto SB1 ERP
								cCodTES,;                       							//38 - Codigo da TES SB1 ERP
								0,;  				            							//39 - Recno do BM1 para uso generico
								0,;   														//40 - Total do desconto aglutinado para o item - integracao com a nota de saida.
								BA3->BA3_CODINT,;											//41 
								BA3->BA3_CODEMP,;											//42 
								BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC),;				//43 
								BA3->BA3_CONEMP,;											//44 
								BA3->BA3_VERCON,;											//45 
								BA3->BA3_SUBCON,;											//46 
								BA3->BA3_VERSUB,;											//47 
								BA3->BA3_CODPLA,;											//48 
								BA3->BA3_VERSAO,; 											//49 
								'',;														//50 
								0,;	 	 													//51 
								BA3->BA3_TIPOUS,;			  								//52 
								BA3->(RecNo()),;											//53 
								BG9->(RecNo()),;											//54
								BT5->(RecNo()),;											//55
								BQC->(RecNo()),;											//56
								BT6->(RecNo()),;											//57
								"",;	 													//58
								aVlrMens[nNx,2],;											//59 
								aVlrMens[nNx,1],;											//60 
								IIF(BA1->BA1_OPEORI<>PLSINTPAD(),.T.,.F.),; 				//61
								"",;														//62 
								{},;														//63 
								{},;     													//64 
								{},;														//65 
								.F.,;                           							//66
								""/*cTpPlan*/,; 								    		//67
								IIF(BI3->(Fieldpos("BI3_TPFORN"))>0,BI3->BI3_TPFORN,''),;	//68
								""/*cCodFor*/,;												//69
								""/*cSeqDep*/,; 											//70
								""/*cPlanGpe*/}) 											//71 

				nPosCob := ASCAN(aMesVlrCob,{|x| x[1] == aVlrMens[nNx,1] .And. x[2] == aVlrMens[nNx,2]}) // Verifico se ja foi adicionado o mes

				If nPosCob > 0 // Se sim, apenas add no mes o array temporario
					aAdd(aMesVlrCob[nPosCob,3],aTempCob[1])											
				Else // Se não, crio um novo mes e adiciono o array temporario
					aAdd(aMesVlrCob,{aVlrMens[nNx,1],aVlrMens[nNx,2],aTempCob})
				EndIf
				aTempCob := {} //Zera o temporario para a proxima iteração
			EndIf										
		Next
	EndIf	
Next

// Apos gravar no array todos os meses que irao gerar NCC, percorre os meses e gera cada NCC para um Mes
For nNx := 1 To len(aMesVlrCob)
	//Gera a NCC
	If len(aMesVlrCob[nNx,3]) > 0 .And. aRetNiv[1] 
		cPrefixo := GetNewPar("MV_PL9BPNC","PLS")
		cNumTit  := PLSE1NUM(cPrefixo) 
			
		lTitGer := gerTitCred(	Substr(cMatric,1,14),;
								aMesVlrCob[nNx,2],;
								aMesVlrCob[nNx,1],;
								"",;
								"",;
								"",;
								dDataBase,;
								dDataBase+GetNewPar("MV_PL9BVEN",0),;//Vencimento
								aMesVlrCob[nNx,3],;
								aRetNiv[2],;
								aRetNiv[3],;
								"0",;
								cPrefixo,;
								cNumTit)
	EndIf

	//Exibe titulo gerado
	If lTitGer .And. !lRpc
		cValorNCC := Alltrim(Transform(SE1->E1_VALOR, "@E 999999.99"))
		aAdd(aRecNCC,SE1->(Recno()))
		nRecNCC := SE1->(Recno())
			
		//Guardo empresa para evitar errorlog no PLSAPUSRPq
		cEmpDe	:= mv_par04 
		cEmpAte := mv_par05 

		PERGUNTE("AFI340",.F.)
		lContabiliza  	:= MV_PAR11 == 1
		lAglutina   	:= MV_PAR08 == 1
		lDigita   		:= MV_PAR09 == 1
		nTaxaCM 		:= RecMoeda(dDataBase,SE1->E1_MOEDA)
		
		If Len(aRecSE1) > 0 .And. MaIntBxCR(3,aRecSE1,,aRecNCC,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,dDatabase )
			if lHabMetric .and. lLibSupFw .and. lVrsAppSw 
				FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_utilizacao-de-ncc_total", 1 }} )
			endif

			For nX := 1 To Len(aRecSE1)
				SE1->(dbGoTo(aRecSE1[nX]))
				nValorFim += SE1->E1_SALDO
			Next
		EndIf 
		
		If (nValorFim > 0)
			cMsgNCC := "Foi gerado o desconto de R$ " + cValorNCC + CRLF +  "Débito em aberto: R$ " + Alltrim(Transform(nValorFim, "@E 999999.99")) + " Titulo: " +SE1->E1_PREFIXO + " " + SE1->E1_NUM 
		Else
			SE1->(dbGoTo(nRecNCC))
			If (SE1->E1_SALDO == SE1->E1_VALOR)
				cMsgNCC := "Foi gerado o título NCC - "+SE1->E1_PREFIXO + " " + SE1->E1_NUM+" no valor de R$ "+Alltrim(Transform(SE1->E1_VALOR, "@E 999999.99"))
			Else
				cMsgNCC := "Foi gerado o desconto de R$ " + Alltrim(Transform(SE1->E1_VALOR - SE1->E1_SALDO, "@E 999999.99")) + CRLF +"Título NCC - "+SE1->E1_PREFIXO + " " + SE1->E1_NUM+" no valor de R$ "+Alltrim(Transform(SE1->E1_VALOR, "@E 999999.99")) +" com saldo de R$ "+Alltrim(Transform(SE1->E1_SALDO, "@E 999999.99"))
			EndIf
		EndIf
		
		Aviso( "É necessário informar ao solicitante.",cMsgNCC,{ "OK" }, 2 )//"É necessário informar o solicitante."

		//Retorno Empresa após o PERGUNTE("AFI340",.F.)
		mv_par04 := cEmpDe
		mv_par05 := cEmpAte 
		
	EndIf	
Next

Return           
 


//-------------------------------------------------------------------
/*/{Protheus.doc} gerTitCred

Gera o titulo de NCC 
@author  Renan Sakai
@version P11
@since   04/05/17
/*/
//-------------------------------------------------------------------

Static Function gerTitCred(cMatric,cAno,cMes,cBanco,cOrig,cNivel,dEmissao,dVencto,aVlrCob,cCodCli,cLoja,cSituac,cPrefixo,cNumero)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBA3 := BA3->(IndexOrd())
LOCAL nRecBA3 := BA3->(Recno())
LOCAL aAux    := {}
LOCAL cCodFor
LOCAL cLojFor
LOCAL cConEmp
LOCAL cTipo
LOCAL aVlrCon
LOCAL aVlrAux
LOCAL aRetorno	
LOCAL nVlrCon  	:= 0
LOCAL cNatureza := ''
LOCAL cCodInt	:= ''
LOCAL bGerRec  	:= { || PLGERREC(aAux[1],;//1
								 aAux[2],;//2
								 cMatric,;//3
								 cMes,;//4
								 cANo,;//5
								 dVencto,;//6
								 M->BDC_NUMERO,;//7
								 nVlrCon,;//8
								 aAux[3],;//9
								 cCodCli,;//10
								 cLoja,;//11
								 cTipo,;//12
								 aVlrCon,;//13
								 "4",;//14
								 NIL,;//15
								 NIL,;//16
								 NIL,;//17
								 0,;//18
								 NIL,;//19
								 NIL,;//20
								 cBanco,;//21
								 cSituac,;//22
								 cNatureza,;//23
								 NIL,;//24
								 cOrig,;//25
								 cTipoPag,;//26
								 cPortado,;//27
								 cAgePor,;//28
								 cCCPor,;//29
								 cBcoCli,;//30
								 cAgeCli,;//31
								 cCCCli,;//32
								 dEmissao,;//33	
								 NIL,;//34	
								 NIL,;//35	
								 NIL,;//36	
								 NIL,;//37 	
								 NIL,;//38
								 cCodInt,;//39
								 NIL,;//40
								 NIL,;//41
								 NIL,;//42
								 NIL,;//43
								 NIL,;//44
								 .T.)}//45


Local cNumCob  	:= "00000000"		// Cobranca automatica de pessoa fisica
Local nOpc		:= 0
Local nValor    := 0
LOCAL cTipoPag	:= ''
LOCAL cPortado	:= ''
LOCAL cAgePor	:= ''
LOCAL cCCPor	:= ''
LOCAL cBcoCli	:= ''
LOCAL cAgeCli	:= ''
LOCAL cCCCli	:= ''
LOCAL lOk		:= .T.
DEFAULT cNivel 	:= '4'
DEFAULT dEmissao:= dDataBase
DEFAULT dVencto := PLMontVen(BA3->BA3_VENCTO,cMes,cAno)
DEFAULT aVlrCob := {}
DEFAULT cCodCli := ""
DEFAULT cLoja   := ""
DEFAULT cSituac := "1"   
DEFAULT cPrefixo:= ""
DEFAULT cNumero := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustes no dicionario...                                                 ³
//³ Caso o indice 19 da tabea BEAJ nao tenha cido criada nao deixa o sistema ³
//³ processeguir, alteracao requisita e aprovado pelo Tulio.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! CheckBEAIndex("BEAJ")
	Return .F.	
EndIf

aAux := {cPrefixo,cNumero,""}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na familia informada...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(1))

If ! BA3->(DbSeek(xFilial("BA3")+cMatric))
   BA3->(DbSetOrder(nOrdBA3))
   BA3->(DbGoTo(nRecBA3))
   Help("",1,"PLSA76002")
   Return .F.
Endif     
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valor a ser gerado                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aVlrCob) > 0
	aVlrCon	 := aClone(aVlrCob)     
	aEval(aVlrCon,{|x| IF(!x[9],nVlrCon := IF(x[1]=="1",nVlrCon+x[2],If(x[1]=="2",nVlrCon-x[2],nVlrCon)),nil) })	
EndIf	
	
If Empty(cCodCli)
   cCodCli  	:= BA3->BA3_CODCLI
   cLoja    	:= BA3->BA3_LOJA
Endif   

cCodFor  	:= BA3->BA3_CODFOR
cLojFor  	:= BA3->BA3_LOJFOR
cConEmp  	:= BA3->BA3_CONEMP
cTipo    	:= BG9->BG9_TIPO
cCodInt		:= BA3->BA3_CODINT

If BA3->( FieldPos("BA3_TIPPAG") ) > 0
	cTipoPag	:= BA3->BA3_TIPPAG
	cPortado	:= BA3->BA3_PORTAD
	cAgePor		:= BA3->BA3_AGEDEP
	cCCPor		:= BA3->BA3_CTACOR
	cBcoCli		:= BA3->BA3_BCOCLI
	cAgeCli		:= BA3->BA3_AGECLI
	cCCCli		:= BA3->BA3_CTACLI
Endif

If nVlrCon < 0
   nVlrCon  := ABS(nVlrCon)
Endif
  
Begin Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Incrementado regra de busca de natureza...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNatureza := A627BusNat(BG9->BG9_TIPO,BA3->BA3_NATURE,(cCodCli+cLoja),(BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o retorno seja diferente de "1" gravo no arquivo de criticas.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! BDC->(DbSeek(xFilial("BDC") + BA3->BA3_CODINT + cNumCob))
	Copy "BDC" TO Memory Blank
	M->BDC_TIPO := Iif(BA3->BA3_TIPOUS == '1', '2', '1')
	M->BDC_MESINI := cMes
	M->BDC_MESFIM := cMes
	M->BDC_ANOINI := cAno
	M->BDC_ANOFIM := cAno  
	M->BDC_NUMERO := PLSA625Num()
	M->BDC_DTEMIS := dEmissao
	nOpcX := 3
Else
	Copy "BDC" TO Memory
	If cAno + cMes > BDC->BDC_ANOFIM + BDC->BDC_MESFIM 
		M->BDC_MESFIM := cMes
		M->BDC_ANOFIM := cAno
	ElseIf cAno + cMes < BDC->BDC_ANOINI + BDC->BDC_MESINI 
		M->BDC_MESINI := cMes
		M->BDC_ANOINI := cAno
	Endif
	nOpcX := 4
Endif

If ValType(aRetorno) <> "A"
	aRetorno:={}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera o titulo NCC                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetorno := Eval(bGerRec)

If 	aRetorno[1][1]
	M->BDC_CONGER 	:= 1
	nValor          := aRetorno[1][4]
	M->BDC_VALOR	:= nValor
	SE1->( dbSetorder(01) ) 
	SE1->( dbSeek(xFilial("SE1")+aAux[1]+aAux[2],.T.) )
Else
	M->BDC_CONCRI	:= 1             
	nValor          := aRetorno[1][4]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o lote de faturamento...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->BDC_HORAF := Time()
PLUPTENC("BDC",nOpcX)    
BDC->( ConfirmSX8() )           

PLSA625Cri(M->BDC_NUMERO,nValor,aRetorno,BA3->BA3_CODINT,;
BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
BA3->BA3_VERSUB, BA3->BA3_MATRIC,GETMV("MV_PLCDTGP"),"4",cAno,cMes,.F.)

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvos...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(nOrdBA3))
BA3->(DbGoTo(nRecBA3))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return aRetorno[1][1]

//-------------------------------------------------------------------
/*/{Protheus.doc} AltPL99B
Realiza a alteração da solicitação de Planos RN412

@author  Vinicius.Queiros
@version P12
@since   21/12/2020
/*/
//-------------------------------------------------------------------

Function AltPL99B()

	Local lRetorno := .T.

	If B5J->B5J_STATUS <> "0"
		Help( ,,STR0015,,STR0064, 1, 0 ) // "Atenção";"Não é permitido realizar alteração quando o status estiver em Bloqueio Efetuado ou Confim. Emitida"
		lRetorno := .F.
	Else
		FWExecView('ALTERAR','PLSA99B', MODEL_OPERATION_UPDATE,, { || .T. } )
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} PL99BPosValid
Pos validação do modelo de dados PLSA99B

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 06/09/2022
/*/
//-------------------------------------------------------------------
Static Function PL99BPosValid(oModel)

	Local lRetorno := .T.
	Local oMulta := Nil
	Local aBeneficiarios := {}
	Local oModelB5K := oModel:GetModel("B5KDETAIL")
	Local nX := 0
	Local nValorMulta := 0
	Local nOperation := oModel:GetOperation()
	Local aSaveLines := FWSaveRows()

	If nOperation == MODEL_OPERATION_INSERT

		If !IsBlind() .And. FindClass("PLBenefMulta")
			oMulta := PLBenefMulta():New()

			For nX := 1 TO oModelB5K:Length()
				oModelB5K:GoLine(nX)

				If oModelB5K:IsDeleted()
                    Loop
                EndIf

				aAdd(aBeneficiarios, oModelB5K:GetValue("B5K_MATUSU"))
			Next nX

			If oMulta:SetBeneficiarios(aBeneficiarios, dDataBase)

				FwMsgRun(Nil, {|| nValorMulta := oMulta:Calcular()}, Nil, STR0065) // "Verificando multa rescisória de contrato dos beneficiários..."

				If nValorMulta > 0
					If !FWAlertYesNo(oMulta:GetHtmlMulta(), STR0068) // "Multa Rescisória de Contrato"
						Help("", 1, "HELP", Nil, STR0069,  1, 0) // "Solicitação Cancelada." 
						lRetorno := .F.
					EndIf					
				EndIf
			EndIf
		EndIf

	EndIf

	FWRestRows(aSaveLines)

Return lRetorno