#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "DBTREE.CH"
#INCLUDE	"LOJA901D.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao      ³ LjTracker    ³ Autor ³ SIGALOJA         ³ Data ³ 02/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao   ³ Consulta Tracker                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ LjTracker()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ LjTracker                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function LJECTracker(cRotina)

Local aArea      := GetArea() //WorkArea Atual
Local oDlg       := Nil//Objeto da Dialog principal
Local oTree      := Nil//Objeto do Tree da tela principal
Local oPanel     := Nil //Objeto do panel
Local oScrollBox := Nil//componente TGrid 
Local oBtn1  	   := Nil //Botaão que confirma a geracao da consulta 
Local oBtn2  	   := Nil //Botao que cancela a geração da consulta
Local oPedEcom   := Nil //Objeto MSGET de Orcamento
Local cPedECom   := Space(TamSx3("C5_PEDECOM")[1]) //Pedido E-Commerce
Local lGeraTree  := .F. //Confirma a geração da consulta

DEFAULT cRotina := ""

//Montando a tela de filtro
DEFINE MSDIALOG oDlg FROM 000, 000 TO 150, 400 PIXEL TITLE OemToAnsi(STR0001) //"Filtro para geração da Consulta Tracker"

oScrollBox := TScrollBox():new(oDlg, 007, 007, 095, 230, .T., .T., .T.)
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT			

@ 012, 003 SAY OemToAnsi(STR0002) SIZE 080, 010 OF oScrollBox PIXEL COLOR CLR_HBLUE //"Pedido eCommerce:"
@ 010, 065 MSGET oPedEcom VAR cPedECom SIZE 040, 005  WHEN .T. OF oScrollBox PIXEL

DEFINE SBUTTON oBtn1 FROM 50, 135 TYPE 1 ENABLE OF oDlg ACTION (lGeraTree := .T., oDlg:End())	 
DEFINE SBUTTON oBtn2 FROM 50, 165 TYPE 2 ENABLE OF oDlg ACTION  oDlg:End()      

ACTIVATE MSDIALOG oDlg CENTERED

If lGeraTree
	Processa({|lEnd| LjGeraTrack(oTree, cPedECom, cRotina)}, STR0003, STR0004) 	 //"Aguarde..."##"Gerando a Consulta Tracker"  	       		
EndIf

//Restaura a entrada da rotina                                    
RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LjGeraTrac³ Autor ³ SIGALOJA             ³ Data ³ 02/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega Consulta Tracker                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjGeraTracker()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LjTracker                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LjGeraTrack(oTree, cPedECom, cRotina)   

Local cWhere 		:= "" //Condicional da query
Local cParcela 	:= "" //Parcelas Financeiro
Local cCargo     	:= "" //Filtro do objeto Tree
Local cName      	:= "" //Descricao da Filial
Local cAliasTmp  	:= GetNextAlias() //Alias a consulta
Local nI	    	:= 0 //Contador
Local nBtn       	:= 0 //Botao
Local nSeqSC5		:= 0 //Sequencia do objeto SC5
Local nSeqSL1		:= 0 //Sequencia do objeto SL1
Local nSeqSE1		:= 0 //Sequencia do objeto SE1
Local aFiltro		:= {} //Filtro para detalhe
Local aMsSize		:= MsAdvSize() //Array de Dimensões
Local aObjects  	:= {{100, 100, .T., .T., .T.}} //Array de Objetos
Local aInfo		:= {aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4}  //Array de Informações
Local aPosObj		:= MsObjSize( aInfo, aObjects, .T. , .T. ) //Array de Posições dos objetos
Local aVendas  	:= {} //Array que armazena vendas
Local oDlg     	:= Nil//Objeto da Dialog principal
Local nTamPref   := SE1->(TamSX3("E1_PREFIXO")[1]) //Tamanho do Prefixo do título
Local nTamNum		:= SE1->(TamSX3("E1_NUM")[1]) //Tamanho do número do Título
Local cFilSE1		:= xFilial("SE1") //Filial SE1
Local lResEst := !SuperGetMv("MV_RESAUT") .AND. SuperGetMv("MV_LJECOM0",.F., .F.) //consulta de reserva?
Local cAliasC6  	:= GetNextAlias() //Alias consulta SC6
Local aFilLoc  := IIF( ExistFunc("LOJX904Loc") , LOJX904Loc(), { {cFilAnt, {}} }) //Locais de Estoque EC
Local lMultEst :=  Len(aFilLoc) > 1 .OR. ( Len(aFilLoc) = 1 .AND. Len(aFilLoc[1]) > 1 .AND.  Len(aFilLoc[01, 02]) > 0)  //MultiEstoque habilitado
Local cFilMGU		:= cFilAnt
Local cFilSC5		:= ""
Local lMGUFilPed	:= MGU->(ColumnPos("MGU_FILPED")) > 0
Local cAliasTmp2	:= ""
Local cPedEC		:= PadL(AllTrim(cPedEcom),MGU->(TamSx3("MGU_PEDECO")[1])) 
 

