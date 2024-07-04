#INCLUDE "LOJA602.CH"
#INCLUDE "PROTHEUS.Ch"   
#INCLUDE "FWMVCDEF.CH"
Static aItensDev := {}
                                                                                               
                                                                                           
//-------------------------------------------------------------------
/*LOJA602

Devolução de vendas                 

@author  Caio Murakami
@since   11/06/2013
@version 1.0      
*/
//-------------------------------------------------------------------
Function LOJA602()

Local cLabelOpcao   := STR0001  	// "Estornar"
Local cLock 		:= cUserName + cEstacao   //Controle de acesso da rotina
Local aLegend		:= Lj602Leg()
Local cFiltro     	:= ""             //Filtro da mBrowse
Local nPosL4Est     := SL4->(FieldPos("L4_ESTORN"))
Local nPosL1Sta     := SL1->(FieldPos("L1_STATUES"))
Local oBrowse		:= Nil
Local nCount		:= 0   
Local cFilLeg		:= "" 
Local cCorLeg		:= "" 
Local cSTRLeg		:= ""
Local lIsMDI 		:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),SetMDIChild(0)) //Verifica se acessou via SIGAMDI

Private aRotina		:= MenuDef()      //Opcoes de execucao da rotina

If nPosL4Est = 0 .OR. nPosL1Sta = 0
	MsgStop(STR0007) //"Para utilizacao da rotina de estorno, faz-se necessária a criacao dos campos, L4_ESTORN e L1_STATUES contidos na FNC 000000225902010"
	Return Nil
EndIf

If lIsMDI .AND. !LockByName( cLock )
	Return Nil
EndIf	

cFiltro := "(!Empty(L1_DOC) .OR. !Empty(L1_DOCPED)) .AND. ( !Empty(L1_SERIE) .OR. !Empty(L1_SERPED) ) .AND. L1_TIPO <> 'D' .AND. ( L1_TIPO == 'V' .OR. L1_TIPO == 'P') .AND. L1_STORC <> 'E'"

oBrowse := FWmBrowse():New()	
oBrowse:SetAlias( 'SL1' )   
//-- Adiciona legendas ao Browse
For nCount := 1 To Len(aLegend)
	cFilLeg := aLegend[nCount,1]  
	cCorLeg	:= aLegend[nCount,2]  
	cSTRLeg	:= aLegend[nCount,3]
	oBrowse:AddLegend( cFilLeg, cCorLeg , cSTRLeg ) 
Next nCount
oBrowse:SetFilterDefault(cFiltro)		 
oBrowse:SetDescription( cLabelOpcao ) 
oBrowse:Activate()	                    

Return Nil   


