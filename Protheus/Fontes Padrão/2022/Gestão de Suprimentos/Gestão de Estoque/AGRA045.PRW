#INCLUDE "AGRA045.CH"                                  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
 

Static Function BrowseDef()
Local oBrowse as object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('NNR')
	oBrowse:SetDescription(STR0024)	//-- Armazens Warehouses
	
Return oBrowse


//-------------------------------------------------------------------
/*{Protheus.doc} AGRA045
Programa de manutenção de locais de estoques

@author Caio Quiqueto
@since 27/04/2012
@version P11.6
@obs Uso genérico. Programa convertido para uso em integrações 
*/
//-------------------------------------------------------------------
Function AGRA045( xAutoCab, nOpcAuto )
Local lRet 		:= .T.
Local oModel	:= Nil
Local cLogErr	:= ''
Local aLogErr	:= {}

Private aRotina := MenuDef()

Default	xAutoCab:= {}
Default nOpcAuto:= 3

If Len( xAutoCab ) > 0
	oModel 	:= FWLoadModel( 'AGRA045' )
	lRet 	:= FwMVCRotAuto( oModel,"NNR",nOpcAuto,{ { "NNRMASTER", xAutoCab } },, .T. )
	If !( lRet )
		If IsBlind()
			aLogErr	:= oModel:GetErrorMessage()
			AEval( aLogErr , { | x |  cLogErr += cValToChar( x ) + CRLF } )
			Help(" ",1, aLogErr[ 5 ],, cLogErr ,1,0)
		Else
			MostraErro()
		EndIf
	EndIf
Else
	DEFINE FWMBROWSE oMBrowse ALIAS "NNR"
	ACTIVATE FWMBROWSE oMBrowse
Endif

Return lRet

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
			[n,5] Nivel de acesso
			[n,6] Habilita Menu Funcional

@since 27/04/2012
@version P11.6
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
Local aRotAdic	:= {}              

ADD OPTION aRotina TITLE STR0002 		ACTION "PesqBrw"			OPERATION 0							ACCESS 0 //"Pesquisar" 	
ADD OPTION aRotina TITLE STR0003	 	ACTION "VIEWDEF.AGRA045"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //"Visualizar"	
ADD OPTION aRotina TITLE STR0004 		ACTION "VIEWDEF.AGRA045"	OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Incluir"		
ADD OPTION aRotina TITLE STR0005 		ACTION "VIEWDEF.AGRA045"	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Alterar"		
ADD OPTION aRotina TITLE STR0006 		ACTION "VIEWDEF.AGRA045"	OPERATION MODEL_OPERATION_DELETE	ACCESS 3 //"Excluir"		

