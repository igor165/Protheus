#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOJA980.CH"    


Static cRotina := "LOJA980"	//Nome da Rotina
Static cDescr	:= STR0001 //"Gar./Serv. por Faixa de Pre�o" 		 
Static lProdSF   := .F.			//Produto Servi�o Financeiro
Static cTipoProd	:= ""			//B1_TIPO
Static cProdChave	:= ""			//Ultimo campo chave digitado no M->MBF_PRDGAR

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA980   �Autor  �Microsiga           � Data �  08/08/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Garantia por Faixa de Pre�o                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function LOJA980()
	Local oBrowse := Nil						//Objeto Browse
	Local aAliSX2 := SX2->(GetArea())  //WorkAreaSX2 

	cNomeRot := FunName()

	SX2->(DbSetOrder(1))
	If SX2->(DbSeek("MBF")) 
		cDescr :=  SX2->(X2Nome() )
	EndIf

	RestArea(aAliSX2)


	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'MBF' )
	oBrowse:SetDescription( cDescr )
	oBrowse:Activate()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef	� Autor � Vendas CRM            � Data �14/08/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef() 
	Local aRotina := {}                                     //Array da MenuDef

	ADD OPTION aRotina Title STR0002     Action "ViewDef." + cRotina OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0003     Action "ViewDef." + cRotina OPERATION MODEL_OPERATION_INSERT ACCESS 0  //3  "Incluir"
	ADD OPTION aRotina Title STR0004     Action "ViewDef." + cRotina OPERATION MODEL_OPERATION_UPDATE ACCESS 0  //4"Alterar"
	ADD OPTION aRotina Title STR0005     Action "ViewDef." + cRotina OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir"

Return aRotina					


Function Lj980VlIni()

Return nValor      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |ModelDef	� Autor � Vendas CRM            � Data �14/08/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o da View                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel - Modelo			              	                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruMBF := FWFormStruct( 1, 'MBF')  //Estrutura da Tabela MBF
	Local oStruMBL := FWFormStruct( 1, 'MBL')  //Estrutura da Tabela MBL
	Local oModel   := nil                       //Modelo

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( cRotina, /*bPreValidacao*/, { |oMdl| Lj98VlPk(oMdl)} , /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( cRotina + "M", NIL, oStruMBF )

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
	oModel:AddGrid( cRotina + "D", cRotina + "M", oStruMBL ,{|A,B,C,D|Lj980It2(A,B,C,D)})

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( cRotina + "D", { { 'MBL_FILIAL', 'xFilial( "MBL" ) ' } , { 'MBL_CODIGO', 'MBF_CODIGO' } } , "MBL_FILIAL + MBL_CODIGO" )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( cRotina + "D" ):SetUniqueLine( {'MBL_ITEM' } ) 

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( cDescr )      

	oModel:SetPrimaryKey({"MBF_PRDGAR", "MBF_PRODPRD", "MBF_GRUPO"})

	//Se rotina foi chamada pelo cadastro e servicos financeiros, inicializa o Produto Servico
	If IsIncallStack("LOJA871")
		oStruMBF:SetProperty("MBF_PRDGAR", MODEL_FIELD_INIT, {|| M->MG8_PRDSB1})
	EndIf

Return oModel


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |ViewDef	� Autor � Vendas CRM            � Data �14/08/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o da View                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel - Modelo da View                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMK                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
	Local oModel   := FWLoadModel( cRotina )     //Modelo
	Local oStruMBF := FWFormStruct( 2, 'MBF')		//Estrutura da Tabela MBF
	Local oStruMBL := FWFormStruct( 2, 'MBL') 	//Estrutura da Tabela MBL
	Local oView 	:= nil                        //View de Retorno


	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "V" + cRotina + "M" , oStruMBF, cRotina + "M"  )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid( "V" + cRotina + "D" , oStruMBL, cRotina + "D"  )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'INFERIOR', 70 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( "V" + cRotina + "M", 'SUPERIOR' )
	oView:SetOwnerView( "V" + cRotina + "D", 'INFERIOR' )

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( "V" + cRotina + "D", 'MBL_ITEM' )         

