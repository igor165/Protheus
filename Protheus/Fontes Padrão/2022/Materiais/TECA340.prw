#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TECA340.CH"
#INCLUDE "FWMVCDEF.CH"
           
Static oGetPrd   := Nil    					// GetDados Produtos.
Static oGetAce	 := Nil						// GetDados Acessorios.
Static oViewPrp	:= Nil						// View Proposta
Static aLdCfgAlo := {} 						// Array com configuracoes de alocacao.

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �TECA340	 �Autor  �Vendas CRM          � Data � 23/10/12    ���
��������������������������������������������������������������������������͹��
���Desc.     �Configurador de Alocacao de Recursos.					 	   ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro					                           ���
��������������������������������������������������������������������������͹��
���Parametros�ExpO1 - GetDados Produtos. 		 				           ���
���			 �ExpC2 - GetDados Acessorios.  				 			   ���
���			 �ExpA3 - Array com configuracoes de alocacao.		 	  	   ���
��������������������������������������������������������������������������͹��
���Uso       �FATA600							                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TECA340(oViewProp,oMdlPROD,oMdlACES,aConfigAlo)

Local nPercReducao  := 30    													// Tamanho da interface.
Local nOpc			:= 4				   										// Operacao alterar.
Local bCloseOnOk	:= {||.T.}													// Bloco de codigo para fechamento da interface.

Private n								   										// Linha da aCols.

oViewPrp	:= oViewProp
oGetPrd   := oMdlPROD
oGetAce	  := oMdlACES

aLdCfgAlo := aClone(aConfigAlo)

If oGetPrd:SeekLine({{"ADZ_PRDALO", "1" }}) .Or. oGetAce:SeekLine({{"ADZ_PRDALO", "1" }})  
	FWExecView(STR0001,"VIEWDEF.TECA340",nOpc,/*oDlg*/,bCloseOnOk,/*bOk*/,nPercReducao)   			// "Proposta Comercial"
Else
	MsgStop(STR0002,STR0003)  // "N�o h� produtos de aloca��o na proposta comercial."#"Aten��o"
EndIf

