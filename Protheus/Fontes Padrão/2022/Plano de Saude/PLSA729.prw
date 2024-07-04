#INCLUDE "PLSA729.ch"
#INCLUDE "PROTHEUS.CH"
#Include "RWMAKE.CH" 
#Include "TOPCONN.CH"   
#Include "MSOLE.CH"    

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA729   �Autor  �Microsiga           � Data �  11/03/2015���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de contratos padr�o							       ���
���          � 							                                   ���
�������������������������������������������������������������������������͹��
���Uso       � SEGMENTO SAUDE VERSAO 12                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PLSA729()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B2L' )
oBrowse:SetDescription(STR0001) //'Defini��o do documento'
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { STR0002,'PesqBrw'         , 0, 1, 0, .T. } )//'Pesquisar'
aAdd( aRotina, { STR0003,'VIEWDEF.PLSA729', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0004,'VIEWDEF.PLSA729', 0, 3, 0, NIL } ) //'Incluir'
aAdd( aRotina, { STR0005,'VIEWDEF.PLSA729', 0, 4, 0, NIL } ) //'Alterar'
aAdd( aRotina, { STR0006,'VIEWDEF.PLSA729', 0, 5, 0, NIL } ) //'Excluir'
aAdd( aRotina, { STR0007,'VIEWDEF.PLSA729', 0, 8, 0, NIL } ) //'Imprimir'
aAdd( aRotina, { STR0008,'VIEWDEF.PLSA729', 0, 9, 0, NIL } ) //'Copiar'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

Local oStruB2L := FWFormStruct( 1, 'B2L', , )//Master
Local oStruB1X := FWFormStruct( 1, 'B1X', , )//Detail

Private oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA729MD', /*bPreValidacao*/,{|oModel| PL729ValCampo(oModel) } /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )  

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'B2LMASTER', NIL, oStruB2L )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'B1XDETAIL', 'B2LMASTER', oStruB1X, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


oModel:SetPrimaryKey({"B2L_FILIAL","B2L_COD","B2L_REV"})


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B1XDETAIL', { { 'B1X_FILIAL', 'xFilial("B1X")' } ,;
	                                { 'B1X_CDB1V', 'B2L_COD' } } ,  "B1X_FILIAL+B1X_CDB1V+B1X_SEQ" )

// Indica que � opcional ter dados informados na Grid
oModel:GetModel( 'B1XDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B2LMASTER' ):SetDescription(STR0009) //'Defini��o do documento'

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0009) //'Defini��o do documento'

//Valida se existem codigos duplicados no aCols
oModel:GetModel('B1XDETAIL'):SetUniqueLine({'B1X_SEQ'})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStruB1X := FWFormStruct( 2, 'B1X' )
Local oStruB2L := FWFormStruct( 2, 'B2L' )
Local oModel   := FWLoadModel( 'PLSA729' )
Local oView    := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B2L' , oStruB2L, 'B2LMASTER'   )     

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B1X' , oStruB1X, 'B1XDETAIL'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRID', 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B2L' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_B1X' , 'GRID'  )

