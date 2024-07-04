#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA390.CH'

//-------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} TECA390()

Realiza a Inclusão de Exceções no Modulo RH, onde é possivel incluir através do Cliente
Contrato ou Local de Atendimento
*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA390(aMdlGrid)
Local oBrowse

Private cCadastro

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ABV')
oBrowse:SetDescription(STR0001)	//Exceções por Cliente
oBrowse:Activate()


Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} MenuDef()

Inclusão dos Menu na Rotina

@return ExpA: Retorna o Array com os Menus
*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0009 	ACTION 'PesqBrw'			OPERATION 1	ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0010 	ACTION 'VIEWDEF.TECA390'	OPERATION 2	ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0011 	ACTION 'VIEWDEF.TECA390'	OPERATION 3	ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0012 	ACTION 'VIEWDEF.TECA390'	OPERATION 5	ACCESS 0 //"Excluir"

Return (aRotina)

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef()

Criação do Modelo de Dados conforme arquitetura MVC

@return ExpO: Modelo de Dados
*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oStruABV			:= FWFormStruct(1,'ABV',/*bAvalCampo*/,/*lViewUsado*/)
Local oStruGrid			:= FwFormStruct(1,'SP2',/*bAvalCampo8/,/*lViewUsado*/)
Local oModel
Local bDcommit 		:= {|oModel| At390Commit(oModel)}
Local bPosValidacao	:= {|oModel| At390PosValid(oModel)}
Local bLoadSP2		:= {|oModel| At390Load(oModel)}

oModel := MPFormModel():New('TECA390',/*bPreValidacao*/,bPosValidacao,bDcommit,/*bCancel*/)
oModel:AddFields('ABVMASTER',/*cOwner*/,oStruABV,/*bPreValidacao*/,/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldAbp*/)
oModel:AddGrid( 'SP2GRID','ABVMASTER',oStruGrid,/*bPreValidacao*/,/*bLinePost*/,/*bCarga*/,/*bPost*/,bLoadSP2) // Adiciona uma Grid ao modelo

oStruGrid	:= FwFormStruct(1,'SP2',/*bAvalCampo8/,/*lViewUsado*/)  //Adiciona Grid com as informações da tabela de exceções por periodo que foram geradas pela exceção por cliente

oModel:GetModel('SP2GRID'):SetOptional(.T.)
oModel:GetModel('SP2GRID'):SetNoInsertLine(.T.)
oModel:GetModel('SP2GRID'):SetNoUpdateLine(.T.)
oModel:GetModel('SP2GRID'):SetNoDeleteLine(.T.)

oModel:GetModel('ABVMASTER'):SetDescription('ABV')
oModel:setDescription(STR0002)

Return oModel

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ViewDef()

Criação da View da Tela de Cadastro

@return ExpO: View criada para o cadastro
*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel := FWLoadModel('TECA390')
Local oStruABV	:= FWFormStruct(2,'ABV')
Local oStruGrid	:= FWFormStruct(2,'SP2')	
Local oMdlGrid	:= oModel:GetModel('oStruGrid')
Local nOperation 	:= oModel:GetOperation()


oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_GERAL', oStruABV, 'ABVMASTER') 	//View geral onde será o cabeçalho, tabela ABV
oView:AddGrid('VIEW_GRID', oStruGrid, 'SP2GRID')		//View do grid onde tera as exceções por periodo relacionadas, tabela SP2

oView:CreateHorizontalBox('TELAGERAL',60)
oView:CreateHorizontalBox('INFERIOR', 40)

oView:SetOwnerView( 'VIEW_GERAL','TELAGERAL' )
oView:SetOwnerView( 'VIEW_GRID','INFERIOR' )

Return(oView)

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc}  At390Commit()

Realiza a Gravação dos Dados utilizando o Model

@param ExpO:Modelo de Dados da Tela de cadastro

@return ExpL: Retorna .T. quando houve sucesso na Gravação
*/
//--------------------------------------------------------------------------------------------------------------------
Function At390Commit(oModel)

Local lRetorno := .T.
Local lConfirm 
Local nOperation	:= oModel:GetOperation()

If nOperation == 5					// Quando a operação for de exclusão, questionará se realmente deseja excluir a exceção por cliente junto as exceções por periodo que estão relacionadas.
	If !IsBlind()
		lConfirm:= MsgYesNo(STR0015) //As exceções por período mostradas na tabela estão relacionadas com a exceção por cliente selecionada e também serão excluídas. Está certo que deseja realizar esta ação?
	Else
		lConfirm	:= .T.
	EndIf
		
	If lConfirm == .T.
		Begin Transaction
	
			If !(lRetorno := At390ExcAt(oModel))
				DisarmTransacation()
			Else
				FWFormCommit(oModel)
			EndIf
	
		End Transaction
	EndIf
Else				//Senão for exclusão, não haverá questionamento.
	Begin Transaction
	
		If !(lRetorno := At390ExcAt(oModel))
			DisarmTransacation()
		Else
			FWFormCommit(oModel)
		EndIf
	
	End Transaction
EndIf

Return( lRetorno )

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc}  At390ExcAt()

Realiza a Gravação dos dados utilizando a ExecAuto Pona090 para inclusão de exceções 
no Modulo RH

@param ExpO:Modelo de Dados da Tela de cadastro

@return ExpL: Retorna .T. quando houve sucesso na ExecAuto
*/
//--------------------------------------------------------------------------------------------------------------------
Function At390ExcAt(oModel)

Local nOperation := oModel:GetOperation()
Local aLinha			:= {}			//array que será passado com os valores no execauto para preencher a tabela PS2
Local lRetorno			:= .T.			//validador de retorno, caso ocorra algum erro, ele retorna false, evitando que seja adicionado dados na tabela ABV
Local cCCusto			:= ""			//será gravado o valor do centro de custo obtido por contrato ou local
Local aCCusto			:= {}			//será gravado os valores de centro de custo obitidos pelos contratos do Cliente escolhido
Local nX				:= 1			//Contador para posição do array aCCusto
Local nDestino			:= 0			//Determina qual execauto será executado
Local cValores			:= ""			//Recebe os valores de local ou contrato para ser utilizado no posicione
Local aArea				:= GetArea()	//Pega posição GetArea()

Private lMsHelpAuto 	:= .T. 			// Controle interno do ExecAuto
Private lMsErroAuto 	:= .F. 			// Informa a ocorrência de erros no ExecAuto
Private INCLUI 			:= .T. 			// Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
Private ALTERA 			:= .F. 			// Variavel necessária para o ExecAuto identificar que se trata de uma alteração

If !EMPTY(FwFldGet("ABV_LOCAL"))															//Verifica se Local foi preenchido
	cValores	:= FwFldGet("ABV_LOCAL")
	cCCusto		:= Posicione("ABS", 1, xFilial("ABS") + cValores, "ABS_CCUSTO")
	nDestino	:= 0	
ElseIf !EMPTY(FwFldGet("ABV_CONTRA"))														//Verifica se Contrato foi preenchido
	cValores	:= FwFldGet("ABV_CONTRA")
	cCCusto		:= Posicione("AAH", 1, xFilial("AAH") + cValores, "AAH_CCUSTO")
	nDestino	:= 0
ElseIf !EMPTY(FwFldGet("ABV_CODCLI"))														//Verifica se Cliente/Loja foi preenchido
	DbSelectArea("AAH")
	DbSetOrder(2)
	If DbSeek(xFilial("AAH")+FwFldGet("ABV_CODCLI")+FwFldGet("ABV_LOJA"))	
		While !AAH->(Eof()) .And. xFilial("AAH") == AAH->AAH_FILIAL .And. FwFldGet("ABV_CODCLI") == AAH->AAH_CODCLI  .And. FwFldGet("ABV_LOJA") == AAH->AAH_LOJA
			If (!EMPTY(AAH->AAH_CCUSTO) .AND. aScan(aCCusto,{|x| x[1] == AAH->AAH_CCUSTO})==0)
				aAdd(aCCusto, {AAH->AAH_CCUSTO})
			End
			AAH->(DbSkip())
		End
	EndIf
	nDestino	:= 1