Return( .T. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  23/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de Dados Configurador de Alocacao de Recursos.	   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �ExpO - Modelo de Dados                                      ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA600                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel        := Nil																																												   		// Objeto que contem o modelo de dados.
Local oStructADY	:= FWFormStruct(1,"ADY",{|cCampo| AllTrim(cCampo)+"|" $ "ADY_FILIAL|ADY_PROPOS|ADY_PREVIS|" } ,/*lViewUsado*/)																				// Campos cabecalho da proposta comercial.
Local oStructADZ  	:= FWFormStruct(1,"ADZ",{|cCampo| AllTrim(cCampo)+"|" $ "ADZ_FILIAL|ADZ_ITEM|ADZ_PRODUT|ADZ_DESCRI|ADZ_UM|ADZ_QTDVEN|ADZ_TPPROD|ADZ_FOLDER|ADZ_PROPOS|ADZ_REVISA|ADZ_PRDALO|ADZ_REC_WT" } ,/*lViewUsado*/)		// Campos Itens da proposta comercial.
Local oStructABO 	:= FWFormStruct(1,"ABO",/*bAvalCampo*/,/*lViewUsado*/)																																		// Campos configurador de alocacao.
Local bLoadAdy		:= {|oMdlFields,lCopy| At340LdAdy(oMdlFields,lCopy)} 																																		// Bloco de codigo para fazer load do cabe�alho da proposta comercial.
Local bLoadAdz	 	:= {|oMdlGrid  ,lCopy| At340LdAdz(oMdlGrid,lCopy)}																																			// Bloco de codigo para fazer load dos itens da proposta comercial.
Local bLoadAbo		:= {|oMdlFields,lCopy| At340LdAbo(oMdlFields,lCopy)} 																																		// Bloco de codigo para fazer load da configuracao da alocacao de recursos.
Local bPosValidacao := {|oModel|At340VdAlo(oModel)} 																																							// Bloco de codigo para validar o formulario.
Local bDcommit 		:= {|oModel| At340Commit(oModel)}

// Legenda Configurador de Alocacao de Recursos
oStructADZ:AddField(	AllTrim("")			,;  	// [01] C Titulo do campo
						AllTrim(STR0004)	,;   	// [02] C ToolTip do campo
						"ADZ_LEGEN" 		,;    	// [03] C identificador (ID) do Field
						"C" 				,;    	// [04] C Tipo do campo
						15 					,;    	// [05] N Tamanho do campo
						0 					,;    	// [06] N Decimal do campo
						Nil 				,;    	// [07] B Code-block de valida��o do campo
						Nil					,;     	// [08] B Code-block de valida��o When do campo
						Nil 				,;    	// [09] A Lista de valores permitido do campo
						Nil 				,;  	// [10] L Indica se o campo tem preenchimento obrigat�rio
						{|| "BR_BRANCO"} 	,;   	// [11] B Code-block de inicializacao do campo
						Nil 				,;  	// [12] L Indica se trata de um campo chave
						Nil 				,;     	// [13] L Indica se o campo pode receber valor em uma opera��o de update.
						.T. )              			// [14] L Indica se o campo � virtual


// Pasta Configurador de Alocacao
oStructADZ:AddField(	AllTrim(STR0005)	,;  	// [01] C Titulo do campo
						AllTrim(STR0005)	,;   	// [02] C ToolTip do campo
						"ADZ_PASTA" 		,;    	// [03] C identificador (ID) do Field
						"C" 				,;    	// [04] C Tipo do campo
						15 					,;    	// [05] N Tamanho do campo
						0 					,;    	// [06] N Decimal do campo
						Nil 				,;    	// [07] B Code-block de valida��o do campo
						Nil					,;     	// [08] B Code-block de valida��o When do campo
						Nil 				,;    	// [09] A Lista de valores permitido do campo
						Nil 				,;  	// [10] L Indica se o campo tem preenchimento obrigat�rio
						Nil   				,;   	// [11] B Code-block de inicializacao do campo
						Nil 				,;  	// [12] L Indica se trata de um campo chave
						Nil 				,;     	// [13] L Indica se o campo pode receber valor em uma opera��o de update.
						.T. )              			// [14] L Indica se o campo � virtual
						
						
//������������������������������������������������������������������Ŀ
//� Instancia o modelo de dados Configurador de Alocacao de Recursos.�
//��������������������������������������������������������������������
oModel := MPFormModel():New("TECA340",/*bPreValidacao*/,bPosValidacao,bDcommit/*bCommit*/,/*bCancel*/)

//����������������������������������������Ŀ
//� Adiciona os campos no modelo de dados. �
//������������������������������������������
oModel:AddFields("ADYMASTER",/*cOwner*/,oStructADY,/*bPreValidacao*/,/*bPosValidacao*/,bLoadAdy)
oModel:AddGrid("ADZDETAIL","ADYMASTER",oStructADZ,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,bLoadAdz)
oModel:AddFields("ABOFIELDS","ADZDETAIL",oStructABO,/*bPreValidacao*/,/*bPosValidacao*/,bLoadAbo)

//�������������������������������Ŀ
//� Relacionamento com ADYMASTER. �
//���������������������������������
oModel:SetRelation("ADZDETAIL",{	{"ADZ_FILIAL","xFilial('ADZ')"}	,;
									{"ADZ_PROPOS","ADY_PROPOS"}		,;
									{"ADZ_REVISA","ADY_PREVIS"}}	,;
									ADZ->( IndexKey(1)))

//�������������������������������Ŀ
//� Relacionamento com ADZDETAIL. �
//���������������������������������
oModel:SetRelation("ABOFIELDS",{	{"ABO_FILIAL","xFilial('ABO')"}	,;
									{"ABO_PROPOS","ADZ_PROPOS"}		,;
									{"ABO_REVPRO","ADZ_REVISA"}		,;
									{"ABO_FOLPRO","ADZ_FOLDER"}		,;
									{"ABO_ITPRO","ADZ_ITEM"} 		,;
									{"ABO_PRODUT","ADZ_PRODUT"}}	,;
									ABO->( IndexKey(1)))
									
//����������������������������������Ŀ
//� Cabecalho da proposta comercial. �
//������������������������������������
oModel:GetModel("ADYMASTER"):SetOnlyView(.T.)
oModel:GetModel("ADYMASTER"):SetOnlyQuery(.T.)

//������������������������������Ŀ
//� Itens da proposta comercial. �
//��������������������������������
oModel:GetModel("ADZDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("ADZDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("ADZDETAIL"):SetNoDeleteLine(.T.)

//���������������������������������������Ŀ
//� Configurador da alocacao de recursos. �
//�����������������������������������������
oModel:GetModel("ABOFIELDS"):SetOnlyQuery(.T.)

oModel:SetDescription(STR0006)	// "Configurador de Aloca��o de Recursos"

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  23/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface Configurador de Alocacao de Recursos.	          ���
�������������������������������������������������������������������������͹��
���Retorno   �ExpO - Interface                                            ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA600                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView     	:= Nil																																									// Objeto que contem interface configurador de alocacao de recursos.
Local oModel   		:= FWLoadModel("TECA340")																																				// Objeto que contem o modelo de dados.
Local oStructADZ  	:= FWFormStruct(2,"ADZ",{|cCampo| AllTrim(cCampo)+"|" $ "ADZ_FILIAL|ADZ_ITEM|ADZ_PRODUT|ADZ_DESCRI|ADZ_UM|ADZ_QTDVEN|ADZ_TPPROD|ADZ_FOLDER|"} ,/*lViewUsado*/)			// Campos Itens da proposta comercial.
Local oStructABO 	:= FWFormStruct(2,"ABO",/*bAvalCampo*/,/*lViewUsado*/)	 																												// Campos configurador de alocacao.
Local lTecXRh		:= SuperGetMv("MV_TECXRH",,.F.)																																		// Integracao Gestao de Servicos com RH?.

// Legenda Configurador de Alocacao de Recursos
oStructADZ:AddField(	"ADZ_LEGEN" 		,;	// [01] C Nome do Campo
						"01" 				,; 	// [02] C Ordem
						AllTrim("")			,; 	// [03] C Titulo do campo
						AllTrim(STR0004)	,; 	// [04] C Descri��o do campo
						{STR0004} 	   		,; 	// [05] A Array com Help
						"C" 				,; 	// [06] C Tipo do campo
						"@BMP" 				,; 	// [07] C Picture
						Nil 				,; 	// [08] B Bloco de Picture Var
						"" 					,; 	// [09] C Consulta F3
						.F. 				,;	// [10] L Indica se o campo � evit�vel
						Nil 				,; 	// [11] C Pasta do campo
						Nil 				,;	// [12] C Agrupamento do campo
						Nil 				,; 	// [13] A Lista de valores permitido do campo (Combo)
						Nil 				,;	// [14] N Tamanho Maximo da maior op��o do combo
						Nil 				,;	// [15] C Inicializador de Browse
						.T. 				,;	// [16] L Indica se o campo � virtual
						Nil )                 	// [17] C Picture Vari�vel

// Pasta Configurador de Alocacao de Recursos
oStructADZ:AddField(	"ADZ_PASTA" 		,;	// [01] C Nome do Campo
						"02" 				,; 	// [02] C Ordem
						AllTrim(STR0005)	,; 	// [03] C Titulo do campo
						AllTrim(STR0005)	,; 	// [04] C Descri��o do campo
						{STR0005} 	   		,; 	// [05] A Array com Help
						"C" 				,; 	// [06] C Tipo do campo
						"" 					,; 	// [07] C Picture
						Nil 				,; 	// [08] B Bloco de Picture Var
						"" 					,; 	// [09] C Consulta F3
						.F. 				,;	// [10] L Indica se o campo � evit�vel
						Nil 				,; 	// [11] C Pasta do campo
						Nil 				,;	// [12] C Agrupamento do campo
						Nil 				,; 	// [13] A Lista de valores permitido do campo (Combo)
						Nil 				,;	// [14] N Tamanho Maximo da maior op��o do combo
						Nil 				,;	// [15] C Inicializador de Browse
						.T. 				,;	// [16] L Indica se o campo � virtual
						Nil )                 	// [17] C Picture Vari�vel

//�����������������������������������������������Ŀ
//� Remove os campos da interface. 				  �
//� Estes campos nao sera utilizado pelo usuario. �
//�������������������������������������������������
oStructADZ:RemoveField("ADZ_FOLDER")
oStructABO:RemoveField("ABO_PROPOS")
oStructABO:RemoveField("ABO_REVPRO")
oStructABO:RemoveField("ABO_FOLPRO")
oStructABO:RemoveField("ABO_ITPRO")
oStructABO:RemoveField("ABO_PRODUT")
oStructABO:RemoveField("ABO_TPPROD")

//���������������������������������������������������������������������Ŀ
//� Remove os campos da interface. 									  	�
//� Estes campos nao sera utilizado pelo usuario sem integracao com RH. �
//�����������������������������������������������������������������������
If !lTecXRh
	oStructABO:RemoveField("ABO_CARGO")
	oStructABO:RemoveField("ABO_DCARGO")
EndIf

oStructADZ:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

//�������������������������������������������������������������Ŀ
//� Instancia a interface Configuracao de Alocacao de Recursos. �
//���������������������������������������������������������������
oView := FWFormView():New()
oView:SetModel(oModel)

//����������������������������������Ŀ
//� Adiciona os campos na interface. �
//������������������������������������
oView:AddGrid("VIEW_PRD_ALOC",oStructADZ,"ADZDETAIL")
oView:AddField("VIEW_CONF_ALOC",oStructABO,"ABOFIELDS")

//������������������������������Ŀ
//� Itens da proposta comercial. �
//��������������������������������
oView:CreateHorizontalBox("TOP",40)
oView:EnableTitleView("VIEW_PRD_ALOC",STR0007)	// "Produtos de Aloca��o"
oView:SetOwnerView("VIEW_PRD_ALOC","TOP")

//���������������������������������������Ŀ
//� Configurador de alocacao de recursos. �
//�����������������������������������������
oView:CreateHorizontalBox("BOTTOM",60)
oView:CreateVerticalBox("FIELDS",85,"BOTTOM")
oView:EnableTitleView("VIEW_CONF_ALOC",STR0006)	// "Configurador de Aloca��o de Recursos"
oView:SetOwnerView("VIEW_CONF_ALOC","FIELDS")

//������������������Ŀ
//� Botoes de Acoes. �
//��������������������
oView:CreateVerticalBox("BUTTONS",15,"BOTTOM")
oView:AddOtherObject("ACTION_BTN",{|oPanel| At340BtAct(oPanel) })
oView:SetOwnerView("ACTION_BTN","BUTTONS")

//���������Ŀ
//� Legenda �
//�����������
oView:AddUserButton("Legenda","",{|| At340Leg() })

Return(oView)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Vendas CRM          � Data �  23/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Criacao do MenuDef.	  	                        		  ���
�������������������������������������������������������������������������͹��
���Retorno   �ExpA - Opcoes de menu                                       ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA600                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0008 ACTION "PesqBrw" 			OPERATION 1	ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.TECA340"	OPERATION 2	ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.TECA340"	OPERATION 4	ACCESS 0	// "Alterar"

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �At340Leg  �Autor  �Vendas CRM          � Data �  24/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda da Vistoria Tecnica.	  	                          ���
�������������������������������������������������������������������������͹��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �TECA270                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function At340Leg()

Local oLegenda := FWLegend():New()

oLegenda:Add("","BR_BRANCO",STR0011)	// "Aloca��o n�o configurado."
oLegenda:Add("","BR_VERDE",STR0012)		// "Aloca��o configurado / estimado automaticamente."
oLegenda:Add("","BR_AMARELO",STR0013)	// "Aloca��o configurado / estimado manualmente."

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �At340VdAlo �Autor  �Vendas CRM          � Data � 23/10/12     ���
���������������������������������������������������������������������������͹��
���Desc.     �Valida toda a rotina alocacao de recurso(TudoOK).			   	���
���������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro / Falso		             	          	    ���
���������������������������������������������������������������������������͹��
���Parametros�ExpO - Modelo de Dados 										���
���������������������������������������������������������������������������͹��
���Uso       �FATA600							                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function At340VdAlo(oModel)

Local oMdlGrid		:= oModel:GetModel("ADZDETAIL")  		// Modelo de dados itens da proposta comercial.
Local oMdlFields	:= oModel:GetModel("ABOFIELDS")			// Modelo de dados configurador de alocacao de recursos.
Local nX		  	:= 0									// Incremento utilizado no laco For.
Local lRetorno      := .T.								    // Retorno da validacao.
Local lTecXRh		:= SuperGetMv("MV_TECXRH",,.F.)		// Integracao Gestao de Servicos com RH?.

For nX := 1 To oMdlGrid:Length()
	
	oMdlGrid:GoLine(nX)
	
	If oMdlFields:GetValue("ABO_TPREC") == "1"
		If lTecXRh
			If ( Empty(oMdlFields:GetValue("ABO_CARGO")) .AND. Empty(oMdlFields:GetValue("ABO_FUNCAO")) )
				//����������������������������������������������������������������������������������������������������������������Ŀ
				//�	 Problema: O cargo / fun��o n�o foi informado para os produtos de aloca��o configurados como recurso humano.   �
				//�	 Solucao: Verifique os produtos configurados como recurso humano e defina um cargo ou uma fun��o para o mesmo. �
				//�	          Caso deseja realizar uma aloca��o espec�fica informe os dois campos.  							   �
				//������������������������������������������������������������������������������������������������������������������
				lRetorno := .F.
				Help("",1,"AT340CARGXFUN")
			EndIf
		Else
			If ( Empty(oMdlFields:GetValue("ABO_FUNCAO")) )
				//������������������������������������������������������������������������������������������������������Ŀ
				//�	 Problema: Fun��o n�o foi informada para os produtos de aloca��o configurados como recurso humano.   �
				//�	 Solucao: Verifique os produtos configurados como recurso humano e defina uma fun��o para o mesmo.   �
				//��������������������������������������������������������������������������������������������������������
				lRetorno := .F.
				Help("",1,"AT340FUNCAO")
			EndIf
		EndIf
	ElseIf Empty(oMdlFields:GetValue("ABO_TPREC"))
		//�������������������������������������������������������������������������������Ŀ
		//�	 Problema: O tipo de recurso n�o foi informado para os produtos de aloca��o.  �
		//�	 Solucao: Defina um tipo de recurso para todos os produtos de aloca��o. 	  �
		//���������������������������������������������������������������������������������
		lRetorno := .F.
		Help("",1,"AT340RECURSO")
	EndIf
	
	If lRetorno
		If Empty(oMdlFields:GetValue("ABO_PERINI"))
			//�������������������������������������������������������������������������������Ŀ
			//�	 Problema: O per�odo inicial n�o foi informado para os produtos de aloca��o.  �
			//�	 Solucao: Informe o per�odo inicial para aloca��o destes recursos.  		  �
			//���������������������������������������������������������������������������������
			lRetorno := .F.
			Help("",1,"AT340PINI")
		ElseIf Empty(oMdlFields:GetValue("ABO_PERFIM"))
			//����������������������������������������������������������������������������Ŀ
			//�	 Problema: O per�odo final n�o foi informado para os produtos de aloca��o. �
			//�	 Solucao: Informe o per�odo final para aloca��o destes recursos.           �
			//������������������������������������������������������������������������������
			lRetorno := .F.
			Help("",1,"AT340PFIM")
		ElseIf Empty(oMdlFields:GetValue("ABO_TURNO"))
			//���������������������������������������������������������������������������������Ŀ
			//�	 Problema: O turno de trabalho n�o foi informando para os produtos de aloca��o. �
			//�	 Solucao: Informe o turno de trabalho para estes produtos de aloca��o.          �
			//�����������������������������������������������������������������������������������
			lRetorno := .F.
			Help("",1,"AT340TUR")
		ElseIf oMdlFields:GetValue("ABO_TOTAL") == 0
			//����������������������������������������������������������������������Ŀ
			//�	 Problema: Existem produtos de aloca��o n�o estimados.	             �
			//�	 Solucao: Selecione o produto de aloca��o e clique no bot�o estimar. �
			//������������������������������������������������������������������������
			lRetorno := .F.
			Help("",1,"AT340ESTALL")
		EndIf
		
	EndIf
	
	If !lRetorno
		Exit
	EndIf
	
Next nX

If lRetorno
	//���������������������������������������������������������������Ŀ
	//�	 Retorna a configuracao da alocacao para proposta comercial.  �
	//�����������������������������������������������������������������

	At600RAloc(oMdlGrid,oMdlFields,oGetPrd,oGetAce,oViewPrp)

EndIf

Return( lRetorno )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �At340LdAdy �Autor  �Vendas CRM          � Data � 23/10/12    ���
��������������������������������������������������������������������������͹��
���Desc.     �Faz load do cabecalho da proposta.  		   				   ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpA - Array com o cabecalho da proposta.		               ���
��������������������������������������������������������������������������͹��
���Parametros�ExpO1 - Objeto model fields. 						           ���
���			 �ExpL2 - Formualario de copia?								   ���
��������������������������������������������������������������������������͹��
���Uso       �FATA600							                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function At340LdAdy(oMdlFields,lCopy)

Local aArea		 := GetArea()       					   								// Guarda a area atual.
Local oStruct  	 := oMdlFields:GetStruct()				   								// Retorna a estrutura ADY.
Local aCampos  	 := oStruct:GetFields()													// Retorna os campos da estrutura ADY.
Local aLoadAdy 	 := Array(Len(aCampos))													// Array com as posicoes dos campos da ADY.

aLoadAdy[1]	:= xFilial("ADY")
aLoadAdy[2]	:= M->ADY_PROPOS
aLoadAdy[3]	:= M->ADY_PREVIS

RestArea(aArea)

Return( aLoadAdy )
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �At340LdAdz �Autor  �Vendas CRM          � Data � 23/10/12    ���
��������������������������������������������������������������������������͹��
���Desc.     �Faz load dos produtos de alocacao da proposta comercial.     ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpA - Array com os produtos.		                           ���
��������������������������������������������������������������������������͹��
���Parametros�ExpO1 - Objeto model grid. 						           ���
���			 �ExpL2 - Formualario de copia?								   ���
��������������������������������������������������������������������������͹��       
���Uso       �FATA600							                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function At340LdAdz(oMdlGrid,lCopy)

Local oStruct  := oMdlGrid:GetStruct()												// Retorna a estrutura atual.
Local aCampos  := oStruct:GetFields()												// Retorna os campos da estrutura.
Local aLoadAdz := {} 																// Array com os produtos para ser carregados.
Local nX	   := 0   						   										// Incremento utilizado no For.
Local nI	   := 0							   								   	 	// Incremento utilizado no For.
Local nLinha   := 0                            								   	  	// Linha atual.
Local nPosCpo  := 0																  	// Posicao do campo que sera feito o load.
Local nPosRec  := Len(oGetPrd:aHeader)	   											// Posicao do campo ADZ_REC_WT no aHeader.
Local nPosAlo  := aScan(oGetPrd:aHeader,{|x| AllTrim(x[2]) == "ADZ_PRDALO" })   	// Posicao do campo ADZ_PRDALO

If nPosRec > 0 .AND. nPosAlo > 0
	For nX := 1 To Len(oGetPrd:aCols)
		If !aTail(oGetPrd:aCols[nX])
			If oGetPrd:aCols[nX][nPosAlo] == "1"
				aAdd(aLoadAdz,{oGetPrd:aCols[nX][nPosRec],Array(Len(aCampos))})
				nLinha := Len(aLoadAdz)
				For nI := 1 To Len(aCampos)
					nPosCpo := aScan(oGetPrd:aHeader,{|x| Alltrim(x[2]) == Alltrim(aCampos[nI][3]) })
					If nPosCpo > 0
						aLoadAdz[nLinha][2][nI] := oGetPrd:aCols[nX][nPosCpo]
					EndIf
					Do Case
						Case Alltrim(aCampos[nI][3]) == "ADZ_PROPOS"
							aLoadAdz[nLinha][2][nI]	 := M->ADY_PROPOS
						Case Alltrim(aCampos[nI][3]) == "ADZ_REVISA"
							aLoadAdz[nLinha][2][nI]	 := M->ADY_PREVIS
						Case Alltrim(aCampos[nI][3]) == "ADZ_PASTA"
							aLoadAdz[nLinha][2][nI]	 := "Produto"
						Case Alltrim(aCampos[nI][3]) == "ADZ_FOLDER"
							aLoadAdz[nLinha][2][nI]	 := "1"
						Case Alltrim(aCampos[nI][3]) == "ADZ_LEGEN"
							aLoadAdz[nLinha][2][nI]	 := "BR_BRANCO"
					EndCase
				NexT nI
			EndIf
		EndIf
	Next nX
EndIf

If nPosRec > 0 .AND. nPosAlo > 0
	For nX := 1 To Len(oGetAce:aCols)
		If !aTail(oGetAce:aCols[nX])
			If oGetAce:aCols[nX][nPosAlo] == "1"
				aAdd(aLoadAdz,{oGetAce:aCols[nX][nPosRec],Array(Len(aCampos))})
				nLinha := Len(aLoadAdz)
				For nI := 1 To Len(aCampos)
					nPosCpo := aScan(oGetAce:aHeader,{|x| Alltrim(x[2]) == Alltrim(aCampos[nI][3]) })
					If nPosCpo > 0
						aLoadAdz[nLinha][2][nI] := oGetAce:aCols[nX][nPosCpo]
					EndIf
					Do Case
						Case Alltrim(aCampos[nI][3]) == "ADZ_PROPOS"
							aLoadAdz[nLinha][2][nI]	 := M->ADY_PROPOS
						Case Alltrim(aCampos[nI][3]) == "ADZ_REVISA"
							aLoadAdz[nLinha][2][nI]	 := M->ADY_PREVIS
						Case Alltrim(aCampos[nI][3]) == "ADZ_PASTA"
							aLoadAdz[nLinha][2][nI]	 := "Acessorio"
						Case Alltrim(aCampos[nI][3]) == "ADZ_FOLDER"
							aLoadAdz[nLinha][2][nI]	 := "2"
						Case Alltrim(aCampos[nI][3]) == "ADZ_LEGEN"
							aLoadAdz[nLinha][2][nI]	 := "BR_BRANCO"                           
					EndCase
				NexT nI
			EndIf
		EndIf
	Next nX
EndIf

Return( aLoadAdz )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �At340LdAbo �Autor  �Vendas CRM          � Data � 23/10/12    ���
��������������������������������������������������������������������������͹��
���Desc.     �Faz load da configuracao de alocacao de recursos.   		   ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpA - Array com a configuracao.		                       ���
��������������������������������������������������������������������������͹��
���Parametros�ExpO1 - Objeto model fields. 						           ���
���			 �ExpL2 - Formualario de copia?								   ���
��������������������������������������������������������������������������͹��
���Uso       �FATA600							                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function At340LdAbo(oMdlFields,lCopy)

Local aArea		 := GetArea()       					   								// Guarda a area atual.
Local aAreaABO 	 := ABO->(GetArea())     											 	// Guarda a area ABO.
Local oMdlGrid 	 := oMdlFields:GetOwner()												// Retorna o model do modelo de dados.
Local oStruct  	 := oMdlFields:GetStruct()				   								// Retorna a estrutura ABO.
Local aCampos  	 := oStruct:GetFields()													// Retorna os campos da estrutura ABO.
Local aLoadAbo 	 := Array(Len(aCampos))													// Array com as posicoes dos campos da ABO.
Local nX	   	 := 0  																	// Incremento utilizado no For.
Local nPChave	 := 0 																	// Chave Folder+Item.
Local nPItPro    := 0																	// Posicao do item da proposta comercial.
Local nPFator	 := 0																	// Posicao do fator de multiplicacao.
Local nPItem	 := aScan(oGetPrd:aHeader,{|x|AllTrim(x[2]) == "ADZ_ITEM"})            // Posicao do campo item no aCols da proposta comercial.
Local nPQtdVen	 := aScan(oGetPrd:aHeader,{|x|AllTrim(x[2]) == "ADZ_QTDVEN"})			// Posicao do campo quantidade no aCols da proposta comercial.
Local nPTpProd	 := aScan(oGetPrd:aHeader,{|x|AllTrim(x[2]) == "ADZ_TPPROD"})			// Posicao do campo tipo de produto.
Local lEstManual := .F.																	// Estimativa de horas foi alterada pelo usuario no aCols da proposta?

DbSelectArea("ABO")
DbSetOrder(1)

If Len(aLdCfgAlo) == 0
	
	If DbSeek(	xFilial("ABO")+oMdlGrid:GetValue("ADZ_PROPOS")+oMdlGrid:GetValue("ADZ_REVISA")+;
	   			oMdlGrid:GetValue("ADZ_FOLDER")+oMdlGrid:GetValue("ADZ_ITEM")+oMdlGrid:GetValue("ADZ_PRODUT"))
		For nX := 1 To Len(aLoadAbo)
			If !aCampos[nX][MODEL_FIELD_VIRTUAL]
				If aCampos[nX][MODEL_FIELD_IDFIELD] == "ABO_TPPROD"
					If oMdlGrid:GetValue("ADZ_FOLDER") == "1"
						nPItPro := aScan(oGetPrd:aCols,{|x| x[nPItem] == oMdlGrid:GetValue("ADZ_ITEM")})
						aLoadAbo[nX]	:= oGetPrd:aCols[nPItPro][nPTpProd]
					ElseIf oMdlGrid:GetValue("ADZ_FOLDER") == "2"
						nPItPro := aScan(oGetAce:aCols,{|x| x[nPItem] == oMdlGrid:GetValue("ADZ_ITEM")})
						aLoadAbo[nX]	:= oGetAce:aCols[nPItPro][nPTpProd]
					EndIf
				ElseIf aCampos[nX][MODEL_FIELD_IDFIELD] == "ABO_FATOR"
					If &("ABO->"+Alltrim(aCampos[nX][3])) == 0
						aLoadAbo[nX]	:= 0
						lEstManual		:= .T.
					Else
						aLoadAbo[nX] := &("ABO->"+Alltrim(aCampos[nX][3]))
					EndIf
				ElseIf aCampos[nX][MODEL_FIELD_IDFIELD] == "ABO_TOTAL"
					If oMdlGrid:GetValue("ADZ_FOLDER") == "1"
						nPItPro := aScan(oGetPrd:aCols,{|x| x[nPItem] == oMdlGrid:GetValue("ADZ_ITEM")})
						If &("ABO->"+Alltrim(aCampos[nX][3])) <> oGetPrd:aCols[nPItPro][nPQtdVen]
							nPFator := aScan(aCampos,{|x| x[MODEL_FIELD_IDFIELD] == "ABO_FATOR" })
							aLoadAbo[nPFator]	:= 0
							aLoadAbo[nX] 		:= oGetPrd:aCols[nPItPro][nPQtdVen]
							lEstManual 			:= .T.
						Else
							aLoadAbo[nX] := &("ABO->"+Alltrim(aCampos[nX][3]))
						EndIf
					ElseIf oMdlGrid:GetValue("ADZ_FOLDER") == "2"
						nPItPro := aScan(oGetAce:aCols,{|x| x[nPItem] == oMdlGrid:GetValue("ADZ_ITEM")})
						If &("ABO->"+Alltrim(aCampos[nX][3])) <> oGetAce:aCols[nPItPro][nPQtdVen]
							nPFator := aScan(aCampos,{|x| x[MODEL_FIELD_IDFIELD] == "ABO_FATOR" })
							aLoadAbo[nPFator]	:= 0
							aLoadAbo[nX]		:= oGetAce:aCols[nPItPro][nPQtdVen]
							lEstManual 			:= .T.
						Else
							aLoadAbo[nX] := &("ABO->"+Alltrim(aCampos[nX][3]))
						EndIf
					EndIf
				Else
					aLoadAbo[nX]	:= &("ABO->"+Alltrim(aCampos[nX][3]))
				EndIf
			EndIf
		Next nX
		
		If lEstManual
			oMdlGrid:SetValue("ADZ_LEGEN","BR_AMARELO")
		Else
			oMdlGrid:SetValue("ADZ_LEGEN","BR_VERDE")
		EndIf
		
	Else
		//������������������������������������Ŀ
		//� Monta o relacionamento como o pai. �
		//��������������������������������������
		aLoadAbo[1] := xFilial("ABO")
		aLoadAbo[2]	:= M->ADY_PROPOS
		aLoadAbo[3]	:= M->ADY_PREVIS
		aLoadAbo[4]	:= oMdlGrid:GetValue("ADZ_FOLDER")
		aLoadAbo[5]	:= oMdlGrid:GetValue("ADZ_ITEM")
		aLoadAbo[6]	:= oMdlGrid:GetValue("ADZ_PRODUT")
		aLoadAbo[7]	:= oMdlGrid:GetValue("ADZ_TPPROD")
	EndIf
Else
	nPChave := aScan(aLdCfgAlo,{|x| x[1] == oMdlGrid:GetValue("ADZ_FOLDER")+oMdlGrid:GetValue("ADZ_ITEM")+oMdlGrid:GetValue("ADZ_PRODUT") })
	If nPChave > 0
		For nX := 1 To Len(aLoadAbo)
			If ( !Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]) $ "ABO_TPPROD|ABO_FATOR|ABO_TOTAL" )
				aLoadAbo[nX] := aLdCfgAlo[nPChave][2][nX]
			ElseIf Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]) == "ABO_TPPROD"
				If oMdlGrid:GetValue("ADZ_FOLDER") == "1"
					nPItPro := aScan(oGetPrd:aCols,{|x| x[nPItem] == oMdlGrid:GetValue("ADZ_ITEM")})
					aLoadAbo[nX]	:= oGetPrd:aCols[nPItPro][nPTpProd]
				ElseIf oMdlGrid:GetValue("ADZ_FOLDER") == "2"
					nPItPro := aScan(oGetAce:aCols,{|x| x[nPItem] == oMdlGrid:GetValue("ADZ_ITEM")})
					aLoadAbo[nX]	:= oGetAce:aCols[nPItPro][nPTpProd]
				EndIf
			ElseIf Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]) == "ABO_FATOR"
				If aLdCfgAlo[nPChave][2][nX] == 0
					lEstManual := .T.
				Else
					aLoadAbo[nX] := aLdCfgAlo[nPChave][2][nX]
				EndIf
			ElseIf Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]) == "ABO_TOTAL"
				If oMdlGrid:GetValue("ADZ_FOLDER") == "1"
					nPItPro := aScan(oGetPrd:aCols,{|x| x[nPItem] == oMdlGrid:GetValue("ADZ_ITEM")})
					If aLdCfgAlo[nPChave][2][nX] <> oGetPrd:aCols[nPItPro][nPQtdVen]
						nPFator := aScan(aCampos,{|x| x[MODEL_FIELD_IDFIELD] == "ABO_FATOR" })
						aLoadAbo[nPFator]	:= 0
						aLoadAbo[nX] 	  	:= oGetPrd:aCols[nPItPro][nPQtdVen]
						lEstManual        	:= .T.
					Else
						aLoadAbo[nX] := aLdCfgAlo[nPChave][2][nX]
					EndIf
				ElseIf oMdlGrid:GetValue("ADZ_FOLDER") == "2"
					nPItPro := aScan(oGetAce:aCols,{|x| x[nPItem] == oMdlGrid:GetValue("ADZ_ITEM")})
					If aLdCfgAlo[nPChave][2][nX] <> oGetAce:aCols[nPItPro][nPQtdVen]
						nPFator := aScan(aCampos,{|x| x[MODEL_FIELD_IDFIELD] == "ABO_FATOR"})
						aLoadAbo[nPFator]	:= 0
						aLoadAbo[nX] 		:= oGetAce:aCols[nPItPro][nPQtdVen]
						lEstManual			:= .T.
					Else
						aLoadAbo[nX] := aLdCfgAlo[nPChave][2][nX]
					EndIf
				EndIf
			EndIf
		Next nX
		
		If lEstManual
			oMdlGrid:SetValue("ADZ_LEGEN","BR_AMARELO")
		Else
			oMdlGrid:SetValue("ADZ_LEGEN","BR_VERDE")
		EndIf
		
	Else
		//������������������������������������Ŀ
		//� Monta o relacionamento como o pai. �
		//��������������������������������������
		aLoadAbo[1] := xFilial("ABO")
		aLoadAbo[2]	:= M->ADY_PROPOS
		aLoadAbo[3]	:= M->ADY_PREVIS
		aLoadAbo[4]	:= oMdlGrid:GetValue("ADZ_FOLDER")
		aLoadAbo[5]	:= oMdlGrid:GetValue("ADZ_ITEM")
		aLoadAbo[6]	:= oMdlGrid:GetValue("ADZ_PRODUT")
		aLoadAbo[7]	:= oMdlGrid:GetValue("ADZ_TPPROD")
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaABO)