If ExistBlock("CMA150AMNU")
	aRotAdic := ExecBlock ("CMA150AMNU",.F.,.F.)
	If ValType(aRotAdic) == "A"
		aEval(aRotAdic,{|x| aAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de locais de estoque

@since 27/04/2012
@version P11.6
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local lValTabSGQ	:= AliasInDic("SGQ")
Local oStruNNR 		:= FWFormStruct(1,'NNR') // Cria a estrutura a ser usada no Modelo deDados
Local oStruSGQ 		:= NIL
Local oModel 		:= NIL

If lValTabSGQ
	oStruSGQ := FWFormStruct(1,'SGQ')
Endif
	                                        
oModel := MPFormModel():New('AGRA045',,{|oModel| AGRA045B(oModel:GetOperation(), oModel)},{|oModel|AG045Commi(oModel)}) 
oModel:AddFields('NNRMASTER',,oStruNNR)
oModel:GetModel('NNRMASTER'):SetDescription(STR0007) //#Cadastro de Armazém
oModel:SetPrimaryKey({"NNR_CODIGO"})

If lValTabSGQ 
	oModel:AddGrid("SGQUSER",'NNRMASTER',oStruSGQ)
	oModel:GetModel("SGQUSER"):SetOptional(.T.)
	oModel:SetRelation( 'SGQUSER', {{'GQ_FILIAL','xFilial("SGQ")'},{'GQ_TIPOPER',"'1'"},{'GQ_LOCAL','NNR_CODIGO'}} )
	oModel:GetModel("SGQUSER"):SetUniqueLine({"GQ_USER","GQ_GRPUSER"})
	oModel:GetModel('SGQUSER'):SetDescription(STR0015)//#Permissões de Usuário
			
	oModel:AddGrid('SGQPROD','NNRMASTER',oStruSGQ)
	oModel:GetModel("SGQPROD"):SetOptional(.T.)
	oModel:SetRelation( 'SGQPROD', {{'GQ_FILIAL','xFilial("SGQ")'},{'GQ_TIPOPER',"'2'"},{'GQ_LOCAL','NNR_CODIGO'}} )
	oModel:GetModel("SGQPROD"):SetUniqueLine({"GQ_PRODUTO","GQ_GRPPROD"})
	oModel:GetModel('SGQPROD'):SetDescription(STR0018)//#Permissões por Produto
Endif
	
Return oModel // Retorna o Modelo de dados

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Interface do modelo de dados de locais de estoque

@since 27/04/2012
@version P11.6
*/
//-------------------------------------------------------------------
Static Function ViewDef()            
Local lValTabSGQ	:= AliasInDic("SGQ")
Local oModel 		:= FWLoadModel('AGRA045') 
Local oStruNNR 		:= FWFormStruct(2, 'NNR')
Local oStruSGQu		:= NIL
Local oStruSGQp		:= NIL
Local oView 		:= FWFormView():New() 

If lValTabSGQ 
	oStruSGQu := FWFormStruct(2,'SGQ',{|cCampo| AllTrim(cCampo) $ 'GQ_USER|GQ_GRPUSER|GQ_DESCRI'})
	oStruSGQp := FWFormStruct(2,'SGQ',{|cCampo| AllTrim(cCampo) $ 'GQ_PRODUTO|GQ_GRPPROD|GQ_DESCRI'})
Endif
// Remove campo para módulos diferente do WMS
If nModulo <> 42
	oStruNNR:RemoveField( "NNR_AMZUNI"	)
EndIf

If lValTabSGQ
	oView:SetModel(oModel) 
	
	oView:CreateVerticalBos("TESTE",100)
	
	oView:CreateHorizontalBox("MAIN",30,"TESTE")
	oView:CreateHorizontalBox("ITEMS",70,"TESTE")
	
	oView:AddField('VIEW_NNR',oStruNNR,'NNRMASTER')
	oView:SetOwnerView('VIEW_NNR','MAIN')
	oView:CreateFolder('PASTAS',"ITEMS")
Else
	oView:SetModel(oModel)                           
	oView:AddField('VIEW_NNR', oStruNNR,'NNRMASTER')
	oView:CreateHorizontalBox("MAIN",100)
	oView:SetOwnerView('VIEW_NNR','MAIN')
	oView:EnableControlBar(.T.)
EndIf

If lValTabSGQ  	
	oView:AddGrid ('VIEW_USU', oStruSGQu, 'SGQUSER')
	oView:AddSheet( 'PASTAS', 'ABA01', STR0015 )//#Permissões de Usuário
	oView:CreateHorizontalBox( 'ESQUERDA' , 100,,, 'PASTAS', 'ABA01' )
	oView:SetOwnerView( 'SGQUSER' , 'ESQUERDA')
	
	oView:AddGrid ('VIEW_PRO', oStruSGQp, 'SGQPROD')
	oView:AddSheet( 'PASTAS', 'ABA02', STR0018 )//#Permissões por Produto
	oView:CreateHorizontalBox( 'DIREITA' , 100,,, 'PASTAS', 'ABA02' )
	oView:SetOwnerView( 'SGQPROD' , 'DIREITA')
EndIf

Return oView 

//-------------------------------------------------------------------
/*{Protheus.doc} AG045commi
Comita  o forulmario

@since 27/04/2012
@version P11.6
*/
//-------------------------------------------------------------------
Static Function AG045Commi(oModel)
Local lRet		:= .F.
Local lPIMSINT:= (SuperGetMV("MV_PIMSINT",.F.,.F.) .And. FindFunction("PIMSGeraXML"))// Indica se Existe Integração Protheus x PIMS Graos
Local lUsaMsg	:= SuperGetMV("MV_MSGPIMS",.F.,.F.) //Nova integração via MGS Unica  
local nOpcX	:= oModel:GetOperation()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento Integracao POS - Synthesis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lIntPOS := (SuperGetMV("MV_LJSYNT",,"0") == "1")

// Proteção para parametro que foi publicado com tipo caracter e deveria ser tipo logico
lUsaMsg := Iif (valtype(lUsaMsg)=='C',Iif ((lUsaMsg = '.T.' .or. lUsaMsg = 'T'),.T.,.F.),lUsaMsg)

If TableInDic('NM7')

	If nOpcX == MODEL_OPERATION_INSERT

		cData := dDataBase 
		cHora := Time()
		cCodigo := oModel:GetModel("NNRMASTER"):GetValue('NNR_CODIGO')		

		DbSelectArea('NM7')
		If !dbSeek(xFilial('NNR')+cCodigo)
			Reclock("NM7",.T.)
			NM7->NM7_FILIAL =  xFilial('NNR')
			NM7->NM7_CODIGO =  cCodigo
			NM7->NM7_DATATU =  cData			
			//NM7->NM7_HORATU =  cHora				
			MsUnLock()
		Endif

		
		NM7->(dbCloseArea())

	Endif

	If nOpcX == MODEL_OPERATION_DELETE

		cCodigo := oModel:GetModel("NNRMASTER"):GetValue('NNR_CODIGO')
		
		DbSelectArea('NM7')
		dbSetorder(1)

		If dbSeek(xFilial('NNR')+cCodigo)
			Reclock("NM7",.F.)
			DbDelete()
			MsUnLock()
		Endif

		NM7->(dbCloseArea())

	Endif

Endif

If nOpcX == MODEL_OPERATION_UPDATE .And. NNR->(FieldPos("NNR_DRPEXP")) > 0        // Alteracao Limpa o campo de Exportacao de Dados 
   oModel:GetModel("NNRMASTER"):SetValue('NNR_DRPEXP','')
Endif
	
If nOpcX == MODEL_OPERATION_UPDATE .AND. lIntPOS .And. NNR->(FieldPos("NNR_POSFLG") > 0) .And. NNR->(FieldPos("NNR_POSDTE") > 0) .And. (NNR->NNR_POSFLG == "1")
   oModel:GetModel("NNRMASTER"):SetValue("NNR_POSDTE",CtoD(""))
Endif
	
lRet := FWFormCommit(oModel)

If lRet .And. lPIMSINT .And. !lUsaMsg .And. (nOpcX == MODEL_OPERATION_INSERT .Or. nOpcX == MODEL_OPERATION_UPDATE)
    PIMSGeraXML(STR0023,STR0022,"2","NNR") //"WareHouse" ## "Cadastro de Armazem"
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} AGR045VlTp
validação do tipo

@since 27/04/2012
@version P11.6 AGR045VlTp
*/
//-------------------------------------------------------------------
Function AGR045VlTp(nTipo)
Local lRet   := .T.
Local dUlMes := SuperGetMV("MV_ULMES",.F.,SToD("19970101")) 
Local aSaldo := {}
	
Default nTipo := 1

SB2->(dbSetorder(2))
If dbSeek(xFilial("SB2")+M->NNR_CODIGO)
	While !SB2->(EOF()) .And. SB2->B2_LOCAL == M->NNR_CODIGO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao permitir que o usuario altere o tipo de armazem quando   |
		//| existe saldo movimentado no mesmo.                           |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SB2->(FieldPos("B2_TIPO")) > 0 
			aSaldo := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dUlMes)
		 	If SB2->B2_QATU <> aSaldo[1] .Or. SB2->B2_VATU1 <> aSaldo[2]
		  		If nTipo == 1
	    	   		Help(" ",1,"A225TIPO")
		       	EndIf     
		        lRet := .F.
		    EndIf
		EndIf
		If !lRet 
	 		Exit
	   	EndIf    
		SB2->(dbSkip())
	End        