oView:EnableTitleView( 'VIEW_B1X' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_B1X', 'B1X_SEQ' )   

Return oView  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PL729GeraDoc �Autor  � TOTVS          � Data �  12/03/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para carregar o contrato						       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Plano de Saude                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL729GeraDoc(cRDA,cDoc,cRev)
Local hWord		:= 0
Local cPath      := ""
Local cCampo     := ""
Local cDado      := ""
Local cArqDot		:= "" //Nome do contrato.dot
Local cPathDot	:= PLSMUDSIS(AllTrim((GetNewPar("MV_DIRACA","\DOT\")))) //PATH DO ARQUIVO MODELO WORD
Local cPathEst	:= Alltrim(GetMv("MV_DIREST")) // Path do arquivo a ser armazenado na estacao de trabalho
Local cTabela 	:= ""
Local cIndice 	:= ""
Local cChave  	:= ""
Local cMacro     := ""
Local cRef       := ""
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local nCont      := 0
Local nColunas   := 0
Local aColuna    := {}
Local aDado      := {}
Local aResult    := {}
Local lAvanca    := .T.
Local cChave2		:= ""
Local cChv			:= ""

Default cRDA     := ""
Default cDoc     := ""
Default cRev     := ""

Private hWord

//Posicionando na RDA que sera impresso o contrato
DbSelectArea("BAU")
dBSetOrder(1)
If BAU->(MSSEEK(xFilial("BAU")+cRDA))

	//Enquanto nao � criado a nova tabela que ira associar a RDA aos codigos de contrato, sera chumbado o contrato para teste
	//*Contrato
	DbSelectArea("B2L")
	dBSetOrder(1)
	If B2L->(MSSEEK(xFilial("B2L")+cDoc+cRev))
	
		cArqDot  := alltrim(B2L->B2L_PATH)//"doc_modelo.dot"//
		cPathDot := cPathDot + cArqDot//"C:\TEMP\doc_modelo.dot"//
		
		//�����������������������������������������������������������������������Ŀ
		//� Caso exista link de comunicacao com o Word, este deve ser fechado     �
		//�������������������������������������������������������������������������
		If ValType( hWord ) <> "U"
			If hWord == 0
				OLE_CloseFile( hWord )
				OLE_CloseLink( hWord )
			EndIf
		Endif
		
		//�����������������������������������������������������������������������Ŀ
		//� Criando link de comunicacao com o word                                �
		//�������������������������������������������������������������������������
		hWord := OLE_CreateLink()
		
		If ! File(cPathDot) // Verifica a existencia do DOT no ROOTPATH Protheus / Servidor
			MsgBox(STR0010)//"Atencao...contrato n�o encontrado no Servidor"
		ElseIf hWord == "-1"
			MsgBox(STR0011)//"Imposs�vel estabelecer comunica��o com o Microsoft Word."
		Else	
			// Caso encontre arquivo ja gerado na estacao
			//com o mesmo nome apaga primeiramente antes de gerar a nova impressao
			If File( cPathEst + cArqDot )
				Ferase( cPathEst + cArqDot )
			EndIf
	
			CpyS2T(cPathDot,cPathEst,.T.) // Copia do Server para o Remote, eh necessario

			//�����������������������������������������������������������������������Ŀ
			//� Gerando novo documento do Word na estacao                             �
			//�������������������������������������������������������������������������
			OLE_NewFile( hWord, cPathEst + cArqDot)
	
			//**Detalhes do contrato
			DbSelectArea("B1X")
			dBSetOrder(1)
			If B1X->(MSSEEK(xFilial("B1X")+cDoc))
				While !B1X->(EOF()) .And. xFilial("B1X")+B1X->B1X_CDB1V == xFilial("B2L")+B2L->B2L_COD
				
					If B1X->B1X_ATIVO == "1"
						If !Empty(B1X->B1X_TABELA) .And. (B1X->B1X_TABELA <> "BAU") //So ira atualizar se n�o estiver vazio,para evitar que uma Macro com tabela vazio desposicione o registro
							cTabela := alltrim(B1X->B1X_TABELA)
							cIndice := alltrim(B1X->B1X_INDICE)
							cChave  := alltrim(B1X->B1X_CHAVE)
							cMacro  := alltrim(B1X->B1X_MACRO)
							cRef    := cChave
							cChave  := &(cChave)
							cChave2 := AllTrim(B1X->B1X_COMPAR)
							 
						Endif
						
						If B1X->B1X_LOOP == "2"//N�o
						 	If Empty(B1X->B1X_TABELA) .Or. (B1X->B1X_TABELA == "BAU")
						   		cCampo:= ALLTRIM(B1X->B1X_VARIA)
						   		cDado := &(B1X->B1X_CAMPO)
						   		If valtype(cDado)== "N"
						   			cDado := str(cDado)
						   		Endif
						   		OLE_SetDocumentVar( hWord,cCampo,cDado)
						   		lAvanca := .T.
						   	Else
						   		DbSelectArea(cTabela)
								dBSetOrder(val(cIndice))
								If (MSSEEK(cChave))
									cCampo:= ALLTRIM(B1X->B1X_VARIA)
						   			cDado := &(B1X->B1X_CAMPO)
						   			cMacro:= ALLTRIM(B1X->B1X_MACRO)
						   			lAvanca := .T.						   		
								Endif
						   	Endif
							
							//�����������������������������������������������������������������������Ŀ
							//� Atualizando variaveis do documento                                    �
							//�������������������������������������������������������������������������
						   //Importante: A execu��o da fun��o OLE_UpdateFields n�o pode ser ap�s o OLE_ExecuteMacro 
						   //para evitar o desposicionamento da carga dos itens da(s) primeira(s) Macro que j� foram executadas.	
						   	OLE_UpdateFields( hWord )
						   		
						Else							
							
							If !Empty(cTabela)//1� Passo)Idenficacao que se trata de uma nova tabela

									//2� Passo)Cria��o da estruta de colunas e dados do .dot com as colunas e os valores que foram solicitados:
				  					B1X->( dbSkip() )//avan�o para o pr�ximo registro
				  						  							
				  					While !B1X->(EOF()) .And. xFilial("B1X")+B1X->B1X_CDB1V == xFilial("B2L")+B2L->B2L_COD					
										If B1X->B1X_ATIVO == "1" .And. B1X->B1X_LOOP == "1" 
											If Empty(B1X->B1X_TABELA)//necessario para identificar que deve parar porque mudou a tabela 
				  								aAdd(aColuna,{alltrim(B1X->B1X_VARIA),alltrim(B1X->B1X_CAMPO)})
				  								B1X->( dbSkip() )//avan�o para o pr�ximo registro
				  							Else
				  								lAvanca := .F.
				  								Exit //Proxima tabela, logo deve sair mas n�o desposicionar a B1X
				  							Endif	 					   												  					
				  						Else
				  							lAvanca := .F.
				  							Exit // Sai mas n�o desposicionar a B1X					  							
				  						Endif	
			                     EndDo
			                     
				  					//3� Passo)Alimentando o array aDados:
				  					DbSelectArea(cTabela)
									&(cTabela)->(dBSetOrder(val(cIndice)))

									If &(cTabela)->(dbSeek(cChave))

	                    				nCont 	 := 1 
	                    				cChv	 := cChave2
										cChave2 := AllTrim(&(cChave2))

				  						While !&(cTabela)->(EOF()) .And. cChave == cChave2
									
				  							aAdd(aResult,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})//No maximo 30 colunas
				  												  							
				  							For nX:= 1 to len(aColuna)
				  	                        	cDado := &(aColuna[nX][2])
				  								aResult[nCont][nX]:= cDado
						   					Next nX
						   					
						   					cChave2 := AllTrim(&(cChv))//&(cRef)
						   					&(cTabela)->(dbSkip())
						   					nCont++ 
			                     	EndDo
				  						
				  					Endif
				  					&(cTabela)->(dbCloseArea())
				  					
								   	//4� Passo)Campo importante para definir quantos registros a Macro ir� executar
									OLE_SetDocumentVar( hWord,"item",len(aResult))
									
									nColunas := len(aColuna)	
									//5� Passo)Atualizando as variaveis do word que s�o criadas dinamicamente ou seja n�o podem estr visiveis no .dot
							 		For nX := 1 to len(aResult)//Total de registros
										For nZ := 1 to nColunas
											If nZ <= 30
												OLE_SetDocumentVar( hWord,"dado"+AllTrim(Str(nZ))/*+"_"*/+AllTrim(Str(nX)),aResult[nX][nZ])                
											else
												Exit
											EndIf
										Next nz																																																																		
									Next nX 

									//6� Passo)Execu��o da Macro que ir� imprimir as variaveis que foram criadas dinamicamente
									//Importante: A macro que foi criada deve possui a quantidade correta de colunas que foi informada. 
									OLE_ExecuteMacro( hWord, cMacro )
									aResult    := {}//Importante para n�o carregar registros vazios 
								Endif
						  Endif 
					Endif 
					
					If lAvanca
						B1X->( dbSkip() )
					Endif	
	
				EndDo
		  Endif		
		Endif					
   Endif
Endif

OLE_CloseLink( hWord, .F. )
									   
Return ()


//-------------------------------------------------------------------
//Valida se os cmapos informados existe
Function PL729ValCampo(oMdul)
Local oModel 		:= FwLoadModel("PLSA729")
Local nOpc 			:= oModel:GetOperation()
Local lRet    		:= .T. 
Local oModelB1X 	:= oModel:GetModel('B1XDETAIL')
Local aEntidades  	:= {} 
Local nX         	:= 0
Local nY         	:= 0
Local aArea     	:= GetArea()
Local cMask     	:= "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cTCBuild  	:= "TCGetBuild"
Local cFile     	:= ""
Local oDlg      	:= NIL
Local oFont     	:= NIL
Local oMemo     	:= NIL
Local oMdl		  	:= Nil	
Local cTexto  		:= ""
Local cTabela 		:= ""
Local cCampo 		:= ""
Local cIndice 		:= ""

//1� - Verifica��o -> Checo se o campo B2L_PATH est� preenchido quando Contrato ou aditivo.
oMdl := oMdul:GetModel( 'B2LMASTER' )
If ( (oMdl:GetValue('B2L_TIPO') $ '1,2') .AND. Empty(oMdl:GetValue('B2L_PATH')) )
	Help( ,, 'Aten��o',, 'Para contratos e aditivos, adicionar o nome do documento. DOT', 1, 0 )
	Return lRet := .F.
EndIf

//2� Verifico os campos
aAdd(aEntidades,{oModelB1X,"B1X_TABELA","B1X_CAMPO","B1X_INDICE"})
	
For nX := 1 To Len(aEntidades)
	For nY := 1 To aEntidades[nX][1]:Length()
		aEntidades[nX][1]:GoLine(nY)
	
		If aEntidades[1][1]:IsDeleted(nY) == .F. //N�o valida linhas deletadas 
			
			If Empty(aEntidades[nX][1]:GetValue(aEntidades[nX][2]))
				If Empty(cTabela)
					cTabela := "BAU"
					cIndice := "1"
				Endif	
			Else
				cTabela  := aEntidades[nX][1]:GetValue(aEntidades[nX][2])
				cIndice := aEntidades[nX][1]:GetValue(aEntidades[nX][4])		
			Endif	
			
			If len(alltrim(cTabela)) == 3 .Or. Empty(alltrim(cTabela)) 
				If !Empty(aEntidades[nX][1]:GetValue(aEntidades[nX][3])) .And. at("POSICIONE",aEntidades[nX][1]:GetValue(aEntidades[nX][3])) == 0 
				 	
				 	DbSelectArea(cTabela)
					dBSetOrder(val(cIndice))	
					cCampo := SUBSTR(alltrim(aEntidades[nX][1]:GetValue(aEntidades[nX][3])),6)
							 
					If !Empty(cCampo)
						cCampo := alltrim(cTabela)+'->(FieldPos("'+cCampo+'"))'
						If &cCampo == 0 
							cTexto += alltrim(aEntidades[nX][1]:GetValue(aEntidades[nX][3])) + CRLF
							lRet := .F.
						Endif
					Else
						cTexto += alltrim(aEntidades[nX][1]:GetValue(aEntidades[nX][3])) + CRLF
						lRet := .F.
					Endif	
					 				
				Endif
			Else
				cTexto += alltrim(aEntidades[nX][1]:GetValue(aEntidades[nX][2])) + CRLF
				lRet := .F.				
			Endif	
		Endif	                  
	 		
	Next nY	
Next nX

If !Empty(cTexto)

	Define Font oFont Name "Mono AS" Size 5, 12
	
	Define MsDialog oDlg Title STR0012 From 3, 0 to 340, 417 Pixel//"Lista de campos que n�o existe:"
	
	@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
	oMemo:bRClicked := { || AllwaysTrue() }
	oMemo:oFont     := oFont
	
	Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
	Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
	MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel
	
	Activate MsDialog oDlg Center

Endif
	
RestArea(aArea)

Return lRet


