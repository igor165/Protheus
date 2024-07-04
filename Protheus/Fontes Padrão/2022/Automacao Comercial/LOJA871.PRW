#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA871.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA871 
Cadastro de Servico financeiro.

@author Varejo
@since 20/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA871()
Local oBrowse


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MG8' )
oBrowse:SetDescription(STR0002)//#"Cadastro de Serviço"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw"  		       OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.LOJA871"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.LOJA871"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.LOJA871"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.LOJA871"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMG8 := FWFormStruct(1,"MG8") // Informe os campos que eu quero no cabecalho
Local oModel := Nil

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA871",{|oModel| LJ871Pre(oModel)},{|| LJ871Pos()},/*Commit*/,/*Cancel*/)

oModel:AddFields("MG8MASTER", Nil/*cOwner*/, oStructMG8 ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

oModel:SetPrimaryKey( { "MG8_FILIAL","MG8_CODIGO" } )
                                                                        
oModel:GetModel("MG8MASTER"):SetDescription(STR0002) //#"Cadastro de Serviço"


Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel("LOJA871")
Local oStructMG8 := FWFormStruct(2,"MG8") // Informe os campos que eu quero no cabecalho
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
            

oView:AddField( "VIEWMG8" , oStructMG8, "MG8MASTER" )
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMG8' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWMG8' )
                                                       	
Return oView
               
//-------------------------------------------------------------------
/*{Protheus.doc} Mg8VldPd
Valida se o produto ja foi cadastrado como servico

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Function Mg8VldPd(cProd)
Local lRet:= .T.
Local aArea:= GetArea()
             

SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1")+cProd)) 
	If SB1->B1_TIPO <> SuperGetMv("MV_LJTPSF",,"SF")
		lRet:= .F.
		Help( ,, 'HELP',, STR0003, 1, 0)    //#"Produto selecionado não é do tipo SF (Serviço Financeiro)."
	EndIf	
Else
	lRet:= .F.
	Help( ,, 'HELP',, STR0004, 1, 0)    //#"Produto selecionado não é do tipo SF (Serviço Financeiro)."		
EndIf

If lRet
	MG8->(DbSetOrder(2))
	If MG8->(DbSeek(xFilial("MG8")+cProd))
		lRet:= .F.
		Help( ,, 'HELP',, STR0005, 1, 0)    //#"Produto ja cadastrado como serviço!"
	EndIf
EndIf
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LJ871Pre
Efetua o pre valida do modelo.

@author Varejo
@since 25/06/2014
@version versao
*/
//-------------------------------------------------------------------
Static Function LJ871Pre(oModel)

Local nOperation := oModel:GetOperation() //Operacao do Modelo

MBF->(dbSetOrder(1))

//Se existe atrelamento informa ao usuario
If nOperation == MODEL_OPERATION_DELETE .AND. MBF->(dbSeek(xFilial("MBF") + FwFldGet("MG8_PRDSB1")))
	MsgInfo(STR0006) //#"Existem atrelamentos a esse serviço e também serão apagados se confirmada a exclusão"
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} LJ871Pos
Efetua o pos valida do modelo.

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LJ871Pos()

Local lRet     	:= .T.           
Local aArea    	:= GetArea()                    //armazena posicionamento atual da tabela
Local oView	   		:= FwViewActive()   // Pega view ativa
Local oModel   	:= oView:GetModel('MG8MASTER') // Modelo 
Local cProdSf  	:= '' // Codido do produto servico
Local nOperation	:= oModel:GetOperation() 		//Operacao do Modelo

MBF->(dbSetOrder(1))
MBL->(dbSetOrder(1))

If INCLUI 
	If Empty(oModel:GETValue('MG8_PRDSB1') )            
		//Inclui o Produto Servico ao incluir
		If !IncSFSB1(@cProdSf,oModel)
			lRet:=.F.   
		Else
			oModel:SetValue('MG8_PRDSB1', cProdSf )	
			MsgInfo(STR0007+Alltrim(cProdSf)+" "+Alltrim(oModel:GetValue('MG8_DESCRI'))+STR0008,STR0009) //#"O produto " ##" do tipo serviço financeiro foi criado com sucesso e associado ao cadastro do serviço!" ###"Atenção"
		EndIf
	EndIf
	
	If lRet .AND. oModel:GetValue("MG8_TPXPRD") == "1"
		FWExecView("", "LOJA980", MODEL_OPERATION_INSERT,,{||.T.}) 
	EndIf
ElseIf nOperation == MODEL_OPERATION_DELETE .AND. MBF->(dbSeek(xFilial("MBF") + oModel:GetValue("MG8_PRDSB1")))             			
	While MBF->(!EOF()) .AND. MBF->(MBF_FILIAL + MBF_PRDGAR) == xFilial("MBF") + oModel:GetValue("MG8_PRDSB1")  						
		//Apaga atrelamento - Itens
		If MBL->(dbSeek(xFilial("MBL") + MBF->MBF_CODIGO))
			While MBL->(!EOF()) .AND. MBL->(MBL_FILIAL + MBL_CODIGO) == xFilial("MBL") + MBF->MBF_CODIGO  
				RecLock("MBL", .F.)
				MBL->(dbDelete())
				MBL->(MsUnLock())
				
				MBL->(dbSkip())
			EndDo
		EndIf 
		
		//Apaga atrelamento - Cabecalho
		RecLock("MBF", .F.)
		MBF->(dbDelete())
		MBF->(MsUnLock())
			
		MBF->(dbSkip())
	EndDo							