Else																							//Caso nenhum campo tenha sido preenchido foi preenchido
	lRetorno:= .F.
	nDestino	:= 2
EndIf

If nDestino == 0 
	If !Empty(cCCusto)
		If (nOperation == 3 .OR. nOperation == 5)
		
			aadd(aLinha,{"P2_FILIAL"     	,xFilial("SP2"),NIL})
			aadd(aLinha,{"P2_MOTIVO"     	,FwFldGet("ABV_MOTIVO") ,NIL})
			aadd(aLinha,{"P2_DATA"       	,FwFldGet("ABV_DATA") ,NIL})
			aadd(aLinha,{"P2_DATAATE"		,FwFldGet("ABV_DATAAT") ,NIL})
			aadd(aLinha,{"P2_MAT"        	,Space(TAMSX3("P2_MAT")[1]) ,NIL})//
			aadd(aLinha,{"P2_TURNO"      	,Space(TAMSX3("P2_TURNO")[1]) ,NIL})//
			aadd(aLinha,{"P2_CC"         	,cCCusto ,NIL})//
			aadd(aLinha,{"P2_TRABA"      	,FwFldGet("ABV_TRABA") ,NIL})
			aadd(aLinha,{"P2_TIPODIA"    	,FwFldGet("ABV_TIPDIA") ,NIL})
			aadd(aLinha,{"P2_MINHNOT"  		,FwFldGet("ABV_MINHNT") ,NIL})
			aadd(aLinha,{"P2_CODHEXT"    	,FwFldGet("ABV_CODHEX") ,NIL})
			aadd(aLinha,{"P2_CODHNOT"  		,FwFldGet("ABV_CODHNT") ,NIL})
			aadd(aLinha,{"P2_HERDHOR"   	,FwFldGet("ABV_HERDHR") ,NIL})
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Teste de Inclusao                                            |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Pona090(aLinha,nOperation)
			If nOperation == 3
				If !lMsErroAuto
					ConOut(STR0005) //"Inclusao com sucesso! "
				Else
					lRetorno := .F.
					ConOut(STR0006) //"Erro na inclusao!"
					MostraErro()
				EndIf
			ElseIf nOperation == 5
				If !lMsErroAuto
					ConOut(STR0007) //"Inclusao com sucesso! "
				Else
					lRetorno := .F.
					ConOut(STR0008) //"Erro na inclusao!"
					MostraErro()
				EndIf
			EndIf
			aLinha := {}
		EndIf
	Else
		lRetorno := .F.
		MsgStop(STR0014,STR0013)	
	EndIf	
ElseIf nDestino == 1 
	If Len(aCCusto) > 0
		If (nOperation == 3 .OR. nOperation == 5)
			For nX := 1 to Len(aCCusto)
				aadd(aLinha,{"P2_FILIAL"  		,xFilial("SP2"),NIL})
				aadd(aLinha,{"P2_MOTIVO"     	,FwFldGet("ABV_MOTIVO"),NIL})
				aadd(aLinha,{"P2_DATA"       	,FwFldGet("ABV_DATA") ,NIL})
				aadd(aLinha,{"P2_DATAATE"		,FwFldGet("ABV_DATAAT") ,NIL})
				aadd(aLinha,{"P2_MAT"        	,Space(TAMSX3("P2_MAT")[1]) ,NIL})//
				aadd(aLinha,{"P2_TURNO"      	,Space(TAMSX3("P2_TURNO")[1]) ,NIL})//
				aadd(aLinha,{"P2_CC"         	,aCCusto[nX][1] ,NIL})//
				aadd(aLinha,{"P2_TRABA"      	,FwFldGet("ABV_TRABA") ,NIL})
				aadd(aLinha,{"P2_TIPODIA"    	,FwFldGet("ABV_TIPDIA") ,NIL})
				aadd(aLinha,{"P2_MINHNOT"  		,FwFldGet("ABV_MINHNT") ,NIL})
				aadd(aLinha,{"P2_CODHEXT"    	,FwFldGet("ABV_CODHEX") ,NIL})
				aadd(aLinha,{"P2_CODHNOT"  		,FwFldGet("ABV_CODHNT") ,NIL})
				aadd(aLinha,{"P2_HERDHOR"   	,FwFldGet("ABV_HERDHR") ,NIL})
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Teste de Inclusao                                            |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Pona090(aLinha,nOperation)
				
				If !lMsErroAuto
					If At390Confirm(aCCusto[nX][1],nOperation)
						ConOut(STR0005) //"Inclusao com sucesso! "
					Else
						lRetorno := .F.
						ConOut(STR0006) //"Erro na inclusao!"	
					EndIf	
				Else
					lRetorno := .F.
					ConOut(STR0006) //"Erro na inclusao!"
					MostraErro()
				EndIf		
				aLinha := {}
			Next nX
		EndIf
	Else 
		lRetorno := .F.
		MsgStop(STR0014,STR0013)
	EndIf
EndIf   

RestArea(aArea)
Return (lRetorno)

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc}  At390When()

Habilta/Desabilita os campos ABV_CODCLI/ABV_LOJA/ABV_CONTRA/ABV_LOCAL conforme
a Regra de Negocio

@return ExpL: Retorna .F. para o campo que será desativado.
*/
//--------------------------------------------------------------------------------------------------------------------
Function At390When()

Local cCampo		:= ReadVar()
Local lCondicao		:= .T.

Do Case
	
	Case cCampo == "M->ABV_CONTRA"
		If (EMPTY(M->ABV_LOCAL) .AND. EMPTY(M->ABV_CODCLI) .AND. EMPTY(M->ABV_LOJA))
			lCondicao := .T.
		Else
			lCondicao := .F.
		EndIF
	Case cCampo == "M->ABV_LOCAL"
		If	(EMPTY(M->ABV_CONTRA) .AND. EMPTY(M->ABV_CODCLI) .AND. EMPTY(M->ABV_LOJA))
			lCondicao := .T.
		Else
			lCondicao := .F.
		EndIf
	Case cCampo == "M->ABV_CODCLI"
		If	(EMPTY(M->ABV_CONTRA) .AND. EMPTY(M->ABV_LOCAL))
			lCondicao := .T.
		Else
			lCondicao := .F.
		EndIf
	Case cCampo == "M->ABV_LOJA"
		If	(EMPTY(M->ABV_CONTRA) .AND. EMPTY(M->ABV_LOCAL))
			lCondicao := .T.
		Else
			lCondicao := .F.
		EndIf
		
EndCase

Return(lCondicao)     

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc}  At390PosValid()

Verifica se os campos ABV_LOCAL/ABV_CONTRA/ABV_CODCLI estão preenchidos antes se serem
enviados para a ExecAuto.

@param ExpO:Modelo de Dados da Tela de cadastro

@return ExpL: Retorna .F. quando todos os campos estão vazios
*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At390PosValid(oModel)
Local lRet 	:= .T.
Local nOperation := oModel:GetOperation()
Local aArea	:= GetArea()
   
If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	DbSelectArea("ABV")
	ABV->(DbSetOrder(2))
	If ABV->(DbSeek(xFilial("ABV")+DTOS(FwFldGet("ABV_DATA"))+FwFldGet("ABV_TIPDIA")))	
		Help(" ",1,"JAGRAVADO")
		lRet := .F.
	EndIf	
	//Verifica se os campos estão preenchidos antes do envio da ExecAuto
	If lRet .And. Empty(FwFldGet("ABV_LOCAL")) .AND. Empty(FwFldGet("ABV_CONTRA")) .AND. Empty(FwFldGet("ABV_CODCLI"))
		lRet := .F.
		HELP(" ",1,"AT390OBRIG")
	EndIf
	
	If lRet .And. !EMPTY(FwFldGet("ABV_CODCLI"))
		AAH->(DbSetOrder(2))		
		If AAH->(DbSeek(xFilial("AAH")+FwFldGet("ABV_CODCLI")+FwFldGet("ABV_LOJA")))				
			While !AAH->(Eof()) .And. (xFilial("AAH") == AAH->AAH_FILIAL) .And. (FwFldGet("ABV_CODCLI") == AAH->AAH_CODCLI)  .And. (FwFldGet("ABV_LOJA") == AAH->AAH_LOJA)  
				If (!EMPTY(AAH->AAH_CCUSTO))
					lRet := .T.
					Exit
				Else
					lRet := .F.					
				End
				AAH->(DbSkip())
			End
			If !lRet			
				HELP(" ",1,"A390CCUSTO")
			EndIf
		Else
			lRet := .F.
			HELP(" ",1,"A390CCUSTO")
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return (lRet)

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc}  At390Load()
Realiza o Load do grid com as informações das Exceções por periodo que tem relação com as Exceções por Cliente///