If lMultEst .AND. lMGUFilPed
	cAliasTmp2 := GetNextAlias()
	//Localiza a Filial para qual foi gerado o Pedido de Venda
	BeginSql alias cAliasTmp2
		SELECT 
			MGU.MGU_FILPED
		FROM %table:MGU% MGU
		WHERE
			MGU.MGU_PEDECO = %exp:cPedEC% AND
			MGU.%NotDel% AND
			MGU.MGU_FILIAL  = %xFilial:MGU%  AND
			MGU.MGU_CONFIR = '1'
			ORDER BY MGU_FILPED				
		
	EndSql	
	(cAliasTmp2)->(DbGoTop())
	If (cAliasTmp2)->(!Eof()) .AND. !Empty((cAliasTmp2)->MGU_FILPED)
		cFilMGU := (cAliasTmp2)->MGU_FILPED
	EndIf
	(cAliasTmp2)->(DbCloseArea())
	cFilSE1		:= xFilial("SE1", cFilMGU) //Filial SE1
EndIf

cFilSC5 := xFilial("SC5", cFilMGU)


cPedECom := Padr(cPedECom, TamSx3("C5_PEDECOM")[1])

//Condicional para a query		
cWhere := "%"
cWhere += " C5_FILIAL = '" + cFilSC5 + "'"
cWhere += " AND C5_PEDECOM = '" + cPedECom + "'"
cWhere += " AND SC5.D_E_L_E_T_ <> '*'" 
cWhere += " AND L1_FILIAL = '" + xFilial("SL1", cFilMGU) + "'" 	
cWhere += " AND L1_ECFLAG = '1'" 	   			
cWhere += " AND SL1.D_E_L_E_T_ <> '*'"
cWhere += "%"              											
			                                          
//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		C5_FILIAL, C5_NUM, C5_PEDECOM, L1_FILIAL, L1_NUM,
		L1_DOCPED, L1_SERPED 
	FROM %table:SC5% SC5	
	INNER JOIN %table:SL1% SL1 
	ON (  SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC 	 )						
	WHERE %exp:cWhere% 			
EndSql	

If lResEst
	BeginSql alias cAliasC6
		SELECT 
			C6_ITEM, C6_RESERVA, C6_PRODUTO, C6_QTDVEN, C6_DESCRI
		FROM %table:SC5% SC5	
		INNER JOIN %table:SC6% SC6 
		ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM								
		WHERE  
		C6_RESERVA <> '' AND
		C5_PEDECOM =  %Exp:cPedECom% AND
		SC6.%NotDel% AND
		SC5.%NotDel% AND
		C5_FILIAL  = %exp:cFilSC5% 
		ORDER BY C6_ITEM				
	EndSql		
	
	(cAliasC6)->(dbGoTop())
EndIf
	
//Contador da Regua
(cAliasTmp)->(ProcRegua(RecCount()))
	
//Posiciona no inicio do arquivo
(cAliasTmp)->(dbGoTop())



