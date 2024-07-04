#INCLUDE "LOJA7033.ch"
#INCLUDE 'Protheus.ch' 
#INCLUDE 'TBICONN.ch'
#INCLUDE "TBICODE.CH"
#INCLUDE 'TOPConn.ch'
  
#DEFINE CRLF CHR(13)+CHR(10)
/*----------------------------------------------------------                                  
  	   Integração Totvs Colaboração DRP NeoGrid   
     Recebimento de Solicitacao / Pedido de Compra
@author  	Carlos MOta
@version 	P11                                                                                             
@build		
@since 		23/07/2013
@return 	Nil														  	  
----------------------------------------------------------*/
Function LOJA7033(lSched)
   
Local aRet     		:= {}  // Vetor com o retorno do envio para a NeoGrid
Local aItem         := {}  // Vetor com os itens do rebebimento
Local lRet     		:= .f. // Retorno da comunicacao                 
Local aMov     		:= {}  // Vetor com a movimentacao de importacao
Local dIni     		:= CtoD('01/01/2000')  // Data de Inicio
Local dFim     		:= Date()              // Data Final
Local cXML			:= ""	//XML recebido do TSS
Local oXML			:= Nil	//Objeto com estrutura XML
Local oXMLIt	    := Nil	//Objeto com estrutura parial do XML (Entrega dos Itens)
Local cError		:= ""	//Mensagem de erro na manipulação do arquivo com XML recebido
Local cWarning    	:= ""	//Mensagem de alerta na manipulação do arquivo com XML recebido
Local nNeoCom			:= ""  // Tipo de comunicacao com a NeoGrid 1 - TSS 2 - EDI        
Local cPathIn			:= ""	// Pasta com as infomacoes do XML não lidos
Local cPathRec		:= ""	// Pasta com as informações do XML já lidos 
Local oTss				:= Nil	// Objeto com as informacoes do TSS
Local nNeoPvSl		:= 0    // Tipo de Importacao para o Protheus 1 - Pedido de Compra 2 - Solicitacao de Compra 
Local n1				:= 0   // Contador
Local lAtivaDRP		:= .F.	// Ativa Protheus x Integração DRP Neogrid

Default lSched      := .F.

Private cEmp          := ""   // Empresa
Private cFilTrab      := ""   // Filial
//Para ler também no LOJA7033A
Private cTFTESSai		:= ""	// Parâmetro para TES Saída para Transf. Filiais 
Private cTFTESEnt		:= ""	// Parâmetro para TES Entrada para Transf. Filiais 
Private cTFCondPg		:= ""	// Parâmetro para Cond. Pag. para Transf. Filiais 
Private cTFSerie		:= ""  // Parâmetro para Série Específica para Transf. Filiais 
Private aCliFil		:= {}	// Relação Clientes x Filiais
Private aForFil		:= {}	// Relação Fornecedores x Filiais
Private lLeuSA1SA2	:= .F.	// Flag para entender que leu a função LOJA7033TF() para capturar quem é empresa nos cli/fornec.

Static aRetXML		:= {}	// Static para armazenar todos os itens de XML lidos

If ValType(lSched) = "A"
   cEmp     := lSched[2] // Empresa passada pelo Schedule
   cFilTrab := lSched[3] // Filial  passada pelo Schedule
   lSched   := .T.
Endif

// Configuracao para schedule
If lSched 
	RPCSETType(3)                  
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilTrab TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                                                           "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                                           "SX5","SM0"
	Conout(STR0001 + dtoc(date()) + STR0002 + time()) //"SCHEDULE Importação DRP - Iniciando rotinas scheduladas em "###" as "  //"SCHEDULE Importação DRP - Iniciando rotinas scheduladas em "###" as "
	LjGrvLog(STR0057,STR0001+dtoc(date())+STR0002+time(),Nil)	//"Importacao DRP Neogrid" //"SCHEDULE Importação DRP - Iniciando rotinas scheduladas em "###" as "  //"SCHEDULE Importação DRP - Iniciando rotinas scheduladas em "###" as "
	Conout(STR0003) //"Iniciando Processo de Importacao"
	LjGrvLog(STR0057,STR0003,Nil)	//"Importacao DRP Neogrid"  //"Iniciando Processo de Importacao"
	Conout(STR0004+ cEmp +STR0005+ cFilTrab) //"Empresa: "###" Filial: "
	LjGrvLog(STR0057,STR0004+ cEmp +STR0005+ cFilTrab,Nil)	//"Importacao DRP Neogrid"  //"Empresa: "###" Filial: "
Endif 

