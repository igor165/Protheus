#INCLUDE "SFCA011.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA011                                                                                                          
Tela de cadastro de Turno

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA011()
Local oBrowse

SFCValInt() // Verifica integração ligada

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYM')
oBrowse:SetDescription( STR0001 )  // 'Cadastro de Turno'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA011' OPERATION 2 ACCESS 0 // 'Visualizar'
If SFCIntegra() == 1
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA011' OPERATION 3 ACCESS 0 // 'Incluir'    
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA011' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA011' OPERATION 5 ACCESS 0 // 'Excluir'   
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA011' OPERATION 9 ACCESS 0 // 'Copiar'     
Endif

ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA011' OPERATION 8 ACCESS 0 // 'Imprimir'   

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYM := FWFormStruct( 1, 'CYM', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStructCYF := FWFormStruct( 1, 'CYF', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructCYR := FWFormStruct( 1, 'CYR', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA011', /*bPreValidacao*/, { |oMdl| SFCA011POS( oMdl ) } /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYMMASTER', /*cOwner*/, oStructCYM, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid                                                                                               
oModel:AddGrid( 'CYFDETAIL', 'CYMMASTER', oStructCYF, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'CYRDETAIL', 'CYFDETAIL', oStructCYR, /*bLinePre*/, { |oMdl| SFCA011BRWDY( oMdl ) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CYFDETAIL', { { 'CYF_FILIAL', 'xFilial( "CYF" )' }, { 'CYF_CDTN', 'CYM_CDTN' } }, CYF->( IndexKey(1)) )
oModel:SetRelation( 'CYRDETAIL', { { 'CYR_FILIAL', 'xFilial( "CYR" )' }, { 'CYR_CDTN', 'CYM_CDTN'  }, { 'CYR_NRTN', 'CYF_NRTN' } } , CYR->( IndexKey(1)))

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 )    //'Modelo de Dados de Turno'

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CYFDETAIL' ):SetUniqueLine( { 'CYF_NRTN' } )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYMMASTER' ):SetDescription( STR0010 )  //'Dados de Turno'
oModel:GetModel( 'CYFDETAIL' ):SetDescription( STR0011 )  //'Dados de Semanas do Modelo Turno'
oModel:GetModel( 'CYRDETAIL' ):SetDescription( STR0012 )  //'Dados dos Dias das Semanas do Modelo Turno'

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({"CYM_FILIAL", "CYM_CDTN"})    

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CYFDETAIL' ):SetOptional(.T.)  
oModel:GetModel( 'CYRDETAIL' ):SetOptional(.T.)      

// Valida o tamanho do turno conforme PCP
If SFCIntegra() == 1
	oModel:GetModel( 'CYMMASTER' ):GetStruct():SetProperty( 'CYM_CDTN',  MODEL_FIELD_TAMANHO,  3  )
EndIf    

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA011' )
// Cria a estrutura a ser usada na View
Local oStructCYM := FWFormStruct( 2, 'CYM' )
Local oStructCYF := FWFormStruct( 2, 'CYF' )
Local oStructCYR := FWFormStruct( 2, 'CYR' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYM', oStructCYM, 'CYMMASTER' )                

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CYF', oStructCYF, 'CYFDETAIL' )   
oView:AddGrid(  'VIEW_CYR', oStructCYR, 'CYRDETAIL' )                        

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 20 )
oView:CreateHorizontalBox( 'INFERIORSEMANA', 40 )
oView:CreateHorizontalBox( 'INFERIORDIA', 40 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYM', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CYF', 'INFERIORSEMANA' )
oView:SetOwnerView( 'VIEW_CYR', 'INFERIORDIA' )

//Remove o campo repetido em tela
oStructCYF:RemoveField("CYF_CDTN")
oStructCYF:RemoveField("CYF_LGTN")
oStructCYR:RemoveField("CYR_CDTN") 

//Adiciona auto incremento
oView:AddIncrementField("VIEW_CYF","CYF_NRTN")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA011BRWDY
Rotina de validação do grid da tabela CYR

@param   oModelGrid        Model do grid da tabela

@author Tiago Gauziski
@since 14/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA011BRWDY (oModelGrid)                                    
Local cHRBG        := FwFldGet('CYR_HRBG')
Local cHRED        := FwFldGet('CYR_HRED')
Local cNRDYWK      := FwFldGet('CYR_NRDYWK')
Local cNRDYWKLST   := FwFldGet('CYR_NRDYWK')                                
Local cNRDYWKNXT   := FwFldGet('CYR_NRDYWK')
Local lExistHrUt   := .F.
Local lExistPard   := .F.
Local lHrValid     := .F.
Local lRet         := .T.
Local nCYF         := 0
Local nI           := 0
Local nJ           := 0
Local nLineCYF     
Local nLineCYR     
Local oModel       
Local oModelCYF    

Default lAutomacao := .F.

If !lAutomacao
	oModel       := oModelGrid:GetModel( 'VIEW_CYR' )
	oModelCYF    := oModel:GetModel( 'CYFDETAIL' )
	nLineCYR     := oModelGrid:GetLine()
	nLineCYF     := oModelCYF:GetLine()

	oModelGrid:SetValue('CYR_HRBG',SFCA011COR(oModelGrid:GetValue('CYR_HRBG')))
	oModelGrid:SetValue('CYR_HRED',SFCA011COR(oModelGrid:GetValue('CYR_HRED')))
EndIf

If (cNRDYWKLST == "1")
	cNRDYWKLST := "7"
Else
	cNRDYWKLST := AllTrim(STR(VAL(cNRDYWK) - 1))
EndIf

If (cNRDYWKNXT == "7")
	cNRDYWKNXT := "1"
Else
	cNRDYWKNXT := AllTrim(STR(VAL(cNRDYWK) + 1))
EndIf
If(!SFCXCheckHour(cHRBG))
	SFCMsgErro(STR0013, "SFCA011") //"Insira uma Hora Inicial válida. Hora deve possuir formato HH:MM:SS"
	lRet = .F.	 
ElseIf(!SFCXCheckHour(cHRED))
	SFCMsgErro(STR0014, "SFCA011") //"Insira uma Hora Final válida. Hora deve possuir formato HH:MM:SS"
	lRet = .F.    
Else	  
   	If(FwFldGet('CYR_TPTE') == '2') // PARADA
   		//verifica se a descrição está em branco
		If(Vazio(FwFldGet('CYR_DSSP')))
			SFCMsgErro(STR0015, "SFCA011") //"Caso parada, é necessário informar a descrição"
			lRet = .F.	
		Else
			For nCYF := 1 To oModelCYF:GetQtdLine()
				oModelCYF:GoLine( nCYF )
				
				If !oModelCYF:IsDeleted( nCYF )
					For nI := 1 To oModelGrid:GetQtdLine()
						If ((nI == nLineCYR .And. nCYF == nLineCYF) .Or. oModelGrid:IsDeleted( nI ))
							Loop
						EndIf
						//validar a existencia apenas para semana corrente
						If(nCYF == nLineCYF)
							//verifica se existe hora util para aquele dia
							If(FwFldGet('CYR_TPTE', nI) == '1' .And. FwFldGet('CYR_NRDYWK', nI) == cNRDYWK)
								lExistHrUt := .T.
								//verifica se existe uma hora util que aceite o periodo da parada informado
								If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRBG) == .T. .And.;
							   	   SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRED) == .T.)
									lHrValid = .T.
								EndIf	
							ElseIf(FwFldGet('CYR_TPTE', nI) == '1' .And. FwFldGet('CYR_NRDYWK', nI) == cNRDYWKLST)
								lExistHrUt := .T.
								//verifica se existe uma hora util que aceite o periodo da parada informado
								If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRBG) == .T. .And.;
							   	   SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRED) == .T.)
									lHrValid = .T.
								EndIf	
							EndIf
						EndIf
						//verifica se existe uma parada contida no periodo informado
						If(FwFldGet('CYR_TPTE', nI) == '2' .And. FwFldGet('CYR_NRDYWK', nI) == cNRDYWK)
							If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRBG, .T.) == .T. .Or.;
						   	   SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRED, .T.) == .T. .Or.;
						   	   SFCXContidoRangeHoras(cHRBG, cHRED, FwFldGet('CYR_HRBG', nI), .T.) == .T. .Or.;
						   	   SFCXContidoRangeHoras(cHRBG, cHRED, FwFldGet('CYR_HRED', nI), .T.) == .T. .Or.;
						   	   (cHRBG == FwFldGet('CYR_HRBG', nI) .And. cHRED == FwFldGet('CYR_HRED', nI)))
								lExistPard = .T.
							EndIf	
						ElseIf(FwFldGet('CYR_TPTE', nI) == '2' .And. FwFldGet('CYR_NRDYWK', nI) == cNRDYWKLST)
							If(SFCXHourToSeg(FwFldGet('CYR_HRBG', nI)) > SFCXHourToSeg(FwFldGet('CYR_HRED', nI)) .And.;
							   SFCXHourToSeg(FwFldGet('CYR_HRED', nI)) > SFCXHourToSeg(cHRBG)  )
								lExistPard = .T.
							EndIf	
						ElseIf(FwFldGet('CYR_TPTE', nI) == '2' .And. FwFldGet('CYR_NRDYWK', nI) == cNRDYWKNXT .And. SFCXHourToSeg(cHRBG) > SFCXHourToSeg(cHRED))
							If(SFCXHourToSeg(cHRED) > SFCXHourToSeg(FwFldGet('CYR_HRBG', nI)) )
								lExistPard = .T.
							EndIf	
						EndIF
						//condição de saida, pois se as variaveis estiverem .T., não é preciso mais se manter no loop.
						If(lHrValid .And. lExistPard)
							Exit
						EndIf		
					Next
				EndIf
			Next 
			If(lHrValid == .F.)
				SFCMsgErro(STR0016, "SFCA011") //"Não é possível criar a parada, pois não existe hora útil no período informado."
				lRet = .F. 
			ElseIf(lExistHrUt == .F.)
				SFCMsgErro(STR0017, "SFCA011") //"Não é possível criar uma parada, pois não existe hora útil para este dia."
				lRet = .F. 
			ElseIf(lExistPard == .T.)
				SFCMsgErro(STR0018, "SFCA011") //"Não é possível criar uma parada, pois já existe uma parada no período informado."
				lRet = .F. 
			EndIf
		EndIf
	Else
		For nCYF := 1 To oModelCYF:GetQtdLine()
			oModelCYF:GoLine( nCYF )
				
			If !oModelCYF:IsDeleted( nCYF )
				For nI := 1 To oModelGrid:GetQtdLine() 
					//passa dos registro marcados como deletados                                             
					If ((nI == nLineCYR .And. nCYF == nLineCYF) .Or. oModelGrid:IsDeleted( nI ))
						Loop
					EndIf
					lHrValid := .F.           
					//verifica se existe uma hora útil contido no período informado
					If(SFCXHourToSeg(cHRBG) > SFCXHourToSeg(cHRED))
						If(FwFldGet('CYR_NRDYWK', nI) == cNRDYWK .And. FwFldGet('CYR_TPTE', nI) == '1')
							If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRBG, .T.) == .T. .Or.;
						   	   SFCXContidoRangeHoras(cHRBG, cHRED, FwFldGet('CYR_HRED', nI), .T.) == .T. )
								lExistHrUt = .T.
								Exit
							EndIf
						ElseIf(FwFldGet('CYR_NRDYWK', nI) == cNRDYWKLST .And. FwFldGet('CYR_TPTE', nI) == '1')
							If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRBG, .T.) == .T.)
								lExistHrUt = .T.
								Exit
							EndIf	
						ElseIf(FwFldGet('CYR_NRDYWK', nI) == cNRDYWKNXT .And. FwFldGet('CYR_TPTE', nI) == '1')
							If(SFCXHourToSeg(cHRED) > SFCXHourToSeg(FwFldGet('CYR_HRBG', nI)))
								lExistHrUt = .T.
								Exit
							EndIf	
						EndIf	
					ElseIf(FwFldGet('CYR_NRDYWK', nI) == cNRDYWK .And. FwFldGet('CYR_TPTE', nI) == '1')
						If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRBG, .T.) == .T. .Or.;
					 	   SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRED, .T.) == .T. .Or.;
					 	   SFCXContidoRangeHoras(cHRBG, cHRED, FwFldGet('CYR_HRBG', nI), .T.) == .T. .Or.;
					   	   SFCXContidoRangeHoras(cHRBG, cHRED, FwFldGet('CYR_HRED', nI), .T.) == .T. .Or.;
					   	   (cHRBG == FwFldGet('CYR_HRBG', nI) .And. cHRED == FwFldGet('CYR_HRED', nI)))
							lExistHrUt = .T.
							Exit
						EndIf
					ElseIf(FwFldGet('CYR_NRDYWK', nI) == cNRDYWKLST .And. FwFldGet('CYR_TPTE', nI) == '1')
						If(SFCXHourToSeg(FwFldGet('CYR_HRBG', nI)) > SFCXHourToSeg(FwFldGet('CYR_HRED', nI)))
							If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRBG, .T.) == .T. .Or.;
						 	   SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nI), FwFldGet('CYR_HRED', nI), cHRED, .T.) == .T. .Or.;
						 	   SFCXContidoRangeHoras(cHRBG, cHRED, FwFldGet('CYR_HRBG', nI), .T.) == .T. .Or.;
						   	   SFCXContidoRangeHoras(cHRBG, cHRED, FwFldGet('CYR_HRED', nI), .T.) == .T. .Or.;
						   	   (cHRBG == FwFldGet('CYR_HRBG', nI) .And. cHRED == FwFldGet('CYR_HRED', nI)))
								lExistHrUt = .T.
								Exit
							EndIf
						EndIf 	
					EndIf
					If(nCYF == nLineCYF)
					 	//verifica se existe parada não contido em uma hora útil, pois caso ocorra, quer dizer foi alterado a hora util tornando alguma parada inválida
						If nI <> nLineCYR .And. FwFldGet('CYR_TPTE', nI) == '2' .And. FwFldGet('CYR_NRDYWK', nI) == cNRDYWK 
							For nJ := 1 To oModelGrid:GetQtdLine() 
								If(FwFldGet('CYR_NRDYWK', nJ) == cNRDYWK .And. FwFldGet('CYR_TPTE', nJ) == '1')
									If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nJ), FwFldGet('CYR_HRED', nJ), FwFldGet('CYR_HRBG',nI)) == .T. .And.;
								   	   SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nJ), FwFldGet('CYR_HRED', nJ), FwFldGet('CYR_HRED',nI)) == .T.)
										lHrValid := .T.
										Exit
									EndIf
								ElseIf(FwFldGet('CYR_NRDYWK', nJ) == cNRDYWKLST .And. FwFldGet('CYR_TPTE', nJ) == '1')
									If(SFCXHourToSeg(FwFldGet('CYR_HRBG', nJ)) > SFCXHourToSeg(FwFldGet('CYR_HRED', nJ)) .And.;
									   SFCXHourToSeg(FwFldGet('CYR_HRED', nJ)) > SFCXHourToSeg(FwFldGet('CYR_HRBG', nI)) .And.;
								   	   SFCXHourToSeg(FwFldGet('CYR_HRED', nJ)) > SFCXHourToSeg(FwFldGet('CYR_HRED', nI)) )
										lHrValid := .T.
										Exit
									EndIf
								EndIf			
							Next
							If (lHrValid == .F.)
								SFCMsgErro(STR0020, "SFCA011") //"Não é possível alterar o horário, pois esta alteração influencia uma parada relacionada a este horário."
								lRet = .F.
								Exit
							EndIf
						EndIf	  
					EndIf	 
				Next
			Endif
		Next
		
		If(lExistHrUt == .T.)
			SFCMsgErro(STR0021, "SFCA011") //"Não é possível criar o horário, pois já existe um horário útil no período informado."
			lRet = .F. 
		EndIf
	EndIf