//Monta consulta tracker	
If (cAliasTmp)->(!Eof()) .And. !Empty(cPedECom)
	DEFINE MSDIALOG oDlg  TITLE OemToAnsi(STR0005) FROM aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel //"Pedido eCommerce"
	oTree := DbTree():New(15, 3, 197, 315, oDlg,,, .T.)
	oTree:lShowHint := .F. //Desabilita o Hint
	oTree:Align := CONTROL_ALIGN_ALLCLIENT 
	
	//Descricao da Filial
	cName := LjTrackFil(SC5->C5_FILIAL, "SC5")
	
	//Contador SC5
	nSeqSC5 := 1
	
	While (cAliasTmp)->(!Eof())	
		IncProc()  						   			 			    									
																				        								 							
		//Contador SL1
		nSeqSL1 ++
								
		//Filtro SL1
		cCargo := "SL1" + cValToChar(nSeqSL1)
				
		aAdd(aFiltro, {cCargo,; 								  
						 (cAliasTmp)->L1_FILIAL + (cAliasTmp)->L1_NUM})								 				
																
		DBADDTREE oTree PROMPT PADR(STR0006 + AllTrim((cAliasTmp)->L1_DOCPED) + " - " + (cAliasTmp)->L1_SERPED, 100) OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cCargo 	//"Venda:"			   				
		DBADDITEM oTree PROMPT STR0007 + (cAliasTmp)->L1_FILIAL + " - " + cName RESOURCE "EDIT" CARGO cCargo		//"Filial:"	
		DBADDITEM oTree PROMPT STR0008 + (cAliasTmp)->L1_NUM RESOURCE "EDIT" CARGO cCargo //"Orcamento:"				 																																							 																					 													 
									
		//Pedido de Venda																																																															
		cCargo := "SC5" + cValToChar(nSeqSC5)
								
		//Filtro SC5
		aAdd(aFiltro, {cCargo,; 								  
						 (cAliasTmp)->C5_FILIAL + (cAliasTmp)->C5_NUM})								
				
		DBADDTREE oTree PROMPT OemToAnsi(STR0009) + (cAliasTmp)->C5_NUM OPENED RESOURCE "FOLDER7", "FOLDER8" CARGO cCargo 	//"Pedido de Venda:"			
		If !lResEst .OR. (cAliasC6)->(Eof())
			DBADDITEM oTree PROMPT STR0010 + (cAliasTmp)->C5_NUM RESOURCE "Checked" CARGO cCargo //"Pedido:"
		Else
			DBADDTREE oTree PROMPT OemToAnsi(STR0010) + (cAliasTmp)->C5_NUM OPENED RESOURCE "FOLDER12", "FOLDER13" CARGO cCargo //"Pedido:" 				
			
			Do While !(cAliasC6)->(Eof())
			
				DBADDITEM oTree PROMPT STR0011 + RTrim((cAliasC6)->C6_RESERVA)  + STR0012 + RTrim((cAliasC6)->C6_PRODUTO) + " - " + RTrim((cAliasC6)->C6_DESCRI)+ STR0013 + RTrim(	cValtoChar((cAliasC6)->C6_QTDVEN))   RESOURCE "BR_VERDE.PNG" CARGO cCargo 	//"Reserva:"##" Produto: "##" Qtde: "										            																		       														
				(cAliasC6)->(DbSkip(1))
			EndDo
			
			DBENDTREE oTree
		
		Endif
		DBADDITEM oTree PROMPT STR0002 + ":"  + (cAliasTmp)->C5_PEDECOM RESOURCE "Checked" CARGO cCargo // 	"Pedido eCommerce"										            																		       														
		DBENDTREE oTree
																										      						                                               																						
		//Contas a Receber			    																    												
		SE1->(dbSetOrder(1))
				
		If SE1->(dbSeek(cFilSE1 + Padr((cAliasTmp)->L1_SERPED, nTamPref) + Padr((cAliasTmp)->L1_DOCPED, nTamNum)))										
			While SE1->(!EOF()) .And. SE1->E1_FILIAL = cFilSE1 .And.; 
				SE1->E1_PREFIXO == Padr((cAliasTmp)->L1_SERPED, nTamPref) .And.; 
				SE1->E1_NUM ==  Padr((cAliasTmp)->L1_DOCPED, nTamNum)																		
						
				//Contador SE1
				nSeqSE1 ++
						
				cCargo := "SE1" + cValToChar(nSeqSE1)
						
				//Filtro SE1
				aAdd(aFiltro, {cCargo,;								 		  
						 		 SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA})
												
				cParcela := IIF(!Empty(SE1->E1_PARCELA), " - " + SE1->E1_PARCELA, "")
						
				DBADDTREE oTree PROMPT OemToAnsi(STR0014) + SE1->E1_PREFIXO + " - " + AllTrim(SE1->E1_NUM) + cParcela OPEN RESOURCE "FOLDER10", "FOLDER11" CARGO cCargo  //"Contas a Receber:"								
				DBADDITEM oTree PROMPT STR0015 + SE1->E1_PREFIXO RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Prefixo: "
				DBADDITEM oTree PROMPT STR0016 + SE1->E1_NUM RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Codigo: "					
				DBADDITEM oTree PROMPT STR0017 + SE1->E1_PARCELA RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Parcela: "
				DBADDITEM oTree PROMPT STR0018 + CValToChar(SE1->E1_VALOR) RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Valor:"								
				DBENDTREE oTree
					
				SE1->(dbSkip())
			EndDo								
		EndIf
				
		//Encerra Venda												
		DBENDTREE oTree 
							    
		(cAliasTmp)->(DbSkip())			
	EndDo	


	If cRotina == "LOJA901D"
   		aButtons := { {"BUDGETY", {|| Lj901DCnPg(oTree, aFiltro, cPedECom)},OemToAnsi(STR0037)}} //"Confirmar Pagamento"
   	Else  		
		aButtons := {{"BMPVISUAL", {|| LjTrackDet(oTree, aFiltro, cFilMGU)},OemToAnsi(STR0019)},;   //"Detalhe"
				  {"PESQUISA", {|| LjTrackPesq(@oTree, nBtn := 1)}, OemToAnsi(STR0020), OemtoAnsi(STR0021)}}  //"Pesquisa texto genérico"##"Pesquisa"
	EndIf
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, { ||oDlg:End()},, aButtons) CENTERED			
Else
	MsgInfo(STR0022) //"A Consulta não encontrou informações para exibir, verifique os parametros."				
EndIf
	
//Fecha Arquivos temporarios
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())
EndIf

If (Select(cAliasC6) > 0)
	(cAliasC6)->(dbCloseArea())
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LjTrackFil   ³ Autor ³ SIGALOJA          ³ Data ³ 02/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o Nome das filiais.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjTrackFil                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LjTracker                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LjTrackFil(cCod,cAliasTab)

Local cNome   := "" //Nome da Empresa
Local aModoComp := {{ 3, "FwFilName"}, {2, "FWUnitName"}, {1,"FWCompanyName"}} //Funções do Nome
Local cFunction := "FWGrpName"
Local nC := 0  //Contador
Local bBloco := {}  //Bloco de Codigo 

Default cAliasTab := "SC5"

For nC := 1 to Len(aModoComp)

	If FWModeAccess(cAliasTab, aModoComp[nC, 01]) = "E"
		cFunction := aModoComp[nC, 02]
		Exit
	EndIf
Next


bBloco := &("{ |_Emp, _Filial| " + cFunction +"(_Emp, _Filial) }")
cNome := EVAL(bBloco, cEmpAnt, cCod )




Return cNome

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LjTrackPesq   ³ Autor ³ SIGALOJA                   ³ Data ³ 02/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa Texto                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjTrackPesq(oTree)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1-Objeto do Tree                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LjTracker.PRW                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LjTrackPesq(oTree, nBtn)