EndIf

Return lRet





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Agr045VldCºAutor  ³Leonardo Quintania  º Data ³ 18/01/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao e preenchimento dos campos de usuarios e Grupo    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AGRA045                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Agr045VldC()
Local lRet	:= .F.
Local cCampo:= ReadVar()
Local cConteudo := &(ReadVar())
Local oModel	:= FWModelActive()
Local oModelGrid:= NIL

oModelGrid := oModel:GetModel(Iif("USER"$cCampo,"SGQUSER","SGQPROD"))

If	Alltrim(cConteudo) == "*" .Or. Empty(cConteudo)
	lRet := .T.
	oModelGrid:SetValue("GQ_DESCRI",IIf(Empty(cConteudo),"",STR0010))	//"TODOS"
Else

	If	cCampo $ "M->GQ_USER"
		If	UsrExist(cConteudo)
			oModelGrid:SetValue("GQ_GRPUSER",CriaVar("GQ_GRPUSER",.F.))
			oModelGrid:SetValue("GQ_DESCRI",UsrRetName(cConteudo))
			lRet:=.T.
		EndIf
	ElseIf cCampo $ "M->GQ_GRPUSER"
		If !Empty(GrpRetName(cConteudo))
			oModelGrid:SetValue("GQ_USER",CriaVar("GQ_USER",.F.))
			oModelGrid:SetValue("GQ_DESCRI",GrpRetName(cConteudo))
			lRet := .T.
		EndIf
	ElseIf cCampo $ "M->GQ_PRODUTO"
		If	ExistCpo("SB1",cConteudo,1)
			oModelGrid:SetValue("GQ_GRPPROD",CriaVar("GQ_GRPPROD",.F.))
			oModelGrid:SetValue("GQ_DESCRI",Posicione("SB1",1,xFilial("SB1")+cConteudo,"B1_DESC"))
			lRet := .T.
		EndIf
	ElseIf cCampo $ "M->GQ_GRPPROD"
		If	ExistCpo("SBM",cConteudo,1)
			oModelGrid:SetValue("GQ_PRODUTO",CriaVar("GQ_PRODUTO",.F.))
			oModelGrid:SetValue("GQ_DESCRI",Posicione("SBM",1,xFilial("SBM")+cConteudo,"BM_DESC"))
			lRet := .T.
		EndIf
	EndIf
	