Return( aLoadAbo )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �At340BtAct �Autor  �Vendas CRM          � Data � 23/10/12    ���
��������������������������������������������������������������������������͹��
���Desc.     �Botoes da interface configurador de alocacao de recursos.    ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro.		  			                       ���
��������������������������������������������������������������������������͹��
���Parametros�ExpO1 - Objeto Panel. 						    	       ���
��������������������������������������������������������������������������͹��
���Uso       �FATA600							                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function At340BtAct(oPanel)

Local oModel  := FwModelActive()    					// Modelo de dados ativo.
Local oView	  := FwViewActive()							// Interface ativa.
Local nHeight := (((oPanel:nHeight/2)*(1/3))+10)		// Altura dos botoes na interface.
Local nWidth  := ((oPanel:nWidth/2)*0.12)				// Largura dos botoes na interface.

@ (nHeight)    ,(nWidth)  Button STR0014 Size 50, 10 Message STR0015 Pixel Action At340VdEst(oModel,oView) Of oPanel  // "Estimar"#"Estima o total de horas para aloca��o deste recurso."
@ (nHeight+20) ,(nWidth)  Button STR0016 Size 50, 10 Message STR0017 Pixel Action At340Clear(oModel,oView) Of oPanel  // "Limpar"#"Limpar a configura��o da aloca��o deste recurso."

Return( .T. )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �At340VdEst �Autor  �Vendas CRM          � Data � 23/10/12     ���
���������������������������������������������������������������������������͹��
���Desc.     �Validada a configuracao dos recursos e estima o total de  	���
���			 �horas para aloca��o. 		   									���
���������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro / Falso.		             	            ���
���������������������������������������������������������������������������͹��
���Parametros�ExpO1 - Modelo de Dados Principal. 						   	���
���			 �ExpO2 - Interface. 						  			     	���  
���			 �ExpL3 - Estimativa Manual. 						  			���
���������������������������������������������������������������������������͹��
���Uso       �FATA600							                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function At340VdEst(oModel,oView,lEstManual)

Local oMdlGrid		:= oModel:GetModel("ADZDETAIL")				// Modelo de dados itens da proposta comercial.
Local oMdlFields	:= oModel:GetModel("ABOFIELDS")				// Modelo de dados configurador de alocacao de recursos.
Local lRetorno		:= .T.										// Retorno da validacao.
Local lTecXRh		:= SuperGetMv("MV_TECXRH",,.F.)	   		// Integracao Gestao de Servicos com RH?.

Default lEstManual	:= .F.     								    // Utiliza as validacoes da estimativa automatica.
Default oView		:= Nil 										// Interface.