EndIf
                          
If !lAutomacao
	//reposiciona os browsers
	oModelCYF:GoLine(nLineCYF)
	oModelGrid:GoLine(nLineCYR)
EndIf

If (lRet)
   	If(oModelGrid:LoadValue("CYR_QTTE", SFCXHourToSeg(ELAPTIME(cHRBG, cHRED))))
		lRet := .T.
	Else   
		SFCMsgErro(STR0022, "SFCA011") //"Erro ao tentar gravar a hora informada"
		lRet := .F.	
	EndIf
	
EndIf 

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA011POS 
Rotina para Validar os dados no momento da inclusão ou alteração
Uso Geral.

@param   oModel        Objeto do model principal
@author Tiago Gauziski
@since 15/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA011POS (oModel)
Local lRet      := .T.
Local nOpc      := (oModel:GetOperation())  
Local aArea     := GetArea()
Local aAreaCYA  := CYA->(GetArea())
Local aAreaCYX  := CYX->(GetArea())
Local aAreaCYL  := CYL->(GetArea())
Local aAreaCYV  := CYV->(GetArea())
Local aAreaCYW  := CYW->(GetArea())
Local aAreaCZ2  := CZ2->(GetArea())
Local aAreaCZ5  := CZ5->(GetArea())
Local nI        := 0
Local nJ        := 0
Local nCont     := 0
Local nQTTEUTWK := 0
Local nQTTESPWK := 0
Local nQTTEUTAL := 0
Local nQTTESPAL := 0                             
Local cNRDYWKLST 
Local cNRDYWKNXT 
Local cNRDYWK    
Local oModelCYF := oModel:GetModel( 'CYFDETAIL' )
Local oModelCYR := oModel:GetModel( 'CYRDETAIL' )
Local oModelCYM := oModel:GetModel( 'CYMMASTER' )

If nOpc == 3 .Or. nOpc == 4
	
	For nI := 1 To oModelCYF:GetQtdLine()
		oModelCYF:GoLine(nI)
		If(!oModelCYF:IsDeleted( nI ))
			For nJ := 1 To oModelCYR:GetQtdLine()    
			
				If(!oModelCYR:IsDeleted( nJ ) .AND. (oModelCYR:IsUpdated(nJ) .OR. oModelCYR:IsInserted(nJ))) 
				
					cNRDYWK := FwFldGet('CYR_NRDYWK', nJ)
					If (cNRDYWK == "1")
						cNRDYWKLST := "7"
					Else
						cNRDYWKLST := AllTrim(STR(VAL(cNRDYWK) - 1))
					EndIf
					
					If (cNRDYWK == "7")
						cNRDYWKNXT := "1"
					Else
						cNRDYWKNXT := AllTrim(STR(VAL(cNRDYWK) + 1))
					EndIf
					If(oModelCYR:IsDeleted( nJ ) .And. FwFldGet('CYR_TPTE', nJ) == '1' .And. FwFldGet('CYR_QTTE', nJ) <> 0)
				    	For nCont := 1 To oModelCYR:GetQtdLine()
				    		If(	FwFldGet('CYR_NRDYWK', nCont) == cNRDYWK .And. FwFldGet('CYR_TPTE', nCont) == '2')
				    			If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nJ), FwFldGet('CYR_HRED', nJ), FwFldGet('CYR_HRBG', nCont)) == .T. .And.;
				   	      		   SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nJ), FwFldGet('CYR_HRED', nJ), FwFldGet('CYR_HRED', nCont)) == .T.) 
				   	   				oModelCYR:GoLine(nCont)
				   	   				oModelCYR:DeleteLine()	
				   	   			EndIf
				   	   		ElseIf(	FwFldGet('CYR_NRDYWK', nCont) == cNRDYWKNXT .And. FwFldGet('CYR_TPTE', nCont) == '2')
				    			If(SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nJ), FwFldGet('CYR_HRED', nJ), FwFldGet('CYR_HRBG', nCont)) == .T. .And.;
				   	      		   SFCXContidoRangeHoras(FwFldGet('CYR_HRBG', nJ), FwFldGet('CYR_HRED', nJ), FwFldGet('CYR_HRED', nCont)) == .T.) 
				   	   				oModelCYR:GoLine(nCont)
				   	   				oModelCYR:DeleteLine()	
				   	   			EndIf
				    		EndIf
				    	Next	
					ElseIf(!oModelCYR:IsDeleted(nJ) .And. FwFldGet('CYR_TPTE', nJ) == '1')
						nQTTEUTWK := nQTTEUTWK + FwFldGet('CYR_QTTE', nJ)
					ElseIf(!oModelCYR:IsDeleted(nJ) .And. FwFldGet('CYR_TPTE', nJ) == '2') 
						nQTTESPWK := nQTTESPWK + FwFldGet('CYR_QTTE', nJ)
					EndIf
				EndIf
			Next
			oModelCYF:SetValue("CYF_QTTEUT", nQTTEUTWK)
			oModelCYF:SetValue("CYF_QTTESP", nQTTESPWK)
			nQTTEUTAL := nQTTEUTAL + nQTTEUTWK
			nQTTESPAL := nQTTESPAL + nQTTESPWK
			nQTTEUTWK := 0
			nQTTESPWK := 0                                                       
		Else
			For nJ := 1 To oModelCYR:GetQtdLine()
				oModelCYR:GoLine(nJ)
				oModelCYR:DeleteLine()
			Next
		EndIf	  
    Next
    
    oModelCYM:SetValue("CYM_QTTEWK", nQTTEUTAL)
    oModelCYM:SetValue("CYM_QTSPWK", nQTTESPAL)
Else

	dbSelectArea('CYA')
	CYA->(dbSetOrder(2))
	IF CYA->(dbSeek(xFilial('CYA')+oModel:GetValue('CYMMASTER','CYM_CDTN')))
		SFCMsgErro(STR0024 + ALLTRIM(CYA->CYA_CDARPO), 'SFCA011') //"Registro está sendo usado na Área de Produção "
    	lRet := .F.
	Endif
	
	dbSelectArea('CYX')
	CYX->(dbSetOrder(7))
	IF CYX->(dbSeek(xFilial('CYX')+oModel:GetValue('CYMMASTER','CYM_CDTN')))
		SFCMsgErro(STR0025, 'SFCA011') //"Registro está sendo usado em Apontamento de Produção "
    	lRet := .F.
	Endif
	
	dbSelectArea('CYL')
	CYL->(dbSetOrder(4))
	IF CYL->(dbSeek(xFilial('CYX')+oModel:GetValue('CYMMASTER','CYM_CDTN')))
		SFCMsgErro(STR0026 + ALLTRIM(CYL->CYL_CDMQ), 'SFCA011') //"Registro está sendo usado na Máquina "
    	lRet := .F.
	Endif
	
	dbSelectArea('CYV')
	CYV->(dbSetOrder(4))
	IF CYV->(dbSeek(xFilial('CYV')+oModel:GetValue('CYMMASTER','CYM_CDTN')))
		SFCMsgErro(STR0025 + ALLTRIM(CYV->CYV_NRSQRP), 'SFCA011') //"Registro está sendo usado no Apontamento de Produção "
    	lRet := .F.
	Endif
	
	dbSelectArea('CYW')
	CYW->(dbSetOrder(2))
	IF CYW->(dbSeek(xFilial('CYW')+oModel:GetValue('CYMMASTER','CYM_CDTN')))
		SFCMsgErro(STR0027 + ALLTRIM(CYW->CYW_NRSQRP), 'SFCA011') //"Registro está sendo usado na Mão-de-Obra do Apontamento de Produção "
    	lRet := .F.
	Endif
	
	dbSelectArea('CZ2')
	CZ2->(dbSetOrder(2))
	IF CZ2->(dbSeek(xFilial('CZ2')+oModel:GetValue('CYMMASTER','CYM_CDTN')))
		SFCMsgErro(STR0028 + ALLTRIM(CZ2->CZ2_NRSQSP), 'SFCA011') //"Registro está sendo usado na Manutenção Programada "
    	lRet := .F.
	Endif
	
	dbSelectArea('CZ5')
	CZ5->(dbSetOrder(7))
	IF CZ5->(dbSeek(xFilial('CZ5')+oModel:GetValue('CYMMASTER','CYM_CDTN')))
		SFCMsgErro(STR0030, 'SFCA011') //"Registro está sendo usado nos Indicadores de Fábrica"
    	lRet := .F.
	Endif
	
	IF PADR(GetMv("MV_SFCCDTN"),TamSx3("CYM_CDTN")[1],"") == oModel:GetValue('CYMMASTER','CYM_CDTN')
		SFCMsgErro(STR0029, 'SFCA011') //"Registro está sendo usado no parâmetro MV_SFCCDTN (Turno Padrão)"
    	lRet := .F.
	Endif
EndIf

if lRet .AND. SFCIntegra() == 1 .AND. !IsInCallStack("A780IntSFC")
	if Len(ALLTRIM(oModelCYM:GetValue('CYM_CDTN'))) > 3
	    	SFCMsgErro(STR0023, "SFCA011") //"Código de Calendário deve possuir no máximo 3 posições"
    	lRet := .F.
 	Else
		lRet := AUTO780(nOpc,oModel)
    Endif
EndIf

RestArea(aArea)
RestArea(aAreaCYA)
RestArea(aAreaCYX)
RestArea(aAreaCYL)
RestArea(aAreaCYV)
RestArea(aAreaCYW)
RestArea(aAreaCZ2)
RestArea(aAreaCZ5)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO780
Rotina para Integracao com o Protheus - MATA780

@param   nOpc        Operacao Executada
@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function AUTO780(nOpc,oModel)
Local aCab     := {}// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
Local aDados   := {}// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
Local aItens   := {}
Local lRetorno := .F.
Local nI	   := 0
Local nI2	   := 0
Local nI3	   := 0
Local nJ       := 0
Local nPosReg  := 0
Local aPeriodo := {}
Local aAcum    := {}
Local aDia     := {}
Local nValor   := 0
Local nInt     := 0
Local cReferIni    := ''
Local cReferFim    := ''
Local oModelCYF    := oModel:GetModel( 'CYFDETAIL' )
Local oModelCYR    := oModel:GetModel( 'CYRDETAIL' )
Local lHelpDark    := HelpInDark(.F.)
Local lHelp        := HelpLog(.T.)
Default lAutomacao := .F.

Private lMsHelpAuto := .T. // Grava help no log
Private lMsErroAuto := .f.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos
		