EndIf	
Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} AG045IniD
Inicializador padrão para o campo descrição

@since 27/04/2012
@version P11.6
*/
//-------------------------------------------------------------------
Function Agr045Ides()  
Local cRet			:= ""
Local lValTabSGQ	:= AliasInDic("SGQ")

If lValTabSGQ .And. !INCLUI
	If !(AllTrim(SGQ->GQ_USER) == "*" .Or. AllTrim(SGQ->GQ_GRPUSER) == "*" .Or. AllTrim(SGQ->GQ_PRODUTO) == "*" .Or. AllTrim(SGQ->GQ_GRPPROD) == "*")
		If	!(Empty(SGQ->GQ_USER))
			cRet := UsrRetName(SGQ->GQ_USER)
		ElseIf !(Empty(SGQ->GQ_GRPUSER))
			cRet := GrpRetName(SGQ->GQ_GRPUSER)
		ElseIf !(Empty(SGQ->GQ_PRODUTO))
			cRet := Posicione("SB1",1,xFilial("SB1")+SGQ->GQ_PRODUTO,"B1_DESC")
		ElseIf !(Empty(SGQ->GQ_GRPPROD))
			cRet := Posicione("SBM",1,xFilial("SBM")+SGQ->GQ_GRPPROD,"BM_DESC")
		EndIf
	Else
		cRet := STR0010 //-- TODOS
	EndIf
Endif

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} IntegDef
Integracao do cadastro de Armazens por mensagem unica

@since 01/11/2012
@version P11.6
*/
//-------------------------------------------------------------------
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Default xEnt := ""
Default nTypeTrans := ""
Default cTypeMessage := ""
Default cVersion := ""
Default cTransac := ""
Default lEAIObj := .F.

If nTypeTrans == TRANS_RECEIVE
	lEAIObj := lEAIObj .And. ValType(xEnt) == "O"
EndIf	

