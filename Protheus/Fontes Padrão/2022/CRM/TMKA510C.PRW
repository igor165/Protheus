#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMKA510C.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณHelpDeskFindCalls     บAutorณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     |Interface de usuario para busca e selecao de chamados.             บฑฑ 
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class HelpDeskFindCalls 
Data oDlg
Data nMeter
Data lFinding
Data lStop
Data cSelCall
Data isHistory
Data cPergunte
Data lViewOnly
Data cProduto
Data cKeyWords
Data cGroup
Data cStr1
Data cStr2
Data cStr3

Method new() Constructor  
Method showDialog(cCodSB1, cPrivateWords, lCancela)
Method openBrowse()
Method Cancel()      
Method SelItem(oRelBrowse,aList, oResolution)
Method Tk510CACols(aHeaderADF, aColsADF, cCodADE)
Method Tk510Finish(oSayFinish, oRelBrowse,aList,lChAssVld)
Method Find(oRelBrowse, aFields)
Method FillData(cAlias, aFields, oRelBrowse)
Method Tk510ExPsq()

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew          บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method new() Class HelpDeskFindCalls 
Self:lFinding 	:= .F.
Self:lStop		:= .F.   
Self:cSelCall	:= ""
Self:isHistory	:= .F.    
Self:lViewOnly	:= .F. 
Self:cProduto	:= "" 
Self:cKeyWords	:= ""
Self:cGroup		:= ""
Self:cStr1 		:= STR0001 // "Associar a chamado anterior"
Self:cStr2 		:= STR0002 // "Confirme os dados do chamado que serแ associado ao chamado atual"
Self:cStr3 		:= STR0003 // "Nใo hแ chamado selecionado para associar ao chamado atual."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPergunte - TMK510HI                                                           ณ
//ณMV_PAR01 - De                                                        		 ณ
//ณMV_PAR02 - Ate                                                                ณ
//ณMV_PAR03 - Do Chamado                                                         ณ
//ณMV_PAR04 - Ate o chamado                                                      ณ
//ณMV_PAR05 - Status do chamado                                                  ณ
//ณMV_PAR06 - Do Cliente                                                         ณ
//ณMV_PAR07 - Da Loja                                                            ณ	
//ณMV_PAR08 - Ate o Cliente                                                      ณ
//ณMV_PAR09 - Ate a Loja                                                         ณ	
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
Self:cPergunte	:= "TMK510HI"
Return Self  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณshowDialog   บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method showDialog(cCodSB1, cPrivateWords, lCancela) Class HelpDeskFindCalls    
Local aArea				:= GetArea()    
Local aAreaADE			:= ADE->(GetArea())
Local aAreaADF			:= ADF->(GetArea())
Local oWizard 										//Obteto principal com a tela de dialogo
Local aSizeDlg      	:= MsAdvSize(.T.,.F.,400)	//Array com as dimensoes da tela principal.
Local aInfo				:={}						//Array para utilizacao do MsAdvSize
Local aPosObj			:= {}						//Array com as coordenadas para posicionamento dos objetos
Local aObjects			:={}						//Array com os objetos da tela    
Local oPanel                                        //Variavel auxiliar utilizado na constru็ใo dos paineis
Local oFont											//Fonte utilizado nos objetos 
Local lFinish := .F.

Local oCheck1
Local oProd
Local lCheck1	:= .F.

Local oCheck2
Local oCall
Local cCall 	:= SPACE(30)
Local lCheck2	:= .F.

Local oCheck3
Local oKeyWords
Local lCheck3	:= .F.   

Local nDaysBefore	:= Val(SuperGetMV("MV_TKDAYBF",.F.,"180"))
Local oSinceFrom
Local dInitialDate	:= dDatabase-nDaysBefore
Local dSinceFrom 	:= dInitialDate

Local oMeter
Local aFields    := {{.F., "", "", "", "", "", "", ""}} //Checkbox # Chamado # Produto # Data # Cliente # Class. Incidente # Incidente
Local oRelBrowse

Local cAbstract := ""
Local oAbstract

Local cItemObs := ""
Local oItemObs
                                                      
Local oResolution  
Local aHeaderADF := {}
Local aColsADF	 := {}   
Local bMontCols  := {||}
Local bPesquisa	 := {||}

Local oSayFinish

Local aColsBkp := aClone(aCols)
Local aHeaderBkp := aClone(aHeader)

Local nPosObs	:= 0	//Posicao da observacao no itens do chamado

Local lTK510CNXT := ExistBlock("TK510CNXT")
                               
//Local cDescEntity	:= POSICIONE('SX2',1,M->ADE_ENTIDA,'X2NOME()')
//Local aOpcoes	:= {"Historico por Contato","Historico por " + IIF(!Empty(cDescEntity),cDescEntity,"Entidade"), "No Chamado"}	// "Historico por Contato","Historico por Entidade"
Local nArquivo  := 1											// Consulta por 1 - Contato ou por 2 - Cliente		
Local oArquivo													// Objeto radio para escolha do tipo de historico
Local lFim		:= .F.		//Indica se o usuario chegou ao fim do wizard