@param ExpO:Modelo de Dados da Tela de cadastro.

@return ExpL: Retorna o grid preenchido ou vazio

*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At390Load(oMdlGrid)
Local aArea     	:= GetArea() 
Local aAreaSP2	:= SP2->(GetArea())  
Local oStruct  	:= oMdlGrid:GetStruct()          // Retorna a estrutura atual.
Local aCampos  	:= oStruct:GetFields()           // Retorna os campos da estrutura.
Local aLoadSP2 	:= {}								 // Array onde o grid será carregado
Local nX          := 0
Local nI  	:= 0
Local nLinha := 0 
Local cAliasABV	:= "ABV"
Local cCentCusto
Local aCentCusto	:= {}
Local cDadoABV	:= "0"
Local nDefCntCst										//define centro de custo
Local nCont											//Contador
Local cLojaABV 										//Loja do Cliente
Local nLocCont										//Local ou Contrato

DbSelectArea(cAliasABV)
DbSelectArea("SP2")
DbSetOrder(2)

Do Case
	Case !EMPTY((cAliasABV)->ABV_LOCAL)  			// se local não estiver vazio, o centro de custo será o local.
	nLocCont	:= 0
	cDadoABV	:= (cAliasABV)->ABV_LOCAL
	cCentCusto := At390CCust(cDadoABV, nLocCont) 	// chama a função para pegar centro de custo por local
	nDefCntCst	:=1 									//
	Case !EMPTY((cAliasABV)->ABV_CONTRA)			// se contrato não estiver vazio, o centro de custo será o do contrato
	nLocCont	:= 1
	cDadoABV	:= (cAliasABV)->ABV_CONTRA
	cCentCusto := At390CCust(cDadoABV, nLocCont)	// chama a função para pegar centro de custo por contrato
	nDefCntCst	:=1
   Case !EMPTY((cAliasABV)->ABV_CODCLI)			// se cliente estiver vazio, será o centro de custo dos contratos que  o cliente possui
	cDadoABV	 := (cAliasABV)->ABV_CODCLI
	cLojaABV	:= (cAliasABV)->ABV_LOJA
	aCentCusto := At390CstCl(cDadoABV, cLojaABV)	// chama a função que carrega de acordo com os contratos do cliente, passa a loja do cliente
	nDefCntCst :=0
EndCase

If(nDefCntCst == 1) 									// Se o centro de custo for referente a local ou contrato, então terá comente um centro de custo
	If(DbSeek(xFilial("SP2") + Dtos((cAliasABV)->ABV_DATA) + cCentCusto + (cAliasABV)->ABV_TIPDIA)) 
	   
	  While ( SP2->(!Eof()) .AND. P2_FILIAL == xFilial("SP2") .AND. P2_CC == cCentCusto .AND. P2_TIPODIA == (cAliasABV)->ABV_TIPDIA .AND. P2_DATA == (cAliasABV)->ABV_DATA) 
	   
	   	aAdd(aLoadSP2,{SP2->(Recno()),Array(Len(aCampos))})
	   	nLinha := Len(aLoadSP2)
	   		For nX := 1 To Len(aCampos)
	   			If !aCampos[nX][MODEL_FIELD_VIRTUAL]
	      			aLoadSP2[nLinha][2][nX] := &("SP2->"+Alltrim(aCampos[nX][3]))
	      		Else
	      			aLoadSP2[nLinha][2][nX] := &(GetSx3Cache(aCampos[nX][3],"X3_RELACAO"))
	      		EndIf	 
	 		Next nX
	   	        
	  		SP2->(DbSkip())
	  End
	EndIf