If nOpc==3 .OR. nOpc==4

	aCab:= {{'H7_CODIGO',oModel:GetValue('CYMMASTER','CYM_CDTN'), Nil},{'H7_DESCRI',oModel:GetValue('CYMMASTER','CYM_DSTN'),Nil}}

	For nI := 2 To 8
		aAcum := {}
		
		For nJ := 1 to oModelCYF:GetQtdLine()
			oModelCYF:GoLine(nJ)			
			For nI2 := 1 To oModelCYR:GetQtdLine()
				oModelCYR:GoLine(nI2)
				
				If !oModelCYR:IsDeleted() .AND. oModelCYR:GetValue('CYR_NRDYWK') == ALLTRIM(STR(if(nI==8,1,nI)))					
					AADD(aAcum, SFCXHRTOCEN(oModelCYR:GetValue('CYR_HRBG')))
					AADD(aAcum, SFCXHRTOCEN( if(oModelCYR:GetValue('CYR_HRED')=="00:00:00", "24:00:00",(oModelCYR:GetValue('CYR_HRED')) ) ) )
				Endif
			Next
		Next
		
		aSort(aAcum)
		aDia := {}
		
		For nI3 := 1 to Len(aAcum) Step 2
			aPeriodo := {}
			
			aAdd(aPeriodo,aAcum[nI3])
			aAdd(aPeriodo,aAcum[nI3 + 1])
			
			if !Empty(aPeriodo)
				aAdd(aDia,aPeriodo)
			Endif
		Next
		
		aAdd(aItens,if(!Empty(aDia),aDia,{nil}))
	Next

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de exclusao somente sera necessario passar o cabecalho com o codigo do calendario ³
	//³a ser excluido, porem o array de itens devera ser passado vazio somente para nao ocorrer  ³
	//³erro na execucao da rotina.                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCab   := {{'H7_CODIGO',oModel:GetValue('CYMMASTER','CYM_CDTN'), Nil}}
	aItens := {}
EndIf

MSExecAuto({|x,y,Z| MATA780(x,y,z)},nopc,aCab,aItens)
If lMsErroAuto 
	lRetorno := .F.
	If !lAutomacao
		If !IsTelNet()
			MostraErro()
		Else
			ErroTelnet()
		EndIf
	EndIf
Else
	lRetorno:=.T.
EndIf         

HelpInDark(lHelpDark)
HelpLog(lHelp)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA011COR
Rotina para corrigir as horas, que no protheus devem ser de acordo com
parâmetro MV_PRECISA 

@param   nHora        Hora

@author Samantha Preima
@since 04/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SFCA011COR(cHora)
Local nSeg   := VAL(Substr(cHora,7,2))
Local nMin   := VAL(Substr(cHora,4,2))
Local nHora  := VAL(Substr(cHora,1,2))
Local nPrec  := SuperGetMV("MV_PRECISA",.F.,4)

IF nSeg > 0
	nMin++
	
	if nMin > 59
		nHora++
		nMin := 0
		
		if nHora > 23
			nHora := 0
		Endif
	Endif
Endif

IF nMin > 0
	Do Case
	    Case nPrec == 1 // De hora em hora
	    	if nMin > 0 .AND. nMin < 60
				nHora++
				nMin := 0
			Endif
		Case nPrec == 2	// De 30 em 30 minutos
			if nMin > 0 .AND. nMin <= 30
			   	nMin := 30
			ElseIF nMin > 30 .AND. nMin < 60
				nHora++
				nMin := 0
			Endif
		Case nPrec == 4 // De 15 em 15 minutos
			if nMin > 0 .AND. nMin <= 15
			   	nMin := 15
			ElseIf nMin > 15 .AND. nMin <= 30
				nMin := 30
			ElseIf nMin > 30 .AND. nMin <= 45
				nMin := 45
			ElseIf nMin > 45 .AND. nMin < 60
				nHora++
				nMin := 0
			Endif
		Case nPrec == 6 // De 10 em 10 minutos
			if nMin > 0 .AND. nMin <= 10
			   	nMin := 10
			ElseIf nMin > 10 .AND. nMin <= 20
				nMin := 20
			ElseIf nMin > 20 .AND. nMin <= 30
				nMin := 30
			ElseIf nMin > 30 .AND. nMin <= 40
				nMin := 40
			ElseIf nMin > 40 .AND. nMin <= 50
				nMin := 50
			ElseIf nMin > 50 .AND. nMin < 60
				nHora++
				nMin := 0
			Endif
		Case nPrec == 12 // De 5 em 5 minutos
			if nMin > 0 .AND. nMin <= 5
			   	nMin := 5
			ElseIf nMin > 5 .AND. nMin <= 10
				nMin := 10
			ElseIf nMin > 10 .AND. nMin <= 15
				nMin := 15
			ElseIf nMin > 15 .AND. nMin <= 20
				nMin := 20
			ElseIf nMin > 20 .AND. nMin <= 25
				nMin := 25
			ElseIf nMin > 25 .AND. nMin <= 30
				nMin := 30
			ElseIf nMin > 30 .AND. nMin <= 35
				nMin := 35
			ElseIf nMin > 35 .AND. nMin <= 40
				nMin := 40
			ElseIf nMin > 40 .AND. nMin <= 45
				nMin := 45
			ElseIf nMin > 45 .AND. nMin <= 50
				nMin := 50
			ElseIf nMin > 50 .AND. nMin <= 55
				nMin := 55
			ElseIf nMin > 55 .AND. nMin < 60
				nHora++
				nMin := 0
			Endif
		Case nPrec == 60 // De minuto em minuto não faz nada
	End Case
Endif

nHora := StrZero(nHora,2)
nMin  := StrZero(nMin,2)

cHora := ALLTRIM(nHora) + ':' + ALLTRIM(nMin) + ':00'

Return cHora

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oWeekContent
Local oWeekDayContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
Local oModelCYF
Local oModelCYR
Local nI
Local nD
Local aWeeks := {}
Local aWeekDays := {}
Local aArea    := GetArea()
Local aAreaCYM := CYM->(GetArea())