Local cChaveTree 	:= "" //Chave de Arvore
Local cChaveSeq 	:= "0000" //Chave da Sequencia
Local nOpcao 		:= 0 //Opção
Local lAchou 		:= .F. //Achou
Local oDlgPesq   	:= Nil //Dialogo
Local oBtn1		:= Nil //Botão 1
Local oBtn2		:= Nil //Botão 2

If nBtn == 1 //"Pesquisa Texto"
	lEditPTree := .T.		
Else         //"Proxima Pesquisa"
	lEditPTree := .F.
EndIf

If lEditPTree
	DEFINE MSDIALOG oDlgPesq FROM 0,0 TO 080,634 PIXEL TITLE OemToAnsi(STR0023) //"Pesquisa Texto"

    cChaveTree := Padr(cChaveTree,100)
	@ 010,05 MSGET cChaveTree SIZE 310,08 OF oDlgPesq PIXEL

	DEFINE SBUTTON oBtn1 FROM 25,005 TYPE 1 PIXEL ENABLE OF oDlgPesq ACTION (nOpcao:=1, oDlgPesq:End())
	DEFINE SBUTTON oBtn2 FROM 25,035 TYPE 2 PIXEL ENABLE OF oDlgPesq ACTION (nOpcao:=2, oDlgPesq:End())

	ACTIVATE MSDIALOG oDlgPesq CENTERED
EndIf

If (nOpcao == 1 .Or. nOpcao == 0) .And. !Empty(AllTrim(cChaveTree))
	cChaveTree := UPPER(AllTrim(cChaveTree))
	dbSelectArea(oTree:cArqTree)
	dbGoTop()	
	
	While !Eof()
		If cChaveTree $ UPPER(T_PROMPT)
			If (nOpcao == 0 .And. T_CARGO > cChaveSeq) .Or. nOpcao == 1
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				// Colocado duas vezes para posicionar na linha onde esta o texto
				// porque se buscar uma vez posiciona no Item pai.                
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				cChaveSeq := T_CARGO
				lAchou := .T.
				lEditPTree := .F.
				Exit
			EndIf
		EndIf
		
		dbSkip()
	Enddo
	
	If !lAchou
		If cChaveSeq <> "0000"
			lEditPTree := .T.
		EndIf
		
		MsgAlert(OemToAnsi(STR0024 + " '" + cChaveTree + "' " + STR0025))//"Texto"##"não encontrado"
	Else
		lEditPTree := .F.
		cChaveTree := ""
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LjTrackDet³ Autor ³ SIGALOJA                        ³ Data ³ 02/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza detalhes do Item posicionado.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ "LjTrackDet()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1-Objeto do Tree                                                 ³±±
±±³          ³ ExpO2-Filtro de Detalhes                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LjTracker.PRW                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LjTrackDet(oTree, aFiltro, cFilMGU)

Local cCargo  := oTree:GetCargo() //No
Local nPos		:= 0 //Posicao

Private Altera   	:= .F.
Private cCadastro	:= ""
Private aRotina 	:= {} //Variavel para Visualizacao do Pedido de Venda e Orcamento
Private lAutoExec	:= .F.