If oMdlFields:GetValue("ABO_TPREC") == "1"
	If lTecXRh
		If ( Empty(oMdlFields:GetValue("ABO_CARGO")) .AND. Empty(oMdlFields:GetValue("ABO_FUNCAO")) )
			//��������������������������������������������������������������������������������Ŀ
			//�	 Problema: O cargo / fun��o n�o foi informado. 								   �
			//�	 Solucao: Informe um cargo ou uma fun��o para aloca��o deste recurso. 		   �
			//�	       	  Caso deseja realizar uma aloca��o espec�fica informe os dois campos. �
			//����������������������������������������������������������������������������������
			lRetorno := .F.
			Help("",1,"AT340CARXFUN")
		EndIf
	Else
		If ( Empty(oMdlFields:GetValue("ABO_FUNCAO")) )
			//�����������������������������������������������������������Ŀ
			//�	 Problema: Fun��o n�o foi informada. 				      �
			//�	 Solucao: Informe uma fun��o para aloca��o deste recurso. �
			//�������������������������������������������������������������
			lRetorno := .F.
			Help("",1,"AT340FUNC")
		EndIf
	EndIf
ElseIf Empty(oMdlFields:GetValue("ABO_TPREC"))
	
	//�������������������������������������������������������������������Ŀ
	//�	 Problema: O tipo de recurso n�o foi informado.     			  �
	//�	 Solucao: Informe um tipo de recurso para aloca��o deste produto. �
	//���������������������������������������������������������������������
	lRetorno := .F.
	Help("",1,"AT340TPREC")
