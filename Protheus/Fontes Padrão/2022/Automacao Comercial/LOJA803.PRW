#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH" 
#INCLUDE "LOJA803.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJ803GetMe ³ Autor ³ Vendas Clientes      ³ Data ³ 16/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Buaco valores da tabela men       						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³LJ803GetMen(lExp1, oExp2, oExp3,oExp3 )              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Adm 				                                  ³±±
±±³          ³ cExp2 - Banco						                      ³±±
±±³          ³ nExp3 - Parcela	                                          ³±±
±±³          ³ lExp4 - Vem de uma array	  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA701 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ803GetMen(cAdm, cBanco, nParcela, lArray)

Local aRet := {} 			// Variavel de Retorno
Local lContinua		:= .T. // Continua no Loop
Local aReaSA1		:= {}	// Backup da Arew 
Local cNomBanco		:=	""  // Nome do banco

Default cAdm 		:= ''
Default cBanco 		:= 	Space(TamSX3("A1_COD")[1])
Default nParcela 	:= 0
Default lArray		:= .F.

DbSelectArea("MEN")
DbSetOrder(2) //MEN_FILIAL+MEN_CODADM+MEN_BANCO

If DbSeek(xFilial("MEN")+cAdm+cBanco) 
	While (!EOF()) .AND. (lContinua) .AND. (cAdm == MEN->MEN_CODADM) .AND. (cBanco == MEN->MEN_BANCO .OR. lArray)	
		If (MEN->MEN_PERDES > 0) .AND. (nParcela >= MEN->MEN_PARINI) .AND. (nParcela <= MEN->MEN_PARFIN) .AND.;
			(dDataBase >= MEN->MEN_DATINI) .AND. (dDataBase <= MEN->MEN_DATFIM)
			If !lArray
				AAdd(aRet,{MEN->MEN_PERDES, MEN->MEN_GERFIN} )
				lContinua := .F.
			Else
				aReaSA1 := GetArea("SA1")				
				DbSelectArea("SA1")
				If DbSeek(xFilial("SA1")+MEN->MEN_BANCO)
					cNomBanco := SA1->A1_NOME
					AAdd(aRet,{MEN->MEN_BANCO, cNomBanco} )
				EndIf
				RestArea(aReaSA1)
			EndIf				
		EndIf
		DbSkip()	
	End
Else	
	aRet := {}
EndIf




Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJ803Tela  ³ Autor ³ Vendas Clientes      ³ Data ³ 16/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de banco                         					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³LJ803GetMen(lExp1, oExp2, oExp3) 		              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp1 - Array com desconto                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA701 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ803Tela(aList)

Local cRet 		:= '' 	// retorno da variavel
Local oDlgMen	:= Nil 	// Tela
Local oFntBox	:= Nil	// Fonte
Local oListMen	:= Nil 	// Lista 

Default aList := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tela de selecao de cartoes.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFntBox NAME "Courier New"
DEFINE MSDIALOG oDlgMen TITLE STR0001 FROM 0,0 TO 230, 190 PIXEL OF GetWndDefault()//"BANCO"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objeto Listbox.                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 0, 0 ListBox oListMen Fields ;
		HEADER STR0002,STR0002; //"CODIGO", "BANCO"
		Size 122, 109 Of oDlgMen Pixel;
		ColSizes 50,50 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configurando ListBox.                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oListMen:SetArray(aList)
oListMen:bLine := {|| { aList[oListMen:nAt][1], aList[oListMen:nAt][2] }  }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configurando Duplo clique do ListBox.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oListMen:bLDblClick := {|| cRet := aList[oListMen:nAt][1], oDlgMen:End() }


DEFINE SBUTTON FROM 133, 175 TYPE 1 ACTION (oDlgMen:End()) ENABLE PIXEL OF oDlgMen


ACTIVATE MSDIALOG oDlgMen CENTERED

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJ803GetMe ³ Autor ³ Vendas Clientes      ³ Data ³ 16/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para definicao do pagamento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³LJ803GetMen(lExp1, oExp2, oExp3) 		              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExp1 - Define se e para criar os objetos 				  ³±±
±±³          ³ oExp2 - Objeto que contera o Panel						  ³±±
±±³          ³ oExp3 - Objeto que contem a dialog principal (LOJA701)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA701 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ803SE1()

Local c1DUP := SuperGetMV("MV_1DUP") 	// Sequência das parcelas "1" = 1..9;A..Z;a..z    e   "A" = A..Z
Local nPCC 	:= 0 						// Gera parcela
Local cCodCLi	:= ""					// Codigo cliente
Local cLojCli   := ""					// loja Cliente
Local aAreaSa1	:= {}					// area do cliente
Local cTipo		:= "DP"					// DEPLICATA
Local cPrefTit	:= SuperGetMV("MV_LJPREPA", , "OUTROS    ")		// Prefixo
Local cNature	:= SuperGetMV("MV_LJNATPA", , "PTC")			// Natureza

Private lMsErroAuto	:= .F.

DbSelectArea("SL4")
DbSetOrder(1)
If DbSeek( xFilial( "SL4" ) + SL1->L1_NUM )
	While SL4->(!EOF()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial( "SL4" ) + SL1->L1_NUM
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa AutoExec para registrar SE1, so se tiver Banco ou adm patrocinando      ³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL4->L4_DESPRC > 0 .AND. !Empty(SL4->L4_BANPRC)
			
			aAreaSa1 := GetArea()
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+SL4->L4_BANPRC)			
				cCodCLi	:= SA1->A1_COD					 
				cLojCli := SA1->A1_LOJA			
			
				nPCC ++
				cParcela	:= LJParcela(nPCC, c1DUP)
				aSE1  := { 	{"E1_FILIAL"	,xFilial("SE1")											,Nil},; 
						    {"E1_PREFIXO"	,cPrefTit												,Nil},; 
							{"E1_NUM"	  	,SL4->L4_NUM											,Nil},; 
							{"E1_PARCELA" 	,cParcela 												,Nil},; 
							{"E1_TIPO"	 	,cTipo													,Nil},; 
							{"E1_NATUREZ" 	,cNature												,Nil},; 
							{"E1_PORTADO" 	, ''   /*cPortador*/									,Nil},; 
					    	{"E1_CLIENTE" 	,cCodCLi												,Nil},; 
					        {"E1_LOJA"	  	,cLojCli												,Nil},; 
							{"E1_EMISSAO" 	,dDatabase 												,Nil},;
							{"E1_VENCTO"  	,SL4->L4_DATA											,Nil},;
							{"E1_VENCREA" 	,SL4->L4_DATA											,Nil},;
							{"E1_MOEDA" 	,1														,Nil},;
							{"E1_ORIGEM"	,"LOJA803"												,Nil},;
							{"E1_FLUXO"		,"S"													,Nil},;
							{"E1_VALOR"	  	,SL4->L4_DESPRC											,Nil},;
							{"E1_VLRREAL"  	,SL4->L4_DESPRC											,Nil},;
							{"E1_HIST"		,STR0004												,Nil}} // "PATROCINIO DE DESCONTO"
				
				MSExecAuto({|x,y| Fina040(x,y)},aSE1, 3) //Inclusao
						
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
				EndIf				
			EndIf		
			RestArea(aAreaSa1)
		EndIf
		SL4->(DbSkip())
	End
EndIf							
Return(.T.)