Do Case
	//Orcamento do Venda Assistida
	Case Left(cCargo, 3) == "SL1"		 				 	
		nPos := aScan(aFiltro, {|x| x[1] == cCargo})
		
		If nPos > 0	.And.  cFilMGU == cFilAnt  	  //Chave está contida na filial atual 							
			SL1->(dbSetOrder(1)) //L1_FILIAL+L1_NUM		
			SL1->(dbSeek(aFiltro[nPos][2]))
						
			aRotina :=	{{STR0026  	, "AxPesqui" 	, 0 , 1 , , .F. },; //"Pesquisar" 
						{ STR0027	, "LJ7Venda" 	, 0 , 2 , , .T. },; //"Visualização"
						{ STR0028	, "Lj7Venda" 	, 0 , 3 , , .T. },; ///"Atendimento"
						{ STR0029, "Lj7Venda" 	, 0 , 4 , , .T. },; //"Finaliza Venda"
						{ STR0030		, "LJ7Orcam" 	, 0 , 4 , , .T. },; //"Orçamento"
						{ STR0031		, "Lj7Legenda", 0 , 8 , , .T. }} //"Legenda"
					
			cCadastro 	:= STR0032 //"Venda Assistida"
			MsgRun(STR0033, STR0034, {|| LJ7Venda("SL1", SL1->(Recno()), 2, Nil, Nil, Nil, "")})	//"Carregando.."##"Aguarde..."
		Else
			MsgAlert(STR0040 +" [" + cFilAnt + "]") //"Somente é possível a visualização de registros da filial corrente" 
		EndIf										
	//Pedido de Venda do Faturamento
	Case Left(cCargo, 3) == "SC5"	    	    										
		nPos := aScan(aFiltro, {|x| x[1] == cCargo})
		
		If nPos > 0  .And. cFilMGU == cFilAnt
			SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM					
			SC5->(dbSeek(aFiltro[nPos][2]))
				
			aRotina :=	StaticCall(MATA410, MenuDef)
			cCadastro 	:= STR0035 //"Pedido de Vendas"						
			MsgRun(STR0033, STR0034, {|| A410Visual("SC5", SC5->(RecNo()), 2)}) //"Carregando.."##"Aguarde..."
		Else
			MsgAlert(STR0040 +" [" + cFilAnt + "]") //"Somente é possível a visualização de registros da filial corrente"
		EndIf	
	//Contas a receber
	Case Left(cCargo, 3) == "SE1"		    	   				
		nPos := aScan(aFiltro, {|x| x[1] == cCargo})
		
		If nPos > 0  .And.  cFilMGU == cFilAnt 
			SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			SE1->(dbSeek(aFiltro[nPos][2]))
			
			aRotina :=	StaticCall(FINA040, MenuDef)
			cCadastro 	:= STR0036		
			MsgRun(STR0033, STR0034, {|| Fa280Visual("SE1", SE1->(Recno()), 1)})  //"Carregando.."##"Aguarde..."
		Else
			MsgAlert(STR0040 +" [" + cFilAnt + "]") //"Somente é possível a visualização de registros da filial corrente"		
		EndIf	
EndCase
	
Return Nil 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj901DCnPg³ Autor ³ SIGALOJA                        ³ Data ³ 02/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma o pagamento do pedido, liberando para faturar.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ "Lj901DCnPg()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1-Objeto do Tree                                                 ³±±
±±³          ³ ExpO2-Filtro de Detalhes                                             ³±±
±±³          ³ ExpC1-Pedido e-commerce                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LjTracker.PRW                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Lj901DCnPg(oTree, aFiltro, cPedECom)

Local cCargo  	:= oTree:GetCargo() //Node
Local nPos			:= 0 //Posicao
Local aArea 		:= GetArea() //WorkArea
Local aAreaSL4 	:= SL4->(GetArea()) //WorkArea SL4
Local aAreaSAE 	:= SAE->(GetArea()) //WorkArea SAE
Local nTamAECod 	:= SAE->(TamSX3("AE_COD"))[1] //Codigo da Administradora Financeira
Local lECLibBl 	:= SAE->(ColumnPos("AE_ECCNFPG")) > 0 //Existe o campo que indica a confirmação do pagamento?
Local cFilMGM		:= xFilial("MGM") //Filial MGM 
Local cSeq 		:= MGM->(Replicate("Z", TamSx3("MGM_SEQ")[1])) //Sequencia MGM
Local aAreaMGM 	:= MGM->(GetArea()) //WorkArea MGM
Local aAreaMGT	:= MGT->(GetArea())  //WorkArea MGT
Local cL1_Chv		:= "" //Chave SL1
Local nTamC5Fil 	:= SC5->(TamSx3("C5_FILIAL")[1]) //Filial SC5
Local cSC5_Chv 	:= "" //Chave SC5
Local cSE1_Chv 	:= "" //Chave SE1
Local aAreaSE1 	:= SE1->(GetArea()) //WorkArea SE1
Local aAreaMGT	:= {} //WorkArea MGT
Local lLiberado   := .f. //Pedido Liberado