ElseIf (nDefCntCst == 0) 							//se o centro de custo for referente ao cliente, ele trará  o centro de custo de todos os contratos, aqui tratará o preenchimento do grid.
	For nCont := 1 To Len(aCentCusto)
		If(DbSeek(xFilial("SP2") + Dtos((cAliasABV)->ABV_DATA) + aCentCusto[nCont][1] + (cAliasABV)->ABV_TIPDIA))   
			While ( SP2->(!Eof()) .AND. P2_FILIAL == xFilial("SP2") .AND. P2_CC == aCentCusto[nCont][1] .AND. P2_TIPODIA == (cAliasABV)->ABV_TIPDIA .AND. P2_DATA == (cAliasABV)->ABV_DATA) 
	   
	   			aAdd(aLoadSP2,{SP2->(Recno()),Array(Len(aCampos))})
	  	 		nLinha := Len(aLoadSP2)
	   			For nX := 1 To Len(aCampos)
	   				If !aCampos[nX][MODEL_FIELD_VIRTUAL]
	      				aLoadSP2[nLinha][2][nX] := &("SP2->"+Alltrim(aCampos[nX][3]))
	      			Else
	      				aLoadSP2[nLinha][2][nX] := &(GetSx3Cache(aCampos[nX][3],"X3_RELACAO"))
	      			EndIf	 
	 			Next nX
	   	        
	  			SP2->(DbSkip())
	 			End
		EndIf
	Next nCont
EndIf	

RestArea(aArea)
RestArea(aAreaSP2)

Return(aLoadSp2)

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc}  At390CCust()
Carrega o centro de custo do contrato ou do Local de atendimento

@param ExpO:Dados Atuais da ABV e verificador se o centro de custo será contrato ou local.

@return ExpL: Retorna o centro de custo do contrato ou do local..

*/
//--------------------------------------------------------------------------------------------------------------------

Function At390CCust(cDadoABV, nLocCont)
Local cCCusto	:= "0"

Do Case
	Case nLocCont == 0
	cCCusto	:= Posicione("ABS", 1, xFilial("ABS") + cDadoABV, "ABS_CCUSTO")
	Case nLocCont ==1
	cCCusto	:=	Posicione("AAH", 1, xFilial("AAH") + cDadoABV, "AAH_CCUSTO")	
EndCase									
	lRetorno:= .F.
	
Return(cCCusto)

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc}  At390CstCl()
Carrega Centro de Custo do Cliente, pois é diferente da forma de carregar pelo contrato e local.

@param ExpO:Dados Atuais da ABV e loja do cliente

@return ExpL: Array com os centros de custo dos contratos que o cliente possui.
*/
//--------------------------------------------------------------------------------------------------------------------

Function At390CstCl(cDadoABV, cLojaABV)
Local aCCusto	:=	{}				//Array onde será adicioando os centro de custo.
Local aArea	:= GetArea()

DbSelectArea("AAH")
DbSetOrder(2)
If DbSeek(xFilial("AAH")+cDadoABV+cLojaABV)	
	While !AAH->(Eof())
		If (!EMPTY(AAH->AAH_CCUSTO) .AND. aScan(aCCusto,{|x| x[1] == AAH->AAH_CCUSTO})==0)
			aAdd(aCCusto, {AAH->AAH_CCUSTO})
		End
		AAH->(DbSkip())
	End
EndIf

RestArea(aArea)

Return(aCCusto)

//--------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} At390Confirm()

Confirma se realmente foi gravado o registro na SP2

@return ExpL: Retorna se realmente foi gravado o registro na SP2
*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At390Confirm(cCentCusto,nOperation)
Local lRet := .F.
Local aArea := GetArea()

If nOperation == 3
	DbSelectArea("SP2")
	SP2->(DbSetOrder(2))
	
	If SP2->(DbSeek(xFilial("SP2") + Dtos(FwFldGet("ABV_DATA")) + cCentCusto + FwFldGet("ABV_TIPDIA")) )
		lRet := .T.
	EndIf
Else
	lRet := .T.
EndIf	

RestArea(aArea)

Return lRet