Local cCBNext	:= {||}
Local cCBFinish	:= {||}
Local lTK510CFIM	:= FindFunction("P_TK510CFIM")		//Project Function para inibir a abertura de historico
Local lShowFin	:= .T.									//Indica se exibira a ultima tela do historico
Local lCFimRet											// Retorno da Project Function TK510CFIM
Local lValNextWiz	:= .T.								// Indica se pode navegar para o proximo Painel
Local aPergunte	:= {}
Local nPerg		:= 0
Local nResps	:= 0
Local nPanel	:= 0
Local aRet		:= {}  
Local aCombo	:= {}
Local nDef		:= 0
Local cPicture	:= ""
Local lOK		:= .F.									// Indica se pressionou Ok no pergunte   
Local cCadastroAux	:= ""      
Local lChAssVld	:= .T.
Local oBmp1
Local oBmp2
Local oBmp3
Local nTSx3GrpAtend	:= TamSX3("ADE_GRUPO")[1]

Private cProduto 	:= SPACE(30)         

Default lCancela := .F.

SaveInter()

lCancela	:= .F.
bPesquisa	:= {||Processa({||Self:Tk510ExPsq(	@lValNextWiz, @oRelBrowse	, @aFields	, @aColsADF	,;
				   				 				@oResolution, @aHeader		, @cAbstract, @oAbstract,;
				 								@cItemObs	, @oItemObs		,@aRet		, @lOk		)}),;
				 								STR0023} // "Aguarde...Pesquisando"

Pergunte(Self:cPergunte, .F.)

If ValType(MV_PAR01)=="D"
	MV_PAR01 := dSinceFrom
EndIf

If ValType(MV_PAR02)=="D"
	MV_PAR02 := dDatabase
EndIf		

DbSelectArea("SX1")
DbSetOrder(1)
If DbSeek(Self:cPergunte)	
	While SX1->(!EOF()) .AND. AllTrim(SX1->X1_GRUPO) == AllTrim(Self:cPergunte)

	    nPerg++             
	    aAdd( aPergunte , Array(9))
		
		//Inicializa a resposta para a ParamBox
	    AAdd(aRet,&("MV_PAR"+STRZERO(nPerg,2)))
	   	
	   	If Empty(SX1->X1_DEF01) 	   	                       
	   		cPicture := ""     
	   		cPicture := SX1->X1_PICTURE
	   		If Empty(cPicture)
	   			cPicture := "@"
	   		EndIf
		   	aPergunte[nPerg,1 ] := 1
		   	aPergunte[nPerg,2 ] := SX1->X1_PERGUNT
		   	aPergunte[nPerg,3 ] := &("MV_PAR"+STRZERO(nPerg,2))
		   	aPergunte[nPerg,4 ] := cPicture
		   	aPergunte[nPerg,5 ] := SX1->X1_VALID
		   	aPergunte[nPerg,6 ] := SX1->X1_F3
		   	aPergunte[nPerg,7 ] := '.T.'
		   	aPergunte[nPerg,8 ] := 50
		   	aPergunte[nPerg,9 ] := .F.
		Else
		    aPergunte[nPerg,1 ] := 2
		    aPergunte[nPerg,2 ] := SX1->X1_PERGUNT
		    aPergunte[nPerg,3 ] := "1"
		    
		    For nDef := 1 To 5
		    	If !Empty(&("SX1->X1_DEF"+StrZero(nDef, 2)))
		    		aAdd(aCombo, AllTrim(Str(nDef)) + "=" + &("SX1->X1_DEF"+StrZero(nDef, 2)))			    	
		    	Else
		    		Exit
		    	EndIf		    		
		    Next 		            
		    aPergunte[nPerg,4 ] := aClone(aCombo)
		    aCombo := {}
		    aPergunte[nPerg,5 ] := 50 
   		    aPergunte[nPerg,6 ] := 	""
		    aPergunte[nPerg,7 ] := .F.   		        
			
		EndIf
		SX1->(DbSkip())
	End      
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAdiciona o produto a pesquisaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(cCodSB1)=="C"
		Self:cProduto := cCodSB1
	Else
		Self:cProduto := Space(TamSX3("ADE_CODSB1")[1])
	EndIf      
	aAdd( aPergunte ,{1,STR0004,Self:cProduto,PesqPict("ADE","ADE_CODSB1"),'Vazio() .OR. ExistCpo("SB1",,1)',"SB1",'.T.',50,.F.}) // "Produto"
	aAdd( aRet, Self:cProduto)
	nPerg++
	&("MV_PAR"+STRZERO(nPerg,2)) := Space(50)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAdiciona a pesquisa por palavra chaveณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(cPrivateWords)=="C"
		Self:cKeyWords := cPrivateWords
	Else
		Self:cKeyWords := Space(99)
	EndIf
	aAdd( aPergunte ,{1,STR0005,Self:cKeyWords,'@','',,'.T.',99,.F.}) // "Resumo / Incidente"
	aAdd( aRet, Self:cKeyWords)
	nPerg++
	&("MV_PAR"+STRZERO(nPerg,2)) := Space(99)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAdiciona a pesquisa por grupo de atendimentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Self:cGroup := Space(TamSX3("ADE_GRUPO")[1])
	aAdd( aPergunte ,{1,"Grp.Atendimento",Self:cGroup,PesqPict('ADE',"ADE_GRUPO"),'Vazio() .OR. ExistCpo("SU0",,1)',"SU0",'.T.',nTSx3GrpAtend,.F.}) // "Produto"
	aAdd( aRet, Self:cGroup)
	nPerg++
	&("MV_PAR"+STRZERO(nPerg,2)) := Space(nTSx3GrpAtend)
	           
	If Type("cCadastro") == "U"
		cCadastro := ""
	EndIf	
	cCadastroAux := cCadastro
	If Self:isHistory
		cCadastro := STR0006 // "Hist๓rico"
	Else                        
		cCadastro := STR0007 // "Associar Chamado"	
	EndIf
	
	cCadastro := cCadastroAux
EndIf      

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ1o. Painel: Perguntas para realizacao da busca                           	   ณ   
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
cCBNext   := {||Eval(bPesquisa),lOk} 
cCBFinish := {||} 

oWizard:= APWizard():New( 	STR0008,; // "Resultado da pesquisa na base de chamados"
							STR0009,; // "Selecione um chamado ou avance"
							STR0010,; // "Procura na base de chamados"
							 ,;
							 cCBNext/*{||IIf(Empty(Self:service:name),Eval({||Aviso(STR0004,STR0005, {"OK"}),.F.}),.T.)}*/,; //"Configurador" # "Informe um nome para o modelo de atendimento"
							 cCBFinish,.T., , , .T.,{aSizeDlg[7],000,aSizeDlg[6]-50,aSizeDlg[5]} )
nPanel++

oPanel 	:= oWizard:GetPanel(nPanel)
ParamBox(aPergunte ,"Pergunte",@aRet,,,,,,oPanel)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ2o. Painel: Resultado da busca realizada                                 	   ณ   
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If !Self:isHistory	
	If !Self:lViewOnly	
		cCBNext   := {||lFinish:=Self:Tk510Finish(oSayFinish, oRelBrowse,aFields,@lChAssVld),lChAssVld} 
		cCBFinish := {||} 
	Else
		cCBNext   := NIL
		cCBFinish := {||lFinish:=.F.,lFim:=.T.}
	EndIf
Else                                  
	If !Self:lViewOnly	
		lShowFin	:= .T.
		If lTK510CFIM
			lCFimRet := P_TK510CFIM()
			If ValType(lCFimRet) == "L"
				lShowFin := lCFimRet
			EndIf
		EndIf
			  
		If lShowFin
			cCBNext   := {||lFinish:=Self:Tk510Finish(oSayFinish, oRelBrowse,aFields,@lChAssVld),lChAssVld} 
			cCBFinish := {||} 
		Else
			cCBNext   := NIL
			cCBFinish := {||lFinish:=.F.,lFim:=.T.} 	
		EndIf
	Else
		cCBNext   := NIL
		cCBFinish := {||lFinish:=.F.,lFim:=.T.} 
		lShowFin := .F.	
	EndIf	
EndIf		

CREATE PANEL oWizard	HEADER 	Self:cStr1; 
						MESSAGE Self:cStr2;  
						NEXT cCBNext;
						FINISH cCBFinish PANEL
nPanel++

aObjects := {}       
oPanel 	:= oWizard:GetPanel(nPanel)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo do posicionamento dos objetos no painel    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd( aObjects, { oPanel:nClientWidth*0.47, oPanel:nClientHeight*0.15, .F., .F., .T. } ) //AAdd( aObjects, { 300, 060, .T., .F., .T. } ) 
AAdd( aObjects, { 001, 005, .T., .F., .T. } )
AAdd( aObjects, { oPanel:nClientWidth*0.47, oPanel:nClientHeight*0.05, .F., .F., .T. } )//AAdd( aObjects, { 300, 030, .F., .F., .T. } )//AAdd( aObjects, { 140, 050, .F., .F., .T. } )
AAdd( aObjects, { oPanel:nClientWidth*0.47, oPanel:nClientHeight*0.15, .F., .F. } )//aAdd( aObjects, { 300, 040, .F., .F. } )//aAdd( aObjects, { 300, 080, .F., .F. } )          
AAdd( aObjects, { 001, 005, .T., .F., .T. } )
AAdd( aObjects, { oPanel:nClientWidth*0.47, oPanel:nClientHeight*0.05, .F., .F., .T. } )//AAdd( aObjects, { 300, 030, .F., .F., .T. } )//AAdd( aObjects, { 140, 050, .F., .F., .T. } )
								 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )	       

nTop  := (oPanel:nTop + oPanel:nHeight + 12)/2	
@ nTop+7, aPosObj[1,2] BITMAP oBmp1 ResName "BR_VERDE" OF oWizard:oDlg Size 10,10 NoBorder When .F. Pixel
@ nTop+7, aPosObj[1,2]+10 SAY STR0011 OF oWizard:oDlg Color CLR_BLUE,CLR_WHITE PIXEL  	//"Em aberto" 

@ nTop+7, aPosObj[1,2]+50 BITMAP oBmp2 ResName "BR_AZUL" OF oWizard:oDlg Size 10,10 NoBorder When .F. Pixel
@ nTop+7, aPosObj[1,2]+60 SAY STR0012 OF oWizard:oDlg Color CLR_BLUE,CLR_WHITE PIXEL  	//"Pendente" 	

@ nTop+7, aPosObj[1,2]+100 BITMAP oBmp3 ResName "BR_PRETO" OF oWizard:oDlg Size 10,10 NoBorder When .F. Pixel
@ nTop+7, aPosObj[1,2]+110 SAY STR0013 OF oWizard:oDlg Color CLR_BLUE,CLR_WHITE PIXEL  	//"Encerrado" 			  


// Checkbox # Chamado # Produto # Data # Cliente		
oRelBrowse := TCBrowse():New( aPosObj[1,1],aPosObj[1,2], aPosObj[1,3],aPosObj[1,4]/*280,aPosObj[1,3]*/,, {"", "", STR0014, STR0015, STR0016, STR0017, STR0018, STR0019},{2,20,30,10,30,20,20},; // "Chamado" # "Produto" # "Data" # "Cliente" # "Class. Incidente" # "Status"
                            oPanel,,,,,{||},,/*oFont*/,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )
                            
oRelBrowse:SetArray(aFields)
oRelBrowse:bLine := {||Tk510Fill(aFields, oRelBrowse:nAt)}						

bMontCols := {|| IIf(Len(aFields)>0,lFinish:=Self:Tk510CACols(aHeader, @aColsADF, aFields[oRelBrowse:nAt,03]),.T.) }
                
aHeader := {}	
FillGetDados(	2				,"ADF"			,1					,/*cSeek*/		,;
				/*{||&cWhile}*/	,{|| .T. }		,/*aNoFields*/		,/*aYesFields*/	,; 
				/*lOnlyYes*/	,/*cQuery*/		,bMontCols			,.T.			)
				
nPosObs	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ADF_OBS"})	  
If nPosObs > 0 .AND. Len(aCols)>0       
	cItemObs:=aCols[1,nPosObs]			
EndIf

@ aPosObj[2,1],aPosObj[2,2]  SAY STR0020 OF oPanel PIXEL SIZE 75,29 // "Incidente relatado no chamado"
@ aPosObj[3,1],aPosObj[3,2] GET oAbstract VAR cAbstract MEMO SIZE aPosObj[3,3],aPosObj[3,4] FONT oFont READONLY OF oPanel PIXEL 

oResolution := MsNewGetDados():New(aPosObj[4,1],aPosObj[4,2], aPosObj[4,3],aPosObj[4,4], ;
									0, /*"Tk510ALinOk"*/, /*"Tk510ATudOk"*/,,,,4096,,,,oPanel,aHeader/*ADF*/, aColsADF)

@ aPosObj[5,1],aPosObj[5,2]  SAY STR0021 OF oPanel PIXEL SIZE 75,29 // "Observa็ใo do item selecionado"
@ aPosObj[6,1],aPosObj[6,2] GET oItemObs VAR cItemObs MEMO SIZE aPosObj[6,3],aPosObj[6,4] FONT oFont READONLY OF oPanel PIXEL 
                                                                        
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao de painel para criar os botoes da tela de atendimento.           	   ณ   
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lShowFin
	CREATE PANEL oWizard  	HEADER 	Self:cStr1; 
							MESSAGE Self:cStr2;  
						 	NEXT /*{||}*/;
						 	FINISH {||lFim:=.T.} PANEL	
	nPanel++						 	
	aObjects := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo do posicionamento dos objetos no painel    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AAdd( aObjects, { 300, 080, .F., .F., .T. } )//AAdd( aObjects, { 001, 100, .T., .F. } )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
	oPanel 	:= oWizard:GetPanel(nPanel)
	aInfo   := { 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )	       
	
	oSayFinish:= tSay():New(aPosObj[1,1],aPosObj[1,2],{||Self:cStr3},oPanel,,,,;    
			,,.T.,CLR_BLACK,CLR_WHITE,aPosObj[1,3],aPosObj[1,4]/*300,20*/)	
EndIf

ACTIVATE WIZARD oWizard WHEN {||.T.} ON INIT {||}

If !lFim   
	lCancela := .T.
	lFinish := .F.	
EndIf   

aCols 	:= aColsBkp
aHeader := aHeaderBkp

RestInter()

RestArea(aArea)  
RestArea(aAreaADE)  
RestArea(aAreaADF)  
Return lFinish     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTk510Finish  บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a mensagem de finaliza็ใo.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510Finish(oSayFinish, oRelBrowse, aList, lChAssVld) Class HelpDeskFindCalls 
Local cText := ""  
Local nI := 1  
Local lSelIt := .F.
    
lChAssVld := .T.

If Self:isHistory
	cText := STR0024 // "Nใo foi selecionado um chamado para ser iniciado o atendimento."
Else                                                                     
	cText := STR0025 // "Nใo hแ chamado selecionado para associar ao chamado atual."  	
EndIf

//Inicializa o checkbox
For nI := 1 To Len(aList)
	If aList[nI][1]
		Self:cSelCall := aList[nI][3]
		lSelIt := .T.
		Exit
	EndIf
Next nI

If lSelIt .AND. !Tk510VldAss(Self:cSelCall)
	lChAssVld := .F.
	Self:cSelCall := ""
ElseIf lSelIt
	If !Self:isHistory
		//Monta o texto
		cText := 	STR0026 + CRLF +; // "Este chamado serแ associado ao chamado #001."
					STR0027 // "Assim que o chamado associado for encerrado, o chamado atual serแ encerrado e o cliente receberแ uma notifica็ใo de encerramento." 
	Else
		cText := 	STR0028 + CRLF // "Serแ iniciado o atendimento ao chamado #001."
	EndIf
	cText := StrTran(cText, "#001", Self:cSelCall)	
EndIf

oSayFinish:SetText(cText)

Return lSelIt   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTk510CACols  บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona um item do Browse.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510CACols(aHeaderADF, aColsADF, cCodADE) Class HelpDeskFindCalls    
Local aArea := GetArea()
Local cCampo := "" 
Local nLin := 0
Local nI   := 0

aColsADF := {}
DbSelectArea("ADF")
DbSetOrder(1) //ADF_FILIAL+ADF_CODIGO
DbSeek(xFilial("ADF")+cCodADE)
While ADF->(!EOF()) .AND. ADF->ADF_CODIGO == cCodADE		                       
						
	AADD( aColsADF, Array( Len( aHeaderADF ) + 1 ) ) 
	nLin := Len( aColsADF )	
	For nI := 1 To Len( aHeaderADF )
		cCampo := aHeaderADF[nI, 2]
		If IsHeadRec(cCampo)	//Recno
  			aColsADF[nLin][nI] := ADF->( Recno() )
	 	ElseIf IsHeadAlias(cCampo)	//Alias
			aColsADF[nLin][nI] := "ADF"
		ElseIf aHeaderADF[nI,10] <> "V"
			aColsADF[nLin][nI] := FieldGet( FieldPos( cCampo ) ) 
		ElseIf AllTrim(cCampo) == "ADF_NMSU9"
			aColsADF[nLin][nI] := POSICIONE("SU9", 2, xFilial("SU9")+ADF->ADF_CODSU9,"U9_DESC")	
		ElseIf AllTrim(cCampo) == "ADF_NMSUQ"
			aColsADF[nLin][nI] := POSICIONE("SUQ", 1, xFilial("SUQ")+ADF->ADF_CODSUQ,"UQ_DESC")				
		ElseIf AllTrim(cCampo) == "ADF_OBS"
			aColsADF[nLin][nI] := MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1])			            
		ElseIf AllTrim(cCampo) == "ADF_NMSU7"
			aColsADF[nLin][nI] := POSICIONE("SU7", 1, xFilial("SU7")+ADF->ADF_CODSU7,"U7_NOME")				
		ElseIf AllTrim(cCampo) == "ADF_NMGRUP"
			aColsADF[nLin][nI] := POSICIONE('SU0', 1, xFilial('SU0')+ADF->ADF_CODSU0,'U0_NOME')							
		Else
			aColsADF[nLin][nI] := CriaVar( cCampo, .T. )
		EndIf
	Next nI
	aColsADF[nLin][nI] := .F.						
						
								    
    DbSelectArea("ADF")
	DbSkip()
End 
//--------------------------------------------------------------------------------------------------------------------------------
// 		Na primeira chamada o aCols nใo ้ preenchido, pois, o registro nใo estแ posicionado, sendo assim, se nใo houver conte๚do
// 	no aCols ้ necessแrio inicilizแ-lo para nใo ficar aparecendo os helps de erro no conte๚do inicializador padrใo dos campos.
//--------------------------------------------------------------------------------------------------------------------------------
If Len( aColsADF ) == 0
	Aadd( aColsADF, Array( Len( aHeaderADF ) + 1 ) )
	nLin := Len( aColsADF )	
	For nI := 1 To Len( aHeaderADF )
	cCampo := aHeaderADF[nI, 2]
		If IsHeadRec(cCampo)	//Recno
  			aColsADF[nLin][nI] := ADF->( Recno() )
	 	ElseIf IsHeadAlias(cCampo)	//Alias
			aColsADF[nLin][nI] := "ADF"
		ElseIf aHeaderADF[nI,10] <> "V"
			aColsADF[nLin][nI] := FieldGet( FieldPos( cCampo ) ) 
		ElseIf AllTrim(cCampo) == "ADF_NMSU9"
			aColsADF[nLin][nI] := POSICIONE("SU9", 2, xFilial("SU9")+ADF->ADF_CODSU9,"U9_DESC")	
		ElseIf AllTrim(cCampo) == "ADF_NMSUQ"
			aColsADF[nLin][nI] := POSICIONE("SUQ", 1, xFilial("SUQ")+ADF->ADF_CODSUQ,"UQ_DESC")				
		ElseIf AllTrim(cCampo) == "ADF_OBS"
			aColsADF[nLin][nI] := MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1])			            
		ElseIf AllTrim(cCampo) == "ADF_NMSU7"
			aColsADF[nLin][nI] := POSICIONE("SU7", 1, xFilial("SU7")+ADF->ADF_CODSU7,"U7_NOME")				
		ElseIf AllTrim(cCampo) == "ADF_NMGRUP"
			aColsADF[nLin][nI] := POSICIONE('SU0', 1, xFilial('SU0')+ADF->ADF_CODSU0,'U0_NOME')							
		Else
			aColsADF[nLin][nI] := CriaVar( cCampo, .T. )
		EndIf
	Next nI
	aColsADF[nLin][nI] := .F.					

EndIf         

DbSelectArea("ADF")
DbCloseArea()	 
RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSelItem      บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona um item do Browse.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SelItem(oRelBrowse,aList, oResolution) Class HelpDeskFindCalls 
Local nI                                 
Local lVal := .T.
        
If Len(aList)>0 .AND. Len(aList)>=oRelBrowse:nAt
	lVal := aList[oRelBrowse:nAt][1]
	                               
	//Inicializa o checkbox
	For nI := 1 To Len(aList)
		aList[nI][1] := .F.
	Next nI            
	aList[oRelBrowse:nAt][1]:=!lVal 
	oRelBrowse:Refresh() 
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFind         บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza procura por chamados que atendam ao criterio de     บฑฑ
ฑฑบ          ณbusca.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Find(oRelBrowse, aFields) Class HelpDeskFindCalls 
Local cQuery := ""  
Local aArea := GetArea()
Local lTK510CQRY	:= ExistBlock("TK510CQRY")	//Ponto de Entrada para alterar a query de filtro.
Local cWhere		:= ""
Local cResult		:= ""						//Retorno do Ponto de Entrada

Default aFields := {}      

If !Self:lFinding
	Self:lFinding 	:= .T.
	DbSelectArea("ADE")
	DbSetOrder(1)  
		
	If ValType(MV_PAR05) == "N"
		MV_PAR05 := cValToChar(MV_PAR05)
	EndIf
	
	#IFDEF TOP		
		cQuery := "	SELECT "		
		cQuery += "	ADE.ADE_FILIAL,	ADE.ADE_CODSB1,	ADE.ADE_ENTIDA,		ADE.ADE_CHAVE, "
		cQuery += "	ADE.ADE_CODIGO,	ADE.ADE_DATA,	ADE.ADE_SEVCOD,		ADE.ADE_CODINC, "
		cQuery += "	ADE.ADE_DATA,	ADE.ADE_STATUS,	ADE.ADE_PLVCHV,		ADE.ADE_DTEXPI,  "		
		cQuery += "	ADE.ADE_OPERAD" + IF(!Empty(Self:cKeyWords),",	SYP.YP_TEXTO  ","")
		cQuery += "	FROM " + RetSQLName("ADE") + " ADE" + IF(!Empty(Self:cKeyWords),", " + RetSQLName("SYP") + " SYP","")
		
		cWhere += "	WHERE ADE.ADE_FILIAL = '" + xFilial("ADE") + "' AND"		
		
		cWhere += "	ADE.ADE_DATA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' AND"		
		
		cWhere += "	ADE.ADE_CODIGO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND"		
		If Val(MV_PAR05) < 4                                              
			cWhere += " ADE.ADE_STATUS = '" + AllTrim(MV_PAR05) + "' AND"					
		EndIf
		
		If !Empty(Self:cProduto)
			cWhere += "	ADE.ADE_CODSB1 = '" + Self:cProduto + "' AND"
		EndIf

		If !Empty(Self:cGroup)
			cWhere += "	ADE.ADE_GRUPO = '" + Self:cGroup + "' AND"
		EndIf		

		If !Empty(Self:cKeyWords)
			cWhere += " SYP.YP_FILIAL = '"+xFilial("SYP")+"' AND"
			cWhere += " ADE.ADE_CODINC = SYP.YP_CHAVE AND"
			Self:cKeyWords := AllTrim(Self:cKeyWords)
			cWhere += " ((UPPER(ADE.ADE_PLVCHV) LIKE '%" + "###" + "%' AND ADE.D_E_L_E_T_ = ' ') OR"
			cWhere += " (UPPER(SYP.YP_TEXTO) LIKE '%" + "###" + "%' AND SYP.D_E_L_E_T_ = ' ')) AND"			
		EndIf		
		cWhere += "	ADE.D_E_L_E_T_ = ' '"  
		
		If lTK510CQRY
			cResult := ExecBlock("TK510CQRY", .F., .F., {cWhere})	
			If ValType(cResult)=="C"			
				cWhere := cResult
			EndIf		
		EndIf
		cQuery += cWhere		
		cQuery += "	ORDER BY " + SqlOrder(IndexKey())
		
		cQuery := ChangeQuery(cQuery)
		cQuery := StrTran(cQuery, "###", AllTrim(Upper(Self:cKeyWords)))		
	
		DbSelectArea("ADE")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ADE", .F., .T.)	
		
		TCSetField("ADE", "ADE_DTEXPI"	, "D")		
		TCSetField("ADE", "ADE_DATA"	, "D")				
	#ELSE       
		DbSelectArea("ADE")
		DbSetOrder(3) //ADE_FILIAL+ ADE_GRUPO		
		DbSeek(xFilial("ADE")+Self:cPosto)	
		nTot := RecCount()
	#ENDIF
			          
	IncProc("Criando lista de chamados...")
	
	Self:FillData("ADE", @aFields, @oRelBrowse)				                            	
		
	DbSelectArea("ADE")
	DbCloseArea()	
	
	Self:lFinding 	:= .F.
	Self:lStop		:= .F.                      
	
	RestArea(aArea)
EndIf
Return Nil      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFillData     บAutor  ณ Vendas Clientes บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os dados na tela de historico.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FillData(cAlias, aFields, oRelBrowse) Class HelpDeskFindCalls 
Local cProduto		:= ""      
Local aProduto		:= {}   
Local cEntidade		:= ""
Local aEntidade		:= {} 
Local aADE_SEVCOD	:= TkSx3Box("ADE_SEVCOD")	// Pesquisa opcoes do campo no dicionario  
Local aADE_STATU 	:= TkSx3Box("ADE_STATUS")
Local nIt := 0                  
Local nCor			:= 0
Local nSizeSev		:= TamSx3("ADE_SEVCOD")[1]
Local cChamadoAtual := ""
Local aCores		:= 	{	{"ADE->ADE_STATUS == '3'"											, "BR_PRETO"	},;		//Chamado Pendente
 							{"ADE->ADE_STATUS == '2'"											, "BR_AZUL"		},;		//Chamado Pendente
 							{"ADE->ADE_STATUS == '1'"											, "BR_VERDE"	}}		//Chamado em aberto

aFields := {}

If Type("M->ADE_CODIGO")=="C" 
	cChamadoAtual := M->ADE_CODIGO
EndIf

While (cAlias)->(!EOF()) .AND. !Self:lStop
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNใo exibe o mesmo chamado que esta aberto na tela de atendimento              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cChamadoAtual)
		If cChamadoAtual == (cAlias)->ADE_CODIGO
			DbSelectArea(cAlias)   	
			DbSkip()
			Loop		
		EndIf	
	EndIf
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega as informacoes do produto                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		    	        
    cProduto := "" 
    nIt := aScan(aProduto, {|x|x[1]==(cAlias)->ADE_CODSB1})  	         
    If nIt<= 0
		SB1->(DbSetOrder(1))
		If SB1->(MsSeek(xFilial("SB1")+(cAlias)->ADE_CODSB1))
			cProduto := SB1->B1_DESC 
			aAdd(aProduto, {(cAlias)->ADE_CODSB1, cProduto})
		EndIf 
	Else
		cProduto := aProduto[nIt][2]
	EndIf        
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega as informacoes da entidade                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		    	        		
	cEntidade		:= ""
	nIt := aScan(aEntidade, {|x|x[1]==(cAlias)->ADE_ENTIDA .AND. x[2]==(cAlias)->ADE_CHAVE})
	If nIt<=0         
		cEntidade := TKENTIDADE((cAlias)->ADE_ENTIDAD,(cAlias)->ADE_CHAVE,1)
		aAdd(aEntidade, {(cAlias)->ADE_ENTIDA,(cAlias)->ADE_CHAVE,cEntidade})		
	Else
		cEntidade		:= aEntidade[nIt][3]
	EndIf
    
	nCor := aScan(aCores, {|x|Eval(&("{||" + x[1] + "}"))})
	If nCor <= 0
		nCor := 1
	EndIf

	//Busca a severidade
 	nPosSev := aScan(aADE_SEVCOD, {|x| Left(x,nSizeSev) == (cAlias)->ADE_SEVCOD})
	
	//Checkbox # Chamado # Produto # Data # Cliente # Class. Incidente # Incidente		
	aAdd(aFields, {.F.,;
					aCores[nCor][2],;
					(cAlias)->ADE_CODIGO,;
					cProduto,;
					(cAlias)->ADE_DATA,;
					cEntidade,;
					If((cAlias)->ADE_SEVCOD $ "1234567890" .AND. Val((cAlias)->ADE_SEVCOD) <= Len(aADE_SEVCOD),aADE_SEVCOD[nPosSev], ""),;						
					If((cAlias)->ADE_STATUS $ "1234567890" .AND. Val((cAlias)->ADE_STATUS) <= Len(aADE_STATUS),aADE_STATUS[Val(ADE->ADE_STATUS)], ""),;						
					(cAlias)->ADE_CODINC})		
            
	DbSelectArea(cAlias)   	
	DbSkip()
End                           
	
oRelBrowse:SetArray(aFields)
oRelBrowse:bLine := {||Tk510Fill(aFields, oRelBrowse:nAt)}	

Return Nil
          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณTk510Fill		ณ Autor ณ Vendas Clientes   ณ Data ณ 21/05/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณPreenche as informacoes do chamado.                         |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณTMKA271       	        						          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Tk510Fill(aFields, nPos) 
Local aRet := {}
Local nLoop := 0

If nPos > 0 .AND. Len(aFields) >= nPos .AND. Len(aFields[nPos]) >= 6
	aRet := {If(aFields[nPos,01],LoaDbitmap(GetResources(),"LBOK"),LoaDbitmap(GetResources(),"LBNO")),;
			LoaDbitmap(GetResources(),aFields[nPos,02]),;
			aFields[nPos,03],;
			aFields[nPos,04],;
			aFields[nPos,05],;
			aFields[nPos,06],;
			aFields[nPos,07],;			
			aFields[nPos,08]}
Else
	aRet := Array(7)  
	For nLoop := 1 To Len(aRet)
		aRet[nLoop] := ""	
	Next nLoop	
EndIf
	
Return aRet           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTk510ExPsqบAutor  ณVendas CRM          บ Data ณ  23/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a pesquisa de chamados apos avancar a tela de para- บฑฑ
ฑฑบ          ณmetrizacao da pesquisa.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP10                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk510ExPsq(	lValNextWiz	, oRelBrowse	, aFields	, aColsADF	,;
					oResolution	, aHeader		, cAbstract	, oAbstract	,;
					cItemObs	, oItemObs		, aRet		, lOk		) Class HelpDeskFindCalls   

Local aCols 	:= {} 
Local nPerg		:= 0
Local nPosObs	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ADF_OBS"})	   

Self:cProduto	:= aRet[Len(aRet)-2]
Self:cKeyWords	:= aRet[Len(aRet)-1]
Self:cGroup		:= aRet[Len(aRet)]

//Atualiza as variaveis MV_PAR de acordo com os valores respondidos
For nPerg := 1 to Len(aRet)
	&("MV_PAR" + StrZero(nPerg,2)) := aRet[nPerg]
Next nPerg

lOk := .T.

ProcRegua(2)
IncProc(STR0022) // "Selecionando registros..."

Self:Find(@oRelBrowse, @aFields) 
	
lValNextWiz:=.T.
aColsADF:={}   
	
oResolution:SetArray(aColsADF, .F.)
	
If 	ValType(aFields)=="A" .AND. Len(aFields)>=oRelBrowse:nAt .AND.	ValType(aFields[oRelBrowse:nAt])=="A" .AND. Len(aFields[oRelBrowse:nAt])>=2
	Self:Tk510CACols(aHeader, @aColsADF, aFields[oRelBrowse:nAt,03])
EndIf

If ValType(aColsADF)=="A"
	oResolution:SetArray(aColsADF, .F.)
EndIf
	
If	ValType(aFields)=="A" .AND. Len(aFields)>=oRelBrowse:nAt .AND.	ValType(aFields[oRelBrowse:nAt])=="A" .AND. Len(aFields[oRelBrowse:nAt])>=8
	cAbstract := MSMM(aFields[oRelBrowse:nAt,09],TamSx3("ADE_INCIDE")[1])
Else
	cAbstract := ""
EndIf
	
oAbstract:Refresh() 
	
cItemObs:=""
oItemObs:Refresh()
	
If	Type("aColsADF")=="A"
	oResolution:ForceRefresh()
EndIf
	
If Len(aFields)>0	
	oRelBrowse:bLDblClick := {|| Self:SelItem(@oRelBrowse,@aFields, @oResolution)}
	oRelBrowse:bChange := {||IIf(Len(aFields)>0,Self:Tk510CACols(aHeader, @aColsADF, aFields[oRelBrowse:nAt,03]),.T.),;
									oResolution:SetArray(aColsADF, .F.),; 
									cAbstract := IIf(Len(aFields)>0,MSMM(aFields[oRelBrowse:nAt,09],TamSx3("ADE_INCIDE")[1]),""), oAbstract:Refresh(),; 
									oResolution:ForceRefresh(),;
									cItemObs:=If(nPosObs > 0 .AND. Len(aColsADF)>=1 .AND. Len(aColsADF[1]) >= nPosObs,aColsADF[1,nPosObs],""),;								
									oItemObs:Refresh()} 	
										
	oResolution:bChange := {|| cItemObs:=If(nPosObs > 0 .AND. Len(oResolution:aCols)>=oResolution:nAt .AND. Len(oResolution:aCols[oResolution:nAt]) >= nPosObs,oResolution:aCols[oResolution:nAt,nPosObs],""),oItemObs:Refresh()}
	oRelBrowse:GoTop()
Else
	oResolution:oBrowse:bLDblClick := {||}
	aCols := {Array(Len(aHeader)+1)}   
	For nPerg:=1 To Len(aHeader)-2
		aCols[1,nPerg] := ""
	Next nPerg               
	aCols[1,nPerg+1] := 0
	aCols[1,nPerg+2] := .F.		
	oResolution:aCols := aClone(aCols)
	aColsADF := aClone(aCols)
EndIf 

Return