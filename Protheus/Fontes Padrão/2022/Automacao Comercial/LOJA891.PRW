#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "LOJA891.CH"

#DEFINE INSERIR   1
#DEFINE ID 2
#DEFINE EMISSAO 3
#DEFINE COD_VEND 4
#DEFINE SECAO 5
#DEFINE PRO_COD 7
#DEFINE PRO_DESC 6
#DEFINE IT_QUANT 8
#DEFINE IT_VRUNIT 9
#DEFINE IT_VLRITEM 10
#DEFINE CLI_NOM 11
#DEFINE CLI_CPF 12
#DEFINE CLI_EMAIL 13
#DEFINE CLI_TEL 14


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJA891()
Rotina responsavel pela importação do arquivo ftp uMov.me

@author Vendas CRM
@since 19/08/2013
/*/
//------------------------------------------------------------------------------------------------

Function LOJA891(cXml)

Local aArea 	  := GetArea()
Local aAreaSA3 	  := SA3->(GetArea())
Local aAreaSA1 	  := SA1->(GetArea())
Local aAreaSBM 	  := SBM->(GetArea())
Local cLinha 	  := ""
Local cArq 	   	  := cXml
Local aDados 	  := {}
Local aCampos 	  := {}
Local cVincVend   := SuperGetMv("MV_VINCVEN")
Local nX		  := 1
Local lMsExec 	  := ExistBlock("Lj891Ent")
Local cError	  := ""
Local cWarning	  := ""
Local nHandle
Local cUkey       := ""
Local aChave	  := {}
Local cArquivo	  := ""
Local cRet		  := ""
Local oXml		  := Nil

Local cNum			:= ""					// Número do Próximo Orçamento
Local aCabec        := {}					// Array de Cabeçalho, para enviar para Loja701
Local aItem 		:= {}					// Array de Item, que prepara para gravar no array Itens
Local aItens		:= {}					// Array para Itens para enviar à Loja701
Local aPagPV		:= {}					// Array para Condição de Pagamento para enviar à Loja701
Local cUnidade		:= ""					// Unidade de Medida
Local ntotItem		:= 0					// Total dos Itens
Local cCodCliente	:= ""					// Código do Cliente
Local cTipoCliente  := ""					// Tipo do Cliente
Local cLoja		    := ""					// Código da Loja
Local cCodVend		:= ""					// Código do Vendedor
Local lGrava		:= .T.					// Controle para ver se eu posso gravar na SLQ/SL1
Local cControleID   := ""					// Controle do ID do uMov
Local nContItem	    := 0					// Contador de Itens - se for 1, leio as inf. principais
Local cCodTab		:= "001"				// Tabela Padrão
Local cUmovInf		:= SuperGetMV( "MV_UMOVINF", , "0" )	// 1-Chave Nome, 2-Chave Telefone, 3-Chave e-mail, 4-Chave CPF
Local cTexto        := ""
Local cTextoDetalhe := ""				// Descrição do erro detalhado
Local lDeuErro			:= .F.

Private INCLUI 	  			:= .T.			// Inclui no ExecAuto
Private ALTERA					:= .F.			// Altera no ExecAuto
Private aRotina   := {}

Private lMsHelpAuto          := .T.            // Controle interno do ExecAuto
Private lMsErroAuto          := .F.            // Informa a ocorrência de erros no ExecAuto

oXML := XmlParser(cArq,"_",@cError,@cWarning)

If XmlChildEx( oXML, "_UMOVIMPORT" ) <> Nil
	
	cCaminho := oXML:_UmovImport:_RelativeDirectory:Text+"\"+oXML:_UmovImport:_FileName:Text

	nHandle := FT_FUSE(cCaminho) //Abri o Arquivo.
    conout(STR0001+cCaminho)  // Caminho:

	If nHandle == -1
		Conout(STR0002)  // Sem Arquivo Para Ser Importado.
	Endif
	
	aCabec    := {}
	aItem     := {}
	aItens    := {}
	aPagPV    := {}
	cNum	  := ""
	lGrava	  := .T.
	nContItem := 0
	    
	While !FT_FEof()
		
		cLinha 		:= FT_FReadLn()
		aDados 		:= Separa(cLinha,";")
		aCampos 	:= {}

		If aDados[INSERIR] == "INSERT" //essa linha é importante para que não se leia desde a primeira linha do arquivo ou seja ira ler apartir dos dados

			If 	(aDados[SECAO] == "Produtos do Pedido"  .OR. Left(aDados[SECAO],8) == "Produtos")
			
				If nContItem = 0   // Primeira linha
				
					cControleID := Strzero( Val( aDados[ID] ), TamSx3("LQ_UMOV")[1])

					// Quem é o vendedor?
					cCodVend := aDados[COD_VEND]
						 	
					DBSelectArea("SL1")
				
					// Primeiro, lerei se já foi gravado o controle para o uMov
					DbSetOrder(17)  // SL1->L1_FILIAL + SL1->L1_UMOV
					If SL1->(DbSeek( xFilial("SL1")+cControleID ))
						lGrava := .F.			// não poderei gravar a inclusão novamente
					EndIf
				
					If lGrava
						DbSetOrder(1) //L1_FILIAL+L1_NUM

           				aAdd(aCabec,{"LQ_DESCONT"		,	0													,	NIL})	// Desconto, por enquanto, 0
						aAdd(aCabec,{"LQ_COMIS"			,	0													,	NIL})	// Comissão    
						aAdd(aCabec,{"LQ_TIPOCLI"		,	PadR(cTipoCliente,TamSx3("LQ_TIPOCLI")[1])	,	NIL})	// Tipo de Cliente
						aAdd(aCabec,{"LQ_NROPCLI"		,	"         "										,	NIL})	// Número de OP do Cliente
						aAdd(aCabec,{"LQ_FILIAL"			,	xFilial("SLQ")									,	Nil})	// Filial			 
						aAdd(aCabec,{"LQ_VEND"			,	PadR(cCodVend,TamSx3("LQ_VEND")[1])			,	Nil})	// Vendedor
						aAdd(aCabec,{"LQ_DTLIM"			,	dDatabase											,	NIL})	// Data Limite				
						aAdd(aCabec,{"LQ_DOC"			,	PadR("",TamSx3("LQ_DOC")[1])					,	NIL})	// Documento
						aAdd(aCabec,{"LQ_SERIE"			,	PadR("",TamSx3("LQ_SERIE")[1])					,	NIL})	// Série
						aAdd(aCabec,{"LQ_PDV"			,	PadR("",TamSx3("LQ_PDV")[1])					,	NIL})	// PDV
						aAdd(aCabec,{"LQ_EMISNF"			,	dDatabase											,	NIL})	// Emissão
						aAdd(aCabec,{"LQ_TIPO"			,	"V"													,	NIL})	// Venda
						aAdd(aCabec,{"LQ_DESCNF"			,	0													,	NIL})	// Desconto NF
						aAdd(aCabec,{"LQ_OPERADO"		,	PadR("",TamSx3("LQ_OPERADO")[1])				,	NIL})	// Operador
						aAdd(aCabec,{"LQ_PARCELA"		,	1													,	NIL})	// Número da Parcela
						aAdd(aCabec,{"LQ_CONDPG"			,	SuperGetMV( "MV_LJCONDP",,"001")			  	,	NIL})	// Cond. Pagamento
						aAdd(aCabec,{"LQ_FORMPG"			,	SuperGetMV( "MV_SIMB1",,"R$")					,	NIL})	// Forma Pagamento
						aAdd(aCabec,{"LQ_EMISSAO"		,	Stod(Substr(aDados[EMISSAO],1,4)+Substr(aDados[EMISSAO],6,2)+Substr(aDados[EMISSAO],9,2))							,	Nil})	// Emissao			 
						aAdd(aCabec,{"LQ_UMOV"			,	cControleID										,	Nil})	// Controle uMov.me
					EndIf			 
						 			 	
				EndIf
				
				nContItem++		 						 
						
				If lGrava
			
					cUnidade := ""
					If SB1->( DbSeek( xFilial("SB1") + aDados[PRO_COD] ) )
						cUnidade := SB1->B1_UM
					EndIf
						 
					aAdd(aItem,{"LR_FILIAL"			,   xFilial("SLR")			                        ,	Nil})	// Filial
					aAdd(aItem,{"LR_PRODUTO"			,	PadR(aDados[PRO_COD],TamSx3("LR_PRODUTO")[1])	,	Nil})	// Cod. do Produto				
					aAdd(aItem,{"LR_UM"				,	PadR(cUnidade,TamSx3("LR_UM")[1])				,	NIL})	// Unidade de Medida 
					aAdd(aItem,{"LR_DESC"			,	0               									,	NIL})	// Desconto
					aAdd(aItem,{"LR_VALDESC"			,	0               									,	NIL})	// Valor de Desconto
					aAdd(aItem,{"LR_DOC"				,	PadR("",TamSx3("LR_DOC")[1])					,	NIL})	// DOC
					aAdd(aItem,{"LR_SERIE"			,	PadR("",TamSx3("LR_SERIE")[1])					,	NIL})	// Série
					aAdd(aItem,{"LR_PDV"				,	PadR("",TamSx3("LR_PDV")[1])					,	NIL})	// PDV
					aAdd(aItem,{"LR_TABELA"			,	SuperGetMV( "MV_TABPAD",,"1")					,	NIL})	// Tabela Padrão
					aAdd(aItem,{"LR_DESCPRO"			,	0													,	NIL})	// Desconto do Produto
					aAdd(aItem,{"LR_VEND"			,	PadR(cCodVend,TamSx3("LR_VEND")[1])			,	Nil})	// Cod. do Vendedor	
					aAdd(aItem,{"LR_TES"				,	PadR("",TamSx3("LR_TES")[1])			    	,	Nil})	// Cod. de Entrada e Saída
					aAdd(aItem,{"LR_QUANT"			,	Val(aDados[IT_QUANT])							,	Nil})	// Quant. Item				
					aAdd(aItem,{"LR_VRUNIT"			,	Val(aDados[IT_VRUNIT])							,	Nil})	// Valor Unitário do Item		
					aAdd(aItem,{"LR_VLRITEM"			,	Val(aDados[IT_VLRITEM])							,	Nil})	// Total do Item				
					aAdd(aItens,aItem)
					nTotItem := nTotItem + Val(aDados[IT_VLRITEM])
					aItem    := {}
					
				EndIf
					     
			ElseIf (aDados[SECAO] == "Totais do Pedido" .OR. Left(aDados[SECAO],6) == "Totais")		    
				
				If lGrava
				
					// Aqui eu vou pesquisar CPF/CNPJ
					cCpf := Ret_Pontos(aDados[CLI_CPF])
				
					If !Empty(cCpf)
					
						cCpf := Strzero( Val(cCpf), 11 )
						DbSelectArea( "SA1")
						DbSetOrder(3) //A1_FILIAL+A1_CGC
						lAchouCPF := .F.
						If SA1->( Dbseek( xFilial("SA1")+cCpf ) )  // Vejo se é CPF
							cCodCliente	  := SA1->A1_COD
							cTipoCliente  := "F"
							cLoja		  := SA1->A1_LOJA
							lAchouCPF     := .T.
						Else
							cCpf := Strzero( Val(cCpf), 14 )
							If SA1->( Dbseek( xFilial("SA1")+cCpf ) )  // Vejo se é CNPJ
								cCodCliente  	:= SA1->A1_COD
								cTipoCliente	:= "J"
								cLoja			:= SA1->A1_LOJA
								lAchouCPF       := .T.
							Else
								// Qual é o código padrão do cliente?
								cCodCliente	    := SuperGetMV("MV_CLIPAD",,"000001")
								cTipoCliente	:= "F"
								cLoja			:= SuperGetMV("MV_LOJAPAD",,"01")
								lAchouCPF       := .F.
							EndIf
						EndIf
					Else
						// Qual é o código padrão do cliente?
						cCodCliente	    := SuperGetMV("MV_CLIPAD",,"000001")
						cTipoCliente	:= "F"
						cLoja			:= SuperGetMV("MV_LOJAPAD",,"01")
						lAchouCPF       := .F.
					
					EndIf
					DBSelectArea("SL1")
					DbSetOrder(1) //L1_FILIAL+L1_NUM
					
					aAdd(aCabec,{"LQ_CLIENTE"	, PadR(cCodCliente,TamSx3("LQ_CLIENTE")[1])	,Nil})	// Cliente
					aAdd(aCabec,{"LQ_LOJA"		, PadR(cLoja,TamSx3("LQ_LOJA")[1])				,Nil})	// Loja
					aAdd(aCabec,{"LQ_VLRTOT"		, A410Arred( nTotItem , "LQ_VLRTOT" )   		,NIL}) // Valor Total
					aAdd(aCabec,{"LQ_VLRLIQ"		, A410Arred( nTotItem , "LQ_VLRLIQ" )   		,NIL})	// Valor Líquido
					aAdd(aCabec,{"LQ_VALBRUT"	, A410Arred( nTotItem , "LQ_VALBRUT" )  		,NIL})	// Valor Bruto
					aAdd(aCabec,{"LQ_VALMERC"	, A410Arred( nTotItem , "LQ_VALMERC" )  		,NIL}) // Valor Mercadoria
					aAdd(aCabec,{"LQ_DINHEIR"	, A410Arred( nTotItem , "LQ_DINHEIR" )  		,NIL})	// Dinheiro
					aAdd(aCabec,{"LQ_ENTRADA"	, A410Arred( nTotItem , "LQ_ENTRADA" )  		,NIL})	// Entrada
					
					If SLQ->( FieldPos( "LQ_UMOVINF" ) ) > 0
						Do Case
						Case cUMovInf == "1"
							aAdd(aCabec,{ "LQ_UMOVINF",	PadR(aDados[CLI_NOM],TamSx3("LQ_UMOVINF")[1])	,	Nil})	// Nome				
						Case cUMovInf == "2"
							aAdd(aCabec,{ "LQ_UMOVINF",	PadR(aDados[CLI_TEL],TamSx3("LQ_UMOVINF")[1])	,	Nil})	// Telefone				
						Case cUMovInf == "3"
							aAdd(aCabec,{ "LQ_UMOVINF",	PadR(aDados[CLI_EMAIL],TamSx3("LQ_UMOVINF")[1])	,	Nil})	// E-Mail				
						Case cUMovInf == "4"
							aAdd(aCabec,{ "LQ_UMOVINF",	PadR(aDados[CLI_CPF],TamSx3("LQ_UMOVINF")[1])	,	Nil})	// CPF				
						EndCase
					EndIf
                		
					Aadd(aPagPV,Array(6))
					aPagPV[Len(aPagPV),01] := {"L4_DATA"	, dDatabase								,NIL}
					aPagPV[Len(aPagPV),02] := {"L4_VALOR"	, A410Arred( nTotItem , "L4_VALOR" )	,NIL}
					aPagPV[Len(aPagPV),03] := {"L4_FORMA"	, SuperGetMV( "MV_SIMB1",,"R$")			,NIL}
					aPagPV[Len(aPagPV),04] := {"L4_ADMINIS"	, " "									,NIL}
					aPagPV[Len(aPagPV),05] := {"L4_FORMAID"	, " "									,NIL}
					aPagPV[Len(aPagPV),06] := {"L4_MOEDA"	, 1 			,NIL}
					
					SetFunName("LOJA701")
					MSExecAuto({|a,b,c,d,e,f,g,h| LOJA701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aCabec,aItens,aPagPV)


					If lMsErroAuto
						lDeuErro := .T.
    					MakeDir("\DEBUG\")
						ConOut(STR0003) // Erro no ExecAuto! Checar o erro no diretorio:\DEBUG\
						MostraErro("\DEBUG\","LOJA891_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG")
						conout(MostraErro())
						ctexto :=  MostraErro()
						conout(ctexto)
						cTextoDetalhe := cTextoDetalhe + Chr(13) + Chr(10) + cTexto + ' - Controle pré-venda ' + cControleID  

						//DisarmTransaction()
						If  __lSX8
							RollBackSX8()
						EndIf           
			
	
					Else
						ConOut(STR0004) // Sucesso na execução do ExecAuto
						
						If  __lSX8
							ConfirmSX8()
						EndIf
						
					EndIf
					
				EndIf	
				    	
				aCabec      := {}
				aItem       := {}
				aItens      := {}
				aPagPV      := {}
				nTotItem    := 0
				nContItem   := 0
				lGrava      := .T.
				lMsErroAuto := .F.
			EndIf                        
		EndIf
		
		FT_FSkip()
		
	EndDo  
				
	Ft_fuse()	//Fecha o arquivo
	
	RestArea(aArea)

EndIf

If XmlChildEx( oXML, "_UMOVEXPORT" ) <> Nil

    If ValType(oXML:_UMovExport:_ListOfKeys:_Key) <> "A"  
   	   XmlNode2Arr(oXML:_UMovExport:_ListOfKeys:_Key,"_Key")
    EndIf 

	cUkey := oXML:_UmovExport:_UniqueKey:Text
	
	cArquivo := oXML:_UmovExport:_FileName:Text
	
	aCampos:=Separa(cUkey,";")
                                                    
  
	For nX := 1 To Len( oXml:_UMovExport:_ListOfKeys:_Key)   
		cRet := oXml:_UMovExport:_ListOfKeys:_Key[nX]:Text
	    Aadd(aChave,cRet)   
	Next nX

	If Trim(aCampos[1]) == "B1_COD" 

		If SB1->(FieldPos("B1_DTUMOV")) > 0  .And. SB1->(FieldPos("B1_HRUMOV")) > 0
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
			For nX := 1 To Len(aChave)                                      
				aDados 		:= Separa(aChave[nX],";")
				If SB1->(DbSeek(xFilial("SB1")+aDados[1]))
					RecLock("SB1",.F.)
					SB1->B1_DTUMOV := dDataBase  
					SB1->B1_HRUMOV := SubStr( StrTran(Time(),":",""),1,4) 	
					SB1->(MsUnlock())	    
				EndIf
			Next nX
		EndIf

	ElseIf Trim(aCampos[1]) == "DA1_CODPRO" 
		If DA1->(FieldPos("DA1_DTUMOV")) > 0  .And. DA1->(FieldPos("DA1_HRUMOV")) > 0
			DbSelectArea("DA1")
			DA1->(DbSetOrder(1))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
			For nX := 1 To Len(aChave)                                      
				aDados 		:= Separa(aChave[nX],";")
				If DA1->(DbSeek(xFilial("DA1")+PadR(cCodTab,TamSx3("DA1_CODTAB")[1])+aDados[1]))
					RecLock("DA1",.F.)
					DA1->DA1_DTUMOV := dDataBase  
					DA1->DA1_HRUMOV := SubStr( StrTran(Time(),":",""),1,4) 	
					DA1->(MsUnlock())	    
				EndIf
			Next nX
		EndIf	

	ElseIf Trim(aCampos[1]) == "A3_COD" 

		If SA3->(FieldPos("A3_DTUMOV")) > 0  .And. SA3->(FieldPos("A3_HRUMOV")) > 0
			DbSelectArea("SA3")
			SA3->(DbSetOrder(1))//A3_FILIAL+A3_COD
			For nX := 1 To Len(aChave)                                      
				aDados 		:= Separa(aChave[nX],";")
				If SA3->(DbSeek(xFilial("SA3")+aDados[1]))
					RecLock("SA3",.F.)
					SA3->A3_DTUMOV := dDataBase  
					SA3->A3_HRUMOV := SubStr( StrTran(Time(),":",""),1,4) 	
					SA3->(MsUnlock())	    
				EndIf
			Next nX
		EndIf

    ElseIf Trim(aCampos[1]) == "BM_GRUPO"
    
		If SBM->(FieldPos("BM_DTUMOV")) > 0  .And. SBM->(FieldPos("BM_HRUMOV")) > 0
			DbSelectArea("SBM")
			SBM->(DbSetOrder(1))//BM_FILIAL+BM_GRUPO
			For nX := 1 To Len(aChave)                                      
				aDados 		:= Separa(aChave[nX],";")
				If SBM->(MsSeek( xFilial("SBM") + aDados[1]))
					RecLock( "SBM", .F.)	
					SBM->BM_DTUMOV := dDataBase
					SBM->BM_HRUMOV := SubStr( StrTran(Time(),":",""),1,4)
					SBM->(MsUnlock())
				EndIf
			Next nX
		EndIf
     
    EndIf
    CONOUT( STR0005 )   // TERMINOU O IMPORT
EndIf

RestArea(aAreaSA3)
RestArea(aAreaSA1)
RestArea(aAreaSBM)

If lMsErroAuto .OR. lDeuErro
	Return {.F.,cTexto}
Else
	Return {.T.,"OK"}//"Ok"//"OK"
EndIf


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ret_Pontos()
Retira pontos, traços e hifens do CPF/CNPJ

@Return cRet - sem os traços
@author Vendas
@since 26/11/2013
/*/
//------------------------------------------------------------------------------------------------
Static Function Ret_Pontos(cString)
Local cRet := ""

cRet := StrTran(cString,".","")
cRet := StrTran(cRet,"/","")
cRet := StrTran(cRet,"-","")

Return cRet