nNeoPvSl		:= GetNewPar("MV_LJNEOPV",1)		//Retorna 1-Pedido de Compra, 2-Solicitação de Compra, 3-Transf. Estoque entre Filiais    
nNeoCom  		:= GetNewPar("MV_LJNEOCM",1)         // Tipo de comunicacao com a NeoGrid 1 - TSS 2 - EDI        
cPathIn  		:= GetNewPar("MV_LJNEOIN","\NEOIN\") // Path onde estão os arquivos de retorno não lidos
cPathRec 		:= GetNewPar("MV_LJNERCV","\NERCV\") // Path onde estão os arquivos de retorno lidos
lAtivaDRP		:= GetNewPar("MV_LJDRP",.F.)			// Parâmetro para ativação de DRP Neogrid 

cTFTESSai		:= GetNewPar("MV_LJNETES","")			// Parâmetro para TES Saída para Transf. Filiais 
cTFTESEnt		:= GetNewPar("MV_LJNETEE","")			// Parâmetro para TES Entrada para Transf. Filiais 
cTFCondPg		:= GetNewPar("MV_LJNECPT","")			// Parâmetro para Cond. Pag. para Transf. Filiais 
cTFSerie		:= GetNewPar("MV_LJNESER","")			// Parâmetro para Série Específica para Transf. Filiais 
cTFEspecie		:= GetNewPar("MV_LJNEESP","")			// Parâmetro para Espécie Específica para Transf. Filiais 

//Verifico se o DRP está ativo via parâmetro
If !lAtivaDRP
	ConOut(STR0014+STR0015) //"ATENCAO: Favor ativar o parametro MV_LJDRP para"###" ativar a Integracao Neogrid x DRP."
	LjGrvLog(STR0057,STR0014+STR0015,Nil)	//"Importacao DRP Neogrid"  //"ATENCAO: Favor ativar o parametro MV_LJDRP para"###" ativar a Integracao Neogrid x DRP."
	If lSched 
   		Reset ENVIRONMENT
	Endif
	Return .F.
EndIf	                

cRootPath	:= GetSrvProfString("RootPath","")
cRootPath 	+= IIf(!(Left(cRootPath,1) == IIf(IsSrvUnix(),"/","\")),IIf(IsSrvUnix(),"/","\"),"")

If Empty(cPathIn)
	ConOut(STR0010) //"Pasta nao definida no parametro MV_LJNEOIN"
	LjGrvLog(STR0057,STR0010,Nil)	//"Importacao DRP Neogrid"  //"Pasta nao definida no parametro MV_LJNEOIN"
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf

If Empty(cPathRec)
	ConOut(STR0011) //"Pasta nao definida no parametro MV_LJNERCV"
	LjGrvLog(STR0057,STR0011,Nil)	//"Importacao DRP Neogrid"  //"Pasta nao definida no parametro MV_LJNERCV"
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf

// Verifica se pasta de retorno não lido já existente
If !ExistDir(cPathIn) 
	ConOut(STR0016+cPathIn+STR0017) //"Pasta "###" nao existe! Verifique o parametro MV_LJNEOIN"
	LjGrvLog(STR0057,STR0016+cPathIn+STR0017,Nil)	//"Importacao DRP Neogrid"  //"Pasta "###" nao existe! Verifique o parametro MV_LJNEOIN"
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf
			
// Verifica se pasta de retorno lido já existente
If !ExistDir(cPathRec) 
	ConOut(STR0016+cPathRec+STR0018) //"Pasta "###" nao existe! Verifique o parametro MV_LJNERCV"
	LjGrvLog(STR0057,STR0016+cPathRec+STR0018,Nil)	//"Importacao DRP Neogrid"  //"Pasta "###" nao existe! Verifique o parametro MV_LJNERCV"
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf

// Verifica se o TES Saída para Transf. Filiais está cadastrada
If Empty(cTFTesSai) 
	ConOut(STR0030+" "+STR0031) //"Tipo de Saida para Transf. Filiais nao cadastrado!"###"Verifique o parametro MV_LJNETES"
	LjGrvLog(STR0057,STR0030+" "+STR0031,Nil)	//"Importacao DRP Neogrid"  //"Tipo de Saida para Transf. Filiais nao cadastrado!"###"Verifique o parametro MV_LJNETES"
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf

// Verifica se o TES Entrada para Transf. Filiais está cadastrada
If Empty(cTFTesEnt) 
	ConOut(STR0032+" "+STR0033) //"Tipo de Entrada para Transf. Filiais nao cadastrado!"###"Verifique o parametro MV_LJNETEE"
	LjGrvLog(STR0057,STR0032+" "+STR0033,Nil)	//"Importacao DRP Neogrid"  //"Tipo de Entrada para Transf. Filiais nao cadastrado!"###"Verifique o parametro MV_LJNETEE"
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf

// Verifica se o TES Entrada para Transf. Filiais está cadastrada
If Empty(cTFCondPg) 
	ConOut(STR0034+" "+STR0035) //"Cond. Pagamento para Transf. Filiais nao cadastrada!"###"Verifique o parametro MV_LJNECPT"
	LjGrvLog(STR0057,STR0034+" "+STR0035,Nil)	//"Importacao DRP Neogrid"  //"Tipo de Entrada para Transf. Filiais nao cadastrado!"###"Verifique o parametro MV_LJNETEE"  
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf

// Verifica se a série para NF para Transf. Filiais está cadastrada
If Empty(cTFSerie) 
	ConOut(STR0036+" "+STR0037) //"Serie para Transf. Filiais nao cadastrada!"###"Verifique o parametro MV_LJNESER"
	LjGrvLog(STR0057,STR0036+" "+STR0037,Nil)	//"Importacao DRP Neogrid"  //"Serie para Transf. Filiais nao cadastrada!"###"Verifique o parametro MV_LJNESER"  
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf

// Verifica se a espécie para NF para Transf. Filiais está cadastrada
If Empty(cTFEspecie) 
	ConOut(STR0038+" "+STR0039) //"Especie para Transf. Filiais nao cadastrada!"###"Verifique o parametro MV_LJNEESP"
	LjGrvLog(STR0057,STR0038+" "+STR0039,Nil)	//"Importacao DRP Neogrid"  //"Especie para Transf. Filiais nao cadastrada!"###"Verifique o parametro MV_LJNEESP"  
	If lSched 
		Reset ENVIRONMENT                      
	Endif
	Return .F.
EndIf

If nNeoCom = 2 //  Recebimento XML atraves do Client Neogrid
    If Empty(cPathIn)
       lRet := .F.
       Return lRet
    Endif
    aMov := Directory(cPathIn + "*.*") 
    If Len(aMov) > 0
       For n1 = 1 to Len(aMov)
       	If (At(".EDI",Alltrim(aMov[n1,1]))>0) .OR. (At(".XML",Alltrim(aMov[n1,1]))>0) //Somente extensões .EDI e .XML
	       	aRetXML := {}  //A demanda é por cada arquivo lido 
				FT_FUSE(cPathIn + alltrim(aMov[n1,1]))
				ProcRegua(FT_FLASTREC())
				FT_FGOTOP()
				cXml  := ""
				oXMl  := "" 
				oXmlIt:= ""  
				aItem := {} 
				Do While !FT_FEOF()
					cLine   := FT_FREADLN()
					cXMl    += cLine + CRLF 
					FT_FSKIP()
				End
				FT_FUSE()
			
				//Mover para a pasta de arquivos lidos de retorno
				If ! _CopyFile(cPathIn+alltrim(aMov[n1,1]), cPathRec+alltrim(aMov[n1,1]))
					Conout(STR0008+cPathIn+alltrim(aMov[n1,1])+STR0009+cPathRec+alltrim(aMov[n1,1])) //"Não foi possivel copiar o arquivo " # " para o diretório "
					LjGrvLog(STR0057,STR0008+cPathIn+alltrim(aMov[n1,1])+STR0009+cPathRec+alltrim(aMov[n1,1]),Nil)	//"Importacao DRP Neogrid"  //"Não foi possivel copiar o arquivo " # " para o diretório "  
					If lSched	
						Reset ENVIRONMENT                      
					Endif
					Return .F.
				Else
					Ferase(cPathIn + alltrim(aMov[n1,1]))
				EndIf
			
				//Apaga o arquivo do diretorio de processamento
				If !Empty(cXML)
			
					//Eliminar quebras de linha acidentais
					cXml := StrTran( cXml, Chr(13)+Chr(10), "" )
				
					oXML := XmlParser(cXml,"_",@cError,@cWarning)
					If !Empty(cError)
						ConOut(STR0059 + cError)  //"Erro na composicao do XML: "
						LjGrvLog(STR0057,STR0059 + cError,Nil)	//"Importacao DRP Neogrid"  //"Erro na composicao do XML: "  
					EndIf
					If oXML != NIL 
						If (!Empty(oXML) .and. Empty(cError))
							oXmlIt := XmlGetChild(oXML:_DOWN_PDCOMPRA,4)
							If ValType(oXmlIt) =  "O"
								If XmlNode2Arr ( oXmlIt:_NS1_ITENS, "_NS1_ITENS" ) // - Transforma em array um objeto (nó) da estrutura do XML 
									aAdd(aItem,oXmlIt)
								Else
									aItem := {}
								Endif
							ElseIf ValType(oXmlIt) = "A"
								aItem := aClone(oXmlIt)
								Loja7033A(aItem,nNeoPvSl)
								aItem := {}  //para não ler o loja7033a abaixo
							Endif
						Endif
					Endif
					
				Else                         
					lRet := .f.
				Endif 
				If Len(aItem) > 0 
					Loja7033A(aItem,nNeoPvSl)
				Endif
			EndIf
		Next N1
	Endif
Endif
If lSched 
	Conout(STR0019) //"Finalizando Processo de Importacao"
	LjGrvLog(STR0057,STR0019,Nil)	//"Importacao DRP Neogrid"  //"Erro na composicao do XML: "  
	Reset ENVIRONMENT                      
Endif
Return lRet


/*----------------------------------------------------------
  	   Integração Totvs Colaboração DRP NeoGrid   
	Monitora documentos no servidor do TOTVS Colaboração.
@author  	Carlos MOta
@version 	P11                                                                                             
@build		
@since 		12/09/2013
@return 	Nil														  	  
----------------------------------------------------------*/
Static Function Loja7033A(aItem,nNeoPvSl)

Local cFilAnt    // Filial
Local nSeq         // Contador
Local nTpDownload    := 0   // 1 - Pedido de Compra 2 - Solicitacao de Compra 

//  Variaveis do XMl
Local cFilDest		:= ""   // Filial
Local cFilOrig		:= cFilAnt   // Filial de Origem
Local cNum           := ""   // Codigo do Pedido
Local cNumDoc        := ""   // Numero do Documento
Local cCodpro        := ""   // Codigo do Produto
Local cCodLoca       := ""   // Codigo do Local 
Local dEmis          := Ctod('') // Data da Emissao
Local nQtdPed        := 0    // Quantidade 
Local cIdOrigem      := ""   // Origem
Local cCodItemOr     := ""   // Codigo do Item Origem
Local cCodLocaldOr   := ""   // Codigo do Local de Origem
Local dDtMovOr       := Ctod('') // Data do Movimento
Local nQtdPedOr      := 0    // Quantidade original do pedido
Local cFornec        := ''   // Codigo do Fornecedor / Loja
Local cFornecedor    := ''   // Codigo Fornecedor
Local cObs           := ''   // Observacao
Local nUnitiz        := 0    // Unitilizacao
Local cGrp1For       := ''   // Grupo do Fornecedor
Local cGrp2For       := ''   // Grupo do Fornecedor
Local dDataProgr     := Ctod('')  // Data Programada para o pedido
Local cCodBar        := ''   // Codigo de Barra
Local cAgrpPrc1      := ''   // Agrupamento
Local cPrzPgt        := ''   // Prazo de Pagamento
Local nCondCmr1      := 0    // Condicao 1
Local nCondCmr2      := 0    // Condicao 2
Local cImportado     := ''   // Origem Importado ou Nacional
Local cCodigoCapa		:= ''	 // Código de Capa
Local nTipoEstoqueSeg:= 0	// Tipo de Estoque de Segurança
Local cPriorTVD      := ''   // Prioridade
Local cGrp2LcEstDest := ''   // Grupo do Local de Estoque Destino
Local cLoja          := ''	// Loja

// Variaveis Pedido / Solicitacao / Transferencia
Local aCb      := {}       // Vetor do Cabecalho
Local aIt      := {}       // Vetor do item
Local aCbAux   := {}       // Vetor do Cabecalho Auxiliar
Local aItAux   := {}       // Vetor do item Auxiliar
Local lContinua:= .T.      // Variavel de validacao para o ExecAuto
Local aAutoA   := {}       // Vetor para cabecalho do ExecAuto para Transf. entre Armazéns
Local aAutoA2  := {}       // Vetor para cabecalho do ExecAuto para Transf. entre Armazéns Auxiliar
Local aAuto    := {}       // Vetor para cabecalho do ExecAuto  
Local aAuto2   := {}       // Vetor para cabecalho do ExecAuto - parte 2  
Local cCond    := GetNewPar("MV_LJNEOCP","001") // Parametro Condicao de pagamento utilizada para a importação dos pedidos de venda / Solicitação de Compra 
Local cFilEnt  := ''       // Filial
Local cDescr   := ''       // Descricao do Produto
Local cUM      := ''       // Unidade de Medida
Local nPreco   := 0        // Preco 
Local nTotal   := 0        // Total do Item
Local cDescrOr := ''       // Descricao do Produto - Origem
Local cUMOr    := ''       // Unidade de Medida - Origem
Local nPrecoOr := 0        // Preco - Origem
Local nTotalOr := 0        // Total do Item - Origem
Local cLocalOr := ""			// Local de Origem
Local cFilialOr := ""		// Filial de Origem
Local dDatPrf              // Data 
Local cLocal   := ''       // Local de Estoque
Local cTpFrete := 'C'      // Tipo de Frete
Local oXmlItem	:= {}			// Objeto local Item
Local nTamFilial	:= TamSX3("B1_FILIAL")[1]	// Tamanho da filial
Local nX		:= 0			// Contador 
Local nY		:= 0			// Contador
Local cTFCliCod	:= ""		// Código do cliente para filial de destino
Local cTFCliLoja	:= ""		// Loja do cliente para filial de destino
Local cTFForCod	:= ""		// Código do fornecedor para filial de origem
Local cTFForLoja	:= ""		// Loja do fornecedor para filial de origem
Local aAutoAux	:= {}		// Auxiliar para ExecAuto de Transferência entre Filiais
Local lSucess		:= .F.		// Determina se o processamento foi realizado com sucesso
Local nSaldoSB2	:= 0		// Verificação de Saldo na SB2
Local nDel			:= 0		// Contador de arrays deletados
Local nTot			:= 0		// Total para For
Local nAscanFilPro := 0		// Ponteiro para posição de elemento do produto
Local nFCount		:= 0		// Número total de campos em um registro
Local nFCICalc	:= SuperGetMV("MV_FCICALC",.F.,0)  //Mata261(), Percentual FCI para Transf. Armazéns

//Controle de rotina automatica
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

If Valtype(aItem) = 'A'
	For nSeq = 1 to Len(aItem) 
		oXmlItem := XmlChildEx(aItem[nSeq], "_NS1_ITENS") 
		If Valtype(oXmlItem) = "A"  //Quando vem uma XML com um item só, recebo como "A".
			If Len(oXmlItem) > 1 
				ConOut(STR0013)  //"XML: Número de elementos dentro dos itens maior que 1. Favor verificar!"
				LjGrvLog(STR0057,STR0013,Nil)	//"Importacao DRP Neogrid"  //"XML: Número de elementos dentro dos itens maior que 1. Favor verificar!"  
			EndIf
			oXmlItem := oXmlItem[1]
		EndIf
		If XmlChildEx(oXmlItem,"_NS1_CODPED") <> NIL .AND. !Empty(oXmlItem:_NS1_CODPED:TEXT)  
		   cNum  := oXmlItem:_NS1_CODPED:TEXT
		Else
		   cNum  := "" 
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_CODPRO") <> NIL .AND. !Empty(oXmlItem:_NS1_CODPRO:TEXT) 
		   cCodPro  := alltrim(oXmlItem:_NS1_CODPRO:TEXT) 
		   If Len(cCodpro) >= TamSx3("B1_COD")[1]
		      cCodPro := SubStr(cCodpro,1,TamSx3("B1_COD")[1])
		   Else 
		      cCodpro := cCodPro +Space(TamSx3("B1_COD")[1] - len(cCodPro)) 
		   EndIf    
		Else
		   cCodPro  := "" 
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_CODLOCA") <> NIL .AND. !Empty(oXmlItem:_NS1_CODLOCA:TEXT) 
		   cCodLoca  := oXmlItem:_NS1_CODLOCA:TEXT
		Else
		   cCodLoca  := "" 
		EndIf                                               

		cFilDest  := xFilial('SC7')
			
		If XmlChildEx(oXmlItem,"_NS1_DTMOV") <> NIL .AND. !Empty(oXmlItem:_NS1_DtMov:TEXT) 
			dEmis    := StoD(oXmlItem:_NS1_DtMov:TEXT)
		Else           
			dEmis    := dDatabase
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_QTDPED") <> NIL .AND. !Empty(oXmlItem:_NS1_QtdPed:TEXT)  
			nQtdPed  := val(oXmlItem:_NS1_QtdPed:TEXT)
		Else           
			nQtdPed  := 0
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_IDORIGEM") <> NIL .AND. !Empty(oXmlItem:_NS1_IdOrigem:TEXT) 
			cIdOrigem:= oXmlItem:_NS1_IdOrigem:TEXT
		Else           
			cIdOrigem:= ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_CODITEMOR") <> NIL .AND. !Empty(oXmlItem:_NS1_CodItemOr:TEXT) 
		   cCodItemOr  := alltrim(oXmlItem:_NS1_CodItemOr:TEXT) 
		   If Len(cCodItemOr) >= TamSx3("B1_COD")[1]
		      cCodItemOr := SubStr(cCodItemOr,1,TamSx3("B1_COD")[1])
		   Else 
		      cCodItemOr := cCodItemOr +Space(TamSx3("B1_COD")[1] - len(cCodItemOr)) 
		   EndIf    
		Else           
			cCodItemOr:= ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_CODLOCALDOR") <> NIL .AND. !Empty(oXmlItem:_NS1_CodLocaldOr:TEXT) 
			cCodLocaldOr:= oXmlItem:_NS1_CodLocaldOr:TEXT
		Else           
			cCodLocaldOr:= ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_DTMOVOR") <> NIL .AND. !Empty(oXmlItem:_NS1_DtMovOr:TEXT)
			dDtMovOr := StoD(oXmlItem:_NS1_DtMovOr:TEXT)
		Else           
			dDtMovOr := ctod("")
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_QTDPEDOR") <> NIL .AND. !Empty(oXmlItem:_NS1_QtdPedOr:TEXT) 
			nQtdPedOr  := Val(oXmlItem:_NS1_QtdPedOr:TEXT)
			If nQtdPedOr < 0			//O número vem menor que 0, entendendo que é transferência
				nQtdPedOr := nQtdPedOr * -1
			EndIf
		Else           
			nQtdPedOr  := 0
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_FORNECEDOR") <> NIL .AND. !Empty(oXmlItem:_NS1_Fornecedor:TEXT) 
			cFornecedor  := oXmlItem:_NS1_Fornecedor:TEXT
			cFornec      := Substr(cFornecedor,1,6)
			cLoja        := Substr(cFornecedor,7,2)
		Else
			cFornec  := ""
			cLoja    := ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_OBS") <> NIL .AND. !Empty(oXmlItem:_NS1_Obs:TEXT)
			cObs := oXmlItem:_NS1_Obs:TEXT
	    Else
			cObs := ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_UNITIZ") <> NIL .AND. !Empty(oXmlItem:_NS1_Unitiz:TEXT)
			nUnitiz := Val(oXmlItem:_NS1_Unitiz:TEXT)
		Else
			nUnitiz := 0
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_GRP1FOR") <> NIL .AND. !Empty(oXmlItem:_NS1_Grp1For:TEXT) 
			cGrp1For := oXmlItem:_NS1_Grp1For:TEXT
		Else
			cGrp1For := ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_GRP2FOR") <> NIL .AND. !Empty(oXmlItem:_NS1_Grp2For:TEXT) 
			cGrp2For := oXmlItem:_NS1_Grp2For:TEXT
		Else
			cGrp2For := ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_DATAPROGR") <> NIL .AND. !Empty(oXmlItem:_NS1_DataProgr:TEXT) 
			dDataProgr    := StoD(oXmlItem:_NS1_DataProgr:TEXT)
		Else           
			dDataProgr    := dDatabase
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_CODBAR") <> NIL .AND. !Empty(oXmlItem:_NS1_CodBar:TEXT)
			cCodBar := oXmlItem:_NS1_CodBar:TEXT
		Else
			cCodBar := ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_IMPORTADO") <> NIL .AND. !Empty(oXmlItem:_NS1_Importado:TEXT)
			cImportado := oXmlItem:_NS1_Importado:TEXT
		Else
			cImportado := ""
		EndIf                               
		If XmlChildEx(oXmlItem,"_NS1_CODIGOCAPA") <> NIL .AND. !Empty(oXmlItem:_NS1_CodigoCapa:TEXT)
			cCodigoCapa := oXmlItem:_NS1_CodigoCapa:TEXT
		Else
			cCodigoCapa := ""
		EndIf                               
		If XmlChildEx(oXmlItem,"_NS1_TIPOESTOQUESEGURANCA") <> NIL .AND. !Empty(oXmlItem:_NS1_TipoEstoqueSeguranca:TEXT)
			nTipoEstoqueSeg := Val(oXmlItem:_NS1_TipoEstoqueSeguranca:TEXT)
		Else
			nTipoEstoqueSeg := 0
		EndIf                               
		If XmlChildEx(oXmlItem,"_NS1_PRIORTVD") <> NIL .AND. !Empty(oXmlItem:_NS1_PriorTVD:TEXT)
			cPriorTVD := oXmlItem:_NS1_PriorTVD:TEXT
    	Else
			cPriorTVD := ""
		EndIf                                               
		If XmlChildEx(oXmlItem,"_NS1_GRP2LCESTDEST") <> NIL .AND. !Empty(oXmlItem:_NS1_Grp2LcEstDest:TEXT) 
			cGrp2LcEstDest := oXmlItem:_NS1_Grp2LcEstDest:TEXT
		Else
			cGrp2LcEstDest := ""
		EndIf
		
		// Validações 		
	    Do Case
	       Case !Empty(cCodLocaldOr)
	       	
	       	// Transferência entre filiais
	       	If Len(Alltrim(cCodLocaldOr))>2 .AND. (Left(cCodLoca,8) <> Left(cCodLocaldOr,8))
	       	
	       		// Carrego informações de quem é empresa na tabela Clientes/Fornecedores
	       		If !lLeuSA1SA2
	       			Loja7033TF()
	       		EndIf
	       	
					// Extrair produto de origem
					If SB1->(DbSeek(xFilial('SB1')+cCodItemOr))
						cUMOr      := SB1->B1_UM
						cDescrOr   := SB1->B1_DESC 
						nPrecoOr   := SB1->B1_PRV1
						nTotalOr   := nQtdPed*nPreco 
						cLocalOr   := If(Len(cCodLocaldOr)>=nTamFilial+1,substr(cCodLocaldOr,nTamFilial+1,2),SB1->B1_LOCPAD)
						cFilialOr  := If(Len(cCodLocaldOr)>2,substr(cCodLocaldOr,1,nTamFilial),'') 
					Else
					Endif

					// Extrair produto de destino
					If SB1->(DbSeek(xFilial('SB1')+cCodPro))
						cUM      := SB1->B1_UM
						cDescr   := SB1->B1_DESC 
						nPreco   := SB1->B1_PRV1
						nTotal   := nQtdPed*nPreco 
						cLocal   := If(Len(cCodLoca)>=nTamFilial+1,substr(cCodLoca,nTamFilial+1,2),SB1->B1_LOCPAD)
						cFilDest  := If(Len(cCodLoca)>2,substr(cCodLoca,1,nTamFilial),'') 
					Else
						cLocal   := If(Len(cCodLoca)>=nTamFilial+1,substr(cCodLoca,nTamFilial+1,2),Substr(cCodLoca,1,2))
						cFilDest  := If(Len(cCodLoca)>2,substr(cCodLoca,1,nTamFilial),'') 
					Endif
					
					//x[3] = A2_FILTRF e x[4] = A2_FILIAL
					nX := Ascan(aForFil,{|x|x[3]=cFilialOr .AND. At(Alltrim(x[4]),Alltrim(cFilDest))>0})
					If nX > 0
						cTFForCod  := aForFil[nX][1]
						cTFForLoja := aForFil[nX][2]
					Else
						cTFForCod	:= ""
						cTFForLoja := ""
					EndIf	 

					//x[3] = A1_FILTRF e x[4] = A1_FILIAL
					nX := Ascan(aCliFil,{|x|x[3]=cFilDest .AND. At(Alltrim(x[4]),Alltrim(cFilialOr))>0})
					If nX > 0
						cTFCliCod  := aCliFil[nX][1]
						cTFCliLoja := aCliFil[nX][2]
					Else
						cTFCliCod	:= ""
						cTFCliLoja := ""
					EndIf	 

					aItAux := {}
					
					// Armazém Origem 
					aadd(aItAux,cFilialOr)		// 01
					aadd(aItAux,cCodItemOr)		// 02
					aadd(aItAux,cLocalOr)		// 03
					aadd(aItAux,nQtdPedOr)		// 04
					aadd(aItAux,0)				// 05

					// Armazém Destino
					aadd(aItAux,cFilDest)		// 06
					aadd(aItAux,cLocal)			// 07

					// Cliente para destino
					aadd(aItAux,cTFCliCod)		// 08
					aadd(aItAux,cTFCliLoja)		// 09

					// Fornecedor de origem
					aadd(aItAux,cTFForCod)		// 10 
					aadd(aItAux,cTFForLoja)		// 11
					
					aadd(aItAux,"")				// 12
					aadd(aItAux,"")				// 13  
					aadd(aItAux,"")				// 14
					aadd(aItAux,"")				// 15
					aadd(aItAux,"")				// 16
					aadd(aItAux,"")				// 17
					aadd(aItAux,"")				// 18
					
					aadd(aItAux,cTod(""))		// 19
					aadd(aItAux,"")				// 20
					aadd(aItAux,"")				// 21
					
					//TES saída e TES entrada
					aadd(aItAux,"")				// 22
					aadd(aItAux,cTFTESSai)		// 23
					aadd(aItAux,cTFTESEnt)		// 24

					//Especial - gravo o número da sequência
					aadd(aItAux,nSeq)				// 25				
					
					aadd(aAuto,aItAux)							   
					aAuto2 := {"","","","",;
									"","","","",;
									"","","","",;
									cTFTESSai,2,cTFTESEnt,cTFCondPg,;  //13 TES Saida, 14 Classificada, 15 TES Entrada, 16 Cond. Pagto. //P2 //P2 //P MV_LJNECPT
									1,2,0,cTFEspecie,;  //20-Espécie
									"","","","",;
									"","","","",;
									"",""}

	       	Else // Transferência entre armazéns
	       	   	       	
					// Extrair produto de origem
					If SB1->(DbSeek(xFilial('SB1')+cCodItemOr))
						cUMOr      := SB1->B1_UM
						cDescrOr   := SB1->B1_DESC 
						nPrecoOr   := SB1->B1_PRV1
						nTotalOr   := nQtdPed*nPreco 
						cLocalOr   := If(Len(cCodLocaldOr)>=nTamFilial+1,substr(cCodLocaldOr,nTamFilial+1,2),SB1->B1_LOCPAD)
						cFilialOr  := If(Len(cCodLocaldOr)>2,substr(cCodLocaldOr,1,nTamFilial),'') 
					Else
						cLocalOr   := If(Len(cCodLocaldOr)>=nTamFilial+1,substr(cCodLocaldOr,nTamFilial+1,2),Substr(cCodLocaldOr,1,2))
						cFilialOr  := If(Len(cCodLocaldOr)>2,substr(cCodLocaldOr,1,nTamFilial),'') 
					Endif
				
					// Extrair produto de destino
					If SB1->(DbSeek(xFilial('SB1')+cCodPro))
						cUM      := SB1->B1_UM
						cDescr   := SB1->B1_DESC 
						nPreco   := SB1->B1_PRV1
						nTotal   := nQtdPed*nPreco 
						cLocal   := If(Len(cCodLoca)>=nTamFilial+1,substr(cCodLoca,nTamFilial+1,2),SB1->B1_LOCPAD)
						cFilDest  := If(Len(cCodLoca)>2,substr(cCodLoca,1,nTamFilial),'') 
					Else
						cLocal   := If(Len(cCodLoca)>=nTamFilial+1,substr(cCodLoca,nTamFilial+1,2),Substr(cCodLoca,1,2))
						cFilDest  := If(Len(cCodLoca)>2,substr(cCodLoca,1,nTamFilial),'') 
					Endif

					// Array da filial
					nAscanFil := 0
					For nY := 1 to Len(aAutoA)
						If nAscanFil = 0 
							nAscanFil := Ascan(aAutoA[nY],{|x|x[1] = cFilDest})
						EndIf
					Next

					aAutoA2 := {}
					If nAscanFil = 0  // Crio o primeiro elemento dentro do AutoA2 somente quando é novo, antes do primeiro item 
						cNumDoc := ""		
						aadd(aAutoA2,{cNumDoc,dDataBase})  //Cabecalho: Num Doc., Data, Filial		
					Endif

					aItAux := {}
					// Armazém Origem 
					aadd(aItAux,cCodItemOr)		// 01
					aadd(aItAux,cDescrOr)		// 02
					aadd(aItAux,cUmOr)			// 03
					aadd(aItAux,cLocalOr)		// 04
					aadd(aItAux,"")				// 05
						       		       
					// Armazém Destino
					aadd(aItAux,cCodPro)			// 06
					aadd(aItAux,cDescr)			// 07
					aadd(aItAux,cUm)				// 08
					aadd(aItAux,cLocal)			// 09
					aadd(aItAux,"")				// 10
											
					aadd(aItAux,"")				// 11 		
					aadd(aItAux,"")				// 12		
					aadd(aItAux,"")				// 13
					aadd(aItAux,dDataBase)		// 14
				
					aadd(aItAux,0)				// 15 	
					aadd(aItAux,nQtdPed)			// 16		
					aadd(aItAux,0)				// 17		
					aadd(aItAux,"")				// 18		
					aadd(aItAux,Str(nSeq))		// 19 		
					aadd(aItAux,"")				// 20
					aadd(aItAux,dDataBase)		// 21
					
					If IntDL()  //Função do sigacusb.prx, também lê no mata261.prx (MV_INTDL)
						aadd(aItAux,"")				// 22
					EndIf

					aadd(aItAux,"")				// 23

					If V240CAT83()  //Função do mata240.prx, também lê no mata261.prx (MV_CAT8309)
						aadd(aItAux,"")				// 24
						aadd(aItAux,"")				// 25
					EndIf
					
					If nFCICalc = 1					//Percentual FCI Importação para Mata261()
						aadd(aItAux,0)				// 26
					EndIf		

					aadd(aAutoA2,aItAux)
					
					If nAscanFil = 0
						aAdd(aAutoA,{{cFilDest},aAutoA2})
					Else
						For nY := 1 to Len(aAutoA2) 
							aAdd(aAutoA[nAscanFil][2],aAutoA2[nY])
						Next
					EndIf
					
				EndIf

	       Case Empty(cCodLocaldOr)

				If nNeoPvSl = 1  // Pedido de Compra
				
					// Dados dos Itens
					// Lembramos que, para gerar o pedido de compra,
					// devo pegar o último preço de compra gravado na SB1
					
					If SB1->(DbSeek(xFilial('SB1')+cCodPro))
						cUM      := SB1->B1_UM
						nPreco   := SB1->B1_UPRC
						nTotal   := nQtdPed*nPreco 
						cLocal   := If(Len(cCodLoca)>=nTamFilial+1,substr(cCodLoca,nTamFilial+1,2),SB1->B1_LOCPAD)
					Else
						cUM		  := ""
						nPreco   := 0
						nTotal   := 0
						cLocal   := If(Len(cCodLoca)>=nTamFilial+1,substr(cCodLoca,nTamFilial+1,2),Substr(cCodLoca,1,2))
					Endif
					cFilDest  := If(Len(cCodLoca)>2,substr(cCodLoca,1,nTamFilial),'')

					// Array da filial
					nAscanFil := Ascan(aCb,{|x|x[1] = cFilDest})
				
					If nAscanFil = 0
						aCb2 := {}
						aAdd(aCb2, {'C7_FILIAL'	, cFilDest				, Nil})	// Filial	
						aAdd(aCb2, {'C7_NUM'		, ""					, Nil})	// Numero do Pedido
						aAdd(aCb2, {'C7_EMISSAO'	, ddataBase			, Nil})	// Data de Emissao
						aAdd(aCb2, {'C7_FORNECE'	, cfornec				, Nil})	// Fornecedor
						aAdd(aCb2, {'C7_LOJA'	, cLoja	   			, Nil})	// Loja do Fornecedor
						aAdd(aCb2, {'C7_CONTATO'	, ''					, Nil})	// Contato
						aAdd(aCb2, {'C7_COND'	, cCond				, Nil})	// Condicao de Pagamento
						aAdd(aCb2, {'C7_FILENT'	, cFilDest				, Nil})	// Filial de Entrega 
						aAdd(aCb,{cFilDest,aCb2})
					Endif
					
					aIt2 := {}
					AAdd(aIt2, {	{'C7_ITEM'		, ""				, NIL},;	// 01 // Item
				   					{'C7_PRODUTO'	, cCodPro			, NIL},;	// 02 // Produto
									{'C7_QUANT'	, nQtdPed			, NIL},;	// 03 // Quantidade
									{'C7_UM'		, cUm				, NIL},;	// 04 // Unidade de Medida Produto
									{'C7_PRECO'	, nPreco			, NIL},;	// 05
									{'C7_TOTAL'	, nTotal			, NIL},;	// 06
									{'C7_DATPRF'	, dDataBase		, NIL},;	// 07 // DataBase   
									{'C7_LOCAL'	, cLocal			, NIL},;	// 08 // Almoxarifado
									{'C7_TPFRETE'	, 'C'				, NIL},;	// 09
									{'C7_OBS'		, cObs				, NIL},;	// 10 // Observacoes
									{'C7_CODTAB'	, ''				, NIL},;	// 11
									{'C7_TES'	 	, ''				, NIL},;	// 12
									{'C7_FILCEN'	, ''				, NIL},;	// 13
			   						{'C7_TPOP'	 	, 'F'				, NIL},;	// 14
									{'C7_ORIGEM'	, 'LOJA7033'		, NIL},;	// 15
									{'_SEQ'		, nSeq      		, Nil }})	// 16
									

					nAscanFil := Ascan(aIt,{|x|x[1] = cFilDest})
					If nAscanFil = 0
						aAdd(aIt,{cFilDest,aIt2})
					Else
						For nX := 1 to Len(aIt2) 
							aAdd(aIt[nAscanFil][2],aIt2[nX])
						Next
					EndIf
					
					nTpDownload := 1 // Pedido de Compra

				Else             // Solicitacao de Compra

					//[Montagem do array para gerar solicitação de compra em outra filial]
					cFilDest  := If(Len(cCodLoca)>2,substr(cCodLoca,1,nTamFilial),'') 

					// Array da filial
					nAscanFil := Ascan(aCb,{|x|x[1] = cFilDest})
				
					If nAscanFil = 0   
						aCb2 := {}
						aAdd(aCb2, {'C1_NUM'		, ""					, Nil})	
						aAdd(aCb2, {'C1_FILIAL'	, cFilDest				, Nil})	
						aAdd(aCb2, {'C1_EMISSAO'	, ddataBase			, Nil})	
						aAdd(aCb2, {'C1_SOLIV '	, 'DOWNLOAD NEOGRID'	, Nil})
						aAdd(aCb2, {'C1_FILENT'	, cFilDest				, Nil})
						aAdd(aCb2, {'C1_SOLICIT'	, ''    				, Nil})  
						aAdd(aCb,{cFilDest,aCb2})
					Endif	    

					aIt2 := {}
					Aadd(aIt2,{{'C1_ITEM'	, ""				 , NIL},;	 	//01
								{"C1_FORNECE"	, cFornec         , Nil},;		//02
								{"C1_LOJA"		, cLoja           , Nil },;		//03
								{"C1_OBS"		, "Neogrid "+cNum , Nil },;		//04
								{"C1_PRODUTO"	, cCodpro         , Nil },;		//05
								{"C1_QUANT"	, nQtdPed         , Nil },;		//06
								{"C1_QTDORI"	, nQtdPed         , Nil },;		//07
								{"C1_ORIGEM"	, "LOJA7033"      , Nil },;		//08
								{"_SEQ"		, nSeq      		, Nil }})		//09, mudar o número na finalização da gravação

					nAscanFil := Ascan(aIt,{|x|x[1] = cFilDest})
					If nAscanFil = 0
						aAdd(aIt,{cFilDest,aIt2})
					Else
						For nX := 1 to Len(aIt2) 
							aAdd(aIt[nAscanFil][2],aIt2[nX])
						Next
					EndIf
					
					nTpDownload := 2 // Solicitacao de Compra				   

		        Endif
		Endcase
		
		// Gravação em array
		aAdd(aRetXML,{nSeq, "",;
			          {cNum, cCodPro, cCodLoca, dEmis,;
						nQtdPed, cIdOrigem, cCodItemOr, cCodLocaldOr,;
						dDtMovOr, nQtdPedOr, cFornecedor, cObs,;
						nUnitiz, cGrp1For, cGrp2For, dDataProgr,;
						cCodBar, cImportado, cCodigoCapa, nTipoEstoqueSeg,;
						cPriorTVD, cGrp2LcEstDest}})
		
	Next n1
Endif

If lContinua

	Do Case

		Case nTpDownload = 1		//Pedido de Compra 
			If Len(aCb) > 0 .And. Len( aIt ) > 0   
				cFilOrig := cFilAnt
				For nX := 1 to Len(aCb)
					lSuccess := .T.
					cFilAnt	:= aCb[nX][1]
					If cFilAnt <> cFilTrab
						Reset ENVIRONMENT                      
						PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilAnt TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                     						                                      "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                          						                 "SX5","SM0"
					EndIf
					
					//Verificação se o produto existe
					nAscanFilPro := 0
					nAscanFil := Ascan( aIt[nX][2][1],{|x|x[1] == "C7_PRODUTO" })
					If nAscanFil > 0
						nAscanFilPro := nAscanFil  //Para ler em C7_PRECO
						nDel := 0
						nTot := Len(aIt[nX][2])
						For nY := 1 to nTot-nDel
							If nY <= (nTot-nDel)
								cCodPro := aIt[nX][2][nY][nAscanFil][2]
								If !SB1->(DbSeek(xFilial('SB1')+cCodPro))
									ConOut(STR0041 + cCodPro + STR0053)  //"O produto "###" nao existe para efetuar pedido de compra."							
									LjGrvLog(STR0057,STR0041 + cCodPro + STR0053,Nil)	//"Importacao DRP Neogrid"  //"O produto "###" nao existe para efetuar pedido de compra."  
									cCodPro := ""
									//Deleto do circuito de arrays
									nDel:=nDel+1
									aDel(aIt[nX][2],nY)
									aSize(aIt[nX][2],nTot-nDel)
									nY:=nY-1
								EndIf
							EndIf
						Next
						If nTot-nDel=0  //Não há mais itens prontos para a criação do pedido de compra
							lSuccess := .F. 
						EndIf
					Else
						cCodPro := ""
						lSuccess := .F. 
					EndIf

					//Verificação se o produto existe
					If lSuccess
						nAscanFil := Ascan( aIt[nX][2][1],{|x|x[1] == "C7_PRECO" })
						If nAscanFil > 0
							nDel := 0
							nTot := Len(aIt[nX][2])
							For nY := 1 to nTot-nDel
								If nY <= (nTot-nDel)
									cCodPro := aIt[nX][2][nY][nAscanFilPro][2]
									nPreco := aIt[nX][2][nY][nAscanFil][2]
									If nPreco = 0
										ConOut(STR0054 + cCodPro + STR0055 + STR0056) //"Produto "###" sem último preco de compra cadastrado! "###"Favor cadastrar Ultimo Preco no Cadastro de Produtos!"
										LjGrvLog(STR0057,STR0054 + cCodPro + STR0055 + STR0056,Nil)	//"Importacao DRP Neogrid"  //"Produto "###" sem último preco de compra cadastrado! "###"Favor cadastrar Ultimo Preco no Cadastro de Produtos!"  
										cCodPro := ""
										//Deleto do circuito de arrays
										nDel:=nDel+1
										aDel(aIt[nX][2],nY)
										aSize(aIt[nX][2],nTot-nDel)
										nY:=nY-1
									EndIf
								EndIf
							Next
							If nTot-nDel=0  //Não há mais itens prontos para a criação do pedido de compra
								lSuccess := .F. 
							EndIf
						Else
							cCodPro := ""
							lSuccess := .F. 
						EndIf
					EndIf

					If lSuccess
						//Atribuição de ID do documento
						nAscanFil := Ascan( aCb[nX][2],{|x|x[1] == "C7_NUM" })
						If nAscanFil > 0
							aCb[nX][2][nAscanFil][2] := CriaVar("C7_NUM",.T.)
							cNumDoc := aCb[nX][2][nAscanFil][2]
						Else
							cNumDoc := "??????"
						EndIf
					   
						//Atribuição de Sequencial de Item
						nAscanFil := Ascan( aIt[nX][2][1],{|x|x[1] == "C7_ITEM" })
						If nAscanFil > 0
							For nY := 1 to Len(aIt[nX][2])
								aIt[nX][2][nY][nAscanFil][2] := Strzero(nY,TamSX3("C7_ITEM")[1])
							Next
						EndIf
					EndIf
					   
					If lSuccess
						Begin Transaction
							aMsgErr := {}
							Lj7033FixaUsr()
							lMsErroAuto := .F.
							MSExecAuto( {|v,x,y,z,w| MATA120(v,x,y,z,w)},1,aCb[nX][2],aIt[nX][2],3,.F.)
							If lMsErroAuto
								ConOut(STR0020) //"Erro na Criacao do Pedido de Compra"
								LjGrvLog(STR0057,STR0020,Nil)	//"Importacao DRP Neogrid"  //"Erro na Criacao do Pedido de Compra"  
								ConOut(MostraErro())
								LjGrvLog(STR0057,MostraErro(),Nil)	//"Importacao DRP Neogrid"    
								Disarmtransaction()
								lSuccess := .F.
							Else
								ConOut(STR0021 + Alltrim(cFilAnt) + "/" + cNumDoc + STR0022) //"Pedido de Compra "###" criado com sucesso"
								LjGrvLog(STR0057,STR0021 + Alltrim(cFilAnt) + "/" + cNumDoc + STR0022,Nil)	//"Importacao DRP Neogrid"  //"Pedido de Compra "###" criado com sucesso"  
								lSuccess := .T.
							EndIf
						End Transaction
					EndIf
					If lSuccess
						//Marco que foi gravado no array de controle no XML
						//aIt[nX][2][nY][16][2] = número da sequencia
						For nY := 1 to Len(aIt[nX][2])
							nAscanFil := Ascan(aRetXML,{|x|x[1]=aIt[nX][2][nY][16][2]})  //posição _SEQ
							If nAscanFil > 0
								aRetXML[nAscanFil][2] := "X"
							EndIf
						Next
					EndIf
					If cFilAnt <> cFilTrab
						Reset ENVIRONMENT                      
						PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilTrab TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                     						                                      "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                          						                 "SX5","SM0"
					EndIf   
				Next
				cFilAnt	:= cFilOrig   
			EndIf	

		Case nTpDownload = 2		//Solicitação de Compra 
			If Len(aCb) > 0 .And. Len( aIt ) > 0   
				cFilOrig := cFilAnt
				For nX := 1 to Len(aCb)
					lSuccess := .T.
					cFilAnt	:= aCb[nX][1]
					If cFilAnt <> cFilTrab
							Reset ENVIRONMENT                      
							PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilAnt TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                     						                                      "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                          						                 "SX5","SM0"
					EndIf   

					//Verificação se o produto existe
					nAscanFil := Ascan( aIt[nX][2][1],{|x|x[1] == "C1_PRODUTO" })
					If nAscanFil > 0
						nDel := 0
						nTot := Len(aIt[nX][2])
						For nY := 1 to nTot-nDel
							If nY <= (nTot-nDel)
								cCodPro := aIt[nX][2][nY][nAscanFil][2]
								If !SB1->(DbSeek(xFilial('SB1')+cCodPro))
									ConOut(STR0041 + cCodPro + STR0058)  //"O produto "###" nao existe para efetuar solicitacao de compra."							
									LjGrvLog(STR0057,STR0041 + cCodPro + STR0058,Nil)	//"Importacao DRP Neogrid"  //"O produto "###" nao existe para efetuar solicitacao de compra."  
									cCodPro := ""
									//Deleto do circuito de arrays
									nDel:=nDel+1
									aDel(aIt[nX][2],nY)
									aSize(aIt[nX][2],nTot-nDel)
									nY:=nY-1
								EndIf
							EndIf
						Next
						If nTot-nDel=0  //Não há mais itens prontos para a criação da solicitacao de compra
							lSuccess := .F. 
						EndIf
					Else
						cCodPro := ""
						lSuccess := .F. 
					EndIf

					If lSuccess
						//Atribuição de ID do documento
						nAscanFil := Ascan( aCb[nX][2],{|x| x[1] == "C1_NUM"} )
						If nAscanFil > 0
							aCb[nX][2][nAscanFil][2] := CriaVar("C1_NUM",.T.)
							cNumDoc := aCb[nX][2][nAscanFil][2]
						Else
							cNumDoc := "??????"
						EndIf
					   
						//Atribuição de Sequencial de Item
						nAscanFil := Ascan( aIt[nX][2][1],{|x|x[1] == "C1_ITEM" })
						If nAscanFil > 0
							For nY := 1 to Len(aIt[nX][2])
								aIt[nX][2][nY][nAscanFil][2] := Strzero(nY,TamSX3("C1_ITEM")[1])
							Next
						EndIf
					
		   				Begin Transaction
							aMsgErr := {}
							Lj7033FixaUsr()
							lMsErroAuto := .F.
							MSExecAuto({|x,y,z| MATA110(x,y,z)},aCb[nX][2],aIt[nX][2],3) //Inclusao
							If lMsErroAuto
								ConOut(MostraErro())
								LjGrvLog(STR0057,MostraErro(),Nil)	//"Importacao DRP Neogrid"  
								DisarmTransaction()
								ConOut(STR0023) //"Erro na Criacao da Solicitacao de Compra"
								LjGrvLog(STR0057,STR0023,Nil)	//"Importacao DRP Neogrid"  //"Erro na Criacao da Solicitacao de Compra"  
								lSuccess := .F.
							Else
								ConOut(STR0024 + Alltrim(cFilAnt) + "/" + cNumDoc + STR0025) //"Solicitacao de Compra "###" criada com sucesso"
								LjGrvLog(STR0057,STR0024 + Alltrim(cFilAnt) + "/" + cNumDoc + STR0025,Nil)	//"Importacao DRP Neogrid"  //"Solicitacao de Compra "###" criada com sucesso"  
								lSuccess := .T.
							EndIf
						End Transaction
					EndIf	
					If lSuccess
						//Marco que foi gravado no array de controle no XML
						//aIt[nX][2][nY][9][2] = número da sequencia
						For nY := 1 to Len(aIt[nX][2])
							nAscanFil := Ascan(aRetXML,{|x|x[1]=aIt[nX][2][nY][9][2]})  //posição _SEQ
							If nAscanFil > 0
								aRetXML[nAscanFil][2] := "X"
							EndIf
						Next
					EndIf
					If cFilAnt <> cFilTrab
							Reset ENVIRONMENT                      
							PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilTrab TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                     						                                      "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                          						                 "SX5","SM0"
					EndIf   
				Next   
				cFilAnt	:= cFilOrig
			EndIf
				
	   Endcase
			
		//Transferência entre Armazéns 
		If Len(aAutoA) > 0 
			cFilOrig := cFilAnt
			For nX := 1 to Len(aAutoA)
				lSuccess := .T.
				cFilAnt	:= aAutoA[nX][1][1]
				If cFilAnt <> cFilTrab
						Reset ENVIRONMENT                      
						PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilAnt TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                    						                                      "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                         						                 "SX5","SM0"
				EndIf   

				//Pré-Validação:
				//Verifico se o produto existe
				DbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
				If !SB1->(DbSeek(xFilial("SB1")+aAutoA[nX][2][2][1]))
					ConOut(STR0040 + cFilAnt)	//"Filial "
					ConOut(STR0041 + aAutoA[nX][2][2][1] + STR0060)  //"O produto "###" nao existe para efetuar transferencia entre armazens."
					LjGrvLog(STR0057,STR0040 + cFilAnt,Nil)	//"Importacao DRP Neogrid"  //"Filial "  
					LjGrvLog(STR0057,STR0041 + aAutoA[nX][2][2][1] + STR0060,Nil)	//"Importacao DRP Neogrid"  //"O produto "###" nao existe para efetuar transferencia entre armazens."  
					lSuccess := .F.
				EndIf	

				If lSuccess
					//Verifico se tem saldo de estoque
					DbSelectArea("SB2")
					DbSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL  
					If DbSeek(xFilial("SB2") + Left(aAutoA[nX][2][2][1],TamSX3("B2_COD")[1]) + aAutoA[nX][2][2][4],.T.)
						nSaldoSB2 := SaldoSB2(.T.)
					Else
						nSaldoSB2 := 0
					EndIf
					If nSaldoSB2 - aAutoA[nX][2][2][16] < 0  // Saldo menos quantidade
						ConOut(STR0040 + cFilAnt + " - " + STR0062 + aAutoA[nX][2][2][4])	//"Filial "###"Armazem "
						ConOut(STR0041 + aAutoA[nX][2][2][1] + STR0061)  //"O produto "###" nao tem saldo suficiente para efetuar transferencia entre armazens."
						ConOut(STR0044 + aAutoA[nX][2][2][1] + ": " + Alltrim(Str(nSaldoSB2)))     //"Saldo do Estoque              "
						ConOut(STR0045 + aAutoA[nX][2][2][1] + ": " + Alltrim(Str(aAutoA[nX][2][2][16])))  //"Quantidade a ser subtraida em "
						ConOut(STR0046 + aAutoA[nX][2][2][1] + ": " + Alltrim(Str(nSaldoSB2-aAutoA[nX][2][2][16])))  //"Saldo apos transferencia em   "
						ConOut(STR0047)			//"Portanto, a transferencia nao foi efetuada."
						LjGrvLog(STR0057,STR0040 + cFilAnt + " - " + STR0062 + aAutoA[nX][2][2][4],Nil)	//"Importacao DRP Neogrid"  //"Filial "###"Armazem "  
						LjGrvLog(STR0057,STR0041 + aAutoA[nX][2][2][1] + STR0061,Nil)	//"Importacao DRP Neogrid"  //"O produto "###" nao tem saldo suficiente para efetuar transferencia entre armazens  
						LjGrvLog(STR0057,STR0044 + aAutoA[nX][2][2][1] + ": " + Alltrim(Str(nSaldoSB2)),Nil)	//"Importacao DRP Neogrid"  //"Saldo do Estoque              "  
						LjGrvLog(STR0057,STR0045 + aAutoA[nX][2][2][1] + ": " + Alltrim(Str(aAutoA[nX][2][2][16])),Nil)	//"Importacao DRP Neogrid"  //"Quantidade a ser subtraida em "  
						LjGrvLog(STR0057,STR0046 + aAutoA[nX][2][2][1] + ": " + Alltrim(Str(nSaldoSB2-aAutoA[nX][2][2][16])),Nil)	//"Importacao DRP Neogrid"  //"Saldo apos transferencia em   "  
						LjGrvLog(STR0057,STR0047,Nil)	//"Importacao DRP Neogrid"  //"Portanto, a transferencia nao foi efetuada."  
						lSuccess := .F.
					EndIf
				EndIf				

				If lSuccess
					//Atribuição de ID do documento
					aAutoA[nX][2][1][1] := GetSxENum("SD3","D3_DOC",1)
					cNumDoc := aAutoA[nX][2][1][1]
	
					Begin Transaction
						Lj7033FixaUsr()
						lMsErroAuto := .F.
						MSExecAuto({|x,y| mata261(x,y)},aAutoA[nX][2],3)				
						If lMsErroAuto			
							ConOut(MostraErro())		
							LjGrvLog(STR0057,MostraErro(),Nil)	//"Importacao DRP Neogrid"  
							DisarmTransaction()
							ConOut(STR0026) //"Erro na Criacao da Transferencia entre Armazens"
							LjGrvLog(STR0057,STR0026,Nil)	//"Importacao DRP Neogrid"  //"Erro na Criacao da Transferencia entre Armazens"  
							lSuccess := .F.
						Else
							ConOut(STR0027 + Alltrim(cFilAnt) + "/" + cNumDoc + STR0028) //"Transferencia entre Armazens numero "###" criada com sucesso"
							LjGrvLog(STR0057,STR0027 + Alltrim(cFilAnt) + "/" + cNumDoc + STR0028,Nil)	//"Importacao DRP Neogrid"  //"Transferencia entre Armazens numero "###" criada com sucesso"  
							lSuccess := .T.
						EndIf		
					End Transaction
				EndIf
				If lSuccess
					//Marco que foi gravado no array de controle no XML
					//aAutoA[nX][2][2][19] = número da sequencia
					nAscanFil := Ascan(aRetXML,{|x|x[1]=Val(aAutoA[nX][2][2][19])})
					If nAscanFil > 0
						aRetXML[nAscanFil][2] := "X"
					EndIf
				EndIf
				If cFilAnt <> cFilTrab
					Reset ENVIRONMENT                      
					PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilTrab TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                   					                                      "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                      						                 "SX5","SM0"
				EndIf   
			Next
			cFilAnt	:= cFilOrig
		Endif
		  
		//Transferência entre Filiais 
		If Len(aAuto) > 0 .AND. Len(aAuto2) > 0
			SX5->(DbUnlock())
			For nX := 1 to Len(aAuto) 
				lSuccess := .T.

				cFilAnt	:= aAuto[nX][1]   // filial de ORIGEM
				If cFilAnt <> cFilTrab
						Reset ENVIRONMENT                      
						PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilAnt TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                    						                                      "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                         						                 "SX5","SM0"
				EndIf   

				//Pré-Validação: não há como validar dentro do ExecAuto pois não retorna erros.
				//Verifico se o produto existe
				DbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
				If !SB1->(DbSeek(xFilial("SB1")+aAuto[nX][2]))
					ConOut(STR0040 + cFilAnt)	//"Filial "
					ConOut(STR0041 + aAuto[nX][2] + STR0042)  //"O produto "###" nao existe para efetuar transferencia entre filiais."
					LjGrvLog(STR0057,STR0040 + cFilAnt,Nil)	//"Importacao DRP Neogrid"  //"Filial "  
					LjGrvLog(STR0057,STR0041 + aAuto[nX][2] + STR0042,Nil)	//"Importacao DRP Neogrid"  //"O produto "###" nao existe para efetuar transferencia entre filiais."  
					lSuccess := .F.
				EndIf	

				If lSuccess
					//Verifico se tem saldo de estoque
					DbSelectArea("SB2")
					DbSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL  
					If DbSeek(xFilial("SB2") + Left(aAuto[nX][2],TamSX3("B2_COD")[1]) + aAuto[nX][3],.T.)
						nSaldoSB2 := SaldoSB2(.T.)
					Else
						nSaldoSB2 := 0
					EndIf
					If nSaldoSB2 - aAuto[nX][4] < 0  // Saldo menos quantidade
						ConOut(STR0040 + cFilAnt + " - " + STR0062 + aAuto[nX][3])	//"Filial "###"Armazém "
						ConOut(STR0041 + aAuto[nX][2] + STR0043)  //"O produto "###" nao tem saldo suficiente para efetuar transferencia entre filiais."
						ConOut(STR0044 + aAuto[nX][2] + ": " + Alltrim(Str(nSaldoSB2)))     //"Saldo do Estoque              "
						ConOut(STR0045 + aAuto[nX][2] + ": " + Alltrim(Str(aAuto[nX][4])))  //"Quantidade a ser subtraida em "
						ConOut(STR0046 + aAuto[nX][2] + ": " + Alltrim(Str(nSaldoSB2-aAuto[nX][4])))  //"Saldo apos transferencia em   "
						ConOut(STR0047)			//"Portanto, a transferencia nao foi efetuada."
						LjGrvLog(STR0057,STR0040 + cFilAnt + " - " + STR0062 + aAuto[nX][3],Nil)	//"Importacao DRP Neogrid"  //"Filial "###"Armazém "  
						LjGrvLog(STR0057,STR0041 + aAuto[nX][2] + STR0043,Nil)	//"Importacao DRP Neogrid"  //" nao tem saldo suficiente para efetuar transferencia entre filiais."  
						LjGrvLog(STR0057,STR0044 + aAuto[nX][2] + ": " + Alltrim(Str(nSaldoSB2)),Nil)	//"Importacao DRP Neogrid"  //"Saldo do Estoque              "  
						LjGrvLog(STR0057,STR0045 + aAuto[nX][2] + ": " + Alltrim(Str(aAuto[nX][4])),Nil)	//"Importacao DRP Neogrid"  //"Quantidade a ser subtraida em "  
						LjGrvLog(STR0057,STR0046 + aAuto[nX][2] + ": " + Alltrim(Str(nSaldoSB2-aAuto[nX][4])),Nil)	//"Importacao DRP Neogrid"  //"Saldo apos transferencia em   "  
						LjGrvLog(STR0057,STR0047,Nil)	//"Importacao DRP Neogrid"  //"Portanto, a transferencia nao foi efetuada."  
						lSuccess := .F.
					EndIf
				EndIf				

				// Volto à filial de origem
				If cFilAnt <> cFilTrab
					Reset ENVIRONMENT                      
					PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilTrab TABLES "SB1","SC7","SD3","SC1","SA1","SA2","SB2",;
                   					                                      "SD1","SD2","SF4","SC5","SC6","CC7","SIX",;
                                      						                 "SX5","SM0"
				EndIf   

				If lSuccess
					aAutoAux := {aAuto[nX]}
					Lj7033FixaUsr()
					Begin Transaction
						lMsErroAuto := .F.
						MSExecAuto({|x,y,z,a| lSuccess := a310proc(x,y,z,a)},;
										aAutoAux,aAuto2,;
										{{aAuto[nX][6],cTFSerie,""},;
						 				{aAuto[nX][1],cTFSerie,""}},;
						 				{},3)				
						If lMsErroAuto .OR. !lSuccess			
							ConOut(STR0029) //"Erro na Criacao da Transferencia entre Filiais"
							LjGrvLog(STR0057,STR0029,Nil)	//"Importacao DRP Neogrid"  //"Erro na Criacao da Transferencia entre Filiais"  
							ConOut(MostraErro())		
							LjGrvLog(STR0057,MostraErro(),Nil)	//"Importacao DRP Neogrid"  
							DisarmTransaction()
						Else
							//Nota: A transferência pode não ser criada com sucesso, pois há um msexecauto dentro do msexecauto.
							//Por isso, houve pré-validações linhas acima, como produto e saldo de estoque.
							ConOut(STR0049) //"Transferencia entre Filiais criada com sucesso!"
							ConOut(STR0063 + aAutoAux[1][1]) //"Filial de Origem  : "
							ConOut(STR0064 + aAutoAux[1][6]) //"Filial de Destino : "
							ConOut("Produto           : " + aAutoAux[1][2]) //"Produto           : "
							ConOut(STR0065 + Alltrim(Str(aAutoAux[1][4]))) //"Quantidade Transf.: "
							ConOut(" ")
							LjGrvLog(STR0057,STR0049,Nil)	//"Importacao DRP Neogrid"  //"Transferencia entre Filiais criada com sucesso!"  
							LjGrvLog(STR0057,STR0063 + aAutoAux[1][1],Nil)	//"Importacao DRP Neogrid"  //"Filial de Origem  : "  
							LjGrvLog(STR0057,STR0064 + aAutoAux[1][6],Nil)	//"Importacao DRP Neogrid"  //"Filial de Destino : "  
							LjGrvLog(STR0057,"Produto           : " + aAutoAux[1][2],Nil)	//"Importacao DRP Neogrid"  //"Produto           : "  
							LjGrvLog(STR0057,STR0065 + Alltrim(Str(aAutoAux[1][4])),Nil)	//"Importacao DRP Neogrid"  //"Quantidade Transf.: "  
							LjGrvLog(STR0057," ",Nil)	//"Importacao DRP Neogrid"  
						EndIf		
					End Transaction
				EndIf
				If !lSuccess
					ConOut(STR0048)  //"Transferencia nao foi criada!"
					LjGrvLog(STR0057,STR0048,Nil)	//"Importacao DRP Neogrid" //"Transferencia nao foi criada!"  
					// Função para recriação do XML
				Else
					//Marco que foi gravado no array de controle no XML
					//aAuto[nX][25] = número da sequencia
					nAscanFil := Ascan(aRetXML,{|x|x[1]=aAuto[nX][25]})
					If nAscanFil > 0
						aRetXML[nAscanFil][2] := "X"
					EndIf
				EndIf
			Next
		Endif
		  
EndIf

// Se houver erros em algum dos itens, crio um novo XML somente com os itens não processados.
Loja7033VoltaXML(aRetXml)
	
Return .T.


/*----------------------------------------------------------
  	   Integração Totvs Colaboração DRP NeoGrid   
	Copio para o array quem são os cli/fornec. 
	que tem A1_FILTRF/A2_FILTRF
@author  	Edilson Cruz
@version 	P11                                                                                             
@build		
@since 		29/09/2015
@return 	Nil														  	  
----------------------------------------------------------*/
Static Function Loja7033TF()

Local aArea 		:= GetArea()		//Área anterior
Local cArqIdx1    := ""				//Arquivo de Indice Temporario - SA1
Local nIndex1		:= 0				//Quantos Indices Existentes - SA1
Local cArqIdx2    := ""				//Arquivo de Indice Temporario - SA2
Local nIndex2		:= 0				//Quantos Indices Existentes - SA2

//Clientes - atribuo para o array quem é Empresa
dbSelectArea("SA1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta filtro e indice temporario na SA1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqIdx1 := CriaTrab(,.F.)
IndRegua("SA1", cArqIdx1,"A1_FILTRF",,,STR0052) //"Selecionando Registros ..."
nIndex1 := RetIndex("SA1")
#IFNDEF TOP
	dbSetIndex(cArqIdx1+OrdBagExt())
#ENDIF
dbSetOrder(nIndex1+1) //A1_FILTRF

DbSelectArea("SA1")
SA1->(DbSeek(CHR(33),.T.)) //Softseek, procura o primeiro registro após o em branco
Do While !SA1->(Eof())
	If !Empty(SA1->A1_FILTRF)
		aAdd(aCliFil,{SA1->A1_COD,SA1->A1_LOJA,SA1->A1_FILTRF,SA1->A1_FILIAL})
	EndIf	
	SA1->(DbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta filtro e indice temporario na SA2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqIdx2 := CriaTrab(,.F.)
IndRegua("SA2", cArqIdx2,"A2_FILTRF",,,STR0052) //"Selecionando Registros ..."
nIndex2 := RetIndex("SA2")
#IFNDEF TOP
	dbSetIndex(cArqIdx2+OrdBagExt())
#ENDIF
dbSetOrder(nIndex2+1) //A2_FILTRF

//Fornecedores - atribuo para o array quem é Empresa
DbSelectArea("SA2")
SA2->(DbSeek(CHR(33),.T.)) //Softseek, procura o primeiro registro após o em branco
Do While !SA2->(Eof())
	If !Empty(SA2->A2_FILTRF)
		aAdd(aForFil,{SA2->A2_COD,SA2->A2_LOJA,SA2->A2_FILTRF,SA2->A2_FILIAL})
	EndIf	
	SA2->(DbSkip())
EndDo

// Apagar os indices temporarios
dbSelectArea("SA1")
RetIndex("SA1")
Ferase( cArqIdx1 + OrdBagExt() )

dbSelectArea("SA2")
RetIndex("SA2")
Ferase( cArqIdx2 + OrdBagExt() )

RestArea(aArea)
lLeuSA1SA2 := .T.

Return .T.


/*----------------------------------------------------------
  	   Integração Totvs Colaboração DRP NeoGrid   
	Copio para o array os dados não processados por erro.
	Em seguida, crio um arquivo XML somente com os
	dados não processados.
@author  	Edilson Cruz
@version 	P11                                                                                             
@build		
@since 		29/09/2015
@return 	Nil														  	  
----------------------------------------------------------*/
Static Function Loja7033VoltaXML(aRetXml)

Local nX := 0			//Contador
Local cXml 		:= ""	// Montagem XML
Local cXmlAux 	:= ""	// XML por item
Local cArquivo 	:= DTOS(date())+Left(time(),2)+Substr(time(),4,2)+Substr(time(),7,2)+"ret.xml"  // Arquivo default para gravação
Local cXmlCab		:= '<?xml version="1.0" encoding="UTF-8"?>'+CRLF+; // XML - Cabeçalho
						'<DOWN_PDCOMPRA xsi:noNamespaceSchemaLocation="tss_Down_PdCompra.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns1="TotvsColabDownPdCompra">'+CRLF
Local cXmlRodape	:= '</DOWN_PDCOMPRA>'			//XML - Rodapé				
Local nHandle		:= 0				// Handle para FWRITE
Local cPathIn		:= GetNewPar("MV_LJNEOIN","\NEOIN\")   // Considerando o MV_LJNEOIN já validada na função principal 

For nX := 1 to Len(aRetXml)
	If Empty(aRetXml[nX][2])
		
		cXmlAux :="<ITEM>"+CRLF
		cXmlAux +="<ns1:Itens>"+CRLF
		cXmlAux +="<ns1:CodPed>"+aRetXml[nX][3][ 1]+"</ns1:CodPed>"+CRLF
		cXmlAux +="<ns1:CodPro>"+Alltrim(aRetXml[nX][3][ 2])+"</ns1:CodPro>"+CRLF
		cXmlAux +="<ns1:CodLoca>"+aRetXml[nX][3][ 3]+"</ns1:CodLoca>"+CRLF
		If Empty(aRetXml[nX][3][4])
			cXmlAux +="<ns1:DtMov></ns1:DtMov>"+CRLF
		Else
			cXmlAux +="<ns1:DtMov>"+DTOS(aRetXml[nX][3][ 4])+"</ns1:DtMov>"+CRLF
		EndIf
		cXmlAux +="<ns1:QtdPed>"+Alltrim(Str(aRetXml[nX][3][ 5]))+"</ns1:QtdPed>"+CRLF
		cXmlAux +="<ns1:IdOrigem>"+aRetXml[nX][3][ 6]+"</ns1:IdOrigem>"+CRLF
		cXmlAux +="<ns1:CodItemOr>"+Alltrim(aRetXml[nX][3][ 7])+"</ns1:CodItemOr>"+CRLF
		cXmlAux +="<ns1:CodLocaldOr>"+aRetXml[nX][3][ 8]+"</ns1:CodLocaldOr>"+CRLF
		If Empty(aRetXml[nX][3][9])
			cXmlAux +="<ns1:DtMovOr></ns1:DtMovOr>"+CRLF
		Else
			cXmlAux +="<ns1:DtMovOr>"+DTOS(aRetXml[nX][3][ 9])+"</ns1:DtMovOr>"+CRLF
		EndIf
		cXmlAux +="<ns1:QtdPedOr>"+Alltrim(Str(aRetXml[nX][3][10]))+"</ns1:QtdPedOr>"+CRLF
		cXmlAux +="<ns1:Fornecedor>"+aRetXml[nX][3][11]+"</ns1:Fornecedor>"+CRLF
		cXmlAux +="<ns1:Obs>"+aRetXml[nX][3][12]+"</ns1:Obs>"+CRLF
		cXmlAux +="<ns1:Unitiz>"+Alltrim(Str(aRetXml[nX][3][13]))+"</ns1:Unitiz>"+CRLF
		cXmlAux +="<ns1:Grp1For>"+aRetXml[nX][3][14]+"</ns1:Grp1For>"+CRLF
		cXmlAux +="<ns1:Grp2For>"+aRetXml[nX][3][15]+"</ns1:Grp2For>"+CRLF
		If Empty(aRetXml[nX][3][16])
			cXmlAux +="<ns1:DataProgr></ns1:DataProgr>"+CRLF
		Else
			cXmlAux +="<ns1:DataProgr>"+DTOS(aRetXml[nX][3][16])+"</ns1:DataProgr>"+CRLF
		EndIf
		cXmlAux +="<ns1:CodBar>"+aRetXml[nX][3][17]+"</ns1:CodBar>"+CRLF
		cXmlAux +="<ns1:Importado>"+aRetXml[nX][3][18]+"</ns1:Importado>"+CRLF
		cXmlAux +="<ns1:CodigoCapa>"+aRetXml[nX][3][19]+"</ns1:CodigoCapa>"+CRLF
		cXmlAux +="<ns1:TipoEstoqueSeguranca>"+Alltrim(Str(aRetXml[nX][3][20]))+"</ns1:TipoEstoqueSeguranca>"+CRLF
		cXmlAux +="<ns1:PriorTVD>"+aRetXml[nX][3][21]+"</ns1:PriorTVD>"+CRLF
		cXmlAux +="<ns1:Grp2LcEstDest>"+aRetXml[nX][3][22]+"</ns1:Grp2LcEstDest>"+CRLF
		cXmlAux +="</ns1:Itens>"+CRLF
		cXmlAux +="</ITEM>"+CRLF

		cXml += cXmlAux		
	EndIf
Next

If !Empty(cXml)
	nHandle := FCreate( cPathIn + cArquivo )
	If (nHandle == -1)
		FClose( nHandle )
		ConOut(STR0050 + cArquivo + STR0051) //"Arquivo "###" não pode ser criado!"
		LjGrvLog(STR0057,STR0050 + cArquivo + STR0051,Nil)	//"Importacao DRP Neogrid" //"Arquivo "###" não pode ser criado!"  
	Else
		FWrite( nHandle, cXmlCab+cXml+cXmlRodape )
		FClose( nHandle )
	EndIf
	
EndIf

Return .T.


/*----------------------------------------------------------
  	   Integração Totvs Colaboração DRP NeoGrid   
	Após a nova abertura do Prepare Environment,
	Tenho que ler novamente o código do usuário
	e atribuir na variável pública, pois é lido
	na rotina de transferência entre filiais.
@author  	Edilson Cruz
@version 	P11                                                                                             
@build		
@since 		05/11/2015
@return 	Nil														  	  
----------------------------------------------------------*/
Static Function Lj7033FixaUsr()

//Variável pública: quando eu configuro o usuário, existe sempre o administrador com código 000000.
//Logo, preciso executar o job com este código de administrador. 
//Lembrando que é impossível deletar este código no cadastro de usuários.
If __cUserID <> "000000"
	__cUserID := "000000"
	cUserName := "ADMIN"  //Obrigatório para Job
EndIf	

Return .T.