EndIf

If lRetorno
	
	If Empty(oMdlFields:GetValue("ABO_PERINI"))
		
		//�������������������������������������������������������������������Ŀ
		//�	 Problema: O per�odo inicial n�o foi informado. 				  �
		//�	 Solucao: Informe o per�odo inicial para aloca��o deste recurso.  �
		//���������������������������������������������������������������������
		lRetorno := .F.
		Help("",1,"AT340PERINI")
		
	ElseIf Empty(oMdlFields:GetValue("ABO_PERFIM"))
		
		//����������������������������������������������������������������Ŀ
		//�	 Problema: O per�odo final n�o foi informado. 				   �
		//�	 Solucao: Informe o per�odo final para aloca��o deste recurso. �
		//������������������������������������������������������������������
		lRetorno := .F.
		Help("",1,"AT340PERFIM")
		
	ElseIf Empty(oMdlFields:GetValue("ABO_TURNO"))
		
		//���������������������������������������������������������������������Ŀ
		//�	 Problema: O turno de trabalho n�o foi informando. 				    �
		//�	 Solucao: Informe o turno de trabalho para aloca��o deste recurso.  �
		//�����������������������������������������������������������������������
		lRetorno := .F.
		Help("",1,"AT340TURNO")
	EndIf
	
EndIf