If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf             

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE          

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA011: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

		
	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA011 Recebendo Mensagem Business' )
            
			cError := ''
			cWarning := '' 
			
			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
			                                    
			lValid := .F.
			
			If oXML != NIL
				If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
					oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
					oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT   
					
					lValid := .T.
				ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
					oBusinessContent = oXML:_BusinessContent
					oBusinessEvent = EAI_EVENT_UPSERT   
					
					lValid := .T.
				EndIf
			EndIf
			
            If lValid == .F.
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }	
            EndIf
			        
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYM')
			CYM->(dbSetOrder(1))
			lFound := CYM->(dbSeek(xFilial('CYM')+ oBusinessContent:_Code:TEXT))
			
			// Instancia o modelo	
			oModel := FWLoadModel( 'SFCA011' )
			oModelCYF := oModel:GetModel('CYFDETAIL')
			oModelCYR := oModel:GetModel('CYRDETAIL')
			
			// Verifica se a mensagem é de Inclusão/Alteração
			If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
				// Se foi encontrado, envia como Alteração
				If lFound
					nOpc := 4
				Else 
					// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
					nOpc := 3						
				EndIf
			Else  
				// Apaga o registro  
				nOpc := 5						
			EndIf
            
			// Set a operação e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()
            
            // Se operação for diferente de exclusão
			If nOpc # 5
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('CYMMASTER', 'CYM_CDTN', SFCXXtoS(oBusinessContent:_Code:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYMMASTER', 'CYM_DSTN', SFCXXtoS(oBusinessContent:_Description:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYMMASTER', 'CYM_QTTEWK', SFCXStoX(oBusinessContent:_UtilTimeWeek:TEXT, 'N'));If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYMMASTER', 'CYM_QTSPWK', SFCXStoX(oBusinessContent:_StopTimeWeek:TEXT, 'N'));If !lAssign; Return SFCXMKERR(oModel); EndIf


				For nI := 1 To oModelCYF:Length()
		
					oModelCYF:GoLine( nI )
					
					If !oModelCYF:IsDeleted()
				       	oModelCYF:DeleteLine()
					Endif
					
				Next
	            
	            
	            If XmlChildEx(oBusinessContent, "_LISTOFWEEKPRODUCTIONSHIFTS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfWeekProductionShifts) > 0
	            	aWeeks := oBusinessContent:_ListOfWeekProductionShifts:_WeekProductionShift
	            	If ValType(aWeeks) == 'O'
	               		aWeeks := { aWeeks }
	            	EndIf
	            EndIf
	            
				For nI := 1 To Len(aWeeks)
					oModelCYF:AddLine()
				    
				    oWeekContent := aWeeks[nI]
				   	   	                      	     
					lAssign := oModelCYF:SetValue('CYF_NRTN', SFCXXtoS(oWeekContent:_Sequence:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
					
					If XmlChildEx(oWeekContent, "_DESCRIPTION") != NIL 
						lAssign := oModelCYF:SetValue('CYF_DSTN', SFCXXtoS(oWeekContent:_Description:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
					Else
						lAssign := oModelCYF:SetValue('CYF_DSTN', SFCXXtoS(oBusinessContent:_Description:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					lAssign := oModelCYF:SetValue('CYF_QTTEUT', SFCXStoX(oWeekContent:_UtilTimeWeek:TEXT, 'N'));If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYF:SetValue('CYF_QTTESP', SFCXStoX(oWeekContent:_StopTimeWeek:TEXT, 'N'));If !lAssign; Return SFCXMKERR(oModel); EndIf

					If XmlChildEx(oWeekContent, "_REGENERATE") != NIL 
						lAssign := oModelCYF:SetValue('CYF_LGTN', SFCXStoX(oWeekContent:_Regenerate:TEXT, 'L'));If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					For nD := 1 To oModelCYR:Length()
						oModelCYR:GoLine( nD )
						If !oModelCYR:IsDeleted()
					       	oModelCYR:DeleteLine()
						Endif
					Next
					            
					If XmlChildEx(oWeekContent, "_LISTOFWEEKPRODUCTIONSHIFTDAY") != NIL .AND. XmlChildCount(oWeekContent:_ListOfWeekProductionShiftDay) > 0
						aWeekDays := oWeekContent:_ListOfWeekProductionShiftDay:_WeekProductionShiftDay
						If valType(aWeekDays) == 'O'
						   aWeekDays := { aWeekDays }
						EndIf
		            EndIf
					
					For nD := 1 To Len(aWeekDays)
						oModelCYR:AddLine()
					    
					    oWeekDayContent := aWeekDays[nD]
						lAssign := oModelCYR:SetValue('CYR_TPTE', SFCXXtoS(oWeekDayContent:_Type:TEXT)) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYR:SetValue('CYR_NRDYWK', SFCXXtoS(oWeekDayContent:_WeekDay:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf 
						lAssign := oModelCYR:SetValue('CYR_HRBG', SFCXXtoS(oWeekDayContent:_StartHour:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYR:SetValue('CYR_HRED', SFCXXtoS(oWeekDayContent:_EndHour:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf       
						
						If XmlChildEx(oWeekContent, "_TIMEQUANTITY") != NIL 
							lAssign := oModelCYR:SetValue('CYR_QTTE', SFCXStoX(oWeekDayContent:_TimeQuantity:TEXT, 'N'));If !lAssign; Return SFCXMKERR(oModel); EndIf
						Endif
						
						If SFCXXtoS(oWeekDayContent:_Type:TEXT) == '2'
							lAssign := oModelCYR:SetValue('CYR_DSSP', SFCXXtoS(oWeekDayContent:_StopReasonDescription:TEXT));If !lAssign; Return SFCXMKERR(oModel); EndIf
						EndIf
					Next
				Next
			EndIf			
            
            // Validação no Model    
			if oModel:VldData()  
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()    
				
				// Retorna OK                        
				cXMLRet := 'Mensagem de ' + IF(nOpc == 3,'Criacao', IF(nOpc == 4, 'Alteracao', 'Delecao')) + ' recebida com sucesso.'
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				aErro := oModel:GetErrorMessage()
				cXMLRet := SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'
				lRet := .F.
			EndIf

			// Desativa o Model
			oModel:DeActivate()

	  // Mensagem é de Response
      ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
            //conout( '+ IntegDef SFCA011 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA011 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA011 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()
      oModelCYF := oModel:GetModel('CYFDETAIL')
      oModelCYR := oModel:GetModel('CYRDETAIL')

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "ProductionShift",oModel:GetOperation(), { { "Code", oModel:GetValue("CYMMASTER", 'CYM_CDTN') } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          


		cXMLRet += '<Code>' 					+ SFCXXtoS(oModel:GetValue("CYMMASTER", 'CYM_CDTN')) 	+ '</Code>'
		cXMLRet += '<Description>' 				+ SFCXXtoS(oModel:GetValue("CYMMASTER", 'CYM_DSTN')) 	+ '</Description>'
		cXMLRet += '<UtilTimeWeek>' 			+ SFCXXtoS(oModel:GetValue("CYMMASTER", 'CYM_QTTEWK')) 	+ '</UtilTimeWeek>'
		cXMLRet += '<StopTimeWeek>' 			+ SFCXXtoS(oModel:GetValue("CYMMASTER", 'CYM_QTSPWK')) 	+ '</StopTimeWeek>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<ListOfWeekProductionShifts>'

				For nI := 1 To oModelCYF:Length()
					oModelCYF:GoLine( nI )
				
				   	If !oModelCYF:IsDeleted()
				   		cXMLRet += '<WeekProductionShift>'  
							cXMLRet += '<Sequence>' 			+ SFCXXtoS(oModelCYF:GetValue('CYF_NRTN')) 			+ '</Sequence>'
							cXMLRet += '<Description>' 			+ SFCXXtoS(oModelCYF:GetValue('CYF_DSTN')) 			+ '</Description>'
							cXMLRet += '<UtilTimeWeek>' 		+ SFCXXtoS(oModelCYF:GetValue('CYF_QTTEUT')) 		+ '</UtilTimeWeek>'
	   						cXMLRet += '<StopTimeWeek>' 		+ SFCXXtoS(oModelCYF:GetValue('CYF_QTTESP')) 		+ '</StopTimeWeek>'
	   						cXMLRet += '<Regenerate>' 			+ SFCXXtoS(oModelCYF:GetValue('CYF_LGTN')) 			+ '</Regenerate>'
				   	   	                      
				   	   		cXMLRet += '<ListOfWeekProductionShiftDay>'

							For nI := 1 To oModelCYR:Length()
								oModelCYR:GoLine( nI )
							
							   	If !oModelCYR:IsDeleted()
							   		cXMLRet += '<WeekProductionShiftDay>'  
										cXMLRet += '<Type>' 			+ SFCXXtoS(oModelCYR:GetValue('CYR_TPTE')) 			+ '</Type>'
										cXMLRet += '<WeekDay>' 			+ SFCXXtoS(oModelCYR:GetValue('CYR_NRDYWK')) 		+ '</WeekDay>'
										cXMLRet += '<StartHour>' 		+ SFCXXtoS(oModelCYR:GetValue('CYR_HRBG')) 			+ '</StartHour>'
				   						cXMLRet += '<EndHour>' 			+ SFCXXtoS(oModelCYR:GetValue('CYR_HRED')) 			+ '</EndHour>'
				   						cXMLRet += '<TimeQuantity>' 	+ SFCXXtoS(oModelCYR:GetValue('CYR_QTTE')) 			+ '</TimeQuantity>'
							   	   		
							   	   		If oModelCYR:GetValue('CYR_TPTE') == '2'
							   	   			cXMLRet += '<StopReasonDescription>' 		+ SFCXXtoS(oModelCYR:GetValue('CYR_DSSP'))		+ '</StopReasonDescription>'
							   	   	    EndIf
							   	   	    
							   		cXMLRet += '</WeekProductionShiftDay>'
							   	EndIf	      	        
							Next
							
							cXMLRet += '</ListOfWeekProductionShiftDay>'
			
				   	   	
				   		cXMLRet += '</WeekProductionShift>'
				   	EndIf	      	        
				Next
			
			cXMLRet += '</ListOfWeekProductionShifts>'
			
        EndIf
		                
	    		
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aAreaCYM)
RestArea(aArea)
                        
//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }

Function INTDF_A011( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)       

User Function Unit011
	RpcSetEnv( "99","01", "Administrador", "sfc", "SFC", "CARGADTS_SFC", , , , ,  )
	
	cXml := '<BusinessContent><Code>SFC</Code><Description>Turno Padrao</Description><UtilTimeWeek>44</UtilTimeWeek><StopTimeWeek>10</StopTimeWeek><ListOfWeekProductionShifts><WeekProductionShift><Sequence>1</Sequence><UtilTimeWeek>44</UtilTimeWeek><StopTimeWeek>10</StopTimeWeek><Regenerate>false</Regenerate><ListOfWeekProductionShiftDay/></WeekProductionShift></ListOfWeekProductionShifts></BusinessContent>'
	
	INTEGDEF(cXml, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)       


Return NIL