Return oView           

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lj980IVlIn� Autor � Vendas CRM            � Data �14/08/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de retorno do valor Inicial da Faixa                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel - Modelo da View              	                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMK                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj980IVlIn()
	Local nValor 		:= 0         //Valor de Retorno da Rotina
	Local nOperation 	:= 0         //Opera��o do Modelo
	Local nLinhas		:= 0        //Linhas do Grid de Itens
	Local oModel 		:= Nil      //Modelo                          
	Local oModelD  	:= Nil      //Modelo Detalhe
	Local aSaveLines 	:= Nil      //Similar ao GetArea()  


	If IsInCallStack(cRotina)    

		oModel := FWModelActive()
		oModelD  := oModel:GetModel( cRotina + "D" )
		nOperation := oModel:GetOperation()

		If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)  .AND. Len(oModelD:aCols) > 0 .AND. oModelD:Length(.t.) >= 1
			aSaveLines := FWSaveRows()

			nLinhas := oModelD:Length()

			Do While nLinhas > 0

				oModelD:GoLine( nLinhas )

				If !oModelD:IsDeleted()// Deletada e n�o � nova, inserida
					nValor := oModelD:GetValue( 'MBL_VLFIM') 
					nLinhas := 0
				Else
					nLinhas--
				EndIf

			End


			FWRestRows( aSaveLines ) 
		EndIf
	EndIf

	nValor += 1/( 10 ^ TamSx3("MBL_VLINI")[2])

Return nValor

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lj98VlPk  � Autor � Vendas CRM            � Data �14/08/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Valida��o da Chave Prim�ria do registro          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � L�gico - Modelo v�lido              	                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMK                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj98VlPk(oModel) 
	Local nOperation := oModel:GetOperation()
	Local lRet       := .T.     
	Local aAreaMBF   := nil


	If nOperation == MODEL_OPERATION_INSERT 
		aAreaMBF		:= MBF->(GetArea()) 
		MBF->(DbSetOrder(1)) //MBF_PRDGAR+ MBF_PRODPR +MBF_GRUPO
		If MBF->(DbSeek( xFilial("MBF") + oModel:GetValue( cRotina + "M", 'MBF_PRDGAR' )+	oModel:GetValue( cRotina + "M", 'MBF_PRODPR' ) + 	oModel:GetValue( cRotina + "M", 'MBF_GRUPO' )))
			Help( ,, 'HELP',, STR0006, 1, 0)    //"Ja existe registro com esta chave."
			lRet := .F.  
		EndIf
		If !ExistCpo("SB1",oModel:GetValue(cRotina+"M",'MBF_PRDGAR'))
			lRet := .F.  
		EndIf

		RestArea(aAreaMBF)
	EndIf

	//Valido se o PRODUTO e o GRUPO tiverem preenchidos. Se sim, N�O PASSAR. Ou o Produto, ou o Grupo. N�o vale para Serv. Financeiros
	If lRet .AND. !lProdSF .AND. ;
	(nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)

		If !Empty(oModel:GetValue(cRotina+"M",'MBF_PRODPR')) .AND. !Empty(oModel:GetValue(cRotina+"M",'MBF_GRUPO'))
			Help( ,, 'HELP',, "N�o devem estar preenchidos os campos Produto (MBF_PRODPR) e Grupo (MBF_GRUPO). Preencha um dos campos citados.", 1, 0)	//"N�o devem estar preenchidos os campos Produto (MBF_PRODPR) e Grupo (MBF_GRUPO). Preencha um dos campos citados."
			lRet := .F.
		EndIf

	EndIf