If ( lRetorno .AND. !lEstManual )
	MsgRun(STR0018,STR0019,{ || At340ETHrs(oMdlGrid,oMdlFields,oView) } )	// "Estimando total de horas para aloca��o deste recurso..."#"Aguarde"
EndIf

Return( lRetorno )


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �At340ETHrs �Autor  �Vendas CRM          � Data � 23/10/12     ���
���������������������������������������������������������������������������͹��
���Desc.     �Estima o total de horas para aloca��o. 		   			    ���
���������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro / Falso            	          			    ���
���������������������������������������������������������������������������͹��
���Parametros�ExpO1 - Modelo de Dados Itens da Proposta. 				    ���
���			 �ExpO2 - Modelo de Dados Conf. de Alocacao de Recurso. 		���
���			 �ExpO3 - Interce Principal.	    						    ���
���������������������������������������������������������������������������͹��
���Uso       �FATA600							                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function At340ETHrs(oMdlGrid,oMdlFields,oView)

Local lRetorno 		:= .T.									// Retorno do CriaCalend.
Local dDataIni		:= oMdlFields:GetValue("ABO_PERINI")   	// Periodo Inicial.
Local dDataFim  	:= oMdlFields:GetValue("ABO_PERFIM")	// Periodo Final.
Local cTurno		:= oMdlFields:GetValue("ABO_TURNO")		// Turno de Trabalho.
Local nFator 		:= oMdlFields:GetValue("ABO_FATOR")	 	// Fator de Multiplicacao.
Local aTabPadrao	:= {}  									// Tabela de horario padrao.
Local aTabCalend	:= {}									// Tabela do calendario do RH.
Local aExcePer		:= {}								    // Array com as excecoes por periodo.
Local nTotHrsEst	:= 0  									// Total de horas estimada para alocar um recurso.
Local nX			:= 0 									// Incremento utilizado no laco For.
Local nTotal		:= 0									// Total de horas estimada pelo usuario.

lRetorno := CriaCalend(dDataIni,dDataFim,cTurno,"01",@aTabPadrao,@aTabCalend,xFilial("SR6"),,,,aExcePer)

If lRetorno
	For nX := 1 To Len(aTabCalend)
		If aTabCalend[nX][6] == "S"
			If Substr(aTabCalend[nX][4],2,1) == "E"
				nTotHrsEst += TxAjtHoras(aTabCalend[nX][7])
			ElseIf Substr(aTabCalend[nX][4],2,1) == "S"  
				nTotHrsEst += TxAjtHoras(aTabCalend[nX][9])	
			EndIf
		EndIf	
	Next nX
	
	If nTotHrsEst > 0
		oMdlFields:SetValue("ABO_HRSEST",nTotHrsEst)
		If nFator == 0
			oMdlFields:SetValue("ABO_FATOR",1)
			oMdlFields:LoadValue("ABO_TOTAL",nTotHrsEst)
			oMdlGrid:SetValue("ADZ_LEGEN","BR_VERDE")
		Else
			nTotal := (nFator * nTotHrsEst)
			oMdlFields:LoadValue("ABO_TOTAL",nTotal)
			oMdlGrid:SetValue("ADZ_LEGEN","BR_VERDE")
		EndIf
		oView:Refresh()
	EndIf	
	
EndIf