If lECLibBl
	nPos := aScan(aFiltro, {|x| x[1] = "SE1"})
	If nPos > 0
		cSE1_Chv := aFiltro[nPos][2]
	EndIf

	nPos := aScan(aFiltro, {|x| x[1] = "SL1"})
	If nPos > 0
		cL1_Chv := aFiltro[nPos][2]
	EndIf
	nPos := aScan(aFiltro, {|x| x[1] = "SC5"})
	If nPos > 0
		cSC5_Chv := Substr( aFiltro[nPos][2], nTamC5Fil + 1)
	EndIf	
EndIf

If lECLibBl

	//Verifica se o pedido já foi liberado
	aAreaMGT := MGT->(GetArea())
	MGT->(DbSetOrder(2)) //FILIAL + MGT_PEDIDO
	MGT->(DbSeek(xFilial("MGT") + cSC5_Chv))
	
	Do While !lLiberado .AND. MGT->( !Eof()  .AND. MGT_FILIAL = xFilial("MGT") .AND. MGT_PEDIDO = cSC5_Chv)
		lLiberado := AllTrim(MGT->MGT_STATUS) == "LB"
		MGT->(DbSkip(1))
	EndDo	 
	RestArea(aAreaMGT)   
		   				
	If !lLiberado .AND. !Empty(cSE1_Chv) .AND. !Empty(cSC5_Chv) .AND.  !Empty(cL1_Chv)
		SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->(dbSeek(cSE1_Chv)) .and. LJ861EC01(SE1->E1_NUM, SE1->E1_PREFIXO, .T. , SE1->E1_FILORIG)
			

 			SL4->(DbSetOrder(1))//L4_FILIAL + L4_NUM
 			If SL4->(DbSeek(xFilial("SL4", SE1->E1_FILORIG)+ Substr(cL1_Chv, nTamC5Fil + 1)))
 				SAE->(DbSetOrder(1)) //AE_Filial + AE_Cod
 				If SAE->(DbSeek(xFilial("SAE", SE1->E1_FILORIG)+ Left(SL4->L4_ADMINIS,nTamAECod))) 
 					If SAE->AE_ECCNFPG .AND. MsgYesNo(STR0038 +cSC5_Chv + STR0039) //"Deseja liberar o Pedido["##"], em vitude da confirmação do pagamento?"
 						LJ861EC02(SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_FILORIG, .F.)
 						
 						//Gera o log na tabela de status de pedidos
						MGM->(DbSetOrder(2)) //MGM_FILIAL+MGM_SERVIC+MGM_SEQ                                                                                                                                   
						MGM->(DbSeek(cFilMGM+cSeq, .T.))
						MGM->(DbSkip(-1))
						cSeq := MGM->MGM_SEQ
						RestArea(aAreaMGM)
						
						RecLock("MGT", .T.)
						MGT->MGT_FILIAL  := xFilial("MGT")
						MGT->MGT_SEQ     := cSeq
						MGT->MGT_PEDIDO  := cSC5_Chv
						MGT->MGT_STATUS  := "LB"
						MGT->MGT_RASTR   := __cUserID + " " + cUserName
						MGT->MGT_PEDECO := cPedECom
						MGT->(MsUnLock()) 
						RestArea(aAreaMGT)
 					EndIf
 				EndIf
 				RestArea(aAreaSAE)
 			EndIf
 			RestArea(aAreaSL4)
		EndIf
		RestArea(aAreaSE1)
		RestArea(aArea)
	EndIf
EndIf	
	
Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LOJA901D  ³ Autor ³ SIGALOJA                        ³ Data ³ 18/04/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma o pagamento do Pedido.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA901D                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LjTracker.PRW                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOJA901D()
	LJECTracker("LOJA901D")
Return