EndIf

RestArea(aArea)

Return lRet           

//-------------------------------------------------------------------
/*{Protheus.doc} IncSFSB1
Inclui produto servico automatico (SB1).

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function IncSFSB1(cProdSf,oModel)

Local aSB1:={}// array para cadastro automatico                                             
Local aSB0:={}// array para cadastro automatico                                             
Local lRet:= .T. // varial para validacao 

Private lMsErroAuto := .F. // obrigatorio quando usar ExecAuto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄ¿
//³Pega um codigo de produto valido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
cProdSf:= GETSXENUM("SB1","B1_COD","",1)
SB1->(DbSetOrder(1))
While SB1->(DbSeek(xFilial("SB1")+cProdSf))
	ConfirmSx8()
	cProdSf:= GETSXENUM("SB1","B1_COD","",1)
EndDo 
		
//Informacoes da tabela SB1
aAdd( aSB1, { "B1_COD", 	cProdSf, 						Nil } ) //Codigo do produto
aAdd( aSB1, { "B1_DESC", 	oModel:GetValue('MG8_DESCRI'), 	Nil } ) //Descricao do Produto
aAdd( aSB1, { "B1_TIPO", 	SuperGetMv("MV_LJTPSF",,"SF"), 	Nil } ) //Tipo do produto
aAdd( aSB1, { "B1_UM", 		"UN", 							Nil } ) //Unidade de medida
aAdd( aSB1, { "B1_LOCPAD", 	"01", 							Nil } ) //Armazem Padrao
aAdd( aSB1, { "B1_TS", 		oModel:GetValue('MG8_TESSB1'), 	Nil } ) //Descricao do Produto
aAdd( aSB1, { "B1_ADMIN", 	oModel:GetValue('MG8_ADMIN'), 	Nil } ) //Descricao do Produto

//Informacoes da tabela SB0
aAdd( aSB0, {} )
aAdd( aSB0[1], { "B0_PRV1", 0, Nil } ) //Preco de venda 1

//Chamada Rotina automatica
MSExecAuto( {|X,Y,Z| LOJA110(X,Y,Z)}, aSB1, aSB0, 3 ) // nOpcao = 3 para incluir
//Verifica se houve erro durante a execucao
If lMsErroAuto
	DisarmTransaction()	
	//Mostra o erro ocorrido
	MostraErro()       
	lRet:= .F.
	RollBackSX8()
Else
	ConfirmSx8()	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj871VlTpºAutor  ³ Vendas Cliente     º Data ³  05/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacoes dos campos MG8_TPPREC e MG8_TPXPRD.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA871                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj871VlTp()

MBF->(dbSetOrder(1))
MBL->(dbSetOrder(1))

If ReadVar() == "M->MG8_TPPREC" //Validacoes Tipo Precificacao
	//Seta atrelamento quando preco por faixa
	If &(ReadVar()) == "1"
		M->MG8_TPXPRD := "1"
	EndIf
	
	//Verifica se existem atrelamentos para o servico
	If MBF->(dbSeek(xFilial("MBF") + M->MG8_PRDSB1))
		If MsgYesNo(STR0010) //#"Existem atrelamentos a esse serviço, deseja excluí-los?"															
			While MBF->(!EOF()) .AND. MBF->(MBF_FILIAL + MBF_PRDGAR) == xFilial("MBF") + M->MG8_PRDSB1  
				//Apaga atrelamento - Itens
				If MBL->(dbSeek(xFilial("MBL") + MBF->MBF_CODIGO))
					While MBL->(!EOF()) .AND. MBL->(MBL_FILIAL + MBL_CODIGO) == xFilial("MBL") + MBF->MBF_CODIGO  
						RecLock("MBL", .F.)
						MBL->(dbDelete())
						MBL->(MsUnLock())
				
						MBL->(dbSkip())
					EndDo
				EndIf
				
				//Apaga atrelamento - Cabecalho
				RecLock("MBF", .F.)
				MBF->(dbDelete())
				MBF->(MsUnLock())
				
				MBF->(dbSkip())
			EndDo											
		EndIf	
	EndIf
ElseIf ReadVar() == "M->MG8_TPXPRD" //Validacoes Tipo de Atrelamento
	//Verifica se Existe atrelamento
	If &(ReadVar()) == "2"
		//Verifica se existem atrelamentos para o servico
		If MBF->(dbSeek(xFilial("MBF") + M->MG8_PRDSB1))
			If MsgYesNo(STR0010) //#"Existem atrelamentos a esse serviço, deseja excluí-los?"																	
				While MBF->(!EOF()) .AND. MBF->(MBF_FILIAL + MBF_PRDGAR) == xFilial("MBF") + M->MG8_PRDSB1  
					//Apaga atrelamento - Itens
					If MBL->(dbSeek(xFilial("MBL") + MBF->MBF_CODIGO))
						While MBL->(!EOF()) .AND. MBL->(MBL_FILIAL + MBL_CODIGO) == xFilial("MBL") + MBF->MBF_CODIGO  
							RecLock("MBL", .F.)
							MBL->(dbDelete())
							MBL->(MsUnLock())
					
							MBL->(dbSkip())
						EndDo
					EndIf 
					
					//Apaga atrelamento - Cabecalho
					RecLock("MBF", .F.)
					MBF->(dbDelete())
					MBF->(MsUnLock())
				
					MBF->(dbSkip())
				EndDo										    
			EndIf	
		EndIf
	EndIf
EndIf

Return .T.