//-------------------------------------------------------------------
/*MenuDef

@author  Caio Murakami
@since   11/06/2013
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function MenuDef() 

Local cLabelOpcao   := STR0001  	// "Estornar"
Local aRotina  		:= {}           //Opcoes da MBrowse 

aAdd( aRotina, { cLabelOpcao, 'Lj602Estor', 0, 4, 0, NIL } )		//-- Estornar
aAdd( aRotina, { 'Troca' 	, 'Lj602ShowTroca', 0, 3,Nil} ) 			//-- Troca Bruno
aAdd( aRotina, { STR0003 	, 'VIEWDEF.LOJA602', 0, 2, 0, NIL } )	//-- Visualizar
aAdd( aRotina, { STR0002 	, 'AxPesqui', 0, 2, 0, NIL } ) 			//-- Pesquisar

Return aRotina


//-------------------------------------------------------------------
/*Lj602Leg

@author  Caio Murakami
@since   11/06/2013
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function Lj602Leg()
Local aLegend := {} 

Aadd(aLegend,{'!Empty(L1_DOC) .AND. !Empty(L1_SERIE) .AND. L1_STATUS <> "D" .AND. (FieldPos("L1_STATUES") = 0 .OR. Empty(L1_STATUES))',;
			"BR_VERMELHO",;
			STR0004	})	//"Vendas efetuadas" 
			
Aadd(aLegend,{'Empty(L1_DOC) .AND. L1_TIPO=="P"       .AND. !Empty(L1_DOCPED)   .AND. L1_STATUS<>"D" .AND. (FieldPos("L1_STATUES") = 0 .OR. Empty(L1_STATUES))',;
			"BR_AZUL",;
			STR0005	})//"Pedidos encerrados"  
			
Aadd(aLegend,{'L1_STATUS="D" .AND. (FieldPos("L1_STATUES") = 0 .OR. Empty(L1_STATUES)) ',;
			"BR_MARROM",;
			STR0006	}) 	  //"Devoluções pendentes"   
			
Aadd(aLegend,{'FieldPos("L1_STATUES")> 0 .AND. !Empty(L1_STATUES)',;
			"BPMSEDT1",;
			STR0008	    }) 	//"Vendas Estornadas"	

Return aLegend

//-------------------------------------------------------------------
/*ModelDef

@author  Caio Murakami
@since   11/06/2013
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStruSL1 	:= Nil 
Local oStruSL2	:= Nil
Local oStruSL4 	:= Nil 

oStruSL1 := FwFormStruct(1,"SL1",,)
oStruSL2 := FwFormStruct(1,"SL2",,)
oStruSL4 := FwFormStruct(1,"SL4",,)
                                                                         
oModel:= MpFormModel():New("LOJA602",,/*PosVld*/,/*bCommit*/,/*Cancel*/)  

//-- MdFieldSL1
oModel:AddFields("MdFieldSL1",,oStruSL1,/*bPreValid*/,/*bPosValid*/,/*Carga*/)     

//-- MdGridSL2
oModel:AddGrid("MdGridSL2","MdFieldSL1",oStruSL2,,/*bPos*/,/*bPre*/, /*bPosVal*/, /*BLoad*/ ) 

//-- MdGridSL4
oModel:AddGrid("MdGridSL4","MdFieldSL1",oStruSL4 ,,/*bPos*/,/*bPre*/, /*bPosVal*/, /*BLoad*/ )  

//-- Relacao model
oModel:SetRelation("MdGridSL2",{ {'L2_FILIAL','xFilial("SL2")'},{'L2_NUM','L1_NUM'} }, SL2->( IndexKey(1) ) )
oModel:SetRelation("MdGridSL4",{ {'L4_FILIAL','xFilial("SL4")'},{'L4_NUM','L1_NUM'} }, SL4->( IndexKey(1) ) )

//-- Estornar
oModel:SetDescription(STR0001) 								

//-- Nao permite alteraçao
oModel:GetModel("MdFieldSL1"):SetOnlyView(.T.)
oModel:GetModel("MdGridSL2"):SetOnlyView(.T.)
oModel:GetModel("MdGridSL4"):SetOnlyView(.T.)

Return ( oModel )