Return lRet  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lj980Ed   � Autor � Vendas CRM            � Data �14/08/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Valida��o do campo para edi��o                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � L�gico - Registro pode ser editado    				      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMK                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Lj980Ed()
	Local oModel 		:= Nil	//Modelo                          
	Local oModelM		:= Nil	//Modelo Master
	Local lSFinanc  	:= AliasIndic("MG8")
	Local cMvLjTSf		:= Iif(lSFinanc,SuperGetMV("MV_LJTPSF",,"SF"),'') 	// Define se � tipo SF
	Local lRetorno		:= .F.

	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	If IsInCallStack(cRotina)    
		oModel 	:= FWModelActive()
		oModelM	:= oModel:GetModel(cRotina + "M") //Pega o modelo Master

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			lRetorno := .T. 
		ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. Posicione("SB1", 1, xFilial("SB1")+oModelM:GetValue("MBF_PRDGAR"), "B1_TIPO") == cMvLjTSf		
			lRetorno := .T.	
		EndIf

		If (M->MBF_PRDGAR <> cProdChave) .AND. (oModel:GetOperation() == MODEL_OPERATION_UPDATE) //Preciso verificar se o primeiro produto � um servi�o financeiro na altera��o
			cProdChave := M->MBF_PRDGAR		//Assim eu evito passar por esse mesmo lugar mais de x vezes na altera��o
			cTipoProd := Posicione( "SB1", 1, xFilial("SB1")+M->MBF_PRDGAR, "B1_TIPO" )
			If cTipoProd = cMvLjTSf
				lProdSF := .T.
			EndIf
		EndIf

	ElseIf IsInCallStack("LOJA871")
		//Se chamada do Cadastro de Servicos Financeiros, desabilita apenas Produto Servico 
		If ReadVar() <> "M->MBF_PRDGAR"
			lRetorno := .T.
		Else	//Inicializando
			lProdSF := .T.
			cTipoProd := cMvLjTSf	
		EndIf
	EndIf

	If (ReadVar() = "M->MBF_GRUPO" .AND. cTipoProd = cMvLjTSf) //Se Servi�os Financeiros, eu n�o edito o grupo.
		lRetorno := .F.
	EndIf

	If lAutomato
		lRetorno := lAutomato
	EndIf

Return  lRetorno


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lj980It   � Autor � Vendas CRM            � Data �25/10/13  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Valida��o dos valores de Range da Ge por Fx      ���
��� 		   funcao chamada no X3_Valid do campo MBL_VLINI e MBL_VLFIM  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � L�gico - Registro pode ser editado    				      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMK                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Lj980It(oModel,nLinhas,cAcao)

	Local lRetorno		:= .T.
	Local nValor 		:= 0         //Valor de Retorno da Rotina
	Local nOperation 	:= 0         //Opera��o do Modelo

	Local oModelD  	    := Nil      //Modelo Detalhe
	Local aSaveLines 	:= Nil      //Similar ao GetArea()  
	Local nLinhaC		:= 0

	Default nLinhas		:= 0        //Linhas do Grid de Itens
	Default oModel 		:= Nil      //Modelo                          

	If  FWFLDGET("MBL_VLFIM") > 0 .AND. (FWFLDGET("MBL_VLINI") >  FWFLDGET("MBL_VLFIM")) 
		Help( ,, 'HELP',, STR0007 , 1, 0) //"Valor Final deve ser maior que valor inicial"
		lRetorno := .F.    
	Endif	

	If IsInCallStack(cRotina) .AND. lRetorno    

		oModel := FWModelActive()
		oModelD  := oModel:GetModel( cRotina + "D" )
		nOperation := oModel:GetOperation()

		If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)  .AND. Len(oModelD:aCols) > 0 .AND. oModelD:Length(.t.) >= 1
			aSaveLines := FWSaveRows()

			nLinhas := 1
			nLinhaC := oModelD:nLine   // linha corrente

			// Pega valor da linha corrente 
			nValori := oModelD:GetValue( 'MBL_VLINI')						  
			nValor  := oModelD:GetValue( 'MBL_VLFIM')						  

			Do While nLinhas <= oModelD:Length()

				If nLinhas <> nLinhaC  // nao processa linha corrente 

					oModelD:GoLine( nLinhas )

					If !oModelD:IsDeleted()// Deletada e n�o � nova, inserida

						If (nValor  >= oModelD:GetValue( 'MBL_VLINI') .AND. nValor  <= oModelD:GetValue( 'MBL_VLFIM')) .OR. ;
						(nValori >= oModelD:GetValue( 'MBL_VLINI') .AND. nValori <= oModelD:GetValue( 'MBL_VLFIM'))
							Help( ,, 'HELP',, STR0008 + Alltrim(Str(nLinhas)), 1, 0) //"Valor j� cadastrado na Faixa "    
							lRetorno := .F.
							nLinhas := oModelD:Length()+1
						ElseIf 	oModelD:GetValue( 'MBL_VLINI') >= nValori  .AND. oModelD:GetValue( 'MBL_VLFIM') <= nValor
							Help( ,, 'HELP',, STR0009 + Alltrim(Str(nLinhas)), 1, 0) //"Valor contempla Faixa "    
							lRetorno := .F.
							nLinhas := oModelD:Length()+1
						EndIf
					ELse

					EndIf
				EndIf

				nLinhas++
			End

			FWRestRows( aSaveLines ) 
		EndIf
	EndIf

Return  lRetorno


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |Lj980It2  � Autor � Vendas CRM            � Data �25/10/13  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Valida��o da recuperacao de item de garantia     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � L�gico - Registro pode ser editado    				      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMK                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Lj980It2(oModel,nLinha,cAcao,D)

	Local lRet := .T.


	If cAcao == "UNDELETE"
		Help( ,, 'HELP',, STR0010 , 1, 0) //"Item n�o pode ser recuperado"    
		lRet := .F.

	EndIf

Return lRet




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj980VlPro�Autor  � Vendas Cliente     � Data �  28/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se o codigo do produto informado existe             ���
���          � e se esta relacionado a garantia                           ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA980                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj980VlPro(nValid)

	Local	lRet		:= ExistCpo("SB1",&(ReadVar()))						// Variavel de retorno
	Local	cMvLjTGar	:= SuperGetMV("MV_LJTPGAR",,"GE") 					// Define se � tipo GE 
	Local   lSFinanc    := AliasIndic("MG8") 
	Local   cMvLjTSf	:= Iif(lSFinanc,SuperGetMV("MV_LJTPSF",,"SF"),'') 	// Define se � tipo SF 
	Local   oView//       := FwViewActive()             						//View ativa
	Local   oModel// 		:= FWModelActive()
	Local 	nI			:= 0        
	Local 	nOperation // := oModel:GetOperation() 							//Opera��o do Modelo

	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	If !lAutomato
		oView	 := FwViewActive()   // Pega view ativa
		oModel   := oView:GetModel()  // Pega o modelo
		oModelM	 := oModel:GetModel(cRotina + "M")              		//Pega o modelo
		oModelD	 := oModel:GetModel(cRotina + "D")              		//Pega o modelo itens
	Else
		oModel   := FWModelActive()
		oModelM	 := oModel:GetModel("LOJA980M")              		//Pega o modelo
		oModelD	 := oModel:GetModel("LOJA980D")              		//Pega o modelo itens
	EndIf  	 

	nOperation  := oModel:GetOperation() 							//Opera��o do Modelo

	Default nValid		:= 0 	

	If lRet
		If nValid == 1 //MBF_PRDGAR
			cTipoProd := Posicione( "SB1", 1, xFilial("SB1")+&(ReadVar()), "B1_TIPO" )
			lRet := cTipoProd $ cMvLjTGar+"|"+cMvLjTSf
			If !lRet  
				If lSFinanc .AND. cTipoProd == cMvLjTSf
					Help('',1,'PRODINVLD',,STR0011,1,0) //"Produto n�o � Garantia ou Servi�o Financeiro" 
				Else 
					Help('',1,'PRODINVLD',,STR0012,1,0) //"Produto n�o � Garantia" 
				EndIf	
			EndIf

			//Habilita campos nos itens
			aStru:= oModelD:GetStruct() 
			aStru:setProperty("MBL_VLINI", MODEL_FIELD_WHEN, {|| .T.})
			aStru:setProperty("MBL_VLFIM" , MODEL_FIELD_WHEN, {|| .T.})

			//Permite inserir novas linhas
			oModelD:SetNoInsertLine(.F.)

			//Nao permite deletar linhas
			oModelD:SetNoDeleteLine(.F.)

			If cTipoProd $ cMvLjTSf 
				lProdSF:= .T.

				If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
					MG8->(DbSetOrder(2))

					If MG8->(DbSeek(xFilial("MG8")+&(ReadVar())))				 																																																					 					
						//Validacoes Preco Fixo
						If MG8->MG8_TPPREC == "2" 													
							If MG8->MG8_TPXPRD == "1" //Com atrelamento										
								If MsgYesNo(STR0013 +; //"Produto Servi�o configurado para Pre�o Fixo, permitir� inser��o de apenas um �tem e "
								STR0014)   //"se j� houverem �tens adicionados ser�o apagados, deseja continuar?"																						 																																																																																														

									//Deleta linhas do grid se houver mais que 1
									For nI := 2 To oModelD:Length()
										oModelD:GoLine(nI)

										If !oModelD:IsDeleted()
											oModelD:DeleteLine()
										EndIf
									Next

									//Posiciona na primeira linha
									oModelD:GoLine(1)

									//Se primeira linha deletada, insere nova
									If oModelD:IsDeleted()
										//Adiciona linha no grid
										oModelD:AddLine()

										//Posiciona na ultima linha
										oModelD:GoLine(oModelD:Length())
									EndIf																					

									//Insere valores fixos
									oModelD:SetValue("MBL_VLINI", 0.01)
									oModelD:SetValue("MBL_VLFIM", 99999999999.99)
									oModelD:SetValue("MBL_VALOR", 0)
									oModelD:SetValue("MBL_CUSTO", 0)

									//Desabilita campos nos itens
									aStru:= oModelD:GetStruct() 
									aStru:setProperty("MBL_VLINI", MODEL_FIELD_WHEN, {|| .F.})
									aStru:setProperty("MBL_VLFIM" , MODEL_FIELD_WHEN, {|| .F.})

									//Nao permite inserir novas linhas
									oModelD:SetNoInsertLine(.T.)

									//Nao permite deletar linhas
									oModelD:SetNoDeleteLine(.T.)																	
								Else
									Help('',1,'PRODINVLD',,STR0015,1,0) //"Utilize produto que servi�o financeiro esteja configurado para Faixa de Pre�o."
									lRet := .F.
								EndIf						
							Else //Sem atrelamento						  							
								Help('',1,'PRODINVLD',,STR0016,1,0) //"Servi�o Financeiro com pre�o fixo e sem atrelamento, utilizar� custo cadastrado no produto."
								lRet := .F.												
							EndIf
						EndIf																																																			
					EndIf													
				EndIf
			Else	
				lProdSF:= .F.																			
			EndIf
		ElseIf nValid == 2 //MBF_PRODPR

			If lSFinanc .AND. (cTipoProd == cMvLjTSf)  //Servi�o Financeiro
				lRet := Posicione( "SB0", 1, xFilial("SB0")+&(ReadVar()), "B0_SERVFIN" ) == '1'
			Else	  //Garantia Estendida		
				lRet := Posicione( "SB1", 1, xFilial("SB1")+&(ReadVar()), "B1_GARANT" ) == '1'
			EndIf

			If !lRet
				If lSFinanc .AND. (cTipoProd == cMvLjTSf)  //Servi�o Financeiro
					Help('',1,'PRODINVLD',,STR0017,1,0) //"Produto n�o possui Servi�o Financeiro"
				Else		//Garantia Estendida
					Help('',1,'PRODINVLD',,STR0018,1,0) //"Produto n�o possui Garantia"
				EndIf
			EndIf
		EndIf
	Else
		Help('',1,'PRODINVLD',,STR0019,1,0) //"Produto n�o encontrado"
	EndIf
	If lRet .And. !lAutomato
		oView:Refresh(cRotina + "M")
	EndIf

Return lRet