Return( lRetorno )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �At340Clear �Autor  �Vendas CRM          � Data � 23/10/12     ���
���������������������������������������������������������������������������͹��
���Desc.     �Limpa a configuracao da alocacao de recursos.		   	 	    ���
���������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro		             	          			    ���
���������������������������������������������������������������������������͹��
���Parametros�ExpO1 - Modelo de Dados Itens da Proposta. 				    ���
���Parametros�ExpO2 - Modeo de Dados Conf. de Alocacao de Recurso. 		    ���
���������������������������������������������������������������������������͹��
���Uso       �FATA600							                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function At340Clear(oModel,oView)

Local oMdlGrid		:= oModel:GetModel("ADZDETAIL")   	// Modelo de dados itens da proposta comercial.
Local oMdlFields	:= oModel:GetModel("ABOFIELDS")		// Modelo de dados configurador de alocacao de recursos.
Local oStruct  		:= oMdlFields:GetStruct()			// Retorna a estrutura atual.
Local aCampos  		:= oStruct:GetFields()				// Retorna os campos da estrutura.
Local nX 			:= 0      							// Incremento utilizado no laco For.

For nX := 1 To Len(aCampos)
	If !Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]) $ "|ABO_FILIAL|ABO_PROPOS|ABO_REVPRO|ABO_FOLPRO|ABO_ITPRO|ABO_PRODUT|ABO_TPREC"
		Do Case
			Case aCampos[nX][MODEL_FIELD_TIPO] $ "C|M"
				oMdlFields:LoadValue(Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]),"")
			Case aCampos[nX][MODEL_FIELD_TIPO] == "N"
				oMdlFields:LoadValue(Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]),0)
			Case aCampos[nX][MODEL_FIELD_TIPO] == "D"
				oMdlFields:LoadValue(Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]),cTod("//"))
			Case aCampos[nX][MODEL_FIELD_TIPO] == "L"
				oMdlFields:LoadValue(Alltrim(aCampos[nX][MODEL_FIELD_IDFIELD]),.F.)
		EndCase
	EndIf
Next nX

oMdlGrid:SetValue("ADZ_LEGEN","BR_BRANCO")
oView:Refresh()

Return( .T. )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �At340VdPer �Autor  �Vendas CRM          � Data � 23/10/12     ���
���������������������������������������������������������������������������͹��
���Desc.     �Valida o periodo da alocacao de recursos.			   	 	    ���
���������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro / Falso		             	          	    ���
���������������������������������������������������������������������������͹��
���Parametros�Nenhum													    ���
���������������������������������������������������������������������������͹��
���Uso       �FATA600							                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function At340VdPer()

Local dPerIni	 := FwFldGet("ABO_PERINI")			// Data inicial.
Local dPerFim	 := FwFldGet("ABO_PERFIM") 			// Data final.
Local lRetorno	 := .T.								// Retorno da validacao.

If !Empty(dPerIni) .AND. !Empty(dPerFim)
	If dPerIni > dPerFim
		//�������������������������������������������������������Ŀ
		//�	 Problema: Per�odo de aloca��o inv�lido.    		  �
		//�	 Solucao: Verifique o per�odo de aloca��o do recurso. �
		//���������������������������������������������������������
		lRetorno := .F.
		Help("",1,"AT340PER")
	EndIf
EndIf

Return( lRetorno )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �At340Fator �Autor  �Vendas CRM          � Data � 23/10/12     ���
���������������������������������������������������������������������������͹��
���Desc.     �Multiplica fator definido pelo usuario pelo total de horas    ���
���			 �estimada.														���
���������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro / Falso		             	          	    ���
���������������������������������������������������������������������������͹��
���Parametros�Nenhum													    ���
���������������������������������������������������������������������������͹��
���Uso       �FATA600							                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function At340Fator()

Local aArea			:= GetArea()                						// Guarda area atual.
Local oModel		:= FwModelActive()	 								// Retorna o model ativo
Local oMdlGrid		:= oModel:GetModel("ADZDETAIL")						// Modelo de dados itens da proposta comercial.
Local oMdlFields	:= oModel:GetModel("ABOFIELDS")						// Modelo de dados configuracao da alocacao.
Local nFator 		:= oMdlFields:GetValue("ABO_FATOR")					// Periodo Inicial
Local nTotHrsEst	:= oMdlFields:GetValue("ABO_HRSEST")				// Total de horas estimada para alocar um recurso.
Local lRetorno		:= Positivo()  										// Validacao positivo.
Local nTotal		:= 0 												// Total de horas estimado pelo usuario com base nas horas estimada para um recurso.

If lRetorno
	
	If nTotHrsEst > 0
		If nFator > 0
			nTotal := (nFator * nTotHrsEst)
			oMdlFields:LoadValue("ABO_TOTAL",nTotal)
			oMdlGrid:SetValue("ADZ_LEGEN","BR_VERDE")
		Else
			oMdlFields:LoadValue("ABO_TOTAL",0)
			oMdlGrid:SetValue("ADZ_LEGEN","BR_BRANCO")
		EndIf
	Else
		//������������������������������������������������������������������Ŀ
		//�	 Problema: O total de horas n�o foi estimada para este recurso.	 �
		//�	 Solucao: Clique no bot�o estimar.                               �
		//��������������������������������������������������������������������
		lRetorno := .F.
		Help("",1,"AT340EST")
	EndIf
	
EndIf

RestArea(aArea)

Return( lRetorno )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �At340Total �Autor  �Vendas CRM          � Data � 23/10/12     ���
���������������������������������������������������������������������������͹��
���Desc.     �Valida o total de horas digitada manualmente pelo usuario.    ���
���������������������������������������������������������������������������͹��
���Retorno   �ExpL - Verdadeiro / Falso		             	          	    ���
���������������������������������������������������������������������������͹��
���Parametros�Nenhum													    ���
���������������������������������������������������������������������������͹��
���Uso       �FATA600							                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function At340Total()

Local aArea			:= GetArea()                						// Guarda area atual.
Local oModel		:= FwModelActive()	 								// Retorna o model ativo
Local oMdlGrid		:= oModel:GetModel("ADZDETAIL")						// Modelo de dados itens da proposta comercial.
Local oMdlFields	:= oModel:GetModel("ABOFIELDS")						// Modelo de dados configuracao da alocacao.
Local lRetorno		:= Positivo()  										// Validacao positivo.

If lRetorno .AND. At340VdEst(oModel,Nil,.T.)
	oMdlFields:LoadValue("ABO_FATOR",0)
	oMdlGrid:SetValue("ADZ_LEGEN","BR_AMARELO")
Else
	lRetorno := .F.
EndIf

RestArea(aArea)

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} At340Commit
Evita a realiza��o do Commit

@author douglas.bichir
@since 25/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function At340Commit(oModel)

Local lRetorno 	:= .T.

Return( lRetorno )