//-------------------------------------------------------------------
/* ViewDef
Definicao da Visao

@author  Caio Murakami
@since   11/06/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oStruSL1 := FwFormStruct(2,'SL1')
Local oStruSL2 := FwFormStruct(2,'SL2')
Local oStruSL4 := FwFormStruct(2,'SL4')
Local oModel   := FwLoadModel('LOJA602')            
Local oView   
 
oView := FwFormView():New()
oView:SetModel(oModel)  

oView:AddField('VwFieldSL1', oStruSL1 , "MdFieldSL1")    
oView:AddGrid( 'VwGridSL2', oStruSL2  , "MdGridSL2")
oView:AddGrid( 'VwGridSL4', oStruSL4 , "MdGridSL4")

oView:CreateHorizontalBox('CABECALHO',40) 
oView:CreateHorizontalBox('GRID_SL2',30)
oView:CreateHorizontalBox('GRID_SL4',30)

oView:SetOwnerView('VwFieldSL1','CABECALHO')
oView:SetOwnerView('VwGridSL2','GRID_SL2')
oView:SetOwnerView('VwGridSL4','GRID_SL4')

oView:EnableTitleView('VwGridSL2',STR0009) //-- Itens                    
oView:EnableTitleView('VwGridSL4',STR0010) //-- Pagamento            

Return oView   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj602Estor³ Autor ³ Fabiana Cristina      ³ Data ³22/11/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Execução do Estorno das Vendas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj140Exc(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj602Estor(cAlias, nReg, nOpcx )   

Local oEstorno 		:= nil     //Objeto de Estorno
Local cCliOri  		:= Space(TamSX3("A1_COD")[1])  //Cliente original da venda.
Local cLojaOri 		:= Space(TamSx3("A1_LOJA")[1]) //Loja original da venda.      
Local lCentPDV		:= Iif( FindFunction("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Central de PDV
Local lContinua		:= .T.  
Local lRet			:= .T.  
Local lContingency  := .T. //-- Contingencia para a chamada remota na retaguarda   
Local cMsgEstorno	:= ""
Local cNewCli  		:= Space(TamSX3("A1_COD")[1])  //-- Cliente para o estorno.
Local cNewLoja 		:= Space(TamSx3("A1_LOJA")[1]) //-- Loja para o estorno.  

Default cAlias 		:= ""
Default nReg 		:= 0
Default nOpcx 		:= 0 

If nOpcx == 1
	nOpcx := 4 
EndIf

oEstorno := ljClEstVen():New(LJGetStation("SERIE"),xNumCaixa(), LJGetStation("PDV"), dDataBase,0, .T. , {} ) 

oEstorno:GetOrcamento()  //Carrega as propriedades do Orcamento

cCliOri    := oEstorno:cOrc_Cli  
cLojaOri   := oEstorno:cOrc_Loja 
 
If oEstorno:ValidaOrcamento(nOpcx,lCentPDV)  //Valida se o orçamento pode ser estornado				
	If Lj600VlEst(nOpcx) //Valida a estação da retaguarda 			 				
 	   			 	
 		//-- Se a origem for remota ou for confirmado o orçamento
 		If oEstorno:ConfirmaOrcamento(nOpcx)   
 		    
 		    If Alltrim(oEstorno:cOrc_Cli) <> Alltrim(cCliOri) //Houve troca de cliente e loja. 
	 			cNewCli  := oEstorno:cOrc_Cli
	 			cNewLoja := oEstorno:cOrc_Loja
	 			oEstorno:cOrc_Cli  := cCliOri
	 			oEstorno:cOrc_Loja := cLojaOri
	 		EndIf 	    
 		    
 			//-- Se for central de PDV e opção "Estornar" executa estorno da Retaguarda
			If lCentPdv 
			    //-- Estorno via comunicacao por componente 			    
			    //-- "Aguarde..." ,"Efetuando comunicacao com retaguarda"
			    Processa({||lRet := oEstorno:RealizaRpcEstorno(SL1->L1_DOC,SL1->L1_SERIE,@lContinua,lContingency,@cMsgEstorno,cNewCli,cNewLoja)},STR0011,STR0012,.T.  )
			
				If !lRet .OR. !lContinua
				 	MsgInfo(cMsgEstorno)	
				EndIf    		
			EndIf 
				 		
		EndIf		
 	EndIf      
EndIf
     

Return lRet    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj602GrStE ³ Autor ³ Caio Murakami        ³ Data ³04/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para gravacao do status do Orcamento e pagamentos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do orcamento a ser marcado como estornado    ³±±
±±³          ³ ExpC2 = Status do estorno - "1" - Estorno total			   ³±±
±±³          ³   						 - "2" - Estorno parcial		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ ±±
±±³Sintaxe   ³ Lj600GrStE()		                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj602GrStE(cOrcamento,cStatuES)
Local aArea		:= GetArea()
Local aAreaSL1  := SL1->( GetArea() ) 
Local aAreaSL4	:= SL4->( GetArea() ) 
Local lRet 		:= .T. 

Default cOrcamento := "" 
Default cStatuES   := "1" 

//----------------------------------------
//-- cStatuES == "1" - Estorno total
//-- cStatuES == "2" - Estorno parcial
//----------------------------------------

SL1->(DbSetOrder(1)) //-- L1_FILIAL+L1_NUM
SL4->(DbSetOrder(1)) //-- L4_FILIAL+L4_NUM

//-- Marca pagamento como estornado
If SL4->( DbSeek(xFilial("SL4") + cOrcamento ) )
	RecLock("SL4", .F.)
	REPLACE L4_ESTORN  With "S"	
	MsUnLock()	
End

//-- Marca venda como estornada
If SL1->(DbSeek(xFilial("SL1") + cOrcamento))
   RecLock("SL1", .F.)  
   Replace L1_STATUES With cStatuES //Estorno da Venda
   MsUnlock()		
EndIf  

RestArea( aAreaSL4 ) 
RestArea( aAreaSL1 ) 
RestArea( aArea    ) 
Return lRet 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj602ShowTroca ³ Autor ³ Varejo           ³ Data ³10/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre a tela para troca de mercadoria						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³           		                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj602ShowTroca()

Local oTroca := LJEstFrmVenda():New(Nil,Nil,.T.)
oTroca:ShowTroca()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L602ChgCli ºAutor  ³ Vendas Cliente     º Data ³12/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao executada na mudanca do Cliente / Loja.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L602ChgCli( cField, cCodCli, cLojaCli, cNomeCliente)

Local lRet 	:= .T.
Local cCodFil	:= xFilial('SA1')

If cField == "CODCLI" //Chamada atraves do valid do campo Codigo do Cliente

	If !EMPTY(cCodCli) .AND. EMPTY(cLojaCli)
		cLojaCli := Posicione("SA1",1,FWxFilial("SA1",cCodFil)+cCodCli,"A1_LOJA")
		lRet := Lj602SeekCl(cCodFil, cCodCli, cLojaCli)
	else
		lRet := .T.
	EndIf
	
	cNomeCliente := Lj602VldCli(cCodCli,cLojaCli,cCodFil)
	
ElseIf cField == "CODLOJA" //Chamada atraves do valid do campo Loja do Cliente

	If !EMPTY(cLojaCli)
		lRet := Lj602SeekCl(cCodFil, cCodCli, cLojaCli)
	else
		lRet := .T.
	EndIf
	
	cNomeCliente := Lj602VldCli(cCodCli,cLojaCli,cCodFil)
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj602SeekCl ºAutor  ³ Vendas Cliente     º Data ³14/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o cliente existe.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo da Filial                                    º±±
±±º          ³ExpC2 - Codigo do Cliente                                   º±±
±±º          ³ExpC3 - Loja do Cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj602SeekCl(cFilCli, cCodCli, cCodLoja)
Local lRet := .F.

//cFilCli := FWxFilial("SA1",cFilCli)

DbSelectArea("SA1")
If MsSeek(cFilCli+cCodCli+cCodLoja)
	lRet := .T.
Else
	HELP(" ",1,"REGNOIS")
Endif

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj602VldCli ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Devolve o nome do cliente baseado no codigo que foi        º±±
±±º          ³ digitado.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do Cliente                                   º±±
±±º          ³ExpC2 - Loja do Cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj602VldCli(cCodCli, cCodLoja, cFilCli)
Local cDesc := CRIAVAR("A1_NOME",.F.)                //Nome do cliente
Local aArea	:= GetArea()                             //Area atual para restaurar no final da funcao

//cFilCli := FWxFilial("SA1",cFilCli)

If !Empty(cCodCli) .AND. !Empty(cCodLoja)
	DbSelectArea("SA1")
	If DbSeek(cFilCli+cCodCli+cCodLoja)
		cDesc := SA1->A1_NOME
	Endif	
Endif

RestArea(aArea)

Return(cDesc) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj602Devol ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a devolucao chamando o Mata103                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1                                                       º±±
±±º          ³ExpC2                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj602Devol(cCodCli, cLojCli, aItensTab , cCodVen)

Local aItens	:= Lj602PrepIt(aItensTab)//Array com os itens
Local aCab		:= {}				//Cabecalho da nota
Local cSerie	:= Padr(SuperGetMv("MV_LJNFTRO"),3)//Serie da nota
Local cNumDoc	:= ''				//Numero do documento
Local lRet		:= .T.				//Retorno da funcao
Local cRetExec	:= ''				//Retorno da MSExecAuto

PRIVATE lMsErroAuto := .F.
Default cCodVen := ""
CoNout('Entrou na rotina -> Lj602Devol')
If Len(aItens) > 1 .AND. aItens[1]

	aItens := aItens[2]	
	If Lj720Nota(@cSerie, @cNumDoc)		
		aCab := Lj602Cab(		cSerie		, cNumDoc , cCodCli, cLojCli ,;
								cCodVen	)
		If Len(aCab) > 0		
			CoNout('Iniciando a execucao do MSExecAuto(MATA103) -> Lj602Devol')
			MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCab, aItens, 3)
			If lMsErroAuto
				CoNout('Erro no MSExecAuto(MATA103) -> Lj602Devol')
				cRetExec := MostraErro()
				CoNout('MostraErro(MATA103) - ' + cRetExec)
				lRet := .F.
			Else
				CoNout('Devolucao efetuada com sucesso -> MATA103')
			EndIf
		Else
			CoNout('Erro ao gerar o cabecalho da nota Lj602Cab -> Lj602Devol')
			cRetExec := "Erro ao gerar o cabecalho da nota Lj602Cab -> Lj602Devol"
			lRet := .F.
		EndIf		
	Else
		CoNout('Erro ao gerar Serie e Num. Documento Lj720Nota -> Lj602Devol')
		cRetExec := "Erro ao gerar Serie e Num. Documento Lj720Nota -> Lj602Devol"
		lRet := .F.
	Endif 
Else
	CoNout('Falha ao executar a rotina Lj602PrepIt -> Lj602Devol')
	cRetExec := "Falha ao executar a rotina Lj602PrepIt -> Lj602Devol"
	lRet := .F.
EndIf

Return {lRet, cRetExec}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj602PrepIt ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara o array com os itens para realizar a devolucao     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj602PrepIt(aItensTab)

Local lDevolucao 	:= .T.	//Variavel de retorno
Local aLinha		:= {} 	//Itens da TRB
Local aItens		:= {} 	//Variavel de retorno
Local cTesDev   	:= SuperGetMv("MV_TESTROC",.F.)	// TES padrao para troca de mercadorias
Local nX			:= 0	//Variavel de loop

Default aItensTab := {}

If Len(aItensTab) > 0
	aItensDev := aItensTab
Else
	aItensDev := Lj7011GetVar()
EndIf

CoNout('Entrou na funcao -> Lj602PrepIt')
For nX := 1 To Len(aItensDev)
	
	If !(aItensDev[nX][10])
	
		CoNout('Encontrou informacao na TRB -> Lj602PrepIt')
			
		DbSelectArea("SF4")
		SF4->( DbSetOrder(1) )
		If 	SF4->( DbSeek(xFilial("SF4")+aItensDev[nX][9]) )
			
	
			If !Empty(SF4->F4_TESDV)
	
				cTesDev := SF4->F4_TESDV
	
				If !(SF4->(DbSeek(xFilial("SF4")+SF4->F4_TESDV)))
					CoNout('Variavel lDevolucao retornou .F. (1) -> Lj602PrepIt')
					lDevolucao := .F.
					Exit
				EndIf
	
	
			ElseIf !Empty(cTesDev)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona no TES                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SF4")
				DbSetOrder(1)
				If !DbSeek(xFilial("SF4") + cTesDev)
					CoNout('Variavel lDevolucao retornou .F. (2) -> Lj602PrepIt')
					lDevolucao := .F.
				Endif	
	
			Else
				CoNout('Variavel lDevolucao retornou .F. (3) -> Lj602PrepIt')
				lDevolucao := .F.
				Exit			
	
			Endif
	
		ElseIf !Empty(cTesDev)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona no TES                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSetOrder(1)
			If !DbSeek(xFilial("SF4") + cTesDev)
				CoNout('Variavel lDevolucao retornou .F. (4) -> Lj602PrepIt')
				lDevolucao := .F.
			Endif
	
		Else
			CoNout('Variavel lDevolucao retornou .F. (5) -> Lj602PrepIt')
			lDevolucao := .F.
			Exit
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a linha de devolucao que sera gerado o SD1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aLinha := {}				
		AAdd( aLinha, { "D1_COD"    	, aItensDev[nX][3] 		, Nil } )
		AAdd( aLinha, { "D1_QUANT"  	, Val(aItensDev[nX][5]) 	, Nil } )					
		AAdd( aLinha, { "D1_VUNIT"  	, aItensDev[nX][6] 		, Nil } )					
		AAdd( aLinha, { "D1_TOTAL"  	, aItensDev[nX][7] 		, Nil } )
		AAdd( aLinha, { "D1_TES" 	, cTesDev 					, Nil } )
		AAdd( aLinha, { "D1_UM"     	, aItensDev[nX][8] 		, Nil } )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao existe nota fiscal de saida (origem) pois a troca eh de outra loja.    ³
		//³Para gerar o documento de entrada eh necessario passar as duas informacoes.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aLinha, { "D1_NFORI"  	, "XXXXXX"          , Nil } )
		AAdd( aLinha, { "D1_SERIORI"	, "XX"         		, Nil } )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona o item no array principal que sera levado para o Documento de entrada   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aItens, aLinha)
		
	EndIf

Next nX

Return {lDevolucao, aItens}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj602Cab ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara o array com o cabecalho da nota de devolucao     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj602Cab(	cSerie	,cNumDoc, cCodCli, cLojCli ,;
							  	cCodVen)

Local aCab 		:= {} //Array de retorno
Local cTpEspecie 	:= ''	//Tipo da especie 

Default cCodVen := ""

CoNout('Entrou na funcao -> Lj602Cab')

cTpEspecie := Lj602Espec(cSerie)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCab, { "F1_DOC"    , cNumDoc						, Nil } )	// Numero da NF : Obrigatorio
AAdd( aCab, { "F1_SERIE"  , cSerie						, Nil } )	// Serie da NF  : Obrigatorio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho de acordo com o tipo da devolucao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCab, { "F1_TIPO"   , 'D'							, Nil } )	// Tipo da NF   		: Obrigatorio
AAdd( aCab, { "F1_FORNECE", cCodCli   					, Nil } )	// Codigo do Fornecedor : Obrigatorio
AAdd( aCab, { "F1_LOJA"   , cLojCli    					, Nil } )	// Loja do Fornecedor   : Obrigatorio
AAdd( aCab, { "F1_EMISSAO", dDataBase					, Nil } )	// Emissao da NF        : Obrigatorio
AAdd( aCab, { "F1_FORMUL" , 'S'	                    	, Nil } )  // Formulario Proprio 
AAdd( aCab, { "F1_ESPECIE", cTpEspecie               	, Nil } )  	// Especie
AAdd( aCab, { "F1_COND"   , SuperGetMv("MV_CONDPAD")	, Nil } )					// Condicao do Fornecedor

If (SF1->(FieldPos("F1_VEND1")) > 0)
	AAdd( aCab, { "F1_VEND1", cCodVen   					, Nil } )	// Codigo do Vendedor
EndIf
Return aCab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj602Dev ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama a rotina para realizar a devolucao                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj602Dev(cCodCli, cLojCli , cCodVen)

Local aRet := {} //Variavel de retorno

Default cCodVen := ""

MsgRun(STR0013,STR0014,{|| aRet := Lj602Devol(cCodCli, cLojCli,,cCodVen)}) //"Aguarde, gerando nota de devolução..." # "Atenção"

If aRet[1]
	MsgInfo(STR0015) //"Nota de devolução gerada com sucesso!"
Else
	Alert(aRet[2])
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | Lj602Espec ³ Autor ³ Varejo     	        ³ Data ³ 18/04/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a especie cadastrada para a serie, baseada no 		 ³±±
±±³			 | parametro MV_ESPECIE.										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj602Espec(cSerieDoc)											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - serie utilizada na devolucao							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpC1 = especie cadastrada para a serie. Se a especie nao	 ³±±
±±³			 | existir, retornamos 'NF'					     				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA602                                    						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj602Espec(cSerieDoc)

Local cMvEspecie	:= SuperGetMV("MV_ESPECIE",,"")	//pares de SERIE=ESPECIE
LOcal cSerieEspe	:= "" 								//par de SERIE=ESPECIE 
Local cSerie		:= ""								//serie do par
Local cEspecie		:= ""								//retorno do funcao - especie cadastrada para a serie
Local nI			:= 0								//contador
Local nPosSign		:= 0								//posicao do sinal '='

Default cSerieDoc	:= ""

cSerieDoc := AllTrim(cSerieDoc)
CoNout('Entrou na funcao -> Lj602Espec')
If Empty(cMvEspecie) .OR. cPaisLoc <> "BRA"
	//inializa F1_ESPECIE com o conteudo do inicializador padrao
	CoNout('Entrou no If da funcao -> Lj602Espec')
	cEspecie  := CriaVar("F1_ESPECIE",.T.)	
Else
	CoNout('Entrou no Else da funcao -> Lj602Espec')
	//substituimos ';' por quebra de linha
	cMvEspecie := StrTran( cMvEspecie, ";", Chr(13) + Chr(10) )

	//verificamos cada par 'serie = especie'
	For nI := 1 TO MLCount( cMvEspecie )

		//retorna o conteudo de cada linha		
		cSerieEspe := AllTrim( StrTran(MemoLine(cMvEspecie,, nI), CHR(13), CHR(10)) )

		//retorna a posicao do '='
		nPosSign := At( "=", cSerieEspe )

		If nPosSign > 0
			//retorna a serie do parametro (antes '=')
			cSerie := SubStr( cSerieEspe, 1, (nPosSign-1) )

			//se a serie do documento for igual a serie do parametro
			If cSerieDoc  == cSerie
				//retorna a especie (apos '=')
				cEspecie := SubStr( cSerieEspe, (nPosSign+1) )
				cEspecie := PadR( cEspecie, TamSX3("X5_CHAVE")[1] )
				
				//verifica se a especie eh valida
				If Lj602EspOk(cEspecie)
					Exit
				Else
					cEspecie := ""
				EndIf
			EndIf
		EndIf
	Next
EndIf

If Empty(cEspecie)
   cEspecie := PadR( "NF", TamSX3("F1_ESPECIE")[1] )
EndIf

Return cEspecie

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | Lj602EspOk ³ Autor ³ Varejo     	        ³ Data ³ 18/04/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a especie e valida	      							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj602EspOk(cTpEspecie)										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - especie a ser validada								 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpL1 = valida se a especie eh validada						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA602        														 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj602EspOk(cTpEspecie)

Local aArea := GetArea()		//armazena a area
Local lRet	:= .T.				//valida se a especie eh valida

Default cTpEspecie	:= ""

If !Empty(cTpEspecie)
	DbSelectArea("SX5")
	If !SX5->( DbSeek(xFilial("SX5") + "42" + cTpEspecie) )
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet
