#include "Protheus.ch"
#include "LOJA850.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOJA850  ³ Autor ³ Vendas Cliente      ³ Data ³ 18/04/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa Conta Corrente                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA850()						                  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGALOJA							                   	  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOJA850()

Local aMotBx 		:= ReadMotBx()		// Motivo da Baixa
Local aDescMotbx	:= {}				// Descricao Moti da Baixa
Local aArea			:= GetArea()		// Backup da Area
Local nI			:= 0 				// Contador
Local nX			:= 0				// COntador
Local lConfirma 	:= .T.				// Enquanto .T., exibe a Dialog para o usuario
Local nEspLarg 		:= 0 				// Lagura
Local nEspLin  		:= 0                // Linha
Local nOpt			:= 0				//Opcao Escolhida ao clicar-se em um botao("OK"==1, "Cancelar"==2)
Local cMotivo       := SuperGetMv("MV_LJ850MO",,"NOR")	//Motivo de baixa padrao.
Local aTitSE1		:= {}				// Titulos
Local oCbx 			:= Nil				// Nil         
Local oCliNome		:= Nil              // Nome do Cliente
Local oBancoLoja  	:= Nil				// Banco de Loja				
Local dVencIni	:= dDataBase 			// Vencimento inicial
Local dVencFim	:= dDataBase			// Vencimento Final
Local cHstBxTit:= SuperGetMv("MV_LJ850HI",,"")	//Historico padrao para o titulo baixado ref. pagto no Conta Corrente
Local cBcoLoja 	:= CRIAVAR("A6_COD")			// Banco Loja
Local cAgeLoja 	:= CRIAVAR("A6_AGENCIA")		// Age Loja
Local cCtaLoja 	:= CRIAVAR("A6_NUMCON")			// Conta Loja
Local cCliDe  	:= CRIAVAR("E1_CLIENTE")		// Cliente
Local cCliNome	:= CRIAVAR("E1_NOMCLI")			// Nome 
Local cLjDe		:= CRIAVAR("E1_LOJA")			// Loja Cliente
Local cMotBx	:= CriaVar("E5_MOTBX")			// Motivo
Local aBanco	:= {}							// Bancos
Local cCxLoja	:= SuperGetMv("MV_CXLOJA",,"")	// Caixa Loja	
Local lR5		:= GetRpoRelease ("R5")			// Versão do sistemas

If ! lR5
	Return NIL
EndIf

aBanco := StrTokArr(cCxLoja,"/")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informa como valor default o código do Caixa Geral          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBanco) == 3
	SA6->(DbSetOrder(1))
	If SA6->(DbSeek(xFilial("SA6")+aBanco[1]+aBanco[2]+aBanco[3]))
		cBcoLoja  := aBanco[1]
		cAgeLoja  := aBanco[2]
		cCtaLoja  := aBanco[3]
	Endif 		
Endif 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o Array aDescMotBx contendo apenas a descricao do   ³
//³ motivo das Baixas.									 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to len( aMotBx )
	If Substr(aMotBx[nI],34,01) == "A" .or. Substr(aMotBx[nI],34,01) =="R"
		AADD( aDescMotbx,Substr(aMotBx[nI],07,10))
		If Substr(aMotBx[nI],01,03) == cMotivo
			cMotBx := Substr(aMotBx[nI],07,10)		
		Endif 		
	EndIf
Next

While lConfirma

	DEFINE MSDIALOG oDlg FROM 30,16 To 280, 300  TITLE OemToAnsi(STR0004) PIXEL //"Baixa Autom tica"
    
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,40,40,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 002,002+nEspLarg TO 107, 142+nEspLarg PIXEL OF oPanel 
	
	@ 004,005+nEspLarg SAY OemToAnsi(STR0017) SIZE 50,08 PIXEL OF oPanel // "Vencimento"
	@ 013,005+nEspLarg MSGET dVencIni SIZE 50,08  PIXEL OF oPanel HASBUTTON
	@ 013,060+nEspLarg SAY	OemToAnsi(STR0018) SIZE 10,08  PIXEL OF oPanel // "at‚ " 
	@ 013,080+nEspLarg MSGET dVencFim Valid dVencFim >= dVencIni SIZE 50,08  PIXEL OF oPanel HASBUTTON

	@ 023,005+nEspLarg SAY OemToAnsi(STR0019) SIZE 40,08 PIXEL OF oPanel // "Cliente "
	@ 032,005+nEspLarg MSGET cCliDe	F3 "SA1"  SIZE 60,08  PIXEL OF oPanel HASBUTTON
	@ 023,060+nEspLarg SAY	OemToAnsi(STR0025) SIZE 20,08  PIXEL OF oPanel // "Loja"
	@ 032,080+nEspLarg MSGET cLjDe	 SIZE 30,08  PIXEL OF oPanel HASBUTTON

	@ 042,005+nEspLarg SAY	OemToAnsi(STR0020) SIZE 40,08  PIXEL OF oPanel // "Mot.Baixa"
	@ 051,005+nEspLarg COMBOBOX oCbx VAR cMotBx ;
					ITEMS aDescMotBx SIZE 65, 47  PIXEL OF oPanel ;
					Valid (ShowMotBx("R",.T.), cBcoLoja:= CRIAVAR("A6_COD"),;
												cAgeLoja:= CRIAVAR("A6_AGENCIA"),;
												cCtaLoja:= CRIAVAR("A6_NUMCON"))

	@ 063,005+nEspLarg Say OemToAnsi(STR0021) SIZE 30,08  PIXEL OF oPanel  // "Banco : " 
  	@ 072,005+nEspLarg MSGET oBancoLoja VAR cBcoLoja F3 "SA6" When MovBcoBx(cMotBx, .T.) Valid CarregaSa6(@cBcoLoja,,,.T.) SIZE 30,08  PIXEL OF oPanel HASBUTTON
	@ 063,040+nEspLarg Say OemToAnsi(STR0022) SIZE 30,08  PIXEL OF oPanel // "Agˆncia : "
  	@ 072,040+nEspLarg MSGET cAgeLoja When MovBcoBx(cMotBx, .T.) Valid CarregaSa6(@cBcoLoja,@cAgeLoja,,.T.) SIZE 30,08 PIXEL OF oPanel HASBUTTON
	@ 063,080+nEspLarg Say OemToAnsi(STR0023) SIZE 30,08  PIXEL OF oPanel // "Conta : "
  	@ 072,080+nEspLarg MSGET cCtaLoja When MovBcoBx(cMotBx, .T.) Valid If(CarregaSa6(@cBcoLoja,@cAgeLoja,@cCtaLoja,.T.,,.T.),.T.,oBancoLoja:SetFocus()) PIXEL OF oPanel SIZE 60,08 HASBUTTON

	DEFINE SBUTTON FROM 110,083 TYPE 1 ACTION { nOpt:=1 , oDlg:End() } ENABLE OF oDlg
	DEFINE SBUTTON FROM 110,113 TYPE 2 ACTION { nOpt:=2 , oDlg:End() } ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER                                       
	
	If nOpt == 1 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa rotina que exibe tela de escolha de titulos e retorna array com os titulos escolhidos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        

		aTitSE1 := PRCLOJA850( cCliDe,cLjDe,dVencIni,dVencFim,cBcoLoja,cAgeLoja,cCtaLoja,cMotBx )
		
		If Len(aTitSE1) == 0
			Aviso( STR0001 , STR0026 , { STR0003 } ) //"Atenção","Nenhuma movimentacao sera feita!"
		Else		
		
			Begin Transaction		
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta  o flag da rotina automatica como falso (sem erro), antes de executá-la pela primeira vez³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lMsErroAuto := .F.
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ POSICOES DO ARRAY "ATITSE1"	 ³
				//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
				//³aTitSE1[nX][01] - Filial 	 ³
				//³aTitSE1[nX][02] - Prefixo 	 ³
				//³aTitSE1[nX][03] -	Nr.Titulo³
				//³aTitSE1[nX][04] - Parcela	 ³
				//³aTitSE1[nX][05] - Tipo		 ³
				//³aTitSE1[nX][06] - Cliente	 ³
				//³aTitSE1[nX][07] - Lj.Cliente	 ³
				//³aTitSE1[nX][08] - Dt.Emissao	 ³
				//³aTitSE1[nX][09] - Dt.Venc.Real³
				//³aTitSE1[nX][10] -	Vlr.Saldo³
				//³aTitSE1[nX][11] - Nome Cliente³
				//³aTitSE1[nX][12] -	Historico³
				//³aTitSE1[nX][13] - Valor Pago  ³
				//³aTitSE1[nX][14] - Desconto  	 ³
				//³aTitSE1[nX][15] - Acrescimo   ³												
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 to Len(aTitSE1)
				

					If aTitSE1[nX][13] > 0 
					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se um dos titulos nao puder ser incluido via msExecAuto, nao fara'   ³
						//³o msExecAuto para o restante dos titulos,  e fara' o rollback de toda³
						//³a transação fora deste laco For-Next, no If-Endif logo abaixo        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						
						If !lMsErroAuto
		
							aBaixa := {}
							aAdd(aBaixa , {"E1_PREFIXO"   , aTitSE1[nX][02], NIL})
							aAdd(aBaixa , {"E1_NUM"       , aTitSE1[nX][03], NIL})
							aAdd(aBaixa , {"E1_PARCELA"   , aTitSE1[nX][04], NIL})
							aAdd(aBaixa , {"E1_TIPO"      , aTitSE1[nX][05], NIL})
							aAdd(aBaixa , {"AUTMOTBX"	   , cMotBx			, Nil})
							aAdd(aBaixa , {"AUTBANCO"	   , cBcoLoja			, Nil})
							aAdd(aBaixa , {"AUTAGENCIA"	   , cAgeLoja			, Nil})
							aAdd(aBaixa , {"AUTCONTA"	   , cCtaLoja			, Nil})
							aAdd(aBaixa , {"AUTDTBAIXA"		, dDataBase			, Nil})
							aAdd(aBaixa , {"AUTDTCREDITO"	, dDataBase			, Nil})
							aAdd(aBaixa , {"AUTHIST"		, cHstBxTit			, Nil})
							aAdd(aBaixa , {"AUTDESCONT"		, aTitSE1[nX][14]	, Nil})
							aAdd(aBaixa , {"AUTDECRESC"		, 0					, Nil})
							aAdd(aBaixa , {"AUTACRESC"		, 0					, Nil})
							aAdd(aBaixa , {"AUTMULTA"		, aTitSE1[nX][15]	, Nil})
							aAdd(aBaixa , {"AUTJUROS"		, 0					, Nil})
							aAdd(aBaixa , {"AUTVALREC"		, aTitSE1[nX][13]	, Nil})
				
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Executa a Baixa do Titulo pela rotina "Baixas a Receber"          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							MSExecAuto({|x, y| Fina070(x, y )}, aBaixa, 3)
							
						EndIf
						
					Endif 
								
				Next nX
	
				If lMsErroAuto
					
					DisarmTransaction()
					Aviso( STR0001 , STR0026 , { STR0003 } ) //"Atenção","Nenhuma movimentacao sera feita!"
					MostraErro()
					
				Else			
	
					Aviso( STR0027 , STR0028 , { STR0003 } ) //"Sucesso","Todos os títulos selecionados foram baixados.","OK"	
	                            
	
				Endif 
			End Transaction 				

		Endif 
		
		lConfirma := .F. 	
		
	Else
	
		lConfirma := .F. 		
	Endif 	

Enddo	

RestArea(aArea)

Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PRCLOJA850³ Autor ³ Vendas Cliente      ³ Data ³ 18/04/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento para fitlro e selecao dos titulos referente  ³±±
±±³          ³ ao Conta Corrente                    		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA850()						                  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGALOJA							                   	  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PRCLOJA850( cCliDe,cLjDe,dVencIni,dVencFim,cBcoLoja,cAgeLoja,cCtaLoja,cMotBx )

Local cQuery 	:= ""												//Guarda Sentenca SQL
Local aTits	 	:= {}												//Array com os títulos localizados no SE1, para montar a listbox
Local aTitsRet	:= {}												//Array a ser retornado somente com os titulos selecionados
Local aAreaSE1 	:= SE1->(GetArea())								//Guarda area da tabela SE1
Local cPictVlr1	:= PesqPict("SE1","E1_SALDO")						//Picture para valor na Listbox
Local nImpTit	:= 0												//Impostos sobre os titulos
Local nTotAbrt	:= 0												//Totalizador para títulos em aberto (todos os titulos listados)
Local nTotSel	:= 0												//Totalizador para os titulos selecionados
Local nOpt		:= 0												//Opcao Escolhida ao clicar-se em um botao("OK"==1, "Cancelar"==2)
Local nX		:= 0												//Contador para For-Next
Local nPos		:= 0												//Guarda posicao de um array, obtida por aScan
Local nImpTits	:= 0												//Guarda o valor dos titulos de impostos, para abater do titulo principal
Local cLbxHdr  	:= ""												//Header da Listbox
Local cAbatImps	:= SuperGetMv("MV_LJ850AI",,"S")					//Abate os impostos do titulo principal
Local cNatCCor	:= SuperGetMv( "MV_NATCCOR" , .F. , "OUTROS" ,  )	//Natureza referente a Conta Corrente
Local cTipoTit 	:= "FI"												// Simbolo da moeda 1	
Local lConfirma := .T.												//Enquanto .T., exibe a Dialog para o usuario
Local lMark     := .F.												//Se .T. carrega oOk na ListBox - se .F. carrega oNo
Local lChk 		:= .F.												//Se .T. marca todos - se .F. desmarca
Local oOk       := LoadBitmap( GetResources(), "CHECKED" )  			//Bitmap "Marcado", se lMark == .T.
Local oNo       := LoadBitmap( GetResources(), "UNCHECKED" )			//Bitmap "Nao Marcado", se lMark == .F.
Local oDlg							//Objeto tela principal
Local oTotSel						//Objeto totalizador para os titulos selecionados
Local oChk							//Objeto checkbox
Local oLbx							//Objeto listbox
Local oBold							//Objeto fonte para exibicao de totalizadores em destaque na parte inferior da dialog oDlg
LOCAL aSize		:= {}				//Tamanho
Local aObjects 	:= {}				//Array com Objetos								
Local aInfo		:= {}				//Array com Informacoes
Local aPosObj	:= {}   			// Objetos
Local oGet01    := Nil				// Objeto de Entrada
Local oGet02	:= Nil             	// Objeto de Entrada
Local oGet03	:= Nil				// Objeto de Entrada
Local nVlrPagto	:= 0				// Valor Pago
Local nVlrAcresc:= 0				// Valor de Acrecimo
Local nVlrDesc	:= 0				// Valor Desconto
Local cNomeSA1	:= ""				// Nome Sa1
Local nVlrBaixa	:= 0				// Valor da Baixa
Local nVlrBxDes	:= 0				// Valor da Baixa desconto
Local nVlrBxAcr := 0				// Valor da Baixa do acrescimo
Local nSldDesc	:= 0				// Saldo Acrescimo
Local nSldAcre	:= 0				// Saldo Acrescimo
Local cSE1Alias	:= GetNextAlias()	// Pega o alias

Default cCliDe		:= ""
Default cLjDe      	:= ""
Default dVencIni    := dDataBase
Default dVencFim   	:= dDataBase
Default cBcoLoja    := ""
Default cAgeLoja    := ""
Default cCtaLoja    := ""
Default cMotBx      := ""

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura os titulos em aberto, de acordo com os parametros³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery	:=	"SELECT "
	cQuery	+=		"E1_FILIAL, "
	cQuery	+=		"E1_NUM, " 
	cQuery	+=		"E1_PREFIXO, " 
	cQuery	+=		"E1_PARCELA, "
	cQuery	+=		"E1_TIPO, "
	cQuery	+=		"E1_NOMCLI, "
	cQuery	+=		"E1_CLIENTE, "
	cQuery	+=		"E1_LOJA, "
	cQuery	+=		"E1_EMISSAO, "
	cQuery	+=		"E1_VENCREA, "
	cQuery	+=		"E1_SALDO, "
	cQuery	+=		"E1_ACRESC, "
	cQuery	+=		"E1_HIST "
	cQuery	+= "FROM "
	cQuery	+= 	  RetSqlName("SE1") + " "
	cQuery	+= "WHERE "
	cQuery	+=	 	"E1_FILIAL  = '" + xFilial("SE1")	+ "' AND "
	cQuery	+=	 	"E1_CLIENTE =  '" + cCliDe + "' AND " 
	cQuery	+=		"E1_LOJA    = '" + cLjDe			+ "' AND "
	cQuery	+=		"E1_TIPO    = '" + cTipoTit			+ "' AND "
	cQuery	+=		"E1_NATUREZ = '" + cNatCCor			+ "' AND "
	cQuery	+=		"E1_SITUACA ='0' AND "
	cQuery	+=		"E1_ORIGEM  IN ('LOJA701','LOJA010') AND "
	cQuery	+=	 	"E1_VENCTO BETWEEN  '" + DtoS(dVencIni) + "' AND '" + DtoS(dVencFim) + "' AND "
	cQuery	+=		"E1_STATUS  = 'A' AND "
	cQuery	+=		"E1_SALDO   <> 0 AND "
	cQuery	+=		"D_E_L_E_T_ <> '*' "
	cQuery  += 	"ORDER BY "+SqlOrder(SE1->(IndexKey()))
	cQuery	:= ChangeQuery(cQuery)
	
	If Select("TSE1") > 0
		TSE1->(dbCloseArea())
	EndIf
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TSE1", .F., .T. )
	TcSetField("TSE1","E1_VENCREA","D",8,0)
	TcSetField("TSE1","E1_EMISSAO","D",8,0)
	TcSetField("TSE1","E1_SALDO",  "N", TamSX3("E1_SALDO")[1],TamSX3("E1_SALDO")[2])
	TcSetField("TSE1","E1_ACRESC",  "N", TamSX3("E1_ACRESC")[1],TamSX3("E1_ACRESC")[2])
	
	TSE1->(dbGoTop())
	While TSE1->(!EOF())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura por titulos de impostos para fazer o abatimento do valor total, se paramatrizado MV_LJ850AI (default = "S", abate)		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cAbatImps == "S"
			nImpTits := 0
			SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			SE1->(DbSeek(TSE1->E1_FILIAL + TSE1->E1_CLIENTE + TSE1->E1_LOJA + TSE1->E1_PREFIXO + TSE1->E1_NUM + TSE1->E1_PARCELA))
			While SE1->(!EOF()) .And. SE1->E1_FILIAL==TSE1->E1_FILIAL .And. SE1->E1_CLIENTE==TSE1->E1_CLIENTE .And. SE1->E1_LOJA==TSE1->E1_LOJA .And. SE1->E1_PREFIXO==TSE1->E1_PREFIXO .And. SE1->E1_NUM==TSE1->E1_NUM .And. SE1->E1_PARCELA==TSE1->E1_PARCELA
		   	If SE1->E1_TIPO <> cTipoTit
		   		If SubStr(SE1->E1_TIPO,3,1) == "-"
		   			nImpTits += SE1->E1_SALDO
		   		EndIf
		   	EndIf
		   	SE1->(dbSkip())
		 	EndDo
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³nImpTits so' sera' alimentada se parametrizado para abater titulos,³
		//³portanto, caso nao esteja parametrizado, seu valor sera' zero.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	aAdd( aTits, {	lMark,;
	  						TSE1->E1_PREFIXO,;
	  						TSE1->E1_NUM,;
	  						TSE1->E1_PARCELA,;
	  						TSE1->E1_NOMCLI,;
	  						DtoC(TSE1->E1_EMISSAO),;
	  						DtoC(TSE1->E1_VENCREA),;
							Transform(TSE1->E1_SALDO - nImpTits,cPictVlr1),;
							TSE1->E1_HIST,;
	  						TSE1->E1_SALDO - nImpTits,;
	  						TSE1->E1_FILIAL,;
	  						TSE1->E1_TIPO,;
							TSE1->E1_CLIENTE,;
	  						TSE1->E1_LOJA,;
	  						TSE1->E1_ACRESC })
	  	nTotAbrt += TSE1->E1_SALDO - nImpTits
	
		TSE1->(dbSkip())
	EndDo
	TSE1->(dbCloseArea())
#ELSE
	ChkFile("SE1",.F.,cSE1Alias)
	(cSE1Alias)->(DbSetOrder(2))
	If (cSE1Alias)->(DbSeek(xFilial("SE1")+ cCliDe + cLjDe))
	
		While !(cSE1Alias)->(EOF()) .And. (cSE1Alias)->E1_FILIAL == xFilial("SE1") .And. (cSE1Alias)->E1_CLIENTE == cCliDe .And. (cSE1Alias)->E1_LOJA == cLjDe 
		
			If (cSE1Alias)->E1_VENCTO  >= dVencIni .And. (cSE1Alias)->E1_VENCTO <= dVencFim 		

				If 	(cSE1Alias)->E1_SITUACAO == "0" .And. ( Alltrim((cSE1Alias)->E1_ORIGEM)	== "LOJA701" .OR. Alltrim((cSE1Alias)->E1_ORIGEM)	== "LOJA010" );
					.And. (cSE1Alias)->E1_STATUS == "A" .And. (cSE1Alias)->E1_SALDO != 0 ;
					.And. Alltrim((cSE1Alias)->E1_TIPO) == Alltrim(cTipoTit) .And. Alltrim((cSE1Alias)->E1_NATUREZ)  == Alltrim(cNatCCor)
					
					

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Procura por titulos de impostos para fazer o abatimento do valor total, se paramatrizado MV_LJ850AI (default = "S", abate)		³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cAbatImps == "S"
						nImpTits := 0
						(cSE1Alias)->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						(cSE1Alias)->(DbSeek((cSE1Alias)->E1_FILIAL + (cSE1Alias)->E1_CLIENTE + (cSE1Alias)->E1_LOJA + (cSE1Alias)->E1_PREFIXO + (cSE1Alias)->E1_NUM + (cSE1Alias)->E1_PARCELA))
						While SE1->(!EOF()) .And. SE1->E1_FILIAL == (cSE1Alias)->E1_FILIAL .And. SE1->E1_CLIENTE == (cSE1Alias)->E1_CLIENTE .And. SE1->E1_LOJA == (cSE1Alias)->E1_LOJA .And. SE1->E1_PREFIXO == (cSE1Alias)->E1_PREFIXO .And. SE1->E1_NUM == (cSE1Alias)->E1_NUM .And. SE1->E1_PARCELA == (cSE1Alias)->E1_PARCELA
						   	If SE1->E1_TIPO <> cTipoTit
						   		If SubStr(SE1->E1_TIPO,3,1) == "-"
						   			nImpTits += SE1->E1_SALDO
						   		EndIf
						   	EndIf
						   	SE1->(dbSkip())
					 	EndDo
					EndIf
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³nImpTits so' sera' alimentada se parametrizado para abater titulos,³
					//³portanto, caso nao esteja parametrizado, seu valor sera' zero.     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				  	aAdd( aTits, {	lMark,;
				  						(cSE1Alias)->E1_PREFIXO,;
				  						(cSE1Alias)->E1_NUM,;
				  						(cSE1Alias)->E1_PARCELA,;
				  						(cSE1Alias)->E1_NOMCLI,;
				  						DtoC((cSE1Alias)->E1_EMISSAO),;
				  						DtoC((cSE1Alias)->E1_VENCREA),;
										Transform((cSE1Alias)->E1_SALDO - nImpTits,cPictVlr1),;
										(cSE1Alias)->E1_HIST,;
				  						(cSE1Alias)->E1_SALDO - nImpTits,;
				  						(cSE1Alias)->E1_FILIAL,;
				  						(cSE1Alias)->E1_TIPO,;
										(cSE1Alias)->E1_CLIENTE,;
				  						(cSE1Alias)->E1_LOJA,;
				  						(cSE1Alias)->E1_ACRESC })
				  	nTotAbrt += (cSE1Alias)->E1_SALDO - nImpTits     			

				Endif 		    	
	    	Endif 
			(cSE1Alias)->(DbSkip())	
	    Enddo
	Endif 

IIf( Select( cSE1Alias ) > 0, ( cSE1Alias )->( dbCloseArea() ) , Nil )
	
#ENDIF 	
RestArea(aAreaSE1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sai da rotina sem apresentar a Dialog para o usuario, caso nao haja titulos em aberto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aTits ) == 0
   Aviso( STR0001, STR0002 , { STR0003 } ) // "Atencao","Nao existem tÍtulos em aberto para este cliente.","OK"
   Return(aTits)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa o nome do cliente apresentar no Dialog     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+cCliDe+cLjDe))
	cNomeSA1:= Alltrim(SA1->A1_NOME)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta dialogo para a escolha dos titulos pesquisados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aadd( aObjects, {  30,  70, .T., .T.} )
aadd( aObjects, {  20, 180, .T., .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj := MsObjSize( aInfo, aObjects )

While lConfirma

	DEFINE Font oBold Name "Arial" SIZE 0,-12 Bold
	DEFINE MSDIALOG oDlg TITLE STR0004 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Baixa Conta Corrente"
	oDlg:lMaximized := .T.
	
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,85,85,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP
	
	@  0,  1 TO 84,aSize[5]	 OF oPanel PIXEL
	@ 6,   6 Say STR0019 OF  oPanel PIXEL
	@ 6,   73 Say STR0025 OF  oPanel PIXEL
	@ 6,   120 Say STR0029 OF  oPanel PIXEL		
	@ 16,  6  Say cCliDe	Color CLR_BLUE Of oPanel Pixel Font oBold //	Color CLR_BLUE Of oDlg Pixel Font oBold 
	@ 16,  73 Say cLjDe		Color CLR_BLUE Of oPanel Pixel Font oBold //	Color CLR_BLUE Of oDlg Pixel Font oBold 
	@ 16,  120 Say cNomeSA1	Color CLR_BLUE Of oPanel Pixel Font oBold //	Color CLR_BLUE Of oDlg Pixel Font oBold 		
	@ 26,  6 TO 80,152 PROMPT STR0010 OF oPanel PIXEL //"Titulos"	
	@ 26,156 TO 80,311 PROMPT STR0013 OF oPanel PIXEL //"Valores"	
	@ 36, 11 SAY STR0006 OF oPanel PIXEL //"Total em Aberto"
	@ 49, 11 SAY STR0007 OF oPanel PIXEL //"Total Selecionado"	
	@ 36,162 SAY STR0014  OF oPanel PIXEL //"Valor a Pagar"
	@ 49,162 SAY STR0015 OF oPanel PIXEL //"Acréscimo"	
	@ 62,162 SAY STR0016 OF oPanel PIXEL //"Desconto"		
	
	@ 34, 73 MSGET nTotAbrt   SIZE 76,10 OF oPanel WHEN .F. PICTURE TM(nTotAbrt,21,TamSX3("E1_SALDO")[2]) PIXEL Hasbutton
	@ 49, 73 MSGET oTotSel VAR nTotSel    SIZE 76,10 OF oPanel WHEN .F. PICTURE TM(nTotSel,21,TamSX3("E1_SALDO")[2]) PIXEL Hasbutton	
	@ 64 ,11 CheckBox oChk Var lChk PROMPT STR0005 Size 80,007 Pixel Of oDlg On Click(aEval(aTits,{|x| x[1]:=lChk}), nTotSel:=LJ850TitSel(aTits)[1],nVlrAcresc:=LJ850TitSel(aTits)[2]  , oLbx:Refresh(),oGet02:Refresh(), oTotSel:Refresh()) //"Marca/Desmarca Todos"		
	@ 34,231 MSGET oGet01 VAR nVlrPagto     SIZE 76,10 OF oPanel WHEN .T. VALID .T.  PICTURE "@E 999,999,999.99" PIXEL Hasbutton
	@ 49,231 MSGET oGet02 VAR nVlrAcresc    SIZE 76,10 OF oPanel WHEN .T. VALID .T.	 PICTURE "@E 999,999,999.99" PIXEL Hasbutton	
	@ 62,231 MSGET oGet03 VAR nVlrDesc    	SIZE 76,10 OF oPanel WHEN .T. VALID .T.	 PICTURE "@E 999,999,999.99" PIXEL Hasbutton		
	
	@ 06,365 BUTTON STR0011 SIZE 32, 13 OF oPanel PIXEL ACTION { nOpt:=1 , oDlg:End() }  //"&Confirmar"
	@ 06,401 BUTTON STR0012 SIZE 32, 13 OF oPanel PIXEL ACTION { nOpt:=2 , oDlg:End() }  //"&Sair"	
	
  
	@ aPosObj[2,1]-43, aPosObj[2,2] LISTBOX oLbx Var cLbxHdr FIELDS;
		HEADER " ",;
		RetTitle("E1_PREFIXO") ,; 	//"Prefixo"
		RetTitle("E1_NUM") ,;     	//"Nr.Título"
		RetTitle("E1_PARCELA") ,; 	//"Parcela"
		RetTitle("E1_TIPO") ,;    	//"Tipo"
		RetTitle("E1_NOMCLI") ,;  	//"Nome do Cliente"
		RetTitle("E1_EMISSAO") ,; 	//"Emissão"
		RetTitle("E1_VENCREA") ,; 	//"Venc.Real"
		RetTitle("E1_VALOR") ,;   	//"Valor"
		RetTitle("E1_ACRESC") ,;   	//"Valor"		
		RetTitle("E1_HIST")   ; 	//"Histórico"
	SIZE aPosObj[2,3],aPosObj[2,4]+259;
	COLSIZES GetTextWidth(0,"B"),;
		GetTextWidth(0,"BBB"),;
		GetTextWidth(0,"BBBBBBBBB"),;
		GetTextWidth(0,"BBB"),;
		GetTextWidth(0,"BBB"),;
		GetTextWidth(0,"BBBBBBBBBBBB"),;
		GetTextWidth(0,"BBBBBBB"),;
		GetTextWidth(0,"BBBBBBB"),;
		GetTextWidth(0,"BBBBBBBBBBB"),;	
		GetTextWidth(0,"BBBBBBBBBBB"),;			
		GetTextWidth(0,"BBBBBBBBBBB");
	 OF oDlg ON DBLCLICK (aTits[oLbx:nAt,1] := !aTits[oLbx:nAt,1],oLbx:Refresh(),nTotSel:=LJ850TitSel(aTits)[1],nVlrAcresc:=LJ850TitSel(aTits)[2],oGet02:Refresh(), oTotSel:Refresh()) PIXEL

	oLbx:SetArray( aTits )
	oLbx:bLine := {|| {Iif(	aTits[oLbx:nAt,01],oOk,oNo),;			//	lMark
   	                 		aTits[oLbx:nAt,02],;					//	"Prefixo"
      	              		aTits[oLbx:nAt,03],;					//	"Nr.Título"
         	              	aTits[oLbx:nAt,04],;					//	"Parcela"
            	           	aTits[oLbx:nAt,12],;					//	"Tipo"
            	           	aTits[oLbx:nAt,05],;					//	"Nome do Cliente"
               	        	aTits[oLbx:nAt,06],;					//	"Emissão"
                  	     	aTits[oLbx:nAt,07],;					//	"Venc.Real"
                     	  	aTits[oLbx:nAt,08],;					// "Valor"
                     	  	Transform(aTits[oLbx:nAt,15],cPictVlr1),;	// "Acrescimo"                     	  	
                       		aTits[oLbx:nAt,09]}}					// "Histórico"


	Activate msDialog oDlg Center

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida os titulos escolhidos, quando clicado em "OK"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                              	
	If nOpt == 1
		If (nVlrPagto - nVlrDesc) > 0  //Ajustar
			If nTotSel <> 0	//Se total selecionado for maior que zero, ha' titulos marcados
				nSldDesc  := nVlrDesc
				nSldAcre  := nVlrAcresc
				For nX := 1 to Len(aTits)
					If aTits[nX][1]	//Se marcado (.T.)    admin
					
						nVlrBaixa := 0
						nVlrBxDes := 0
						nVlrBxAcr := 0						
						
						
	    				If nVlrPagto > 0 
	
							If nVlrPagto >= aTits[nX][10] + aTits[nX][15]
			
								nVlrBaixa  := aTits[nX][10] + aTits[nX][15]
								nVlrBxDes  := ( (nVlrDesc/nTotSel)* nVlrBaixa )
								nVlrBxAcr  := ( (nVlrAcresc/nTotSel)* nVlrBaixa )
								nVlrBaixa  -= nVlrBxDes
								nVlrBaixa  += nVlrBxAcr								
								nVlrPagto  -= nVlrBaixa
								nSldDesc   -= nVlrBxDes
								nSldAcre   -= nVlrBxAcr
								
							Else
		
								nVlrBaixa  := ( nVlrPagto )
								nVlrBxDes  := nSldDesc
								nVlrBxAcr  := nSldAcre
								nVlrPagto  -= nVlrPagto								
							
							Endif 						
	
						Endif 
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Monta array de retorno, com informacoes necessarias para a pesquisa dos titulos³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAdd(aTitsRet,{ 	aTits[nX][11],;	// Filial
												aTits[nX][02],;	// Prefixo
												aTits[nX][03],;	// Nr.Titulo
												aTits[nX][04],;	// Parcela
												aTits[nX][12],;	// Tipo
												aTits[nX][13],;	// Cliente
												aTits[nX][14],;	// Lj.Cliente
												aTits[nX][06],;	// Dt.Emissao
												aTits[nX][07],;	// Dt.Venc.Real
												aTits[nX][10],;	// Vlr.Saldo
												aTits[nX][05],;	// Nome Cliente
												aTits[nX][09],;	// Historico
												nVlrBaixa,;	// Valor Pago											
												nVlrBxDes,;	// Desconto 
												nVlrBxAcr})	// Acre´scimo																																	
					EndIf
				Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Desmarca flag para sair da Dialog³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lConfirma := .F.	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se clicou em "OK" e não ha' títulos marcados, avisa o usuario, e retorna 'a Dialog³
				//³(para sair da rotina o usuario deve clicar em "Cancelar")                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Aviso(STR0008, STR0009 , { STR0003 } )  //"Escolha os títulos!","Nenhum título foi marcardo.","OK"
			EndIf	
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao será possível efetuar baixas considerando valores negativos                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aviso(STR0001, STR0030 , { STR0003 } )  //"Atencao","O Valor Final da Baixa (Valor Recebido + Acréscimo - Desconto) deverá ser maior que zero.","OK"		
		
		Endif 			
	ElseIf nOpt == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se clicou em "Cancelar", desmarca o flag lConfirma, para poder sair da Dialog,³
		//³e zera o array de retorno, que devera' ser tratado pela funcao principal      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lConfirma := .F.
		aTitsRet  := {}
		nTotSel   := 0
	EndIf

EndDo

Return( aTitsRet )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOJA850  ³ Autor ³ Vendas Cliente      ³ Data ³ 18/04/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar o valor dos tituos selecionados para o objeto     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA850()						                  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGALOJA							                   	  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LJ850TitSel(aTitSel)

Local nX 		:= 0	//Contador para For-Next
Local nVlrSel	:= 0	//Valor a retornar, referente aos titulos selecionados
Local nVlrAcr	:= 0	//Valor a retornar, referente ao acréscimo dos titulos selecionados

Default aTitSel := {}

For nX := 1 to Len(aTitSel)
	If aTitSel[nX][1] == .T.
		nVlrSel += aTitSel[nX][10]
		nVlrAcr += aTitSel[nX][15]
	Endif
Next nX

Return {nVlrSel, nVlrAcr}