Return AGRI045(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRA045B º Autor ³ Ricardo Tomasi     º Data ³  21/07/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina auxilial para validar a tela de cadastro.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGRA045B(nOpc, oModel)
Local lRet 	  := .T.
//Local lIntSFC := FindFunction('IntegraSFC') .And. IntegraSFC() .And. !IsInCallStack("AUTO045")// Determina se existe integracao com o SFC
Local lIntSFC := FindFunction('ExisteSFC') .And. ExisteSFC("NNR") .And. !IsInCallStack("AUTO045")// Determina se existe integracao com o SFC
Local lIntDPR := FindFunction('IntegraDPR') .And. IntegraDPR() .And. !IsInCallStack("AUTO045")// Determina se existe integracao com o DPR
Local lVer117 := (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R7"  .Or.  VAL(GetVersao(.F.))  > 11)


If	lRet
	If	nOpc==5
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe Armazém vinculado nas tabelas SB1, SB2, SBR, SB4 e NN2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		#IFDEF TOP        
			If TcSrvType()<>"AS/400"
			
				BeginSQL Alias "NNRTMP"
				
					SELECT SB1.B1_LOCPAD FROM %Table:SB1% SB1
					WHERE  SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_LOCPAD = %Exp:NNR->NNR_CODIGO% AND SB1.%NotDel%
					UNION 
					SELECT SB2.B2_LOCAL FROM %Table:SB2%  SB2
					WHERE SB2.B2_FILIAL = %xFilial:SB2% AND SB2.B2_LOCAL  = %Exp:NNR->NNR_CODIGO% AND SB2.%NotDel% 
					UNION 
					SELECT SB4.B4_LOCPAD FROM %Table:SB4%  SB4
					WHERE SB4.B4_FILIAL = %xFilial:SB4% AND SB4.B4_LOCPAD = %Exp:NNR->NNR_CODIGO% AND SB4.%NotDel%
					UNION 
					SELECT SBR.BR_LOCPAD FROM %Table:SBR% SBR 
					WHERE SBR.BR_FILIAL = %xFilial:SBR% AND SBR.BR_LOCPAD = %Exp:NNR->NNR_CODIGO% AND SBR.%NotDel%
					UNION 
					SELECT NN2.NN2_ARMPAD FROM %Table:NN2% NN2 
					WHERE NN2.NN2_FILIAL = %xFilial:NN2% AND NN2.NN2_ARMPAD = %Exp:NNR->NNR_CODIGO% AND NN2.%NotDel%
					
				EndSQL			
					
				If NNRTMP->(!Eof())
					Help(" ",1,"NODELETA") //Exibe Help que não é possivel a exclusao do registro
					lRet := .F.
				Else
					lRet := .T.
				EndIf
				NNRTMP->(dbCloseArea())
			Else
		#ENDIF
			lRet := .F.
			SB2->(dbSetOrder(2))
			If !(SB2->(dbSeek(xFilial("SB2")+NNR->NNR_CODIGO)))
				SB1->(dbSetFilter({|| &("SB1->B1_LOCPAD == '" +NNR->NNR_CODIGO +"'")},"SB1->B1_LOCPAD == '" +NNR->NNR_CODIGO +"'"))
				If (SB1->(Eof()))
					SB4->(dbSetFilter({|| &("SB4->B4_LOCPAD == '" +NNR->NNR_CODIGO +"'")},"SB4->B4_LOCPAD == '" +NNR->NNR_CODIGO +"'"))
					If (SB4->(Eof()))
						SBR->(dbSetFilter({|| &("SBR->BR_LOCPAD == '" +NNR->NNR_CODIGO +"'")},"SBR->BR_LOCPAD == '" +NNR->NNR_CODIGO +"'"))
						If (SBR->(Eof()))
							NN2->(dbSetFilter({|| &("NN2->NN2_ARMPAD == '" +NNR->NNR_CODIGO +"'")},"NN2->NN2_ARMPAD == '" +NNR->NNR_CODIGO +"'"))
							If (NN2->(Eof()))
								lRet:= .T.									
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf							
	
			If !lRet
				Help(" ",1,"NODELETA") //Exibe Help que não é possivel a exclusao do registro
			EndIf
		#IFDEF TOP
			EndIf
		#ENDIF
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina para integracao com SFC e DPR	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. lVer117 .And. (lIntDPR .Or. lIntSFC)
	lRet := A045IntSFC(nOpc)	
EndIf
If lRet .And. PCPIntgPPI()
   lRet := AGRA045PPI(,,nOpc, oModel)
EndIf
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} A035IntSFC
Atualiza tabelas do SFC conforme modelagem dos dados(MVC)

@author Leonardo Quintania
@since 13/11/2012
@version 11.80
*/
//-------------------------------------------------------------------
Function A045IntSFC(nOpc,cError,cNome)
Local aArea   := GetArea()	// Salva area atual para posterior restauracao
Local lRet    := .T.		// Conteudo de retorno
Local aCampos := {}			// Array dos campos a serem atualizados pelo modelo
Local aAux    := {}			// Array auxiliar com o conteudo dos campos
Local nX	  	:= 0			// Indexadora de laco For/Next
Local oModel  := NIL		// Objeto de modelo de dados

If M->NNR_CODIGO != Nil .Or. nOpc == 5 //Se nenhuma alteração foi feita no código ou descrição do Armazem, não integra
	
	If nOpc == 3
		aAdd(aCampos,{"CZX_CDDP",M->NNR_CODIGO})
	EndIf
	
	If nOpc # 5
		aAdd(aCampos,{"CZX_DSDP",M->NNR_DESCRI})
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Instancia modelo de dados(Model) do Depositos - SFC e DPR  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel := FWLoadModel("SFCA022")
	oModel:SetOperation(nOpc)
	
	If nOpc == 4
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando se tratar de alteracao primeiramente o registro devera ser posicionado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CZX->(dbSetOrder(1))
		CZX->(dbSeek(xFilial("CZX")+M->NNR_CODIGO))
	ElseIf nOpc == 5
		CZX->(dbSetOrder(1))
		CZX->(dbSeek(xFilial("CZX")+NNR->NNR_CODIGO))
	EndIf
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ativa o modelo de dados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lRet := oModel:Activate())
	
		If nOpc # 5
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem a estrutura de dados do Model ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAux := oModel:GetModel("CZXMASTER"):GetStruct():GetFields()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Loop para validacao e atribuicao de dados dos campos do Model ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To Len(aCampos)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida os campos existentes na estrutura do Model ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCampos[nX,1])}) > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atribui os valores aos campos do Model caso passem pela validacao do formulario ³
					//³referente a tipos de dados, tamanho ou outras incompatibilidades estruturais.   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(oModel:SetValue("CZXMASTER",aCampos[nX,1],aCampos[nX,2]))
						lRet := .F.
						Exit       
					EndIf
				EndIf
			Next nX

		EndIf

	Endif
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida os dados e integridade conforme dicionario do Model ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lRet := oModel:VldData())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva gravacao dos dados na tabela ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := oModel:CommitData()
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera log de erro caso nao tenha passado pela validacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRet
		A010SFCErr(oModel,@cError,NIL,cNome,NNR->NNR_CODIGO)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desativa o Model ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:DeActivate()

EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA045PPI

Realiza a integração com o PC-Factory - PPI Multitask

@param cXml    - XML que será enviado. Caso não seja passado esse parametro, será realizada
                 a chamada do Adapter para criação do XML.
                 Se for passado esse parâmetro, não será exibida a mensagem de erro caso exista,
                 nem será considerado o filtro da tabela SOE.
@param cCodigo - Obrigatório quando utilizado o parâmetro cXml. Contém o código do local de estoque
@param nOpc    - Opção que está sendo executada.
                 MODEL_OPERATION_INSERT
                 MODEL_OPERATION_UPDATE
                 MODEL_OPERATION_DELETE
@param oModelAct - Referência do modelo de dados MVC
@param lFiltra   - Identifica se será realizado ou não o filtro do registro.
@param lPendAut  - Indica se será gerada a pendência sem realizar a pergunta para o usuário, caso ocorra algum erro.

@author  Lucas Konrad França
@version P12
@since   17/08/2015
@return  lRet  - Indica se a integração com o PC-Factory foi realizada.
           .T. -> Integração Realizada
           .F. -> Integração não realizada.
/*/
//-------------------------------------------------------------------------------------------------
Function AGRA045PPI(cXml, cCodigo, nOpc, oModelAct, lFiltra, lPendAut)
   Local lRet      := .T.
   Local aRetXML   := {}
   Local aRetData  := {}
   Local aRetWS    := {}
   Local aRetArq   := {}
   Local aArea     := GetArea()
   Local cOperacao := ""
   Local cGerouXml := ""
   Local cNomeXml  := ""
   Local lRetXml   := .T.
   //Local cBkpTmp   := ""
   //Local oModelAct := Nil

   Private oModelNNR  := Nil
   Private oModel     := oModelAct
   //Variável utilizada para identificar que está sendo executada a integração para o PPI dentro do MATI010.
   Private lRunPPI := .T.

   Default cXml     := ""
   Default cCodigo  := ""
   Default nOpc     := MODEL_OPERATION_UPDATE
   Default lFiltra  := .T.
   Default lPendAut := .F.

   //cBkpTmp := PCPVldTmp("NNR","AGRA045",.T.)
   //Se a variável cTmpPPI não estiver definida, assume o nome retornado pela função PCPVldTmp
   //If Type("cTmpPPI") != "C"
      //cTmpPPI := cBkpTmp
   //EndIf

   If Empty(cXml)
      //oModelAct := FwModelActive()
      oModelNNR := oModelAct:GetModel('NNRMASTER')
      cCodigo   := oModelNNR:GetValue('NNR_CODIGO')
      Do Case
         Case nOpc == MODEL_OPERATION_INSERT
            cOperacao := "incluir"
         Case nOpc == MODEL_OPERATION_UPDATE
            cOperacao := "alterar"
         Case nOpc == MODEL_OPERATION_DELETE
            cOperacao := "excluir"
      EndCase
   EndIf

   //Realiza filtro na tabela SOE, para verificar se o recurso entra na integração.
   If !Empty(cXml) .Or. !lFiltra .Or. PCPFiltPPI("NNR", cCodigo,"oModelNNR:GetValue('?')")
      //Adapter para criação do XML
      If Empty(cXml)
         //aRetXML := FwIntegDef("AGRA045",,,, "AGRA045")
		aRetXML := AGRI045("", TRANS_SEND, EAI_MESSAGE_BUSINESS)
		 If ValType(aRetXML) == "U"
		 	lRetXml := .F.
		 EndIf
      Else
         aRetXML := {.T., cXml}
      EndIf
      /*
         aRetXML[1] - Status da criação do XML
         aRetXML[2] - String com o XML
      */

      If lRetXml .AND. aRetXML[1]
         //Retira os caracteres especiais
         aRetXML[2] := EncodeUTF8(aRetXML[2])

         //Busca a data/hora de geração do XML
         aRetData := PCPxDtXml(aRetXML[2])
         /*
            aRetData[1] - Data de geração AAAAMMDD
            aRetData[1] - Hora de geração HH:MM:SS
         */

         //Envia o XML para o PCFactory
         aRetWS := PCPWebsPPI(aRetXML[2])
         /*
            aRetWS[1] - Status do envio (1 - OK, 2 - Pendente, 3 - Erro.)
            aRetWS[2] - Mensagem de retorno do PPI
         */
         If lPendAut
            lRet := .T.
         Else
            If aRetWS[1] != "1" .And. Empty(cXml)
               //"Atenção! Ocorreram erros na integração com o PCFactory. Erro: "
               // XXXXXX
               // XXXXXX
               // "Deseja incluir/alterar/excluir o local de estoque no protheus e gerar pendência para integração?"
               If !MsgYesNo(STR0019 + AllTrim(aRetWS[2]) + CHR(10) + ;
               	         STR0020 + AllTrim(cOperacao) + STR0021)
                  lRet := .F.
               EndIf
            EndIf
         EndIf
         If lRet
            //Cria o XML fisicamente no diretório parametrizado
            aRetArq := PCPXmLPPI(aRetWS[1],"NNR",cCodigo,aRetData[1],aRetData[2],aRetXML[2])
            /*
               aRetArq[1] Status da criação do arquivo. .T./.F.
               aRetArq[2] Nome do XML caso tenha criado. Mensagem de erro caso não tenha criado o XML.
            */
            If !aRetArq[1]
               If Empty(cXml) .And. !lPendAut
                  Alert(aRetArq[2])
               EndIf
            Else
               cNomeXml := aRetArq[2]
            EndIf
            If Empty(cNomeXml)
               cGerouXml := "2"
            Else
               cGerouXml := "1"
            EndIf
            //Cria a tabela SOF
            PCPCriaSOF("NNR",cCodigo,aRetWS[1],cGerouXml,cNomeXml,aRetData[1],aRetData[2],__cUserId,aRetWS[2],aRetXML[2])
         EndIf
      EndIf
   EndIf
   //Tratativa para retornar .F. mesmo quando é pendência automática;
   //Utilizado apenas para o programa de sincronização.
   If AllTrim(FunName()) == "PCPA111" .And. (Empty(aRetWS) .Or. aRetWS[1] != "1")
      lRet := .F.
   EndIf

   RestArea(aArea)
Return lRet

//-- Objetivo: Validar se não há saldo para permitir a alteração
Function AGRA045WMS()
Local lRet      := .T.
	If (Empty(NNR->NNR_AMZUNI) .And. M->NNR_AMZUNI == '1') .Or. (!Empty(NNR->NNR_AMZUNI) .And. !(NNR->NNR_AMZUNI == M->NNR_AMZUNI))
		lRet := WmsSldAmz(M->NNR_CODIGO)
	EndIf
Return lRet
