#INCLUDE 'LOJA7030.CH'
#INCLUDE 'Protheus.ch' 
#INCLUDE  'TBICONN.ch'
#INCLUDE "TBICODE.CH"
#INCLUDE 'TOPConn.ch'   
#include "fileio.ch"
#DEFINE CRLF CHR(13)+CHR(10)

Static nModAnt := 0		//Para gravação do modelo, verifico se não é o mesmo modelo para criação do mesmo arquivo
//----------------------------------------------------------
/*	 Integração Totvs Colaboração DRP NeoGrid
@author  	Carlos MOta
@version 	P11                                                                                             
@build		
@since 		23/07/2013
@return 	Nil												*/
//----------------------------------------------------------
Function LOJA7030(aParam)

Local cArea      
Local cXML       := ''       // Xml de Envio
Local cQry       := ''       // String da Query
Local cAliasTmp  := 'TMPDRP' // Alias do Arquivo temporario 1
Local cAliasTmp2 := 'TMPDRP2' // Alias do Arquivo temporario 2 
Local cAliasTmp3 := 'TMPDRP3' // Alias do Arquivo temporario 3 
Local lCabXml    := .f.      // Variavel para verificar se existe Cabecalho do XMl
Local lItXml     := .f.      // Variavel para verificar se existe Itens do XMl
Local aRet       := {}       // Vetor com o retorno do envio para a NeoGrid
Local aQry       := {}       // Vetor para guardar os filtros dos eventos
Local aFiltro    := {}       // Vetor para guardar os filtros dos eventos
Local cEmp       := ""       // Recebe a Empresa 
Local cFilTrab   := ""       // Recebe a Filial
Local lSched     := .F.      // Se for Schedule ou nao
Local aPrm       := {}       // Parametros com os filtros
Local oTSS			:= nil      // Objeto com o retorno do Tss
Local cURL			:= ""       // URL para o uso do Tss
Local nNeoCom		:= 0        // Variavel para verificar o tipo de envio para a neogrid <1> WebService ou <2>EDI
Local cRet			:= ""       // Retorno da comunicacao de envio
Local Ddata1		:= Ctod("") // Data Inicio
Local nCusto		:= 0       // Custo do Produto
Local nPreco		:= 0       // Preco do Produto
Local nMargem		:= 0       // Margem do Produto
Local nScan		:= 0		// Retorno do ascan
Local nScan2		:= 0		// Retorno segundo, do ascan
Local N1			:= 0		// Contador do For
Local N2  			:= 0	 	// Contador do For
Local nAtuOri		:= 1		// Variavel 1 (Origem SKU)
Local nAtuDes		:= 1		// Variavel 2 (Origem SKU)
Local nCodNeogrid	:= 0		// Código da Empresa do Neogrid
Local cUsuarioDRP	:= ""		// Código de Usuário Padrão DRP
Local lAtivaDRP	:= .F.		// Ativa Integração Protheus x DRP Neogrid
Local aFiliais	:= {}		// Array com dados das filiais
Local aAreaSM0	:= {}		// GetArea da SM0 (empresas/filiais)
Local nPosFilial	:= 0		// Posição da filial em aFiliais
Local cNomeFilial	:= ""		// Nome da Filial
Local nSaldoSB2	:= 0		// Saldo SB2
Local cOrSKUTipo		:= ""	// Origem SKU Tipo (V=Venda,T=Transferencia)
Local cOrSKUFilial 	:= ""	// Origem SKU Filial
Local cOrSKUCodigo	:= ""	// Origem SKU Codigo
Local cOrSKULocal  	:= ""	// Origem SKU Local
Local nContador		:= 0	// O nContador verifica quantos registros lidos, para depois aplicar na validação do status.
Local nValidador	:= 0	// O nValidador aplica a gravação do status. Como é QUERY, não há problema utilizar este método, ao invés da busca linear que tem atualizações no meio do processo.
Local cPesqChave			:= ""	// Chave para passar do módulo 5 para o 6, ou do módulo 8 para o 9
Local cPesq2Chave		:= ""	// Chave de Pesquisa para SQL
Local cVarAnt			:= ""	// Variável auxiliar
Local nX				:= 0	// Contador
Local cFWModeSB1		:= ""	// Nível de acessos da tabela SB1, retorna "E"xclusivo ou "C"ompartilhado
Local cFWModeSB5		:= ""	// Nível de acessos da tabela SB5, retorna "E"xclusivo ou "C"ompartilhado
Local cFWModeSA2		:= ""	// Nível de acessos da tabela SA2, retorna "E"xclusivo ou "C"ompartilhado
Local cFWModeACU		:= ""	// Nível de acessos da tabela ACU, retorna "E"xclusivo ou "C"ompartilhado
Local cFWModeACV		:= ""	// Nível de acessos da tabela ACV, retorna "E"xclusivo ou "C"ompartilhado
Local cFWModeNNR		:= ""	// Nível de acessos da tabela NNR, retorna "E"xclusivo ou "C"ompartilhado
Local lFWACVPerm		:= .F.	// Permissão de utilização da tabela ACV
Local lFWACUPerm		:= .F.	// Permissão de utilização da tabela ACU
Local lFWSB5Perm		:= .F.	// Permissão de utilização da tabela SB5
Local cFatConv			:= "0" // Fator de conversão
Local cAux				:= ""  // Variável auxiliar para comparações    	
Local cGetDB			:= ""	// Leio o TCGetDB() para ver o SQL utilizado
Local lMultiFilial		:= .F.	//Se houver Local de Estoque compartilhado, For/Next para cada filial.
Local cFilialNNR		:= ""	//Filial NNR
Local cCodigoNNR		:= ""	//Código NNR para XML
Local aGrupo			:= Array(12)	//Array Grupo
Local nPosGrupo			:= 0	//Posição do Grupo
Local nQE				:= 0	//Quantidade para Embalagem / Unitização
Local cCatOuProd		:= ""	//MV_LJNEOGR	//0=Categoria; 1=Produto
Local lEncontrouPE		:= ExistBlock( "LJDRPEG" )		//Se existir o ponto de entrada LJDRPEG() - Ponto de Entrada Grupo
Local lItemRet			:= .T.	//Item de Retorno para modelo 4
Local lGeraPedColoc		:= .T.	//Se gera Linha de Pedidos Colocados - modelo 12
Local aSaldo			:= {}	//Saldo em CalcEst()
Local cPesqChv6 		:= ""	//Para modelo 6  
Local cPesqChv9 		:= ""	//Para modelo 9  
Local nOrOQuant			:= 0	//Quantidade de Origem  Mov. DFU
Local nOrDQuant			:= 0	//Quantidade de Destino Mov. DFU
Local aStruct			:= ""	//Estrutura para criação da tabela temporária cAliasTmp3 
Local oTempTable		:= Nil	//Tabela Temporária
Local lEncontPE12		:= ExistBlock( "LJDRPEP" )		//Se existir o ponto de entrada LJDRPEG() - Ponto de Entrada Grupo
Local cValidXML			:= ""	//Validação Ponto de Entrada LjDrpEp
Local lPEPValid 		:= .F.	//Validação Lógica do Ponto de Entrada LjDrpEp
Local cMsgVldXML		:= ""	//Mensagem de Validação de XML
Local nt1				:= 0	//Para Ponto de Entrada LJDRPEP
Local nt2				:= 0	//Para Ponto de Entrada LJDRPEP
Local ntAnt1			:= 0	//Para Ponto de Entrada LJDRPEP
Local ntAnt2			:= 0	//Para Ponto de Entrada LJDRPEP
Local aPEP				:= {}	//Array para leitura das TAGS para Ponto de Entrada LJDRPEP
Local aSaldoTerc		:= {}	//Saldo em SaldoTerc()

Default aParam := {}

If Valtype(aParam[1]) <> "U"
	If ValType(aParam[1]) = "A" // schedule
		aadd(aPrm,aParam[1][1])  // Data Inicial 
		aadd(aPrm,aParam[1][2])  // Opcao de envio
		aadd(aPrm,aParam[1][3])  // Empresa passada pelo Schedule
		aadd(aPrm,aParam[1][4])  // Filial  passada pelo Schedule
		If Len(aParam[1]) >= 5
			aadd(aPrm,aParam[1][5])  // Se gera Linha de Pedidos Colocados ou não
		Else
			aadd(aPrm,"True")		//Se não passei o parâmetro, gera Linha de Pedidos Colocados
		EndIf

		lSched   := .T.
		aParam := aclone(aPrm)
	EndIf
EndIf
  
// Configuracao para schedule
If lSched 
   If len(aParam) > 2 .and. !Empty(aParam[3])  
      cEmp := aParam[3]   
   Else 
      Return .F.
   Endif

   If len(aParam) > 3 .and. !Empty(aParam[4])  
      cFilTrab := aParam[4]   
   Else 
      Return .F.
   Endif   

   RPCSETType(3)
   PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilTrab TABLES "SB1","SA2","ACV","ACU","SF4","SB2","SB5",;
                                                           "NNR","SD2","SD1","SD3","MFP","MFR","MFQ",;
                                                           "SA1","SC7","SA2","SM0"
	Conout(STR0001 + dtoc(date()) + STR0002 + time()) //"SCHEDULE Envio DRP - Iniciando rotinas scheduladas em "###" as "
	LjGrvLog(STR0017,STR0001 + dtoc(date()) + STR0002 + time(),Nil)	//"Exportacao DRP Neogrid" //"SCHEDULE Envio DRP - Iniciando rotinas scheduladas em "###" as "
	Conout(STR0003) //"Iniciando Processo de Exportacao"
	LjGrvLog(STR0017,STR0003,Nil)	//"Exportacao DRP Neogrid" //"Iniciando Processo de Exportacao"
	Conout(STR0004+ cEmp +STR0005+ cFilTrab) //"Empresa: "###" Filial: "
	LjGrvLog(STR0017,STR0004+ cEmp +STR0005+ cFilTrab,Nil)	//"Exportacao DRP Neogrid" //"Empresa: "###" Filial: "

EndIf
If len(aParam) > 4 .and. !Empty(aParam[5])	//Este quinto parâmetro é recebido pelos modelos 6 (que veio do 5), e 9 (que veio do 8). Recebe a chave do conteúdo do modelo anterior e não será utilizada vindo de Schedule.  
  cPesqChave := aParam[5]
  If Upper(cPesqChave) = "TRUE" .OR. Upper(cPesqChave) = "FALSE"
  	lGeraPedColoc := IIf(Upper(cPesqChave) = "TRUE", .T., .F.)
  	cPesqChave := ""
  EndIf
Endif          

nNeoCom		:= GetNewPar("MV_LJNEOCM",1)			// Tipo de comunicacao com a NeoGrid 1 - TSS 2 - EDI    
cURL			:= IIF(nNeoCom = 1, PadR(GetNewPar("MV_SPEDURL","http://"),250), "") // É usado se somente TSS
nCodNeoGrid	:= GetNewPar("MV_LJNEOEM",1)			// Código da Empresa do Neogrid
cArea			:= GetArea()								// Area corrente
cUsuarioDRP	:= GetNewPar("MV_LJUSDRP","000001")	// Código do Usuário Padrão DRP
lAtivaDRP		:= GetNewPar("MV_LJDRP",.F.)			// Parâmetro para ativação de DRP Neogrid 
cFWModeSB1		:= FWModeAccess("SB1",1)+FWModeAccess("SB1",2)+FWModeAccess("SB1",3) //Nível de acessos da tabela SB1, retorna "E"xclusivo ou "C"ompartilhado
cFWModeSB5		:= FWModeAccess("SB5",1)+FWModeAccess("SB5",2)+FWModeAccess("SB5",3) //Nível de acessos da tabela SB5, retorna "E"xclusivo ou "C"ompartilhado
cFWModeSA2		:= FWModeAccess("SA2",1)+FWModeAccess("SA2",2)+FWModeAccess("SA2",3) //Nível de acessos da tabela SA2, retorna "E"xclusivo ou "C"ompartilhado
cFWModeACU		:= FWModeAccess("ACU",1)+FWModeAccess("ACU",2)+FWModeAccess("ACU",3) //Nível de acessos da tabela ACU, retorna "E"xclusivo ou "C"ompartilhado
cFWModeACV		:= FWModeAccess("ACV",1)+FWModeAccess("ACV",2)+FWModeAccess("ACV",3) //Nível de acessos da tabela ACV, retorna "E"xclusivo ou "C"ompartilhado
cFWModeNNR		:= FWModeAccess("NNR",1)+FWModeAccess("NNR",2)+FWModeAccess("NNR",3) //Nível de acessos da tabela NNR, retorna "E"xclusivo ou "C"ompartilhado
cCatOuProd		:= GetNewPar("MV_LJNEOGR","0")	//0=Categoria (ACU/ACV);1=Produto (SB1)

If !lAtivaDRP
	ConOut(STR0012+STR0013) //"ATENCAO: Favor ativar o parametro MV_LJDRP para"###" ativar a Integracao Protheus x DRP Neogrid."
	LjGrvLog(STR0017,STR0012+STR0013,Nil)	//"Exportacao DRP Neogrid" //"ATENCAO: Favor ativar o parametro MV_LJDRP para"###" ativar a Integracao Protheus x DRP Neogrid."
	Conout(STR0014) //"Finalizando Processo de Exportacao"
	LjGrvLog(STR0017,STR0014,Nil)	//"Exportacao DRP Neogrid" //"Finalizando Processo de Exportacao"
	If lSched 
   		Reset ENVIRONMENT
	Endif
	RestArea(cArea)
	Return .F.
EndIf

//Comparações: EEE,EEC,ECC,CCC
//ACV com ACU: ACV = D (ECC) e ACU = D MG (EEC) não é permitido. Se o tamanho da filial for 2, não é multifilial e considero o compartilhado uma vez em vez de três (caso a filial for 8 por exemplo)
lFWACVPerm := Iif( TamSx3("ACV_FILIAL")[1] = 2, !(Min(1,LenCount(cFWModeSB1,"C")) > Min(1,LenCount(cFWModeACV,"C"))),!(LenCount(cFWModeSB1,"C") > LenCount(cFWModeACV,"C")))
lFWACUPerm := Iif( TamSx3("ACU_FILIAL")[1] = 2, !(Min(1,LenCount(cFWModeACV,"C")) > Min(1,LenCount(cFWModeACU,"C"))),!(LenCount(cFWModeACV,"C") > LenCount(cFWModeACU,"C")))
lFWSB5Perm := Iif( TamSX3("B5_FILIAL")[1] = 2, Min(1,LenCount(cFWModeSB1,"C")) = Min(1,LenCount(cFWModeSB5,"C")),(LenCount(cFWModeSB1,"C") = LenCount(cFWModeSB5,"C")))
cGetDB		:= TCGetDB()

lRet := .T.
//Verificação de Comparação de leitura entre os arquivos
//Tabela SB5
If !lFWSB5Perm
	Conout(STR0018) //"A tabela SB5 deve estar configurada com o mesmo modo de compartilhamento da tabela SB1."
	LjGrvLog(STR0017,STR0018,Nil)	//"Exportacao DRP Neogrid" //"A tabela SB5 deve estar configurada com o mesmo modo de compartilhamento da tabela SB1."
	lRet := .F.
EndIf

//Tabela ACV
If !lFWACVPerm
	Conout(STR0019) //"A tabela ACV deve estar configurada com o mesmo modo de compartilhamento (ou acima) da tabela SB1."
	LjGrvLog(STR0017,STR0019,Nil)	//"Exportacao DRP Neogrid" //"A tabela ACV deve estar configurada com o mesmo modo de compartilhamento (ou acima) da tabela SB1."
	lRet := .F.
EndIf

//Tabela ACU
If !lFWACUPerm
	Conout(STR0020) //"A tabela ACU deve estar configurada com o mesmo modo de compartilhamento (ou acima) da tabela ACV."
	LjGrvLog(STR0017,STR0020,Nil)	//"Exportacao DRP Neogrid" //"A tabela ACU deve estar configurada com o mesmo modo de compartilhamento (ou acima) da tabela ACV."
	lRet := .F.
EndIf

If !lRet
	Conout(STR0014) //"Finalizando Processo de Exportacao"
	LjGrvLog(STR0017,STR0014,Nil)	//"Exportacao DRP Neogrid" //"Finalizando Processo de Exportacao"
	If lSched 
   		Reset ENVIRONMENT
	Endif
	RestArea(cArea)
	Return .F.
EndIf

// Carrega filiais da empresa corrente
If !alltrim(str(aParam[2])) $ '6'
	aAreaSM0 := SM0->(GetArea())
	dbSelectArea("SM0")
	dbSeek(cEmpAnt)
	Do While ! SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt   
		// Adiciona filial		
		Aadd(aFiliais,{FWGETCODFILIAL,SM0->M0_CODIGO,SM0->M0_CGC,SM0->M0_INSC,SM0->M0_FILIAL})
		SM0->(dbSkip())
	Enddo
	RestArea(aAreaSM0)
EndIf

Begin Sequence
	If Empty(aParam) .Or. ValType(aParam) != "A" 
		Break
	EndIf	
	dData1 := If(Valtype(aParam[1])="D",aParam[1],If(Valtype(aParam[1])="C",STOD(aParam[1]),date()))     
	// Produtos (Itens)
	// ACU,ACV,SA2,SB1,SB5
	// ACU = D MG (EEC)
	// ACV = D MG (EEC)
	// SA2 = D 	(ECC)
	// SB1 = D MG (EEC) (detalhe)
	// SB5 = D MG (EEC)
	//Podem ter casos em que o SB1/SB5 for tabela totalmente exclusiva, replicando o mesmo produto em todas as filiais.
	If alltrim(str(aParam[2])) $ '0|4'  
		If Select("TMPDRP") > 0
			TMPDRP->(dbCloseArea())
		EndIf
		cPesqChave		:= ""	   
		nContador 	:= 0
		nValidador	:= 0  
		
		//Novo parâmetro: MV_LJNEOGR //Categoria = 0; Produto = 1	//cCatOuProd
		
		cQry:= "SELECT SB1.B1_COD,SB1.B1_FILIAL,SB1.B1_DESC,SB1.B1_UM,SB1.B1_CONV,"
		cQry+= " SB1.B1_CODBAR,SLK.LK_CODBAR,SB1.B1_GRUPO, "
		cQry+= " SB1.B1_PROC,SB1.B1_LOJPROC, "
		If cCatOuProd = "0"	.AND. !lEncontrouPE		//Por Categoria
			cQry+= " ISNULL(ACV1.ACV_CATEGO,'') CAT1,ISNULL(ACU1.ACU_DESC,'') DESCAT1, "
			cQry+= " ISNULL(ACU1.ACU_CODPAI,'') CAT2,ISNULL(ACU2.ACU_DESC,'') DESCAT2, "
			cQry+= " ISNULL(ACU2.ACU_CODPAI,'') CAT3,ISNULL(ACU3.ACU_DESC,'') DESCAT3, "
			cQry+= " ISNULL(ACU3.ACU_CODPAI,'') CAT4,ISNULL(ACU4.ACU_DESC,'') DESCAT4, "
			cQry+= " ISNULL(ACU4.ACU_CODPAI,'') CAT5,ISNULL(ACU5.ACU_DESC,'') DESCAT5, "
			cQry+= " ISNULL(ACU5.ACU_CODPAI,'') CAT6,ISNULL(ACU6.ACU_DESC,'') DESCAT6, "
			cQry+= " ISNULL(ACU6.ACU_CODPAI,'') CAT7,ISNULL(ACU7.ACU_DESC,'') DESCAT7, "
			cQry+= " ISNULL(ACU7.ACU_CODPAI,'') CAT8,ISNULL(ACU8.ACU_DESC,'') DESCAT8, "
			cQry+= " ISNULL(ACU8.ACU_CODPAI,'') CAT9,ISNULL(ACU9.ACU_DESC,'') DESCAT9, "
			cQry+= " ISNULL(ACU9.ACU_CODPAI,'') CAT10,ISNULL(ACU10.ACU_DESC,'') DESCAT10, "
			cQry+= " ISNULL(ACU10.ACU_CODPAI,'') CAT11,ISNULL(ACU11.ACU_DESC,'') DESCAT11, "
			cQry+= " ISNULL(ACU11.ACU_CODPAI,'') CAT12,ISNULL(ACU12.ACU_DESC,'') DESCAT12  "
		Else		//Por Produto
			cQry+= " '' CAT1,SB1.B1_GRUPO DESCAT1, "
			cQry+= " '' CAT2,SB1.B1_FABRIC DESCAT2, "
			cQry+= " '' CAT3,SB1.B1_MODELO DESCAT3, "
			cQry+= " '' CAT4,'' DESCAT4, "
			cQry+= " '' CAT5,'' DESCAT5, "
			cQry+= " '' CAT6,'' DESCAT6, "
			cQry+= " '' CAT7,'' DESCAT7, "
			cQry+= " '' CAT8,'' DESCAT8, "
			cQry+= " '' CAT9,'' DESCAT9, "
			cQry+= " '' CAT10,'' DESCAT10, "
			cQry+= " '' CAT11,'' DESCAT11, "
			cQry+= " '' CAT12,'' DESCAT12 "
			
		EndIf
		cQry+= " FROM "+RetSqlName( "SB5" ) + " SB5 "
		cQry+= " INNER JOIN "+RetSqlName("SB1")+" SB1"
		cQry+= " ON SB1.B1_COD = SB5.B5_COD" 
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SB5.B5_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB5.B5_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SB1.B1_FILIAL),RTRIM(SB5.B5_FILIAL))>0 OR SB5.B5_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SB1.B1_FILIAL),RTRIM(SB5.B5_FILIAL))>0 OR SB5.B5_FILIAL = '')"
		EndIf
		cQry+= " AND SB1.D_E_L_E_T_ = ''"
		cQry+= "LEFT JOIN "+RetSqlName( "SLK" ) + " SLK " 
		cQry+= "ON  SLK.D_E_L_E_T_=' ' " 
		cQry+= "AND SLK.LK_CODIGO  = SB1.B1_COD " 
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SLK.LK_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SLK.LK_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SB1.B1_FILIAL),RTRIM(SLK.LK_FILIAL))>0 OR SLK.LK_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SB1.B1_FILIAL),RTRIM(SLK.LK_FILIAL))>0 OR SLK.LK_FILIAL = '')"
		EndIf
		
		If cCatOuProd = "0"	.AND. !lEncontrouPE //Por Categoria
			cQry+= "LEFT JOIN "+RetSqlName("ACV") + " ACV1 "  
			cQry+= "ON  ACV1.D_E_L_E_T_= ' ' "  
			cQry+= "AND ACV1.ACV_CODPRO = SB1.B1_COD "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACV1.ACV_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR ACV1.ACV_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(SB1.B1_FILIAL),RTRIM(ACV1.ACV_FILIAL))>0 OR ACV1.ACV_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(SB1.B1_FILIAL),RTRIM(ACV1.ACV_FILIAL))>0 OR ACV1.ACV_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN "+ RetSqlName("ACU")+ " ACU1 "
			cQry+= "ON  ACU1.D_E_L_E_T_= ' ' "  
			cQry+= "AND ACU1.ACU_COD = ACV1.ACV_CATEGO "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU1.ACU_FILIAL),RTRIM(ACV1.ACV_FILIAL))>0 OR ACU1.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACV1.ACV_FILIAL),RTRIM(ACU1.ACU_FILIAL))>0 OR ACU1.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACV1.ACV_FILIAL),RTRIM(ACU1.ACU_FILIAL))>0 OR ACU1.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN "+ RetSqlName("ACU") + " ACU2 "
			cQry+= "ON  ACU2.D_E_L_E_T_= ' ' "  
			cQry+= "AND ACU2.ACU_COD = ACU1.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU2.ACU_FILIAL),RTRIM(ACU1.ACU_FILIAL))>0 OR ACU2.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU1.ACU_FILIAL),RTRIM(ACU2.ACU_FILIAL))>0 OR ACU2.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU1.ACU_FILIAL),RTRIM(ACU2.ACU_FILIAL))>0 OR ACU2.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN "+ RetSqlName("ACU")+ " ACU3 " 
			cQry+= "ON  ACU3.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU3.ACU_COD = ACU2.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU3.ACU_FILIAL),RTRIM(ACU2.ACU_FILIAL))>0 OR ACU3.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU2.ACU_FILIAL),RTRIM(ACU3.ACU_FILIAL))>0 OR ACU3.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU2.ACU_FILIAL),RTRIM(ACU3.ACU_FILIAL))>0 OR ACU3.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU4 " 
			cQry+= "ON  ACU4.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU4.ACU_COD = ACU3.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU4.ACU_FILIAL),RTRIM(ACU3.ACU_FILIAL))>0 OR ACU4.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU3.ACU_FILIAL),RTRIM(ACU4.ACU_FILIAL))>0 OR ACU4.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU3.ACU_FILIAL),RTRIM(ACU4.ACU_FILIAL))>0 OR ACU4.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU5 " 
			cQry+= "ON  ACU5.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU5.ACU_COD = ACU4.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU5.ACU_FILIAL),RTRIM(ACU4.ACU_FILIAL))>0 OR ACU5.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU4.ACU_FILIAL),RTRIM(ACU5.ACU_FILIAL))>0 OR ACU5.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU4.ACU_FILIAL),RTRIM(ACU5.ACU_FILIAL))>0 OR ACU5.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU6 " 
			cQry+= "ON  ACU6.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU6.ACU_COD = ACU5.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU6.ACU_FILIAL),RTRIM(ACU5.ACU_FILIAL))>0 OR ACU6.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU5.ACU_FILIAL),RTRIM(ACU6.ACU_FILIAL))>0 OR ACU6.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU5.ACU_FILIAL),RTRIM(ACU6.ACU_FILIAL))>0 OR ACU6.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU7 " 
			cQry+= "ON  ACU7.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU7.ACU_COD = ACU6.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU7.ACU_FILIAL),RTRIM(ACU6.ACU_FILIAL))>0 OR ACU7.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU6.ACU_FILIAL),RTRIM(ACU7.ACU_FILIAL))>0 OR ACU7.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU6.ACU_FILIAL),RTRIM(ACU7.ACU_FILIAL))>0 OR ACU7.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU8 " 
			cQry+= "ON  ACU8.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU8.ACU_COD = ACU7.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU8.ACU_FILIAL),RTRIM(ACU7.ACU_FILIAL))>0 OR ACU8.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU7.ACU_FILIAL),RTRIM(ACU8.ACU_FILIAL))>0 OR ACU8.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU7.ACU_FILIAL),RTRIM(ACU8.ACU_FILIAL))>0 OR ACU8.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU9 " 
			cQry+= "ON  ACU9.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU9.ACU_COD = ACU8.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU9.ACU_FILIAL),RTRIM(ACU8.ACU_FILIAL))>0 OR ACU9.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU8.ACU_FILIAL),RTRIM(ACU9.ACU_FILIAL))>0 OR ACU9.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU8.ACU_FILIAL),RTRIM(ACU9.ACU_FILIAL))>0 OR ACU9.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU10 " 
			cQry+= "ON  ACU10.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU10.ACU_COD = ACU9.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU10.ACU_FILIAL),RTRIM(ACU9.ACU_FILIAL))>0 OR ACU10.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU9.ACU_FILIAL),RTRIM(ACU10.ACU_FILIAL))>0 OR ACU10.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU9.ACU_FILIAL),RTRIM(ACU10.ACU_FILIAL))>0 OR ACU10.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU11 " 
			cQry+= "ON  ACU11.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU11.ACU_COD = ACU10.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU11.ACU_FILIAL),RTRIM(ACU10.ACU_FILIAL))>0 OR ACU11.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU10.ACU_FILIAL),RTRIM(ACU11.ACU_FILIAL))>0 OR ACU11.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU10.ACU_FILIAL),RTRIM(ACU11.ACU_FILIAL))>0 OR ACU11.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU12 " 
			cQry+= "ON  ACU12.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU12.ACU_COD = ACU11.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU12.ACU_FILIAL),RTRIM(ACU11.ACU_FILIAL))>0 OR ACU12.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU11.ACU_FILIAL),RTRIM(ACU12.ACU_FILIAL))>0 OR ACU12.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU11.ACU_FILIAL),RTRIM(ACU12.ACU_FILIAL))>0 OR ACU12.ACU_FILIAL = '')"
			EndIf
			cQry+= "LEFT JOIN " + RetSqlName("ACU") + " ACU13 " 
			cQry+= "ON  ACU13.D_E_L_E_T_= ' ' " 
			cQry+= "AND ACU13.ACU_COD = ACU12.ACU_CODPAI "
			If At("MSSQL",cGetDB) > 0
				cQry+= "	AND (CHARINDEX(RTRIM(ACU13.ACU_FILIAL),RTRIM(ACU12.ACU_FILIAL))>0 OR ACU13.ACU_FILIAL = '')"
			ElseIf cGetDB == "DB2"
				cQry+= "	AND (LOCATE(RTRIM(ACU12.ACU_FILIAL),RTRIM(ACU13.ACU_FILIAL))>0 OR ACU13.ACU_FILIAL = '')"
			Else
				cQry+= "	AND (INSTR(RTRIM(ACU12.ACU_FILIAL),RTRIM(ACU13.ACU_FILIAL))>0 OR ACU13.ACU_FILIAL = '')"
			EndIf
		EndIf
		cQry+= "WHERE "
		cQry+= "SB5.D_E_L_E_T_ = ' ' "
		cQry+= "AND SB5.B5_DRPEXP = '' "
		cQry+= "ORDER BY SB1.B1_COD "
	
 		cQry := ChangeQuery(cQry)

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )
    	dbSelectArea("TMPDRP")
    	TmpDrp->(Dbgotop())
    	cXML       := ''
    	lCabXml    := .F.
		lItXml     := .F.
    	While !(TmpDrp->(Eof()))            
    		If (nContador % 150 = 0) .AND. len(cXML) > 900000	//Questão de performance (verificar a cada 150 leituras) e se o número de caracteres for superior a 900 mil.
    			//Objetivo: Nova função para gravar em TXT.
    			Lj7030Gr04(oTss,@cXml,cUrl,dData1,;
    						aFiliais,@cPesqChave,cFwModeSB1,nNeoCom,;
    						@lItXml,.F.)
    		EndIf
			If !lCabXml
				cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
				cXML+='<PRODUTO xsi:noNamespaceSchemaLocation="tss_tc_produto.xsd" xmlns:ns1="TotvsColabProd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
				cXML+='  <ITEM>'+CRLF
				lCabXml:=.t.
			Endif
			lItemRet := .T.
			// Validação dos campos obrigatórios para o envio do registro pelo XML
			If !Empty(TMPDRP->B1_COD) .AND. !Empty(TMPDRP->B1_PROC) .AND. !Empty(TMPDRP->B1_LOJPROC) .AND.;
							 Iif(!lEncontrouPE,!EMPTY(TMPDRP->DESCAT1) .AND. !EMPTY(TMPDRP->DESCAT2) .AND. !EMPTY(TMPDRP->DESCAT3),.T.)

				If TMPDRP->B1_COD <> cVarAnt  //Podem ter inúmeras filiais com o mesmo produto, então, passo somente um código (Acontece também quando há mais de um registro ACV por produto)
					cVarAnt := TMPDRP->B1_COD
					
					If lEncontrouPE						//aqui vai ter um ponto de entrada
						aGrupo := ExecBlock( "LJDRPEG" , .F. , .F. , {TMPDRP->B1_COD} )
						If Len(aGrupo) < 12 .OR.;
							((Len(aGrupo)>=1 .AND. ValType(aGrupo[01]) <> "C") .OR.;
							(Len(aGrupo)>=2 .AND. ValType(aGrupo[02]) <> "C") .OR.;
							(Len(aGrupo)>=3 .AND. ValType(aGrupo[03]) <> "C") .OR.;
							(Len(aGrupo)>=4 .AND. ValType(aGrupo[04]) <> "C") .OR.;
							(Len(aGrupo)>=5 .AND. ValType(aGrupo[05]) <> "C") .OR.;
							(Len(aGrupo)>=6 .AND. ValType(aGrupo[06]) <> "C") .OR.;
							(Len(aGrupo)>=7 .AND. ValType(aGrupo[07]) <> "C") .OR.;
							(Len(aGrupo)>=8 .AND. ValType(aGrupo[08]) <> "C") .OR.;
							(Len(aGrupo)>=9 .AND. ValType(aGrupo[09]) <> "C") .OR.;
							(Len(aGrupo)>=10 .AND. ValType(aGrupo[10]) <> "C") .OR.;
							(Len(aGrupo)>=11 .AND. ValType(aGrupo[11]) <> "C") .OR.;
							(Len(aGrupo)>=12 .AND. ValType(aGrupo[12]) <> "C"))
							
							ConOut(STR0028+" "+STR0029) //"Ponto de Entrada LJDRPEG estao com parametros de retorno incorretos!"###"Devera retornar um array com 12 elementos, todos do tipo Caracter."
							LjGrvLog(STR0017,STR0028+" "+STR0029,Nil)	//"Exportacao DRP Neogrid"###"Ponto de Entrada LJDRPEG estao com parametros de retorno incorretos!"###"Devera retornar um array com 12 elementos, todos do tipo Caracter."
							Break
						EndIf
					Else
						aGrupo[01] := TMPDRP->DESCAT1
						aGrupo[02] := TMPDRP->DESCAT2
						aGrupo[03] := TMPDRP->DESCAT3
						aGrupo[04] := TMPDRP->DESCAT4
						aGrupo[05] := TMPDRP->DESCAT5
						aGrupo[06] := TMPDRP->DESCAT6
						aGrupo[07] := TMPDRP->DESCAT7
						aGrupo[08] := TMPDRP->DESCAT8
						aGrupo[09] := TMPDRP->DESCAT9
						aGrupo[10] := TMPDRP->DESCAT10
						aGrupo[11] := TMPDRP->DESCAT11
						aGrupo[12] := TMPDRP->DESCAT12
					EndIf

					//Ver if de categoria aqui
					If !Empty(aGrupo[01]) .AND. !Empty(aGrupo[02]) .AND. !Empty(aGrupo[03])
					
						//Se não tiver ponto de entrada e por tabela acu/acv, o sentido da Categoria é pai->filho, e não filho->pai
						If !lEncontrouPE .AND. cCatOuProd = "0"	
							Afill(aGrupo,"")
							nPosGrupo := 1
							If !Empty(TMPDRP->DESCAT12)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT12 
							EndIf
							If !Empty(TMPDRP->DESCAT11)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT11 
							EndIf
							If !Empty(TMPDRP->DESCAT10)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT10 
							EndIf
							If !Empty(TMPDRP->DESCAT9)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT9 
							EndIf
							If !Empty(TMPDRP->DESCAT8)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT8 
							EndIf
							If !Empty(TMPDRP->DESCAT7)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT7 
							EndIf
							If !Empty(TMPDRP->DESCAT6)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT6 
							EndIf
							If !Empty(TMPDRP->DESCAT5)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT5 
							EndIf
							If !Empty(TMPDRP->DESCAT4)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT4 
							EndIf
							If !Empty(TMPDRP->DESCAT3)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT3 
							EndIf
							If !Empty(TMPDRP->DESCAT2)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT2 
							EndIf
							If !Empty(TMPDRP->DESCAT1)
								aGrupo[nPosGrupo++] := TMPDRP->DESCAT1 
							EndIf
						EndIf
						
						cXML+='<ns1:ITENS>'+CRLF
						cXML+='<ns1:ProdCod>'+RTrim(TMPDRP->B1_COD)+'</ns1:ProdCod>'+CRLF
						cXML+='<ns1:ProdBar>'+IIf(Empty(TMPDRP->B1_CODBAR),alltrim(TMPDRP->LK_CODBAR),alltrim(TMPDRP->B1_CODBAR))+'</ns1:ProdBar>'+CRLF
						cXML+='<ns1:ProdDes>'+alltrim(LjNoAccent(TMPDRP->B1_DESC))+'</ns1:ProdDes>'+CRLF
						cXML+='<ns1:UnidMed>'+alltrim(TMPDRP->B1_UM)+'</ns1:UnidMed>'+CRLF
						
						//Fator de Conversão
						If	TMPDRP->B1_CONV <= 0
							cFatConv := "1,000000"
						Else
							cFatConv := AllTrim(Transform(TMPDRP->B1_CONV,"@E 999999.999999"))
						EndIf
						cXML+='<ns1:FtConv>'+ cFatConv +'</ns1:FtConv>'+CRLF //Não pode fator de conversão ZERO
						
						cXML+='<ns1:FornCod>'+PadR(TMPDRP->B1_PROC,TamSX3("B1_PROC")[1])+alltrim(TMPDRP->B1_LOJPROC)+'</ns1:FornCod>'+CRLF
						
						cXML+='<ns1:Grupo1>'+alltrim(LjNoAccent(aGrupo[01]))+'</ns1:Grupo1>'+CRLF
						cXML+='<ns1:Grupo2>'+alltrim(LjNoAccent(aGrupo[02]))+'</ns1:Grupo2>'+CRLF
						cXML+='<ns1:Grupo3>'+alltrim(LjNoAccent(aGrupo[03]))+'</ns1:Grupo3>'+CRLF
						cXML+='<ns1:Grupo4>'+alltrim(LjNoAccent(aGrupo[04]))+'</ns1:Grupo4>'+CRLF
						cXML+='<ns1:Grupo5>'+alltrim(LjNoAccent(aGrupo[05]))+'</ns1:Grupo5>'+CRLF
						cXML+='<ns1:Grupo6>'+alltrim(LjNoAccent(aGrupo[06]))+'</ns1:Grupo6>'+CRLF
						cXML+='<ns1:FatorConversao1>'+''+'</ns1:FatorConversao1>'+CRLF
						cXML+='<ns1:FatorConversao2>'+''+'</ns1:FatorConversao2>'+CRLF
						cXML+='<ns1:FatorConversao3>'+''+'</ns1:FatorConversao3>'+CRLF
						cXML+='<ns1:Grupo7>'+alltrim(LjNoAccent(aGrupo[07]))+'</ns1:Grupo7>'+CRLF
						cXML+='<ns1:Grupo8>'+alltrim(LjNoAccent(aGrupo[08]))+'</ns1:Grupo8>'+CRLF
						cXML+='<ns1:Grupo9>'+alltrim(LjNoAccent(aGrupo[09]))+'</ns1:Grupo9>'+CRLF
						cXML+='<ns1:Grupo10>'+alltrim(LjNoAccent(aGrupo[10]))+'</ns1:Grupo10>'+CRLF
						cXML+='<ns1:Grupo11>'+alltrim(LjNoAccent(aGrupo[11]))+'</ns1:Grupo11>'+CRLF
						cXML+='<ns1:Grupo12>'+alltrim(LjNoAccent(aGrupo[12]))+'</ns1:Grupo12>'+CRLF
						cXML+='</ns1:ITENS>'+CRLF
						lItXml := .t.
						cPesqChave+=TmpDrp->(B1_COD)+","
						If (nContador % 1000 = 0) .OR. (nContador <= 3)	//Acima de 3, mando no LogLoja a cada 1000 leituras
							LjGrvLog(STR0017," Modelo 4: Envio de Itens/Produtos "+"  XML  Produto:  "+ alltrim (TMPDRP->B1_COD)+ "  Contador:  " + cValToChar(nContador))
						EndIf
						nContador := nContador + 1
					Else
						lItemRet := .F.
					EndIf
				EndIf
			Else
				lItemRet := .F.
			Endif
			
			If !lItemRet
				ConOut(STR0015+alltrim(TMPDRP->B1_COD)+STR0016) //"Modelo 4: Falta atributos ao produto "###". Verifique o codigo/loja do fornecedor, e se ha três categorias ligadas ao produto." 
				LjGrvLog(STR0017,STR0015+alltrim(TMPDRP->B1_COD)+STR0016,Nil)	//"Exportacao DRP Neogrid" //"Modelo 4: Falta atributos ao produto "###". Verifique o codigo/loja do fornecedor, e se ha duas categorias ligadas ao produto."
				If Iif(lEncontrouPE,Empty(aGrupo[01]),Empty(TMPDRP->DESCAT1))
					ConOut(STR0021+STR0026+alltrim(TMPDRP->B1_COD)) //"Primeiro grupo/categoria vazio" //" - Produto "
					LjGrvLog(STR0017,STR0021+STR0026+alltrim(TMPDRP->B1_COD),Nil)	//"Exportacao DRP Neogrid" //"Primeiro grupo/categoria vazio" //" - Produto "
				EndIf
				If Iif(lEncontrouPE,Empty(aGrupo[02]),Empty(TMPDRP->DESCAT2))
					ConOut(STR0022+STR0026+alltrim(TMPDRP->B1_COD)) //"Segundo grupo/categoria vazio" //" - Produto "
					LjGrvLog(STR0017,STR0022+STR0026+alltrim(TMPDRP->B1_COD),Nil)	//"Exportacao DRP Neogrid" //"Segundo grupo/categoria vazio" //" - Produto "
				EndIf
				If Iif(lEncontrouPE,Empty(aGrupo[03]),Empty(TMPDRP->DESCAT3))
					ConOut(STR0023+STR0026+alltrim(TMPDRP->B1_COD)) //"Terceiro grupo/categoria vazio" //" - Produto "
					LjGrvLog(STR0017,STR0023+STR0026+alltrim(TMPDRP->B1_COD),Nil)	//"Exportacao DRP Neogrid" //"Terceiro grupo/categoria vazio" //" - Produto "
				EndIf
				If Empty(TMPDRP->B1_PROC)
					ConOut(STR0024+STR0026+alltrim(TMPDRP->B1_COD)) //"Fornecedor nao encontrado" //" - Produto "
					LjGrvLog(STR0017,STR0024+STR0026+alltrim(TMPDRP->B1_COD),Nil)	//"Exportacao DRP Neogrid" //"Fornecedor nao encontrado" //" - Produto "
				EndIf
				If Empty(TMPDRP->B1_LOJPROC)
					ConOut(STR0025+STR0026+alltrim(TMPDRP->B1_COD)) //"Loja do fornecedor nao encontrada" //" - Produto "
					LjGrvLog(STR0017,STR0025+STR0026+alltrim(TMPDRP->B1_COD),Nil)	//"Exportacao DRP Neogrid" //"Loja do fornecedor nao encontrada" //" - Produto "
				EndIf
			EndIf
					
			TmpDrp->(Dbskip())		
		End
		
		Lj7030Gr04(oTss,@cXml,cUrl,dData1,;
    			aFiliais,@cPesqChave,cFwModeSB1,nNeoCom,;
    			@lItXml,.T.)
		TMPDRP->(dbCloseArea()) 
	Endif
	
	// 5 Mov. Local de Estoque 
	
	// SB1,SB2,SB5
	// SB1 = D MG    (EEC)
	// SB2 = D MG 01 (EEE) (detalhe)
	// SB5 = D MG    (EEC)
	// D MG = D MG 01
	If alltrim(str(aParam[2])) $ '0|5'
		If Select("TMPDRP") > 0
			TMPDRP->(dbCloseArea())
		EndIf	   
		nContador 	:= 0
		nValidador	:= 0
		cPesqChv6	:= ""  

		cQry:= "SELECT SB2.B2_COD,SB2.B2_FILIAL,SB2.B2_LOCAL,'' B5_ESTSNEO,SB1.B1_ESTSEG,SB1.B1_EMAX,SB1.B1_EMIN, "
		cQry+= " (SB1.B1_EMAX*SB2.B2_CM1) ESTMAX, "
		cQry+= " SB1.B1_PROC,SB1.B1_LOJPROC, "
		cQry+= " SB2.B2_DRSALDO,SB1.B1_LM,SB1.B1_LE,SB1.B1_QE,SB1.B1_PE"
		cQry+= " FROM "+ RetSqlName("SB2") +" SB2"
		cQry+= " INNER JOIN "+RETSQLNAME("SB1")+" SB1"
		If At("MSSQL",cGetDB) > 0
			cQry+= "	ON (CHARINDEX(RTRIM(B1_FILIAL),RTRIM(B2_FILIAL))>0 OR B1_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	ON (LOCATE(RTRIM(B2_FILIAL),RTRIM(B1_FILIAL))>0 OR B1_FILIAL = '')"
		Else
			cQry+= "	ON (INSTR(RTRIM(B2_FILIAL),RTRIM(B1_FILIAL))>0 OR B1_FILIAL = '')"
		EndIf
		cQry+= "	AND SB1.B1_COD = SB2.B2_COD" 
		cQry+= "	AND SB1.D_E_L_E_T_ = ''"
		cQry+= "	LEFT JOIN "+ RetSqlName("SB5")+" SB5"
		If At("MSSQL",cGetDB) > 0
			cQry+= "	ON (CHARINDEX(RTRIM(B5_FILIAL),RTRIM(B2_FILIAL))>0 OR B5_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	ON (LOCATE(RTRIM(B2_FILIAL),RTRIM(B5_FILIAL))>0 OR B5_FILIAL = '')"
		Else
			cQry+= "	ON (INSTR(RTRIM(B2_FILIAL),RTRIM(B5_FILIAL))>0 OR B5_FILIAL = '')"
		EndIf
		cQry+= " AND SB5.D_E_L_E_T_ = ' '"
		cQry+= " AND SB5.B5_COD = SB2.B2_COD "       
		cQry+= "	WHERE SB2.D_E_L_E_T_ = ''"	              
		cQry+= " AND SB5.B5_DRPEXP > ' ' "  //Somente se este campo for preenchido, enviar
		cQry+= " ORDER BY B2_COD,B2_FILIAL,B2_LOCAL       

		cQry := ChangeQuery(cQry)

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )
    	dbSelectArea("TMPDRP")
    	TmpDrp->(Dbgotop())
    	cXML       := ''
    	lCabXml    := .F.
		lItXml     := .F.
		cPesqChave		:= ""
    	While !(TmpDrp->(Eof()))           
    		If (nContador % 150 = 0) .AND. len(cXML) > 900000	//Questão de performance (verificar a cada 150 leituras) e se o número de caracteres for superior a 900 mil.
				cPesqChv6 += cPesqChave
				Lj7030Gr05(oTss,@cXml,cUrl,dData1,;
					@cPesqChave,nNeoCom,lItXml,.F.,;
					nContador,@nValidador,aPrm)
    		EndIf
			If !lCabXml
				cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
				cXML+='<LOCAL xsi:noNamespaceSchemaLocation="tss_tc_local.xsd" xmlns:ns1="TotvsColabLocal" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
				cXML+='<ITEM>'+CRLF
	             lCabXml:=.t.
    	    Endif
    	    // Verifico o saldo da SB2. Gravo somente se for diferente ao gravado em B2_DRSALDO
			DBSelectArea("SB2")
			DBSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL
			If SB2->(DbSeek(TMPDRP->B2_FILIAL+TMPDRP->B2_COD+TMPDRP->B2_LOCAL))
				nSaldoSB2 := SaldoSB2(.T.,,,,.T.)	//5º parâmetro - deve considerar o saldo em poder de terceiros
			Else
				nSaldoSB2 := 0
			EndIf
			If TMPDRP->B2_DRSALDO <> nSaldoSB2
		    	cXML+='<ns1:ITENS>'+CRLF
					cXML+='<ns1:ProdCod>'+Rtrim(TMPDRP->B2_COD)+'</ns1:ProdCod>'+CRLF
					cXML+='<ns1:ProdLocal>'+alltrim(TMPDRP->(B2_FILIAL+B2_LOCAL))+'</ns1:ProdLocal>'+CRLF
					cXML+='<ns1:PadFreq>'+'1'+'</ns1:PadFreq>'+CRLF
					cXML+='<ns1:ModPlan>'+'0'+'</ns1:ModPlan>'+CRLF
					cXML+='<ns1:HorPlan>'+''+'</ns1:HorPlan>'+CRLF
					cXML+='<ns1:RepAut>'+''+'</ns1:RepAut>'+CRLF
					cXML+='<ns1:DataMatur>'+''+'</ns1:DataMatur>'+CRLF
					cXML+='<ns1:DataDesc>'+''+'</ns1:DataDesc>'+CRLF
					cXML+='<ns1:NivelServ>'+''+'</ns1:NivelServ>'+CRLF
					cXML+='<ns1:DataValNS>'+''+'</ns1:DataValNS>'+CRLF
					cXML+='<ns1:EstoqSeg>'+ALLTRIM(Transform(TMPDRP->B1_ESTSEG,"@E 99999999999.999"))+'</ns1:EstoqSeg>'+CRLF
					cXML+='<ns1:DataValES>'+''+'</ns1:DataValES>'+CRLF
					cXML+='<ns1:PerioHist>'+''+'</ns1:PerioHist>'+CRLF
					cXML+='<ns1:LoteRep>'+''+'</ns1:LoteRep>'+CRLF
					cXML+='<ns1:MultEmin>'+'1,00'+'</ns1:MultEmin>'+CRLF
					cXML+='<ns1:MultEmax1>'+'1,0'+'</ns1:MultEmax1>'+CRLF
					cXML+='<ns1:MultEmax2>'+'1,0'+'</ns1:MultEmax2>'+CRLF
					cXML+='<ns1:TipoEstoqSeg>'+''+'</ns1:TipoEstoqSeg>'+CRLF
					cXML+='<ns1:LimEstoqMax>'+ALLTRIM(Transform(TMPDRP->B1_LE,"@E 99999999999.999"))+'</ns1:LimEstoqMax>'+CRLF
					cXML+='<ns1:LimEstoqMin>'+ALLTRIM(Transform(TMPDRP->B1_EMIN,"@E 99999999999.999"))+'</ns1:LimEstoqMin>'+CRLF
					cXML+='<ns1:MultExcTransf>'+''+'</ns1:MultExcTransf>'+CRLF
					cXML+='<ns1:EstoqMax>'+ALLTRIM(Transform(TMPDRP->B1_EMAX,"@E 99999999999.999"))+'</ns1:EstoqMax>'+CRLF
					cXML+='<ns1:DataValEMax>'+''+'</ns1:DataValEMax>'+CRLF
					cXML+='<ns1:UtilizaPontoExp>'+''+'</ns1:UtilizaPontoExp>'+CRLF
					cXML+='<ns1:FreqEntrega>'+''+'</ns1:FreqEntrega>'+CRLF
					cXML+='<ns1:UtilizaDfuSku>'+''+'</ns1:UtilizaDfuSku>'+CRLF
					cXML+='<ns1:Buffer>'+''+'</ns1:Buffer>'+CRLF
					cXML+='<ns1:FaseVida>'+''+'</ns1:FaseVida>'+CRLF
					cXML+='<ns1:StatusRep>'+''+'</ns1:StatusRep>'+CRLF
		    	cXML+='</ns1:ITENS>'+CRLF
		    	lItXml := .t.
		    	cPesqChave += Rtrim(TMPDRP->B2_COD) + "." + Alltrim(TMPDRP->(B2_FILIAL+B2_LOCAL)) + "|"
				If (nContador % 1000 = 0) .OR. (nContador <= 3)	//Acima de 3, mando no LogLoja a cada 1000 leituras
			    	LjGrvLog(STR0017," Modelo 5: Mov. Local de Estoque "+"  XML  Produto:  "+ Rtrim (TMPDRP->B2_COD)+ "  Contador:  " + cValToChar(nContador))
			    EndIf
				nContador := nContador + 1
    	    EndIf
     	    TmpDrp->(Dbskip())
    	End
		
		cPesqChv6 += cPesqChave
		Lj7030Gr05(oTss,@cXml,cUrl,dData1,;
					@cPesqChave,nNeoCom,lItXml,.T.,;
					nContador,@nValidador,aPrm)
		LOJA7030({aPrm[1],6,cEmp,cFilTrab,cPesqChv6}) // Origem SKU
		TmpDrp->(DbCloseArea())
    Endif
    
	// 6 Origem SKU 
	If alltrim(str(aParam[2])) $ '6'		//Pesquisa pela mesma filial, código e local  
	   lCabXml := .F.
	   lItXMl  := .F. 
       // Chamando do Local de Estoque 
       If Select("TMPDRP") > 0
			TmpDrp->(Dbgotop())
	    	cXML       := ''
	    	lCabXml    := .F.
			lItXml     := .F.
			nContador 	:= 0
	    	While !(TmpDrp->(Eof()))           
	    		If (nContador % 150 = 0) .AND. len(cXML) > 900000	//Questão de performance (verificar a cada 150 leituras) e se o número de caracteres for superior a 900 mil.
					Lj7030Gr06(oTss,@cXml,cUrl,dData1,;
											lItXml,.F.)
	    		EndIf
	    		If At(Rtrim(TmpDrp->(B2_COD))+"."+Alltrim(TMPDRP->(B2_FILIAL+B2_LOCAL)) + "|", cPesqChave) > 0
					If !lCabXml
						cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
		                cXML+=' <ORIGEM xsi:noNamespaceSchemaLocation="tss_tc_origemSKU.xsd" xmlns:ns1="TotvsColabOrigem" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
			            cXML+='<ITEM>'+CRLF
			            lCabXml:=.t.
		    	    Endif
		    	    
		    	    // Criação de uma segunda query, para ver se houve transferência de filiais de origem para cá.
		    	    // Caso negativo, considera a de fornecedores e sem as origens.
		    	    // Se houver mais de uma transferência, considerar o último.
	
					If Select((cAliasTmp3)) = 0
						// Union 1: Transferências, representado no campo TIPO
		
						cQry:= "SELECT SD1.D1_FILIAL D_FILIAL,SD1.D1_COD D_COD,SD1.D1_LOCAL D_LOCAL,D1_EMISSAO D_EMISSAO,D1_QUANT D_QUANT,"
						cQry+= " SD2.D2_FILIAL O_FILIAL,SD2.D2_COD O_COD,SD2.D2_LOCAL O_LOCAL,SD2.D2_EMISSAO O_EMISSAO,D2_QUANT O_QUANT,D1_NUMSEQ NUMSEQ,'T' TIPO "
						cQry+= " FROM "+ RetSqlName("SD1") +" SD1"
						cQry+= " INNER JOIN "+RETSQLNAME("SD2")+" SD2"
						cQry+= "	ON SD1.D1_DOC = SD2.D2_DOC AND SD1.D1_SERIE = SD2.D2_SERIE " 
						cQry+= "	AND SD2.D_E_L_E_T_ = ' '"
						cQry+= "	INNER JOIN "+ RetSqlName("SF4")+" SF4"	//era left, pois peguei TES que não era Transf. de Filial.
						If At("MSSQL",cGetDB) > 0
							cQry+= "	ON (CHARINDEX(RTRIM(F4_FILIAL),RTRIM(D1_FILIAL))>0 OR F4_FILIAL = '')"
						ElseIf cGetDB == "DB2"
							cQry+= "	ON (LOCATE(RTRIM(D1_FILIAL),RTRIM(F4_FILIAL))>0 OR F4_FILIAL = '')"
						Else
							cQry+= "	ON (INSTR(RTRIM(D1_FILIAL),RTRIM(F4_FILIAL))>0 OR F4_FILIAL = '')"
						EndIf
						cQry+= " AND SF4.D_E_L_E_T_ = ' '"
						cQry+= " AND SF4.F4_TRANFIL = '1'"
						cQry+= " AND SD1.D1_TES = SF4.F4_CODIGO "       
						cQry+= "	WHERE SD1.D_E_L_E_T_ = ' '"
				
						cQry+= " UNION ALL "
		
						// Union 2: Vendas (Saídas), representado no campo TIPO
						
						cQry:= "SELECT SD2.D2_FILIAL D_FILIAL,SD2.D2_COD D_COD,SD2.D2_LOCAL D_LOCAL,D2_EMISSAO D_EMISSAO,D2_QUANT D_QUANT,"
						cQry+=   "'' O_FILIAL,'' O_COD,'' O_LOCAL,SD2.D2_EMISSAO O_EMISSAO,0 O_QUANT,D2_NUMSEQ NUMSEQ,'V' TIPO "
						cQry+= " FROM "+ RetSqlName("SD2") +" SD2"
						cQry+= "	INNER JOIN "+ RetSqlName("SF4")+" SF4"
						If At("MSSQL",cGetDB) > 0
							cQry+= "	ON (CHARINDEX(RTRIM(F4_FILIAL),RTRIM(D2_FILIAL))>0 OR F4_FILIAL = '')"
						ElseIf cGetDB == "DB2"
							cQry+= "	ON (LOCATE(RTRIM(D2_FILIAL),RTRIM(F4_FILIAL))>0 OR F4_FILIAL = '')"
						Else
							cQry+= "	ON (INSTR(RTRIM(D2_FILIAL),RTRIM(F4_FILIAL))>0 OR F4_FILIAL = '')"
						EndIf
						cQry+= " AND SF4.D_E_L_E_T_ = ' '"
						cQry+= " AND SF4.F4_TRANFIL <> '1' AND SF4.F4_DUPLIC = 'S' AND SF4.F4_CODIGO >= '500' "
						cQry+= " AND SD2.D2_TES = SF4.F4_CODIGO       
						cQry+= "	WHERE SD2.D_E_L_E_T_ = ''"	              
						
						cQry+= " UNION ALL "
	
						// Union 3: Transferências entre Armazéns - Requisição/Devolução
						cQry+= " SELECT SD3.D3_FILIAL D_FILIAL,SD3.D3_COD D_COD,SD3.D3_LOCAL D_LOCAL, SD3.D3_EMISSAO D_EMISSAO, SD3.D3_QUANT D_QUANT,"
						cQry+=   "SD4.D3_FILIAL O_FILIAL,SD4.D3_COD O_COD,SD4.D3_LOCAL O_LOCAL,SD4.D3_EMISSAO O_EMISSAO,SD4.D3_QUANT O_QUANT,SD3.D3_NUMSEQ NUMSEQ,'T' TIPO "
						cQry+= "	FROM "+ RetSqlName("SD3") +" SD3 "
						cQry+= "	LEFT JOIN "+RetSqlName("SD3")+" SD4 "
						cQry+= " ON SD3.D3_NUMSEQ = SD4.D3_NUMSEQ "                                   
						cQry+= "  WHERE SD3.D_E_L_E_T_ = ' '  "
						cQry+= " AND SD4.D_E_L_E_T_ = ' '  "
						cQry+= " AND (SD3.D3_CF = 'DE6' OR SD3.D3_CF = 'DE7') "		
						cQry+= " AND (SD4.D3_CF = 'RE6' OR SD4.D3_CF = 'RE7') "
	
						// Union 4: Requisição para Montagem RE1
						cQry+= " UNION ALL "
						cQry+= " SELECT SD3.D3_FILIAL D_FILIAL,SD3.D3_COD D_COD,SD3.D3_LOCAL D_LOCAL, SD3.D3_EMISSAO D_EMISSAO, SD3.D3_QUANT D_QUANT,"
						cQry+=   "'' O_FILIAL,'' O_COD,'' O_LOCAL,SD3.D3_EMISSAO O_EMISSAO,0 O_QUANT,SD3.D3_NUMSEQ NUMSEQ,'V' TIPO "
						cQry+= "	FROM "+ RetSqlName("SD3") +" SD3 "
						cQry+= "  WHERE SD3.D_E_L_E_T_ = ' '  "
						cQry+= " AND (SD3.D3_CF = 'RE1') "		
	
						//Fim da Union
						cQry+= " ORDER BY NUMSEQ DESC"  // Ordem decrescente de número de sequencia: vale o lancto. mais recente
						
						cQry := ChangeQuery(cQry)
		
						dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp2, .F., .T. )
				    	dbSelectArea("TMPDRP2")
				    	TmpDrp2->(Dbgotop())
				    	
				    	aStruct := {}
						//Cria o arquivo temporário
						aAdd(aStruct,{"D_COD"		,"C"	,TamSX3("B2_COD")[1]		,TamSX3("B2_COD")[2]}	)
						aAdd(aStruct,{"D_FILIAL"	,"C"	,TamSX3("B2_FILIAL")[1]		,TamSX3("B2_FILIAL")[2]}	)
						aAdd(aStruct,{"D_LOCAL"		,"C"	,TamSX3("B2_LOCAL")[1]		,TamSX3("B2_LOCAL")[2]}		)
						aAdd(aStruct,{"D_EMISSAO"	,"C"	,TamSX3("D2_EMISSAO")[1]	,TamSX3("D2_EMISSAO")[2]}		)
						aAdd(aStruct,{"D_QUANT"		,"N"	,TamSX3("D2_QUANT")[1]		,TamSX3("D2_QUANT")[2]}	)
						aAdd(aStruct,{"O_COD"		,"C"	,TamSX3("D2_COD")[1]		,TamSX3("D2_COD")[2]}	)
						aAdd(aStruct,{"O_FILIAL"	,"C"	,TamSX3("D2_FILIAL")[1]		,TamSX3("D2_FILIAL")[2]}	)
						aAdd(aStruct,{"O_LOCAL"		,"C"	,TamSX3("D2_LOCAL")[1]		,TamSX3("D2_LOCAL")[2]}		)
						aAdd(aStruct,{"O_EMISSAO"	,"C"	,TamSX3("D2_EMISSAO")[1]	,TamSX3("D2_EMISSAO")[2]}		)
						aAdd(aStruct,{"O_QUANT"		,"N"	,TamSX3("D2_QUANT")[1]		,TamSX3("D2_QUANT")[2]}	)
						aAdd(aStruct,{"NUMSEQ"		,"C"	,TamSX3("D2_NUMSEQ")[1]		,TamSX3("D2_NUMSEQ")[2]}		)
						aAdd(aStruct,{"TIPO"		,"C"	,1							,0}	)
						
						oTempTable := LjCrTmpTbl(cAliasTmp3,aStruct, {"D_COD+D_FILIAL+D_LOCAL"})
						
						//Alimenta o alias temporário com os dados da Query
						dbSelectArea(cAliasTmp2)
						(cAliasTmp2)->(DbGotop())
						While !(cAliasTmp2)->(Eof())
						
							dbSelectArea(cAliasTmp3)
							RecLock(cAliasTmp3,.T.)
								(cAliasTmp3)->D_COD			:= (cAliasTmp2)->D_COD
								(cAliasTmp3)->D_FILIAL		:= (cAliasTmp2)->D_FILIAL
								(cAliasTmp3)->D_LOCAL		:= (cAliasTmp2)->D_LOCAL 
								(cAliasTmp3)->D_EMISSAO		:= (cAliasTmp2)->D_EMISSAO 
								(cAliasTmp3)->D_QUANT		:= (cAliasTmp2)->D_QUANT 
								(cAliasTmp3)->O_COD			:= (cAliasTmp2)->O_COD
								(cAliasTmp3)->O_FILIAL		:= (cAliasTmp2)->O_FILIAL
								(cAliasTmp3)->O_LOCAL		:= (cAliasTmp2)->O_LOCAL 
								(cAliasTmp3)->O_EMISSAO		:= (cAliasTmp2)->O_EMISSAO 
								(cAliasTmp3)->O_QUANT		:= (cAliasTmp2)->O_QUANT 
								(cAliasTmp3)->NUMSEQ		:= (cAliasTmp2)->NUMSEQ 
								(cAliasTmp3)->TIPO			:= (cAliasTmp2)->TIPO 
							(cAliasTmp3)->(MsUnlock())
											
						
				    		(cAliasTmp2)->(DbSkip())
			    		EndDo
				    	(cAliasTmp2)->(DbCloseArea())
			    	EndIf
			    	
			    	(cAliasTmp3)->(DbGotop())
			    	If (cAliasTmp3)->(Dbseek(TmpDrp->B2_COD+TmpDrp->B2_FILIAL+TmpDrp->B2_LOCAL))			    	//Pesquiso somente o corrente
			    	
				    	cOrSKUTipo 		:= ""
						cOrSKUFilial 	:= ""
						cOrSKUCodigo	:= ""
						cOrSKULocal  	:= ""
						dOrSKUEmissao := (cAliasTmp3)->D_EMISSAO
						nOrOQuant		:= 0
						nOrDQuant		:= 0
						
						//Vejo o último lançamento corrente. 
						//Se tiver ao menos uma transferência entre X vendas no último dia, eu considero a transferência.
				    	
				    	While !((cAliasTmp3)->(Eof())) .AND. (cAliasTmp3)->D_COD+(cAliasTmp3)->D_FILIAL+(cAliasTmp3)->D_LOCAL = TmpDrp->B2_COD+TmpDrp->B2_FILIAL+TmpDrp->B2_LOCAL;
				    																			 .AND. dOrSKUEmissao = (cAliasTmp3)->D_EMISSAO            
							// Gravo as informações em uma variável.
							If (cAliasTmp3)->TIPO = "T"
								cOrSKUTipo   := Alltrim((cAliasTmp3)->TIPO)
								cOrSKUFilial := ((cAliasTmp3)->O_FILIAL)
								cOrSKUCodigo := Alltrim((cAliasTmp3)->O_COD)
								cOrSKULocal  := Alltrim((cAliasTmp3)->O_LOCAL)
							EndIf
							nOrOQuant := (cAliasTmp3)->O_QUANT
							nOrDQuant := (cAliasTmp3)->D_QUANT
							(cAliasTmp3)->(DbSkip())
						End
		
			    	    If cOrSKUTipo = "T" .AND. nOrOQuant > 0 .AND. nOrDQuant > 0
			    	    	nAtuOri := nOrOQuant
			    	    	nAtuDes := nOrDQuant
			    	    Else
			    	    	nAtuOri := 1
			    	    	nAtuDes := nAtuOri
			    	    EndIf
						
						DbSelectArea("TMPDRP")
			    	    
					    cXML+='<ns1:ITENS>'+CRLF
			    	       cXML+='<ns1:ProdDest>'+Rtrim(TMPDRP->B2_COD)+'</ns1:ProdDest>'+CRLF
							cXML+='<ns1:LocalDest>'+alltrim(TMPDRP->(B2_FILIAL+B2_LOCAL))+'</ns1:LocalDest>'+CRLF
							cXML+='<ns1:IdDest>'+Alltrim(Str(nCodNeoGrid))+'</ns1:IdDest>'+CRLF
							If cOrSKUTipo <> "T"
								cXML+='<ns1:ProdOri>'+'</ns1:ProdOri>'+CRLF
								cXML+='<ns1:LocalOri>'+'</ns1:LocalOri>'+CRLF
								cXML+='<ns1:IdOri>'+'</ns1:IdOri>'+CRLF
								cXML+='<ns1:FornecDes>'+Alltrim(PadR(TMPDRP->B1_PROC,TamSX3("B1_PROC")[1])+alltrim(TMPDRP->B1_LOJPROC))+'</ns1:FornecDes>'+CRLF
							Else  //Transferência
								cXML+='<ns1:ProdOri>'+cOrSKUCodigo+'</ns1:ProdOri>'+CRLF
								cXML+='<ns1:LocalOri>'+cOrSKUFilial+cOrSKULocal+'</ns1:LocalOri>'+CRLF
								cXML+='<ns1:IdOri>'+Alltrim(Str(nCodNeoGrid))+'</ns1:IdOri>'+CRLF
								cXML+='<ns1:FornecDes>'+'</ns1:FornecDes>'+CRLF
							EndIf
							cXML+='<ns1:QtdOri>'+ALLTRIM(Transform(nAtuOri,"@E 99999999999.99"))+'</ns1:QtdOri>'+CRLF
							cXML+='<ns1:QtdDes>'+ALLTRIM(Transform(nAtuDes,"@E 99999999999.99"))+'</ns1:QtdDes>'+CRLF
							cXML+='<ns1:LeadTime>'+ALLTRIM(Transform(TMPDRP->(B1_PE),"@E 999.999"))+'</ns1:LeadTime>'+CRLF
							cXML+='<ns1:DesvioPad>'+'1,000'+'</ns1:DesvioPad>'+CRLF
							cXML+='<ns1:LoteMin>'+ALLTRIM(Transform(TMPDRP->(B1_LM),"@E 99999999.999"))+'</ns1:LoteMin>'+CRLF
							If TMPDRP->(B1_QE) = 0
								nQE := 1
							Else
								nQE := TMPDRP->(B1_QE)
							EndIf
							cXML+='<ns1:Unitiz>'+ALLTRIM(Transform(nQE,"@E 999999999.999"))+'</ns1:Unitiz>'+CRLF
							cXML+='<ns1:LoteMax>'+ALLTRIM(Transform(TMPDRP->(B1_LE),"@E 99999999.999"))+'</ns1:LoteMax>'+CRLF
							cXML+='<ns1:AntTrf>'+'0'+'</ns1:AntTrf>'+CRLF
							cXML+='<ns1:AntMat>'+'0'+'</ns1:AntMat>'+CRLF
							cXML+='<ns1:TravaPed>'+'0'+'</ns1:TravaPed>'+CRLF
					    cXML+='</ns1:ITENS>'+CRLF
			    	    lItXml := .t.
						If (nContador % 1000 = 0) .OR. (nContador <= 3)	//Acima de 3, mando no LogLoja a cada 1000 leituras
							LjGrvLog(STR0017," Modelo 6: Origem SKU "+"  XML  Produto:  "+ Rtrim (TMPDRP->B2_COD)+ "  Contador:  " + cValToChar(nContador))
						EndIf
						nContador := nContador + 1
					EndIf
				EndIf
	     	    TmpDrp->(Dbskip())
	    	End
			If Select((cAliasTmp3)) > 0
				(cAliasTmp3)->(dbCloseArea())
			EndIf 
			Lj7030Gr06(oTss,@cXml,cUrl,dData1,;
							lItXml,.T.)
    	Endif
    Endif
        
	// 7 Cadastro Local de Estoque
	// NNR
	// NNR = D MG 01 (EEE)
	If alltrim(str(aParam[2])) $ '0|7'  
		If Select("TMPDRP") > 0
			TMPDRP->(dbCloseArea())
		EndIf	   
		cQry:= "SELECT * FROM "+ RetSqlName("NNR") + " NNR " 
		cQry+= " WHERE "
		cQry+= " NNR.D_E_L_E_T_ = ' ' "
		cQry+= " AND NNR_DRPEXP = '' "
	
 		cQry := ChangeQuery(cQry)

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )
    	dbSelectArea("TMPDRP")
    	TmpDrp->(Dbgotop())
    	cXML       := ''
    	lCabXml    := .F.
		lItXml     := .F.
		If Empty(TMPDRP->NNR_FILIAL)	//Filial em branco?
    		lMultiFilial := .T.
    	Else
    		lMultiFilial := .F.
		EndIf

    	While !(TmpDrp->(Eof()))
    	
    		For nX := 1 to Iif(lMultiFilial, Len(aFiliais), 1)
    		
    			If lMultiFilial
    				cFilialNNR := aFiliais[nX][1]
    			Else
    				cFilialNNR := TMPDRP->NNR_FILIAL
    			EndIf
				cCodigoNNR := PadR(cFilialNNR,Iif(TamSx3("NNR_FILIAL")[1]=0,8,TamSx3("NNR_FILIAL")[1]))+alltrim(TMPDRP->NNR_CODIGO)
    		 			
				If !lCabXml
					cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
					cXML+='<CADASTROLOCALESTOQUE xsi:noNamespaceSchemaLocation="tss_tc_Cadastro_Local.xsd" xmlns:ns1="TotvsColabCadLocal" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
					cXML+='<ITEM>'+CRLF
					lCabXml:=.t.
				Endif
				// Leitura do nome da filial
				nPosFilial := Ascan(aFiliais,{|x|x[1]=TMPDRP->NNR_FILIAL})
				If nPosFilial > 0
					cNomeFilial := Alltrim(aFiliais[nPosFilial][5]) + " - "
				ElseIf !Empty(xFilial("NNR"))
					cNomeFilial := "FILIAL " + TMPDRP->NNR_FILIAL + " - "
				Else // Arquivo compartilhado, não há nome de filial.
					cNomeFilial := ""
				EndIf
				
				// Validação dos campos obrigatórios para o envio do registro pelo XML
				cXML+='<ns1:ITENS>'+CRLF
				cXML+='<ns1:Codigo>'+cCodigoNNR+'</ns1:Codigo>'+CRLF
				cXML+='<ns1:Descri>'+cNomeFilial+alltrim(LjNoAccent(TMPDRP->NNR_DESCRI))+'</ns1:Descri>'+CRLF
				cXML+='<ns1:Grupo1>'+'000001'+'</ns1:Grupo1>'+CRLF
				cXML+='<ns1:Grupo2>'+'000002'+'</ns1:Grupo2>'+CRLF
				cXML+='<ns1:Grupo3>'+''+'</ns1:Grupo3>'+CRLF
				cXML+='<ns1:Grupo4>'+''+'</ns1:Grupo4>'+CRLF
				cXML+='<ns1:VsCom>'+'0'+'</ns1:VsCom>'+CRLF
				cXML+='<ns1:PadFrq>'+'1'+'</ns1:PadFrq>'+CRLF
				cXML+='<ns1:CapacMx>'+'0,00'+'</ns1:CapacMx>'+CRLF
				cXML+='<ns1:Obs>'+''+'</ns1:Obs>'+CRLF
				cXML+='</ns1:ITENS>'+CRLF
				lItXml := .t.
			Next	
			TmpDrp->(Dbskip())
		End
		If lCabXml
			cXML+='  </ITEM>'+CRLF
			cXML+='</CADASTROLOCALESTOQUE>'+CRLF
		Endif 
		// Verificação se o XML tem item
		If lItXMl
			// Envio do XMl para o TSS   
        	aRet :=  LOJA7030A(oTss,7,cXML,cURL,dData1)
        	If Len(aRet) > 0
        	   lRet := aRet[1]
        	   oTSS := aRet[2]
        	Else
        	   lRet := .F.
       	Endif
		Else
			lRet := .f.
		Endif
		If Select("TMPDRP") > 0
			If lRet 
				cRet := If(nNeoCom=1,oTss:OWSTOTVSCOLABREMESSADOCRESULT:OWSREMESSADOCRET:OWSDOCUMENTORET[1]:NSTATUS,oTss)
				If Valtype(cRet) = 'N' .and. cRet = 0	
					TmpDrp->(Dbgotop())
		    	    While !(TmpDrp->(Eof()))            
						IF NNR->(DbSeek(TmpDrp->(NNR_FILIAL+NNR_CODIGO)))
							RecLock("NNR",.F.)
							NNR->NNR_DRPEXP := DtoS(dData1)
							NNR->(MSUnlock())
						Endif
						TmpDrp->(Dbskip())
				    End
				Endif 
			Endif
			TMPDRP->(dbCloseArea()) 
		EndIf
    Endif
     
	// 8 Movimentação SKU
	// SD1,SD2,SD3,SF4
	// SD1 = D MG 01 (EEE)
	// SD2 = D MG 01 (EEE)
	// SD3 = D MG 01 (EEE)
	// SF4 = D       (ECC)
	// Sintético por produto, filial, armazém
	// Observar a data de emissão!
	If alltrim(str(aParam[2])) $ '0|8'  
		If Select("TMPDRP") > 0
			TMPDRP->(dbCloseArea())
		EndIf	   
		cPesqChave		:= ""
		cPesqChv9		:= ""
		nContador 	:= 0
		cQry:= "SELECT D2_COD,D2_FILIAL,D2_LOCAL,SUM(D2_QUANT)D2_QUANT,SUM(D2_TRANSF) D2_TRANSF,SUM(D2_ETRANSF) D2_ETRANSF,SUM(D2_TOTAL) D2_TOTAL,SUM(D2_CUSTO1) D2_CUSTO1,SUM(D2_QTDEDEV) D2_QTDEDEV, "
		cQry+= " SUM(D2_VALDEV) D2_VALDEV, SUM(D1_QDEV) D1_QDEV FROM ( "
       
		// Vendas
		cQry+= " SELECT SD2.D2_COD,SD2.D2_FILIAL,SD2.D2_LOCAL,SD2.D2_QUANT D2_QUANT,0 D2_TRANSF,0 D2_ETRANSF,SD2.D2_TOTAL D2_TOTAL, "
		cQry+= " SD2.D2_QTDEDEV D2_QTDEDEV,SD2.D2_VALDEV D2_VALDEV ,0 AS D1_QDEV,SD2.D2_CUSTO1 D2_CUSTO1 " 
		cQry+= " FROM "+ RetSqlname("SD2") +" SD2 " 
		cQry+= "	LEFT JOIN "+ RetSqlName("SB1") + " SB1 " 
		cQry+= " ON SB1.B1_COD = SD2.D2_COD "
		cQry+= " INNER JOIN "+ RetSqlName("SF4")+ " SF4 " 
		cQry+= " ON SF4.F4_CODIGO = D2_TES AND SF4.F4_CODIGO >= '500' " 
		cQry+= "	AND SF4.F4_DUPLIC = 'S' AND SF4.F4_TRANFIL <> '1' AND SF4.D_E_L_E_T_ = '' " 
		cQry+= "  WHERE SD2.D_E_L_E_T_ = ' ' AND SD2.D2_DRPEXP = '' "
		cQry+= "    AND (SD2.D2_EMISSAO = '"+ Dtos(dData1) + "') "
		cQry+= "    AND D2_TIPO = 'N' "
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD2.D2_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (CHARINDEX(RTRIM(SB1.B1_FILIAL),RTRIM(SD2.D2_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (LOCATE(RTRIM(SD2.D2_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (INSTR(RTRIM(SD2.D2_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		EndIf
		cQry+= " UNION ALL "
       
		// Transferência entre filiais - SD2
		cQry+= " SELECT SD2.D2_COD,SD2.D2_FILIAL,SD2.D2_LOCAL,0 D2_QUANT,SD2.D2_QUANT D2_TRANSF,0 D2_ETRANSF,SD2.D2_TOTAL D2_TOTAL, "
		cQry+= " SD2.D2_QTDEDEV D2_QTDEDEV,SD2.D2_VALDEV D2_VALDEV ,0 AS D1_QDEV ,SD2.D2_CUSTO1 D2_CUSTO1 " 
		cQry+= " FROM "+ RetSqlname("SD2") +" SD2 " 
		cQry+= "	LEFT JOIN "+ RetSqlName("SB1") + " SB1 " 
		cQry+= " ON SB1.B1_COD = SD2.D2_COD "
		cQry+= " INNER JOIN "+ RetSqlName("SF4")+ " SF4 " 
		cQry+= " ON SF4.F4_CODIGO = D2_TES AND SF4.F4_CODIGO >= '500' " 
		cQry+= "	AND SF4.F4_TRANFIL = '1' AND SF4.D_E_L_E_T_ = '' " 
		cQry+= "  WHERE SD2.D_E_L_E_T_ = ' ' AND SD2.D2_DRPEXP = '' "
		cQry+= "    AND (SD2.D2_EMISSAO = '"+ Dtos(dData1) + "') "
		cQry+= "    AND D2_TIPO = 'N' "
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD2.D2_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (CHARINDEX(RTRIM(SB1.B1_FILIAL),RTRIM(SD2.D2_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (LOCATE(RTRIM(SD2.D2_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (INSTR(RTRIM(SD2.D2_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		EndIf
		cQry+= " UNION ALL "

		// Devolucao
		cQry+= "	SELECT SD1.D1_COD D2_COD,SD1.D1_FILIAL D2_FILIAL,SD1.D1_LOCAL D2_LOCAL,0 D2_QUANT,0 D2_TRANSF,0 D2_ETRANSF,0 D2_TOTAL,0 D2_QTDEDEV,0 D2_VALDEV, "
		cQry+= "	SD1.D1_QUANT D1_QDEV,SD1.D1_CUSTO D2_CUSTO1  FROM "+ RetSqlName("SD1") +" SD1 "
		cQry+= " LEFT JOIN "+RetSqlName("SB1")+ " SB1 " 
		cQry+= " ON SB1.B1_COD = SD1.D1_COD "
		cQry+= "	INNER JOIN "+ RetSqlName("SF4") + " SF4 "
		cQry+= " ON SF4.F4_CODIGO = SD1.D1_TES "
		cQry+= "  WHERE SD1.D_E_L_E_T_ = ' ' "                              
		cQry+= " AND (SD1.D1_EMISSAO = '"+ Dtos(dData1) + "' ) "
		cQry+= " AND SD1.D1_TIPO = 'D' "		
		cQry+= " AND SF4.F4_TRANFIL <> '1' "		
		cQry+= " AND SD1.D1_DRPEXP = '' "
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD1.D1_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (CHARINDEX(RTRIM(SB1.B1_FILIAL),RTRIM(SD1.D1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (LOCATE(RTRIM(SD1.D1_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (INSTR(RTRIM(SD1.D1_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		EndIf
		cQry+= " UNION ALL "

		// Devolucao de transferência entre filiais - SD1
		// Preciso passar zerado, mas com a quantidade de estoque.
		cQry+= "	SELECT SD1.D1_COD D2_COD,SD1.D1_FILIAL D2_FILIAL,SD1.D1_LOCAL D2_LOCAL,0 D2_QUANT,0 D2_TRANSF,0 D2_ETRANSF,0 D2_TOTAL,0 D2_QTDEDEV,0 D2_VALDEV, "
		cQry+= "	0 D1_QDEV, SD1.D1_CUSTO D2_CUSTO1 FROM "+ RetSqlName("SD1") +" SD1 "
		cQry+= " LEFT JOIN "+RetSqlName("SB1")+ " SB1 " 
		cQry+= " ON SB1.B1_COD = SD1.D1_COD "
		cQry+= "	INNER JOIN "+ RetSqlName("SF4") + " SF4 "
		cQry+= " ON SF4.F4_CODIGO = SD1.D1_TES "
		cQry+= "  WHERE SD1.D_E_L_E_T_ = ' ' "                              
		cQry+= " AND (SD1.D1_EMISSAO = '"+ Dtos(dData1) + "' ) "
		cQry+= " AND SD1.D1_TIPO = 'N' "		
		cQry+= " AND SF4.F4_TRANFIL = '1' "		
		cQry+= " AND SD1.D1_DRPEXP = '' "
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD1.D1_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (CHARINDEX(RTRIM(SB1.B1_FILIAL),RTRIM(SD1.D1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (LOCATE(RTRIM(SD1.D1_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
			cQry+= "	AND (INSTR(RTRIM(SD1.D1_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		EndIf
		cQry+= " UNION ALL "

		// Transferências entre Armazéns - Requisição
		cQry+= " SELECT SD3.D3_COD D2_COD,SD3.D3_FILIAL D2_FILIAL,SD3.D3_LOCAL D2_LOCAL,0 D2_QUANT,(SD3.D3_QUANT) D2_TRANSF,0 D2_ETRANSF,0 D2_TOTAL,0 D2_QTDEDEV,0 D2_VALDEV,0 D1_QDEV ,0 D2_CUSTO1 "
		cQry+= "	FROM "+ RetSqlName("SD3") +" SD3 "
		cQry+= "	LEFT JOIN "+RetSqlName("SB1")+" SB1 "
		cQry+= " ON SB1.B1_COD = SD3.D3_COD "                                   
		cQry+= "  WHERE SD3.D_E_L_E_T_ = ' ' AND SD3.D3_DRPEXP = '' "
		cQry+= " AND (SD3.D3_EMISSAO = '"+ DtoS(dData1) + "' ) "
		cQry+= " AND D3_TM >= '500' "		
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SB1.B1_FILIAL),RTRIM(SD3.D3_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SD3.D3_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SD3.D3_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		EndIf
		cQry+= " UNION ALL "
		
		// Transferências entre Armazéns - Devolução
		// Preciso passar zerado, mas com a quantidade de estoque.
		cQry+= " SELECT SD3.D3_COD D2_COD,SD3.D3_FILIAL D2_FILIAL,SD3.D3_LOCAL D2_LOCAL,0 D2_QUANT,0 D2_TRANSF,(SD3.D3_QUANT) D2_ETRANSF,0 D2_TOTAL,0 D2_QTDEDEV,0 D2_VALDEV,0 D1_QDEV, 0 D2_CUSTO1  "
		cQry+= "	FROM "+ RetSqlName("SD3") +" SD3 "
		cQry+= "	LEFT JOIN "+RetSqlName("SB1")+" SB1 "
		cQry+= " ON SB1.B1_COD = SD3.D3_COD "                                   
		cQry+= "  WHERE SD3.D_E_L_E_T_ = ' ' AND SD3.D3_DRPEXP = '' "
		cQry+= " AND (SD3.D3_EMISSAO = '"+ DtoS(dData1) + "' ) "
		cQry+= " AND D3_TM < '500' "
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SB1.B1_FILIAL),RTRIM(SD3.D3_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SD3.D3_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SD3.D3_FILIAL),RTRIM(SB1.B1_FILIAL))>0 OR SB1.B1_FILIAL = '')"
		EndIf
		
		// Separar em grupo no SQL
		cQry+= " ) TAB "
		cQry+= " GROUP BY TAB.D2_COD,TAB.D2_FILIAL,TAB.D2_LOCAL "
		cQry+= " ORDER BY TAB.D2_COD,TAB.D2_FILIAL,TAB.D2_LOCAL "

 		cQry := ChangeQuery(cQry)

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )
    	dbSelectArea("TMPDRP")
    	TmpDrp->(Dbgotop())
    	cXML       := ''                                                                                                                      
		lCabXml    := .F.
		lItXml     := .F.
    	While !(TmpDrp->(Eof()))            
    		If (nContador % 150 = 0) .AND. len(cXML) > 900000	//Questão de performance (verificar a cada 150 leituras) e se o número de caracteres for superior a 900 mil.
				cPesqChv9 += cPesqChave
				Lj7030Gr08(oTss,@cXml,cUrl,dData1,;
							@cPesqChave,nNeoCom,lItXml,.F.,;
							aPrm,cGetDB)
    		EndIf
			nCusto := 0
			nPreco := 0
			nMargem := 0  
			If TMPDRP->D2_QUANT > 0 .and. TMPDRP->D2_CUSTO1 > 0
				nCusto := TMPDRP->(D2_CUSTO1 / D2_QUANT ) 
				nPreco := TMPDRP->(D2_TOTAL / D2_QUANT ) 
				nMargem := nPreco - nCusto   
			Endif
			If !lCabXml
				cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
				cXML+='<MOVIMENTACAOSKU xsi:noNamespaceSchemaLocation="tss_tc_MovimetacaoSKU.xsd" xmlns:ns1="TotvsColabMovSku" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
				cXML+='  <ITEM>'+CRLF
				lCabXml:=.t.
			Endif
			aSaldo := CalcEst(TMPDRP->D2_COD,TMPDRP->D2_LOCAL,dData1+1)	//Ver se aparentemente não precisará de SB2
			aSaldoTerc 	:= SaldoTerc(TMPDRP->D2_COD,TMPDRP->D2_LOCAL,"T",dData1+1,TMPDRP->D2_LOCAL,.F.)	//Ver se aparentemente não precisará de SB2  //5º parâmetro - deve considerar o saldo em poder de terceiros
			If Len(aSaldo) > 1
				nSaldoSB2 := aSaldo[1] + aSaldoTerc[1]
			Else
				DBSelectArea("SB2")
				DBSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL
				If SB2->(DbSeek(xFilial("SB2")+TMPDRP->D2_COD+TMPDRP->D2_LOCAL))
					nSaldoSB2 := SaldoSB2(.T.,,,,.T.)	//5º parâmetro - deve considerar o saldo em poder de terceiros
				Else
					nSaldoSB2 := 0
				EndIf
			EndIf 
			// Validação dos campos obrigatórios para o envio do registro pelo XML
			cXML+='<ns1:ITENS>'+CRLF
			cXML+='<ns1:ProdCod>'+alltrim(TMPDRP->D2_COD)+'</ns1:ProdCod>'+CRLF
			cXML+='<ns1:ProdLocal>'+alltrim(TMPDRP->(D2_FILIAL+D2_LOCAL))+'</ns1:ProdLocal>'+CRLF
			cXML+='<ns1:DataMov>'+dtos(dData1)+'</ns1:DataMov>'+CRLF
			cXML+='<ns1:QtdVnd>'+alltrim(Transform(TMPDRP->D2_QUANT,"@E 99999999999.99"))+'</ns1:QtdVnd>'+CRLF
			cXML+='<ns1:QtdEstornoVnd>'+alltrim(Transform(TMPDRP->D1_QDEV,"@E 99999999999.99"))+'</ns1:QtdEstornoVnd>'+CRLF
			cXML+='<ns1:PrcMdVnd>'+alltrim(Transform(nPreco,"@E 99999999999.99"))+'</ns1:PrcMdVnd>'+CRLF
			cXML+='<ns1:MrgUnit>'+alltrim(Transform(nMargem,"@E 99999999999.99"))+'</ns1:MrgUnit>'+CRLF
			cXML+='<ns1:QtdTrf>'+alltrim(Transform(TMPDRP->D2_TRANSF,"@E 99999999999.99"))+'</ns1:QtdTrf>'+CRLF
			cXML+='<ns1:QtdEstornoTrf>'+alltrim(Transform(TMPDRP->D2_ETRANSF,"@E 99999999999.99"))+'</ns1:QtdEstornoTrf>'+CRLF
			cXML+='<ns1:CstUnitMd>'+alltrim(Transform(nCusto,"@E 99999999999.99")) +'</ns1:CstUnitMd>'+CRLF
			cXML+='<ns1:QtdEstoque>'+IIF(nSaldoSB2>0,alltrim(Transform(nSaldoSB2,"@E 99999999999.99")),'0,00')+'</ns1:QtdEstoque>'+CRLF
			cXML+='<ns1:FaltaEst>'+IIF(nSaldoSB2<0,alltrim(Transform(nSaldoSB2*-1,"@E 99999999999.99")),'0,00')+'</ns1:FaltaEst>'+CRLF
			cXML+='</ns1:ITENS>'+CRLF
			lItXml := .t.
			cPesqChave+=TmpDrp->(D2_COD+D2_FILIAL+D2_LOCAL)+","
			TmpDrp->(Dbskip())
			If nContador % 1000 = 0 .OR. nContador <= 3	//Acima de 3, mando no LogLoja a cada 1000 leituras
				LjGrvLog(STR0017," Modelo 8: Movimentacao SKU "+"  XML  Produto:  "+ alltrim (TMPDRP->D2_COD)+ "  Contador:  " + cValToChar(nContador))
			EndIf
			nContador := nContador + 1
    	End
		cPesqChv9 += cPesqChave
		Lj7030Gr08(oTss,@cXml,cUrl,dData1,;
					@cPesqChave,nNeoCom,lItXml,.T.,;
					aPrm,cGetDB)
		LOJA7030({aPrm[1],9,cEmp,cFilTrab,cPesqChv9}) // Origem DFU
	Endif
    
	// 9 Movimentação DFU
	// SD2,SF4
	// SD2 = D MG 01 (EEE)
	// SF4 = D       (ECC)
	// Observar a data de emissão!
	If alltrim(str(aParam[2])) $ '9'  
		If Select("TMPDRP") > 0
			TMPDRP->(dbCloseArea())
		EndIf	   
		nContador 	:= 0

		// Union 1: Movimentação de Vendas
		cQry:= " SELECT D2_COD, D2_FILIAL, D2_LOCAL, D2_EMISSAO, SUM(D2_QUANT) D2_QUANT, SUM(D2_QTDEV) D2_QTDEV, SUM(D2_TOTAL) D2_TOTAL, SUM(D2_CUSTO1) D2_CUSTO1 "
		cQry+= " FROM ( "
		cQry+= " SELECT SD2.D2_COD D2_COD,SD2.D2_FILIAL D2_FILIAL,SD2.D2_LOCAL D2_LOCAL,SD2.D2_EMISSAO D2_EMISSAO,SUM(SD2.D2_QUANT) D2_QUANT,SUM(0.00) D2_QTDEV, SUM(SD2.D2_TOTAL) D2_TOTAL,SUM(SD2.D2_CUSTO1) D2_CUSTO1 "
		cQry+= " FROM "+ RetSqlName("SD2")+ " SD2"
		cQry+= " INNER JOIN "+ RetSqlName("SF4")+ " SF4 " 
		cQry+= " ON  SF4.F4_CODIGO = D2_TES AND SF4.F4_CODIGO >= '500' "
		cQry+= " AND SF4.F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = '' " 
		cQry+= "	WHERE SD2.D_E_L_E_T_ = ' ' " 
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD2.D2_FILIAL))>0 OR SF4.F4_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
		EndIf
		cQry+= " AND (SD2.D2_EMISSAO = '"+ Dtos(dData1) + "') "
		cQry+= " AND SD2.D2_TIPO = 'N' AND SD2.D2_DRPEXP = '' "
		cQry+= " GROUP BY SD2.D2_COD,SD2.D2_FILIAL,SD2.D2_LOCAL,SD2.D2_EMISSAO " 
		
		cQry+= " UNION ALL "
		
		// Union 2: Devolução de Movimentação de Vendas
		cQry+= " SELECT SD1.D1_COD D2_COD, SD1.D1_FILIAL D2_FILIAL, SD1.D1_LOCAL D2_LOCAL, SD1.D1_EMISSAO D2_EMISSAO, SUM(0.00) D2_QUANT, SUM(D1_QUANT) D2_QTDEV, -SUM(SD1.D1_TOTAL) D2_TOTAL,-SUM(SD1.D1_CUSTO) D2_CUSTO1 " 
		cQry+= " FROM "+ RetSqlName("SD1")+ " SD1"
		cQry+= " INNER JOIN "+ RetSqlName("SF4")+ " SF4 " 
		cQry+= " ON  SF4.F4_CODIGO = D1_TES "
		cQry+= " AND SF4.F4_TRANFIL <> '1' "		
		cQry+= " AND SF4.D_E_L_E_T_ = '' " 
		cQry+= "	WHERE SD1.D_E_L_E_T_ = ' ' " 
		If At("MSSQL",cGetDB) > 0
			cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD1.D1_FILIAL))>0 OR SF4.F4_FILIAL = '')"
		ElseIf cGetDB == "DB2"
			cQry+= "	AND (LOCATE(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
		Else
			cQry+= "	AND (INSTR(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
		EndIf
		cQry+= " AND (SD1.D1_EMISSAO = '"+ Dtos(dData1) + "') "
		cQry+= " AND SD1.D1_TIPO = 'D' AND SD1.D1_DRPEXP = '' "
		
		cQry+= " GROUP BY SD1.D1_COD,SD1.D1_FILIAL,SD1.D1_LOCAL,SD1.D1_EMISSAO " 
		cQry+= " ) TAB"
		cQry+= " GROUP BY TAB.D2_COD,TAB.D2_FILIAL,TAB.D2_LOCAL,TAB.D2_EMISSAO "
		cQry+= " ORDER BY TAB.D2_COD,TAB.D2_FILIAL,TAB.D2_LOCAL,TAB.D2_EMISSAO " 

 		cQry := ChangeQuery(cQry)

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )
    	dbSelectArea("TMPDRP")
    	TmpDrp->(Dbgotop())
    	cXML       := ''                                                                                                                      
    	lCabXml    := .F.
		lItXml     := .F.
    	While !(TmpDrp->(Eof()))            
    		If (nContador % 150 = 0) .AND. len(cXML) > 900000	//Questão de performance (verificar a cada 150 leituras) e se o número de caracteres for superior a 900 mil.
				Lj7030Gr09(oTss,@cXml,cUrl,dData1,;
						@cPesqChave,nNeoCom,lItXml,.F.,;
						cGetDB)
    		EndIf
    		If At(TmpDrp->(D2_COD+D2_FILIAL+D2_LOCAL) + ",", cPesqChave) > 0		//Vindo do módulo 8 - movimentação SKU
				nPreco := 0
				nMargem := 0  
				If TMPDRP->D2_QUANT > 0 .and. TMPDRP->D2_CUSTO1 > 0
					nCusto := TMPDRP->(D2_CUSTO1 / D2_QUANT ) 
					nPreco := TMPDRP->(D2_TOTAL / D2_QUANT ) 
					nMargem := nPreco - nCusto   
				Endif
				If !lCabXml
					cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
					cXML+='<MOVIMENTACAODFU xsi:noNamespaceSchemaLocation="tss_tc_MovimetacaoDFU.xsd" xmlns:ns1="TotvsColabMovDfu" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
					cXML+='  <ITEM>'+CRLF
					lCabXml:=.t.
				Endif
				// Validação dos campos obrigatórios para o envio do registro pelo XML
				cXML+='<ns1:ITENS>'+CRLF      
				cXML+='<ns1:ProdCod>'+alltrim(TMPDRP->D2_COD)+'</ns1:ProdCod>'+CRLF
				cXML+='<ns1:ProdLocal>'+alltrim(TMPDRP->(D2_FILIAL+D2_LOCAL))+'</ns1:ProdLocal>'+CRLF
				cXML+='<ns1:ProdLocal2>'+alltrim(TMPDRP->(D2_FILIAL+D2_LOCAL))+'</ns1:ProdLocal2>'+CRLF
				cXML+='<ns1:DataMov>'+alltrim(TMPDRP->D2_EMISSAO)+'</ns1:DataMov>'+CRLF
				cXML+='<ns1:QtdVnd>'+alltrim(Transform(TMPDRP->D2_QUANT,"@E 99999999999.99"))+'</ns1:QtdVnd>'+CRLF
				cXML+='<ns1:QtdEstornoVnd>'+alltrim(Transform(TMPDRP->D2_QTDEV,"@E 99999999999.99"))+'</ns1:QtdEstornoVnd>'+CRLF
				cXML+='<ns1:PrcUniMd>'+alltrim(Transform(nPreco,"@E 99999999999.99"))+'</ns1:PrcUniMd>'+CRLF
				cXML+='<ns1:MrgUnit>'+alltrim(Transform(nMargem,"@E 99999999999.99"))+'</ns1:MrgUnit>'+CRLF
				cXML+='<ns1:LocalEnt>'+alltrim(TMPDRP->(D2_FILIAL+D2_LOCAL))+'</ns1:LocalEnt>'+CRLF
				cXML+='</ns1:ITENS>'+CRLF'
				lItXml := .t.
				If nContador % 1000 = 0 .OR. nContador <= 3	//Acima de 3, mando no LogLoja a cada 1000 leituras
					LjGrvLog(STR0017," Modelo 9: Movimentacao DFU "+"  XML  Produto:  "+ alltrim (TMPDRP->D2_COD)+ "  Contador:  " + cValToChar(nContador))
				EndIf
				nContador := nContador + 1
			EndIf
			TmpDrp->(Dbskip())
		End
		Lj7030Gr09(oTss,@cXml,cUrl,dData1,;
				@cPesqChave,nNeoCom,lItXml,.T.,;
				cGetDB)
		
	Endif
    
	// 10 Eventos
	// ACV,MFP,MFQ,MFR,SB1
	// ACV = D MG (EEC)
	// MFP = D MG (EEC)
	// MFQ = D MG (EEC)
	// MFR = D MG (EEC)
	// SB1 = D MG (EEC)
	If alltrim(str(aParam[2])) $ '0|10'
		If Select("TMPDRP") > 0
			TMPDRP->(dbCloseArea())
		EndIf	   
		cQry:= "SELECT ISNULL(ACV.ACV_CODPRO,'') ACV_CODPRO, "
		cQry+= " MFP.MFP_FILIAL, MFP.D_E_L_E_T_, "
		cQry+= " MFP.MFP_DESCR,	MFP.MFP_DTINI,MFP.MFP_DTFIM,MFP.MFP_IMPPAB,MFP.MFP_IMPPPC,MFP.MFP_DANTEC,MFP.MFP_LINK,MFP.MFP_OBS, "
		cQry+= " MFP.MFP_IMPPRV,MFP.MFP_AVSTER,MFP.MFP_IMPPLN,MFP.MFP_IMPREP,MFP.MFP_CODEVE,MFP.MFP_TIPEVE,MFR.MFR_FILIAL,MFR.MFR_CODEVE, "
		cQry+= " MFR.MFR_TIPO,MFR.MFR_ITEM,MFR.MFR_PRODUT,MFR.MFR_GRUPO,MFR.MFR_CATEG,MFR.MFR_FORNEC,MFR.MFR_ARMAZ,MFR.D_E_L_E_T_, "
		cQry+= " MFR.MFR_LOJA,MFR.MFR_GRID,MFQ.MFQ_DESCR "	
		cQry+= " FROM "+ RetSqlName("MFP") + " MFP " 
		cQry+= " INNER JOIN "+ RetSqlName("MFQ") + " MFQ " 
		cQry+= " ON MFP.MFP_TIPEVE = MFQ.MFQ_CODIGO "
		cQry+= " INNER JOIN "+ RetSqlName("MFR") + " MFR " 
		cQry+= " ON MFP.MFP_CODEVE = MFR.MFR_CODEVE "
		cQry+= " LEFT  JOIN "+ RetSqlName("ACV")+ " ACV " 
		cQry+= " ON ACV.ACV_CATEGO = MFR.MFR_CATEG AND ACV.D_E_L_E_T_ = ' ' AND MFR.MFR_TIPO = '3' " 
		cQry+= " WHERE "               	
		cQry+= " MFP.D_E_L_E_T_ = ' ' AND MFP_DRPEXP = '' AND MFR.D_E_L_E_T_ = ' ' "
        cQry+= " ORDER BY MFP_FILIAL,MFP_CODEVE,MFR_TIPO,MFR_ITEM "
         	
 		cQry := ChangeQuery(cQry)

		aQry := {} 
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )
    	dbSelectArea("TMPDRP")
    	TmpDrp->(Dbgotop())
    	cXML       := ''
    	lCabXml    := .F.
		lItXml     := .F.
    	While !(TmpDrp->(Bof())) .AND. !(TmpDrp->(Eof()))
			cFilial := TmpDrp->MFP_FILIAL
			cCodeve := TmpDrp->MFP_CODEVE
			nScan   := aScan(aQry,{|x| x[1] == cFilial+cCodeve})
			If nScan = 0                                      
    	         aadd(aQry,{	cFilial+cCodeve,cFilial,cCodeve,TmpDrp->MFP_DESCR,;
    	         				TmpDrp->MFP_DTINI,TmpDrp->MFP_DTFIM,TmpDrp->MFP_IMPPAB,TmpDrp->MFP_IMPPPC,;
    	         				TmpDrp->MFP_DANTEC,TmpDrp->MFP_LINK,TmpDrp->MFP_IMPPRV,If(TmpDrp->MFP_AVSTER="T","1","0"),;
    	                     TmpDrp->MFP_IMPPLN,TmpDrp->MFP_IMPREP,TmpDrp->MFP_TIPEVE,TMPDRP->MFP_OBS,;
    	                     {},TMPDRP->MFQ_DESCR})
    	         nScan := Len(aQry)
			Endif
			Do Case
			Case TmpDrp->MFR_TIPO = '1'  .and. !Empty(TmpDrp->MFR_PRODUT)
				nScan2	:= aScan(aQry[nScan][17], {|x| x[1] = "2" .AND. x[2] = TmpDrp->MFR_PRODUT } ) 
				If nScan2 = 0
					aadd(aQry[nScan][17],{'2',TmpDrp->MFR_PRODUT}) // Produto Tipo 1
				EndIf
			Case TmpDrp->MFR_TIPO = '3' .and. !Empty(TmpDrp->ACV_CODPRO)
				nScan2	:= aScan(aQry[nScan][17], {|x| x[1] = "2" .AND. x[2] = TmpDrp->ACV_CODPRO } ) 
				If nScan2 = 0
					aadd(aQry[nScan][17],{'2',TmpDrp->ACV_CODPRO})              // Produto Filtro por Categoria
				EndIf
			Case TmpDrp->MFR_TIPO = '4'
				nScan2	:= aScan(aQry[nScan][17], {|x| x[1] = "1" .AND. x[2] = TmpDrp->MFR_FORNEC } ) 
				If nScan2 = 0
					aadd(aQry[nScan][17],{'1',TmpDrp->MFR_FORNEC}) // Fornecedor
				EndIf 
			Case TmpDrp->MFR_TIPO = '5'                            
				nScan2	:= aScan(aQry[nScan][17], {|x| x[1] = "4" .AND. x[2] = TmpDrp->MFR_ARMAZ } ) 
				If nScan2 = 0
					aadd(aQry[nScan][17],{'4',TmpDrp->MFR_ARMAZ})  // Armazém
				EndIf
			Endcase 
			nContador++
			TmpDrp->(Dbskip())
		End
    	For n1 := 1 to Len(aQry) 
			aFiltro := aClone(aQry[n1][17])
			If !Empty(aFiltro)
				Asort(aFiltro,,,{|x,y| x[1] < y[1]}) // ordena o Vetor pelo tipo para gerar o Xml na ordem
				If !lCabXml
					cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
					cXML+='<EVENTOS xsi:noNamespaceSchemaLocation="tss_tc_eventos.xsd" xmlns:ns1="TotvsColabEventos" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
					cXML+='<ITEM>'+CRLF
					lCabXml:=.t.
				Endif
				/*                1            2     3                 4          5                   6              7
				aadd(aQry,{cFilial+cCodeve,cFilial,cCodeve,TmpDrp->MFP_DESCR,TmpDrp->MFP_DTINI,TmpDrp->MFP_DTFIM,TmpDrp->MFP_IMPPAB,;
                           8                   9           10                  11                 12
					TmpDrp->MFP_IMPPPC,TmpDrp->MFP_DANTEC,TmpDrp->MFP_LINK,TmpDrp->MFP_IMPPRV,TmpDrp->MFP_AVSTER,;
    	                  13                    14              15               16          17
					TmpDrp->MFP_IMPPLN,TmpDrp->MFP_IMPREP,TmpDrp->MFP_TIPEVE,TMPDRP->MFP_OBS,{}})	              
				*/
				// Validação dos campos obrigatórios para o envio do registro pelo XML
				cXML+='<ns1:ITENS>'+CRLF
				cXML+='<ns1:ContAlt>'+'A'+'</ns1:ContAlt>'+CRLF
				cXML+='<ns1:CodExtEvento>'+alltrim(aQry[n1][1])+'</ns1:CodExtEvento>'+CRLF
				cXML+='<ns1:CodExtusuario>'+cUsuarioDRP+'</ns1:CodExtusuario>'+CRLF
				cXML+='<ns1:DescTipoEvent>'+alltrim(LjNoAccent(aQry[n1][18]))+'</ns1:DescTipoEvent>'+CRLF
				cXML+='<ns1:DescDoEvento>'+alltrim(LjNoAccent(aQry[n1][4]))+'</ns1:DescDoEvento>'+CRLF
				cXML+='<ns1:DataInicial>'+alltrim(aQry[n1][5])+'</ns1:DataInicial>'+CRLF
				cXML+='<ns1:DataFinal>'+alltrim(aQry[n1][6])+'</ns1:DataFinal>'+CRLF
				cXML+='<ns1:ImpactaPrev>'+If(Empty(aQry[n1][11]),'0','1')+'</ns1:ImpactaPrev>'+CRLF
				Do case 
				Case Empty(aQry[n1][11])   // Nao Impacta na previsão
					cXML+='<ns1:ImpactoPrevAbs>0</ns1:ImpactoPrevAbs>'+CRLF
					cXML+='<ns1:ImpactPrevPerc>0</ns1:ImpactPrevPerc>'+CRLF
					cXML+='<ns1:ImpacRealzAbs>0</ns1:ImpacRealzAbs>'+CRLF
					cXML+='<ns1:ImpacRealzPerc>0</ns1:ImpacRealzPerc>'+CRLF
				Case aQry[n1][11] = '1'   // Impacta na previsão valor percentual
					cXML+='<ns1:ImpactoPrevAbs>0</ns1:ImpactoPrevAbs>'+CRLF
					cXML+='<ns1:ImpactPrevPerc>'+IF(aQry[n1][7]=0,'0',alltrim(Transform(aQry[n1][7],"@E 99.99")))+'</ns1:ImpactPrevPerc>'+CRLF
					cXML+='<ns1:ImpacRealzAbs>0</ns1:ImpacRealzAbs>'+CRLF
					cXML+='<ns1:ImpacRealzPerc>'+If(aQry[n1][8]=0,'0',alltrim(Transform(aQry[n1][8],"@E 99.99")))+'</ns1:ImpacRealzPerc>'+CRLF
				Case aQry[n1][11] = '2'  // Impacta na previsão valor Absoluto
					cXML+='<ns1:ImpactoPrevAbs>'+IF(aQry[n1][7]=0,'0',alltrim(Transform(aQry[n1][7],"@E 99.99")))+'</ns1:ImpactoPrevAbs>'+CRLF
					cXML+='<ns1:ImpactPrevPerc>0</ns1:ImpactPrevPerc>'+CRLF
					cXML+='<ns1:ImpacRealzAbs>'+IF(aQry[n1][8]=0,'0',alltrim(Transform(aQry[n1][8],"@E 99.99")))+'</ns1:ImpacRealzAbs>'+CRLF
					cXML+='<ns1:ImpacRealzPerc>0</ns1:ImpacRealzPerc>'+CRLF
				Endcase    
				cXML+='<ns1:AvisoTermEvento>'+aQry[n1][12]+'</ns1:AvisoTermEvento>'+CRLF
				cXML+='<ns1:DiasAntec>'+iF(aQry[n1][12]='1',STRZERO(aQry[n1][9],2),'0')+'</ns1:DiasAntec>'+CRLF
				cXML+='<ns1:LinkRelacionado>'+alltrim(aQry[n1][10])+'</ns1:LinkRelacionado>'+CRLF
				cXML+='<ns1:OBS>'+alltrim(aQry[n1][16])+'</ns1:OBS>'+CRLF
				cXML+='<ns1:RegrasEvento><![CDATA['
				For n2=1 to Len(aFiltro)
					Do case
					Case aFiltro[n2][1] = '1'
						cXML+='<ns1:F>'+alltrim(aFiltro[n2][2])+'</ns1:F>' 
					Case aFiltro[n2][1] = '2'
						cXML+='<ns1:I>'+alltrim(aFiltro[n2][2])+'</ns1:I>' 
					Case aFiltro[n2][1] = '4'
						cXML+='<ns1:DD1>'+alltrim(aFiltro[n2][2])+'</ns1:DD1>' 
					Endcase                     
				Next n2 
				cXML+=']]></ns1:RegrasEvento>'+CRLF
				cXML+='</ns1:ITENS>'+CRLF
				lItXml := .t.
			Endif
		Next n1
		If lCabXml
			cXML+='</ITEM>'+CRLF
			cXML+='</EVENTOS>'+CRLF
		Endif 
		// Verificação se o XML tem item
		If lItXMl
			// Envio do XMl para o TSS   
			aRet :=  LOJA7030A(oTss,10,cXML,cURL,dData1)
			If Len(aRet) > 0
				lRet := aRet[1]
				oTSS := aRet[2]
			Else
				lRet := .F.
			Endif
		Else
			lRet := .f.
		Endif
		
		If Select("TMPDRP") > 0
			If lRet 
				cRet := If(nNeoCom=1,oTss:OWSTOTVSCOLABREMESSADOCRESULT:OWSREMESSADOCRET:OWSDOCUMENTORET[1]:NSTATUS,oTss)
				If Valtype(cRet) = 'N' .and. cRet = 0	
					TmpDrp->(Dbgotop())
					While !(TmpDrp->(Eof()))            
						IF MFP->(DbSeek(TmpDrp->(MFP_FILIAL+MFP_CODEVE))) .AND. Empty(MFP->MFP_DRPEXP)
							RecLock("MFP",.F.)
							MFP->MFP_DRPEXP := DtoS(dData1)
							MFP->(MSUnlock())
						Endif 
						TmpDrp->(Dbskip())
					End
				Endif 
			Endif
			TMPDRP->(dbCloseArea()) 
		EndIf
    EndIf
    
	// Pedido de Compra
	// 12 Linha de pedidos colocados
	// SC7
	// SC7 = D MG 01 (EEE) 
	If alltrim(str(aParam[2])) $ '0|12' .AND. lGeraPedColoc  
		If Select("TMPDRP") > 0
			TMPDRP->(dbCloseArea())
		EndIf	   
		nContador 	:= 0
		cPesqChave		:= ""  
		cQry:= "SELECT SC7.C7_FILIAL,SC7.C7_NUM,SC7.C7_ITEM,SC7.C7_PRODUTO,SC7.C7_EMISSAO,SC7.C7_LOCAL,SC7.C7_DATPRF,SC7.C7_QUANT,SC7.C7_QUJE, "
		cQry+= " SC7.C7_FORNECE,SC7.C7_LOJA,SC7.C7_DATPRF,SC7.C7_ENCER,SC7.C7_RESIDUO,SC7.C7_PO_EIC FROM "+ RetSqlName("SC7") + " SC7 "
		cQry+= "	WHERE SC7.D_E_L_E_T_ = ' ' "
		cQry+= "	AND SC7.C7_QUJE < SC7.C7_QUANT "
		cQry+= " AND (NOT SC7.C7_ORIGEM = 'LOJA7033') "
		cQry+= " AND (SC7.C7_ENCER = ' ') "
		cQry+= " AND (SC7.C7_RESIDUO <> 'S') "

		cQry := ChangeQuery(cQry)

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )
    	dbSelectArea("TMPDRP")
    	TmpDrp->(Dbgotop())
    	cXML       := ''
    	lCabXml    := .F.
		lItXml     := .F.
    	While !(TmpDrp->(Eof()))            
    		If (nContador % 150 = 0) .AND. len(cXML) > 900000	//Questão de performance (verificar a cada 150 leituras) e se o número de caracteres for superior a 900 mil.
				Lj7030Gr12(oTss,@cXml,cUrl,dData1,;
					@cPesqChave,nNeoCom,lItXml,.F.)
    		EndIf
			If !lCabXml
				cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
				cXML+='<PDCOMPRA xsi:noNamespaceSchemaLocation="tss_tc_PdCompra.xsd" xmlns:ns1="TotvsColabPdCompra" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
				cXML+='<ITEM>'+CRLF
				lCabXml:=.t.
			Endif
			
			//Inicio Ponto de Entrada
			lPEPValid := .F.
			If lEncontPE12
				cValidXML := ExecBlock( "LJDRPEP", .F., .F., {TMPDRP->(C7_FILIAL+C7_NUM+C7_ITEM)} )	//Validações obrigatórias DENTRO do ponto de entrada, portanto preciso validar a string e ver se todas as tags existem lá.
				//Terá o controle TOTAL do XML podendo fazer o que quiser, inclusive incluir FOR/NEXT no próprio ponto de entrada os pedidos ligados ao campo chave.
				
				cMsgVldXML := ""
				If !Empty(cValidXML)
				
					//Validações cValidXML
					aPEP :={{"<ns1:ContrAlt>"	,"</ns1:ContrAlt>"},;
							{"<ns1:CodPed>"		,"</ns1:CodPed>"},;
							{"<ns1:CodNeo>"		,"</ns1:CodNeo>"},;
							{"<ns1:Emissao>"	,"</ns1:Emissao>"},;
							{"<ns1:Obs>"		,"</ns1:Obs>"},;
							{"<ns1:IdDestino>"	,"</ns1:IdDestino>"},;
							{"<ns1:CodItem>"	,"</ns1:CodItem>"},;
							{"<ns1:CodLocalD>"	,"</ns1:CodLocalD>"},;
							{"<ns1:DtMov>"		,"</ns1:DtMov>"},;
							{"<ns1:QtdPed>"		,"</ns1:QtdPed>"},;
							{"<ns1:QtdRec>"		,"</ns1:QtdRec>"},;
							{"<ns1:IdOrigem>"	,"</ns1:IdOrigem>"},;
							{"<ns1:CodItemOr>"	,"</ns1:CodItemOr>"},;
							{"<ns1:CodLocaldOr>","</ns1:CodLocaldOr>"},;
							{"<ns1:DtMovOr>"	,"</ns1:DtMovOr>"},;
							{"<ns1:QtdPedOr>"	,"</ns1:QtdPedOr>"},;
							{"<ns1:QtdEntOr>"	,"</ns1:QtdEntOr>"},;
							{"<ns1:DesLocal>"	,"</ns1:DesLocal>"},;
							{"<ns1:Status>"		,"</ns1:Status>"},;
							{"<ns1:CodTransp>"	,"</ns1:CodTransp>"}}
							
					ntAnt1 := 0
					ntAnt2 := 0

					//Irá verificar se há realmente tags no XML, senão, retornará mensagem de aviso em cMsgVldXML
					If !(At("<ns1:ITENS>",cValidXML) > 0)
						cMsgVldXML += STR0033 + "<ns1:ITENS>" + STR0034 + CRLF	//"Tag"###" nao encontrado"
					EndIf
					For nX := 1 to Len(aPEP)
					
						//ContrAlt
						nt1 := At(aPEP[nX,1],cValidXML)
						nt2 := At(aPEP[nX,2],cValidXML)
						cMsgVldXML += Lj7030VlP(nt1,aPEP[nX,1],nt2,aPEP[nX,2],;
									   ntAnt1,Iif(nX>1,aPEP[nX-1,1],""),ntAnt2,Iif(nX>1,aPEP[nX-1,2],""))
						ntAnt1 := nt1
						ntAnt2 := nt2
					Next
	
					If !(At("</ns1:ITENS>",cValidXML) > 0)
						cMsgVldXML += STR0033 + "</ns1:ITENS>" + STR0034 + CRLF	//"Tag "###" nao encontrado"
					ElseIf ntAnt2 > At("</ns1:ITENS>",cValidXML)
						cMsgVldXML += STR0033 + "</ns1:ITENS>" + STR0035 + "</ns1:CodTransp>" + CRLF	//"Tag "###" devera vir depois da tag "
					EndIf

				Else		//XML não montado, pois a chave não foi encontrada no ponto de entrada
					cMsgVldXML += STR0036 + TMPDRP->(C7_NUM+C7_ITEM) + STR0037 + CRLF	//"Chave "###" nao encontrada no Ponto de Entrada LJDRPEP"
				
				EndIf

				If Empty(cMsgVldXML)		//Não retornou nenhuma ocorrência, o ponto de entrada retornou corretamente
					lPEPValid := .T.
					cXML += cValidXML
				Else
					ConOut(STR0030 + TMPDRP->(C7_NUM+C7_ITEM) + STR0031)	//"Modelo 12: XML da chave "###" esta invalido! Verifique as mensagens abaixo:"
					LjGrvLog(STR0017,STR0030 + TMPDRP->(C7_NUM+C7_ITEM) + STR0031,Nil)	//"Exportacao DRP Neogrid" //"Modelo 12: XML da chave "###" esta invalido! Verifique as mensagens abaixo:"
					ConOut(cMsgVldXML)
					LjGrvLog(STR0017,cMsgVldXML,Nil)	//"Exportacao DRP Neogrid"
					ConOut(STR0032+CRLF)		//"Fim da(s) mensagem(ns)"
					LjGrvLog(STR0017,STR0032,Nil)	//"Exportacao DRP Neogrid"	//"Fim da(s) mensagem(ns)"
				EndIf
			EndIf

			If !lPEPValid
				cXML+='<ns1:ITENS>'+CRLF
				cXML+='<ns1:ContrAlt>'+'A'+'</ns1:ContrAlt>'+CRLF
				cXML+='<ns1:CodPed>'+alltrim(TMPDRP->(C7_NUM+C7_ITEM+C7_PO_EIC))+'</ns1:CodPed>'+CRLF
				cXML+='<ns1:CodNeo>'+''+'</ns1:CodNeo>'+CRLF
				cXML+='<ns1:Emissao>'+alltrim(TMPDRP->C7_EMISSAO)+'</ns1:Emissao>'+CRLF
				cXML+='<ns1:Obs>'+''+'</ns1:Obs>'+CRLF
				cXML+='<ns1:IdDestino>'+Alltrim(Str(nCodNeoGrid))+'</ns1:IdDestino>'+CRLF
				cXML+='<ns1:CodItem>'+alltrim(TMPDRP->C7_PRODUTO)+'</ns1:CodItem>'+CRLF
				cXML+='<ns1:CodLocalD>'+alltrim(TMPDRP->C7_FILIAL+C7_LOCAL)+'</ns1:CodLocalD>'+CRLF
				cXML+='<ns1:DtMov>'+alltrim(TMPDRP->C7_DATPRF)+'</ns1:DtMov>'+CRLF
				cXML+='<ns1:QtdPed>'+alltrim(Transform(TMPDRP->C7_QUANT,"@E 9999999.999"))+'</ns1:QtdPed>'+CRLF
				cXML+='<ns1:QtdRec>'+alltrim(Transform(TMPDRP->C7_QUJE,"@E 9999999.999"))+'</ns1:QtdRec>'+CRLF
				cXML+='<ns1:IdOrigem>'+''+'</ns1:IdOrigem>'+CRLF
				cXML+='<ns1:CodItemOr>'+''+'</ns1:CodItemOr>'+CRLF
				cXML+='<ns1:CodLocaldOr>'+''+'</ns1:CodLocaldOr>'+CRLF
				cXML+='<ns1:DtMovOr>'+''+'</ns1:DtMovOr>'+CRLF
				cXML+='<ns1:QtdPedOr>'+'0,000'+'</ns1:QtdPedOr>'+CRLF
				cXML+='<ns1:QtdEntOr>'+'0,000'+'</ns1:QtdEntOr>'+CRLF
				cXML+='<ns1:DesLocal>'+alltrim(TMPDRP->(C7_FORNECE+C7_LOJA))+'</ns1:DesLocal>'+CRLF
				cXML+='<ns1:Status>'+'1'+'</ns1:Status>'+CRLF
				cXML+='<ns1:CodTransp>'+''+'</ns1:CodTransp>'+CRLF
				cXML+='</ns1:ITENS>'+CRLF
			EndIf
			
			//Fim Ponto de Entrada
			
			lItXml := .t.
			If (nContador % 1000 = 0) .OR. (nContador <= 3)	//Acima de 3, mando no LogLoja a cada 1000 leituras
				LjGrvLog(STR0017," Modelo 12: Linha de Pedidos Colocados "+"  XML  Chave:  "+ alltrim (C7_NUM+C7_ITEM+C7_PRODUTO)+ "  Contador:  " + cValToChar(nContador))
			EndIf
			nContador := nContador + 1
			cPesqChave+=TMPDRP->(C7_NUM+C7_ITEM)+","
			TmpDrp->(Dbskip())
    	End
		Lj7030Gr12(oTss,@cXml,cUrl,dData1,;
					@cPesqChave,nNeoCom,lItXml,.T.)
		TMPDRP->(dbCloseArea()) 
	Endif
	       
	// 13 Fornecedores
	// SA2
	// SA2 = D (ECC)
	If Alltrim(str(aParam[2])) $ '0|13'  
		If Select("TMPDRP") > 0
			TMPDRP->(dbCloseArea())
		EndIf	   
		nContador 	:= 0
		nValidador	:= 0  
		cQry:= "SELECT SA2.A2_FILIAL,SA2.A2_NOME,SA2.A2_COD,SA2.A2_LOJA,SA2.A2_GRUPO,SA2.A2_CONTATO,SA2.A2_TEL,SA2.A2_FAX,SA2.A2_EMAIL, "
		cQry+= " SA2.A2_END,SA2.A2_BAIRRO,SA2.A2_CEP,SA2.A2_EST,SA2.A2_MUN,SA2.A2_PAIS FROM "+ RetSqlName("SA2") + " SA2 " 
		cQry+= " WHERE "
		cQry+= " SA2.D_E_L_E_T_ = ' ' "
		cQry+= " AND A2_DRPEXP = '' "
		cQry+= " AND A2_FILTRF = '' "	//Não ir transferência entre filiais
		cQry+= " AND A2_CODADM = '' "	//Não ir códigos de administradora financeira
		cQry+= " AND A2_FILIAL = '"+xFilial("SA2")+"' "
		cQry+= "ORDER BY SA2.A2_COD,SA2.A2_LOJA "
	
 		cQry := ChangeQuery(cQry)

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )
    	dbSelectArea("TMPDRP")
    	TmpDrp->(Dbgotop())
    	cXML       := ''
    	lCabXml    := .F.
		lItXml     := .F.    	
    	While !(TmpDrp->(Eof()))  
    		//Não haverá repetições de código de fornecedor
    		//Estou passando como se fosse arquivo de fornecedores compartilhado sem ligações com alguma filial.
    		If Alltrim(TMPDRP->(A2_COD+A2_LOJA)) <> cAux 
	    		If (nContador % 150 = 0) .AND. len(cXML) > 900000	//Questão de performance (verificar a cada 150 leituras) e se o número de caracteres for superior a 900 mil.
	    			Lj7030Gr13(oTss,@cXml,cUrl,dData1,;
							nNeoCom,lItXml,.F.,nContador,;
							@nValidador)
	    		EndIf
				If !lCabXml
					cXML:='<?xml version="1.0" encoding="UTF-8"?>'+CRLF
					cXML+='<CADFOR xsi:noNamespaceSchemaLocation="tss_tc_fornecedor.xsd" xmlns:ns1="TotvsColabFonec" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+CRLF
					cXML+='<FORNEC>'+CRLF
					lCabXml:=.t.
				Endif
	                 // Validação dos campos obrigatórios para o envio do registro pelo XML
				cAux := alltrim(TMPDRP->(A2_COD+A2_LOJA))
				cXML+='<ns1:FORNECEDOR>'+CRLF
				cXML+='<ns1:Nome>'+alltrim(LjNoAccent(TMPDRP->A2_NOME))+'</ns1:Nome>'+CRLF
				cXML+='<ns1:Codigo>'+alltrim(TMPDRP->(A2_COD+A2_LOJA))+'</ns1:Codigo>'+CRLF
				cXML+='<ns1:Grupo1>'+alltrim(TMPDRP->A2_GRUPO)+'</ns1:Grupo1>'+CRLF
				cXML+='<ns1:Grupo2>'+alltrim(TMPDRP->A2_GRUPO)+'</ns1:Grupo2>'+CRLF
				cXML+='<ns1:Contato>'+alltrim(LjNoAccent(TMPDRP->A2_CONTATO))+'</ns1:Contato>'+CRLF
				cXML+='<ns1:Fone>'+alltrim(TMPDRP->A2_TEL)+'</ns1:Fone>'+CRLF
				cXML+='<ns1:Fax>'+alltrim(TMPDRP->A2_FAX)+'</ns1:Fax>'+CRLF
				cXML+='<ns1:Email>'+alltrim(LjNoAccent(TMPDRP->A2_EMAIL))+'</ns1:Email>'+CRLF
				cXML+='<ns1:End>'+alltrim(LjNoAccent(TMPDRP->A2_END))+'</ns1:End>'+CRLF
				cXML+='<ns1:CEP>'+alltrim(TMPDRP->A2_CEP)+'</ns1:CEP>'+CRLF
				cXML+='<ns1:UF>'+alltrim(TMPDRP->A2_EST)+'</ns1:UF>'+CRLF
				cXML+='<ns1:Cidade>'+alltrim(TMPDRP->A2_MUN)+'</ns1:Cidade>'+CRLF
				cXML+='<ns1:Pais>'+alltrim(TMPDRP->A2_PAIS)+'</ns1:Pais>'+CRLF
				cXML+='<ns1:CodExt>'+''+'</ns1:CodExt>'+CRLF
				cXML+='<ns1:IntExt>'+'0'+'</ns1:IntExt>'+CRLF
				cXML+='</ns1:FORNECEDOR>'+CRLF
				lItXml := .t.
				If (nContador % 1000 = 0) .OR. (nContador <= 3)	//Acima de 3, mando no LogLoja a cada 1000 leituras
					LjGrvLog(STR0017," Modelo 13: Fornecedores "+"  XML  Codigo/Loja:  "+ alltrim (TMPDRP->(A2_COD+A2_LOJA))+ "  Contador:  " + cValToChar(nContador))
				EndIf
				nContador := nContador + 1
			EndIf
			TmpDrp->(Dbskip())
		End
		Lj7030Gr13(oTss,@cXml,cUrl,dData1,;
				nNeoCom,lItXml,.T.,nContador,;
				@nValidador)
		TMPDRP->(dbCloseArea()) 
    Endif
End Sequence    

//Exclusão de temporários para modelo 6
If ( ValType(oTempTable) == "O" )
	oTempTable:Delete()
	FreeObj(oTempTable)
	oTempTable := Nil
EndIf

If lSched 
	Conout(STR0014) //"Finalizando Processo de Exportacao"
	LjGrvLog(STR0017,STR0014,Nil)	//"Exportacao DRP Neogrid" //"Finalizando Processo de Exportacao"
	Reset ENVIRONMENT
Endif
RestArea(cArea)                

Return Nil        


//----------------------------------------------------------
/*	 Envio do XML para o TSS
@author  	Carlos MOta
@version 	P11                                                                                             
@build		
@since 		23/07/2013
@return 	Nil											  */
//----------------------------------------------------------
Static Function LOJA7030A(oTss,nMod,cXML,cURL,dDataCorrente,lFimXML,lAcima1MB)  

Local lRet 		:= .T.							// Retorno lógico
Local cDescRet	:= ""							// Descrição do retorno
Local cPath      := GetNewPar("MV_LJNEOUT","\Client NeoGrid\bin\OUT\")	// Caminho do diretório de saída dos XMLs
Local cPathBK    := GetNewPar("MV_LJNEOBK","\Client NeoGrid\bin\OUT_BK\")	// Caminho do diretório de saída dos XMLs - Backup
Local nNeoCom    := GetNewPar("MV_LJNEOCM",1) // Tipo de comunicacao com a NeoGrid 1 - TSS 2 - EDI   
Local cFile      := ""							// Nome do arquivo 
Local cFileBK	:= ""							// Nome do arquivo - Backup
Local cFileResum    := ""							// Nome do arquivo - Resumo 
Local nHdlArq		:= 0							// Handle
Local nRetDir		:= 0							// Diretório de retorno
Local lMesmoArquivo := .F.							// Se for mesmo arquivo, simplesmente incluo novas informações no arquivo, sem excluir

Default dDataCorrente := dDataBase				// Caso não receba o parâmetro, pegar a data do dia
Default lFimXML	:= .F.							// Fim do XML
Default lAcima1MB := .F.							// Nova versão que monta XML acima de 1MB

If lAcima1MB
	If (nMod <> nModAnt)
		lMesmoArquivo := .F.
		nModAnt := nMod
	Else
		lMesmoArquivo := .T.
	EndIf
EndIf
    
Do case
	Case nNeoCom = 2 // Comunicacao via EDI
		cFile := ""
		If !ExistDir(cPath) 
		   nRetDir := MakeDir(cPath) // Cria diretorio na Raiz
		else
		   nRetDir := 0
		Endif
		If nRetDir = 0 //LJDIRECT(cPath,.f.)
			Do Case 
			   Case nMod = 4
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_itens"
			   	    cFileResum := "x_itens"
			   Case nMod = 5
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_skus"
			   	    cFileResum := "x_skus"
			   Case nMod = 6
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_origens"
			   	    cFileResum := "x_origens"
			   Case nMod = 7
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_local_estoque"
			   	    cFileResum := "x_local_estoque"
			   Case nMod = 8
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_movim_sku"
			   	    cFileResum := "x_movim_sku"
			   Case nMod = 9
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_movim_dfu"
			   	    cFileResum := "x_movim_dfu"
			   Case nMod = 10
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_eventos"
			   	    cFileResum := "x_eventos"
			   Case nMod = 12
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_lin_ped_colocado"
			   	    cFileResum := "x_lin_ped_colocado"
			   Case nMod = 13
			   	    cFile:= "x_" + StrZero(Year(dDataCorrente),4) + StrZero(Month(dDataCorrente),2) + StrZero(Day(dDataCorrente),2) + "_fornecedores"
			   	    cFileResum := "x_fornecedores"
	  		EndCase
			
			If lMesmoArquivo .AND. File(cPath + cFile+".XML")
				nHdlArq		:= fOpen(cPath + cFile + ".XML",FO_READWRITE)
			Else
				nHdlArq		:= fCreate(cPath + cFile + ".XML")
			EndIf
		    
		    If (nHdlArq < 0)
			    cDescRet := STR0008 //"Atencao, Falha na criação do XML"
				ConOut(STR0009 +  Alltrim(str(nMod)) + " "+cDescRet) //"Modelo "
				LjGrvLog(STR0017,STR0009 +  Alltrim(str(nMod)) + " "+cDescRet,Nil)	//"Exportacao DRP Neogrid" //"Modelo "
				Return{.f.,1}
			Endif
			If lMesmoArquivo
				FSeek(nHdlArq, 0, FS_END)         // Posiciona no fim do arquivo
			EndIf
			FWrite(nHdlArq,cXML)
			FClose(nHdlArq)
	        
		    If (lAcima1MB .AND. lFimXml) .OR. !lAcima1MB
		        If File(cPath+cFile+".XML")
			    	cDescRet := STR0010 + cFile + ".XML" //"Arquivo gerado : "
					ConOut(STR0009 +  Alltrim(str(nMod)) + " "+cDescRet) //"Modelo "
					LjGrvLog(STR0017,STR0009 +  Alltrim(str(nMod)) + " "+cDescRet,Nil)	//"Exportacao DRP Neogrid" //"Modelo "
		        	lRet := .t.
		        	If nNeoCom = 2
		        		oTss := 0
		        	EndIf
		        Else 
					cDescRet := STR0008 //"Atencao, Falha na criação do XML"
					ConOut(STR0009 +  Alltrim(str(nMod)) + " "+cDescRet) //"Modelo "
					LjGrvLog(STR0017,STR0009 +  Alltrim(str(nMod)) + " "+cDescRet,Nil)	//"Exportacao DRP Neogrid" //"Modelo "
					Return{.f.,1}
		        Endif
		    Else
		    	If nNeoCom = 2
		    		oTss := 0
		    	EndIf
		    EndIf
	        
			If .T.		        //Cópia de Backup
				If !ExistDir(cPathBK) 
				   nRetDir := MakeDir(cPathBK) // Cria diretorio na Raiz
				else
				   nRetDir := 0
				Endif
				If nRetDir = 0 //LJDIRECT(cPath,.f.)
		        	cFileBK := cFile + "_gerado_em_" + DTOS(Date())+"_"+StrTran(Time(),":","")
					nHdlArq  	:= fCreate(cPathBk + cFileBK + ".XML")
				    
				    If (nHdlArq < 0)
					    cDescRet := STR0027 //"Atencao, Falha na criacao do XML de Backup - arquivo "
						LjGrvLog(STR0017,STR0027 + cFileBK,Nil)	//"Atencao, Falha na criacao do XML de Backup - arquivo "
					Else
						FWrite(nHdlArq,cXML)
						FClose(nHdlArq)
					Endif
					
					//Montante
					cFileBK := cFileResum + "_total" + "_gerado_em_" + DTOS(Date())
					If File(cPathBK + cFileBK+".XML")
						nHdlArq		:= fOpen(cPathBK + cFileBK + ".XML",FO_READWRITE)
					Else
						nHdlArq		:= fCreate(cPathBK + cFileBK + ".XML")
					EndIf
				    If (nHdlArq < 0)
					    cDescRet := STR0027  //"Atencao, Falha na criacao do XML de Backup - arquivo "
						LjGrvLog(STR0017,STR0027 + cFileBK,Nil)	//"Atencao, Falha na criacao do XML de Backup - arquivo "
					Else 
						FSeek(nHdlArq, 0, FS_END)         // Posiciona no fim do arquivo
						FWrite(nHdlArq,cXML)
						FClose(nHdlArq)
					Endif
					
				EndIf
	        EndIf 
	        	
	    Else
			cDescRet := STR0011 //"Atencao, Falha na criação do Diretorio"
			ConOut(STR0009 +  Alltrim(str(nMod)) + " "+cDescRet) //"Modelo "
			LjGrvLog(STR0017,STR0009 +  Alltrim(str(nMod)) + " "+cDescRet,Nil)	//"Exportacao DRP Neogrid" //"Modelo "
			Return{.f.,1}
	    Endif
Endcase
Return {lRet,oTss}


//----------------------------------------------------------
/*	 Pesquisa de número de caracteres por letra desejada
@author  	
@version 	P12                                                                                             
@build		
@since 		22/12/2015
@return 	Nil											  */
//----------------------------------------------------------
Static Function LenCount(cString,cBusca)
Local nX := 0			//Contador
Local nResult := 0	//Variável que conta quantos cBusca tem no cString

For nX := 1 to Len(cString)
	If SubStr(cString,nX,Len(cBusca)) = cBusca
		nResult := nResult + 1
	EndIf
Next

Return nResult


//----------------------------------------------------------
/*	 Substituição de caracteres especiais, transformando em UTF-8 legível para XML
@author  	
@version 	P12                                                                                             
@build		
@since 		29/05/2017
@return 	Nil											  */
//----------------------------------------------------------
Static Function LjNoAccent(cAux)

cAux := StrTran(cAux,"&","E")		//Retirando o E comercial
cAux := StrTran(cAux,"<","")		//Retirando o "<"
cAux := StrTran(cAux,">","")		//Retirando o ">"
cAux := enCodeUtf8(noAcento(cAux)) 	//UTF-8

Return cAux



//----------------------------------------------------------
/*	 Gravação modelo 4 - Itens
@author  	
@version 	P11                                                                              
@build		
@since 		18/07/2017
@return 	lRet										  */
//----------------------------------------------------------
Static Function Lj7030Gr04(oTss,cXml,cUrl,dData1,;
							aFiliais,cPesqChave,cFwModeSB1,nNeoCom,;
							lItXml,	lFimXML)

Local lRet := .T.		//Retorno
Local cRet := ""
Local aRet := nil
Local nX	:= 0
Local aAreaAtu := {}
Local cProdAnt := ""

Default oTss := nil
Default cXml := ""
Default cUrl := ""
Default dData1 := Date()
Default aFiliais := {}
Default cPesqChave := ""
Default cFwModeSB1 := ""
Default nNeoCom := 2
Default lItXml := .T.
Default lFimXml := .F.

If lFimXML
	cXML+='  </ITEM>'+CRLF
	cXML+='</PRODUTO>'+CRLF
Endif 
// Verificação se o XML tem item
If lItXMl
	// Envio do XMl para o TSS   
	aRet :=  LOJA7030A(oTss,4,cXML,cURL,dData1,lFimXML,.T.)
	If Len(aRet) > 0
	   lRet := aRet[1]
	   oTSS := aRet[2]
	Else
	   lRet := .F.
	Endif
Else
	lRet := .f.
Endif
If Select("TMPDRP") > 0
	If lRet 
	aAreaAtu := GetArea()
		cRet := If(nNeoCom=1,oTss:OWSTOTVSCOLABREMESSADOCRESULT:OWSREMESSADOCRET:OWSDOCUMENTORET[1]:NSTATUS,oTss)
		If Valtype(cRet) = 'N' .and. cRet = 0
			cProdAnt := TmpDrp->B1_COD	
			TmpDrp->(Dbgotop())
    	    While !(TmpDrp->(Eof())) 
    	    	If At(TmpDrp->(B1_COD),cPesqChave) > 0
	    	    	If Substr(cFWModeSB1,3,1) = "E"  //Se for SB1 exclusivo            
						For nX := 1 to Len(aFiliais)	//Pesquiso todas as filiais aFiliais[nX][1]+SB5->B5_COD
							SB5->(DbSeek(aFiliais[nX][1]+TmpDrp->B1_COD)) //Preciso aplicar a gravação do mesmo produto para todas as filiais
							While !(SB5->(Eof())) .AND. SB5->B5_FILIAL+SB5->B5_COD = aFiliais[nX][1]+TmpDrp->B1_COD
								If Empty(SB5->B5_DRPEXP)  
									RecLock("SB5",.F.)
									SB5->B5_DRPEXP := DtoS(dData1)
									SB5->(MSUnlock())
								EndIf
								SB5->(DbSkip())
							EndDo
						Next
					Else
						//Else - SB1 compartilhado
			          IF SB5->(DbSeek(TmpDrp->(B1_FILIAL+B1_COD)))
							If Empty(SB5->B5_DRPEXP)  
								RecLock("SB5",.F.)
								SB5->B5_DRPEXP := DtoS(dData1)
								SB5->(MSUnlock())
							EndIf
			          Endif
					EndIf
				EndIf
				TmpDrp->(Dbskip())
    	    EndDo
    	    
    	    //Voltar posição do B1_COD
    	    //DbGoto para Query não funciona, deverá ser aplicado a pesquisa do ponto onde parou em Do/While
			TmpDrp->(Dbgotop())
    	    While !(TmpDrp->(Eof()))
    	    	If TmpDrp->B1_COD = cProdAnt
    	    		Exit
    	    	EndIf
    	    	TmpDrp->(DbSkip())
    	    EndDo 
    	    
		Endif 
	RestArea( aAreaAtu )
	Endif
EndIf

cXml := ""		//Limpa o campo XML
cPesqChave := ""
		
Return lRet


//----------------------------------------------------------
/*	 Gravação modelo 5 - SKU
@author  	
@version 	P11                                                                              
@build		
@since 		19/07/2017
@return 	lRet											  */
//----------------------------------------------------------
Static Function Lj7030Gr05(oTss,cXml,cUrl,dData1,;
							cPesqChave,nNeoCom,lItXml,lFimXML,;
							nContador,nValidador,aPrm)

Local lRet := .T.		//Retorno
Local cRet := ""
Local aRet := nil
Local cChaveAnt := ""

Default oTss := nil
Default cXml := ""
Default cUrl := ""
Default dData1 := Date()
Default cPesqChave := ""
Default nNeoCom := 2
Default lItXml := .T.
Default lFimXml := .F.
Default nContador := 0
Default nValidador := 0
Default aPrm := {}

If lFimXml
	cXML+='  </ITEM>'+CRLF
	cXML+='</LOCAL>'+CRLF
Endif 
// Verificação se o XML tem item
If lItXMl
   // Envio do XMl para o TSS   
	aRet :=  LOJA7030A(oTss,5,cXML,cURL,dData1,lFimXML,.T.)
	If Len(aRet) > 0
	   lRet := aRet[1]
	   oTSS := aRet[2]
	Else
	   lRet := .F.
	Endif
Else
	lRet := .f.
Endif
If Select("TMPDRP") > 0
	If lRet 
		cRet := If(nNeoCom=1,oTss:OWSTOTVSCOLABREMESSADOCRESULT:OWSREMESSADOCRET:OWSDOCUMENTORET[1]:NSTATUS,oTss)
		If Valtype(cRet) = 'N' .and. cRet = 0	
			cChaveAnt := TmpDrp->(B2_FILIAL+B2_COD+B2_LOCAL)
			//LOJA7030({aPrm[1],6,cEmp,cFilTrab,cPesqChave}) // Origem SKU
			TmpDrp->(Dbgotop())
    	    While !(TmpDrp->(Eof())) .AND. (nValidador < nContador)            
				If At(Rtrim(TmpDrp->(B2_COD))+"."+Alltrim(TMPDRP->(B2_FILIAL+B2_LOCAL)) + "|", cPesqChave) > 0	
					If SB2->(DbSeek(TmpDrp->(B2_FILIAL+B2_COD+B2_LOCAL)))
						nSaldoSB2 := SaldoSB2(.T.,,,,.T.)	//5º parâmetro - deve considerar o saldo em poder de terceiros
						If (nValidador % 1000 = 0) .OR. (nValidador <= 3)	//Acima de 3, mando no LogLoja a cada 1000 leituras
							LjGrvLog(STR0017," Modelo 5: Mov. Local de Estoque "+"  SYS  Produto:  "+ Rtrim (TMPDRP->B2_COD)+ "  Contador:  " + cValToChar(nValidador))
						EndIf
						RecLock("SB2",.F.)
						SB2->B2_DRSALDO := nSaldoSB2
						SB2->(MSUnlock())
						nValidador := nValidador + 1
					Endif
				EndIf
				TmpDrp->(Dbskip())
			End

    	    //Voltar posição do B2_FILIAL+B2_COD+B2_LOCAL
    	    //DbGoto para Query não funciona, deverá ser aplicado a pesquisa do ponto onde parou em Do/While
			TmpDrp->(Dbgotop())
    	    While !(TmpDrp->(Eof()))
    	    	If TmpDrp->(B2_FILIAL+B2_COD+B2_LOCAL) = cChaveAnt
    	    		Exit
    	    	EndIf
    	    	TmpDrp->(DbSkip())
    	    EndDo 
		Endif 
	Endif
EndIf

cXml := ""		//Limpa o campo XML
cPesqChave := ""
		
Return lRet


//----------------------------------------------------------
/*	 Gravação modelo 6 - Origens
@author  	
@version 	P11                                                                              
@build		
@since 		19/07/2017
@return 	lRet											  */
//----------------------------------------------------------
Static Function Lj7030Gr06(oTss,cXml,cUrl,dData1,;
							lItXml,lFimXML)

Local lRet := .T.		//Retorno
Local aRet := nil

Default oTss := nil
Default cXml := ""
Default cUrl := ""
Default dData1 := Date()
Default lItXml := .T.
Default lFimXml := .F.

If lFimXml
	cXML+='  </ITEM>'+CRLF
	cXML+='</ORIGEM>'+CRLF
Endif 
// Verificação se o XML tem item
If lItXMl
   // Envio do XMl para o TSS   
	aRet :=  LOJA7030A(oTss,6,cXML,cURL,dData1,lFimXML,.T.)
	If Len(aRet) > 0
	   lRet := aRet[1]
	   oTSS := aRet[2]
	Else
	   lRet := .F.
	Endif
Endif

cXml := ""		//Limpa o campo XML
		
Return lRet


//----------------------------------------------------------
/*	 Gravação modelo 8 - Movimentações SKU
@author  	
@version 	P11                                                                              
@build		
@since 		19/07/2017
@return 	lRet											  */
//----------------------------------------------------------
Static Function Lj7030Gr08(oTss,cXml,cUrl,dData1,;
							cPesqChave,nNeoCom,lItXml,lFimXML,;
							aPrm,cGetDB)

Local lRet := .T.		//Retorno
Local cRet := ""
Local aRet := nil
Local cPesq2Chave := ""

Default oTss := nil
Default cXml := ""
Default cUrl := ""
Default dData1 := Date()
Default cPesqChave := ""
Default nNeoCom := 2
Default lItXml := .T.
Default lFimXml := .F.
Default aPrm := {}
Default cGetDB := ""

If lFimXml
	cXML+='  </ITEM>'+CRLF
	cXML+='</MOVIMENTACAOSKU>'+CRLF
Endif 
// Verificação se o XML tem item
If lItXMl
	// Envio do XMl para o TSS   
	aRet :=  LOJA7030A(oTss,8,cXML,cURL,dData1,lFimXML,.T.)
	If Len(aRet) > 0
	   lRet := aRet[1]
	   oTSS := aRet[2]
	   If lRet 
			cRet := If(nNeoCom=1,oTss:OWSTOTVSCOLABREMESSADOCRESULT:OWSREMESSADOCRET:OWSDOCUMENTORET[1]:NSTATUS,oTss)
			If Valtype(cRet) = 'N' .and. cRet = 0
				//LOJA7030({aPrm[1],9,cEmp,cFilTrab,cPesqChave}) // Origem DFU

				If Right(cPesqChave,1) = ','		//Retiro a vírgula
					cPesqChave := Substr(cPesqChave,1,Len(cPesqChave)-1)
				EndIf
				cPesq2Chave := "'"+StrTran(cPesqChave,",","','")+"'"		//Para update em SQL
									
				// SD3 - Transferência entre armazéns - Requisição	
				cQry :=""
	   			cQry+= " UPDATE "+ RetSqlName("SD3") 
				cQry+= " SET D3_DRPEXP = '" +DtoS(dData1) +"' " 
				cQry+= " WHERE D3_DRPEXP = '' "
				cQry+= " AND (D3_EMISSAO = '"+ DtoS(dData1) + "') AND D3_TM >= '500' "		
				cQry+= " AND D3_COD+D3_FILIAL+D3_LOCAL IN ("+cPesq2Chave+") "
				cQry+= " AND D_E_L_E_T_ = ' ' "		
   			   
				TCSqlExec(cQry)
				TCSqlExec("COMMIT") 

				// SD3 - Transferência entre armazéns - Devolução	
				cQry :=""
	   			cQry+= " UPDATE "+ RetSqlName("SD3") 
				cQry+= " SET D3_DRPEXP = '" +DtoS(dData1) +"' " 
				cQry+= " WHERE D3_DRPEXP = '' "
				cQry+= " AND (D3_EMISSAO = '"+ DtoS(dData1) + "') AND D3_TM < '500' "		
				cQry+= " AND D3_COD+D3_FILIAL+D3_LOCAL IN ("+cPesq2Chave+") "
				cQry+= " AND D_E_L_E_T_ = ' ' "		
   			   
				TCSqlExec(cQry)
				TCSqlExec("COMMIT") 

				// SD1 - Devolução
				/* Transferir para o modelo 9
				cQry :=""
	   			cQry+= " UPDATE "+ RetSqlName("SD1")
				cQry+= " SET D1_DRPEXP = '" +DtoS(dData1) +"' "
				cQry+= "   FROM "+ RetSqlName("SD1") + " SD1 " 
				cQry+= "	INNER JOIN "+ RetSqlName("SF4") + " SF4 "
				cQry+= " ON SF4.F4_CODIGO = SD1.D1_TES "
				cQry+= "  WHERE SD1.D_E_L_E_T_ = ' ' "                              
				cQry+= " AND (SD1.D1_EMISSAO = '"+ Dtos(dData1) + "' ) "
				cQry+= " AND SD1.D1_TIPO = 'D' "		
				cQry+= " AND SF4.F4_TRANFIL <> '1' "		
				cQry+= " AND SD1.D1_DRPEXP = '' "
				If At("MSSQL",cGetDB) > 0
					cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD1.D1_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				ElseIf cGetDB == "DB2"
					cQry+= "	AND (LOCATE(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				Else
					cQry+= "	AND (INSTR(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				EndIf
				cQry+= " AND SD1.D1_COD+SD1.D1_FILIAL+SD1.D1_LOCAL IN ("+cPesq2Chave+") "
   			   
				TCSqlExec(cQry)
				TCSqlExec("COMMIT") 
				*/

				// SD1 - Devolução de transferência entre filiais
				cQry :=""
	   			cQry+= " UPDATE "+ RetSqlName("SD1")
				cQry+= " SET D1_DRPEXP = '" +DtoS(dData1) +"' " 
				cQry+= "   FROM "+ RetSqlName("SD1") + " SD1 " 
				cQry+= "	INNER JOIN "+ RetSqlName("SF4") + " SF4 "
				cQry+= " ON SF4.F4_CODIGO = SD1.D1_TES "
				cQry+= "  WHERE SD1.D_E_L_E_T_ = ' ' "                              
				cQry+= " AND (SD1.D1_EMISSAO = '"+ Dtos(dData1) + "' ) "
				cQry+= " AND SD1.D1_TIPO = 'N' "		
				cQry+= " AND SF4.F4_TRANFIL = '1' "		
				cQry+= " AND SD1.D1_DRPEXP = '' "
				If At("MSSQL",cGetDB) > 0
					cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD1.D1_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				ElseIf cGetDB == "DB2"
					cQry+= "	AND (LOCATE(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				Else
					cQry+= "	AND (INSTR(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				EndIf
				cQry+= " AND SD1.D1_COD+SD1.D1_FILIAL+SD1.D1_LOCAL IN ("+cPesq2Chave+") "
   			   
				TCSqlExec(cQry)
				TCSqlExec("COMMIT") 

				// SD2 - Transferência entre filiais
				cQry :=""
				cQry+= " UPDATE "+ RetSqlName("SD2") 
				cQry+= " SET D2_DRPEXP = '" +DtoS(dData1) +"' " 
				cQry+= "   FROM "+ RetSqlName("SD2") + " SD2 " 
				cQry+= " INNER JOIN "+ RetSqlName("SF4")+ " SF4 " 
				cQry+= " ON SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_CODIGO >= '500' " 
				cQry+= "	AND SF4.F4_TRANFIL = '1' AND SF4.D_E_L_E_T_ = ' ' " 
				cQry+= "  WHERE SD2.D_E_L_E_T_ = ' ' AND SD2.D2_DRPEXP = '' "
				cQry+= "    AND (SD2.D2_EMISSAO = '"+ Dtos(dData1) + "') "
				cQry+= "    AND D2_TIPO = 'N' "
				If At("MSSQL",cGetDB) > 0
					cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD2.D2_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				ElseIf cGetDB == "DB2"
					cQry+= "	AND (LOCATE(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				Else
					cQry+= "	AND (INSTR(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				EndIf
				cQry+= " AND SD2.D2_COD+SD2.D2_FILIAL+SD2.D2_LOCAL IN ("+cPesq2Chave+") "
		   			   
				TCSqlExec(cQry)
				TCSqlExec("COMMIT")

			Endif      
		Endif 
	Else
		lRet := .F.
	Endif
Else
	lRet := .f.
Endif

cXml := ""		//Limpa o campo XML
cPesqChave := ""
		
Return lRet



//----------------------------------------------------------
/*	 Gravação modelo 9 - Movimentações DFU
@author  	
@version 	P11                                                                              
@build		
@since 		19/07/2017
@return 	lRet										 */
//----------------------------------------------------------
Static Function Lj7030Gr09(oTss,cXml,cUrl,dData1,;
							cPesqChave,nNeoCom,lItXml,lFimXML,;
							cGetDB)

Local lRet := .T.		//Retorno
Local cRet := ""
Local aRet := nil
Local cPesq2Chave := ""

Default oTss := nil
Default cXml := ""
Default cUrl := ""
Default dData1 := Date()
Default cPesqChave := ""
Default nNeoCom := 2
Default lItXml := .T.
Default lFimXml := .F.
Default cGetDB := ""

If lFimXml
	cXML+='  </ITEM>'+CRLF
	cXML+='</MOVIMENTACAODFU>'+CRLF
Endif 
// Verificação se o XML tem item
If lItXMl
	// Envio do XMl para o TSS   
	aRet :=  LOJA7030A(oTss,9,cXML,cURL,dData1,lFimXML)
	If Len(aRet) > 0
		lRet := aRet[1]
		oTSS := aRet[2]
		If lRet 
			cRet := If(nNeoCom=1,oTss:OWSTOTVSCOLABREMESSADOCRESULT:OWSREMESSADOCRET:OWSDOCUMENTORET[1]:NSTATUS,oTss)
			If Valtype(cRet) = 'N' .and. cRet = 0	

				If Right(cPesqChave,1) = ','		//Retiro a vírgula
					cPesqChave := Substr(cPesqChave,1,Len(cPesqChave)-1)
				EndIf
				cPesq2Chave := "'"+StrTran(cPesqChave,",","','")+"'"		//Para update em SQL

				// Vendas
				cQry :=""
				cQry+= " UPDATE "+ RetSqlName("SD2") 
				cQry+= " SET D2_DRPEXP = '" +DtoS(dData1) +"' " 
				cQry+= "   FROM "+ RetSqlName("SD2") + " SD2 " 
				cQry+= " INNER JOIN "+ RetSqlName("SF4")+ " SF4 " 
				cQry+= " ON SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_CODIGO >= '500' " 
				cQry+= "	AND SF4.F4_DUPLIC = 'S' AND SF4.F4_TRANFIL <> '1' AND SF4.D_E_L_E_T_ = ' ' " 
				cQry+= "  WHERE SD2.D_E_L_E_T_ = ' ' AND SD2.D2_DRPEXP = '' "
				cQry+= "    AND (SD2.D2_EMISSAO = '"+ Dtos(dData1) + "') "
				cQry+= "    AND D2_TIPO = 'N' "
				If At("MSSQL",cGetDB) > 0
					cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD2.D2_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				ElseIf cGetDB == "DB2"
					cQry+= "	AND (LOCATE(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				Else
					cQry+= "	AND (INSTR(RTRIM(SD2.D2_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				EndIf
				cQry+= " AND SD2.D2_COD+SD2.D2_FILIAL+SD2.D2_LOCAL IN ("+cPesq2Chave+") "
		   			   
				TCSqlExec(cQry)
				TCSqlExec("COMMIT")

				// SD1 - Devolução
				cQry :=""
	   			cQry+= " UPDATE "+ RetSqlName("SD1")
				cQry+= " SET D1_DRPEXP = '" +DtoS(dData1) +"' "
				cQry+= "   FROM "+ RetSqlName("SD1") + " SD1 " 
				cQry+= "	INNER JOIN "+ RetSqlName("SF4") + " SF4 "
				cQry+= " ON SF4.F4_CODIGO = SD1.D1_TES "
				cQry+= "  WHERE SD1.D_E_L_E_T_ = ' ' "                              
				cQry+= " AND (SD1.D1_EMISSAO = '"+ Dtos(dData1) + "' ) "
				cQry+= " AND SD1.D1_TIPO = 'D' "		
				cQry+= " AND SF4.F4_TRANFIL <> '1' "		
				cQry+= " AND SD1.D1_DRPEXP = '' "
				If At("MSSQL",cGetDB) > 0
					cQry+= "	AND (CHARINDEX(RTRIM(SF4.F4_FILIAL),RTRIM(SD1.D1_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				ElseIf cGetDB == "DB2"
					cQry+= "	AND (LOCATE(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				Else
					cQry+= "	AND (INSTR(RTRIM(SD1.D1_FILIAL),RTRIM(SF4.F4_FILIAL))>0 OR SF4.F4_FILIAL = '')"
				EndIf
				cQry+= " AND SD1.D1_COD+SD1.D1_FILIAL+SD1.D1_LOCAL IN ("+cPesq2Chave+") "
   			   
				TCSqlExec(cQry)
				TCSqlExec("COMMIT") 
			Endif        	   
		Endif
	Else
		lRet := .F.
	Endif
Else
	lRet := .f.
Endif

cXml := ""		//Limpa o campo XML
cPesqChave := ""
		
Return lRet


//----------------------------------------------------------
/*	 Gravação modelo 12 - Linha de Pedidos Colocados
@author  	
@version 	P11                                                                              
@build		
@since 		19/07/2017
@return 	lRet										  */
//----------------------------------------------------------
Static Function Lj7030Gr12(oTss,cXml,cUrl,dData1,;
							cPesqChave,nNeoCom,lItXml,lFimXML)
						
Local lRet := .T.		//Retorno
Local cRet := ""
Local aRet := nil
Local cPesq2Chave := ""

Default oTss := nil
Default cXml := ""
Default cUrl := ""
Default dData1 := Date()
Default cPesqChave := ""
Default nNeoCom := 2
Default lItXml := .T.
Default lFimXml := .F.

If lFimXml
	cXML+='  </ITEM>'+CRLF
	cXML+='</PDCOMPRA>'+CRLF
Endif 
// Verificação se o XML tem item C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN 
If lItXMl
	// Envio do XMl para o TSS   
	aRet :=  LOJA7030A(oTss,12,cXML,cURL,dData1,lFimXML,.T.)
	If Len(aRet) > 0
	   lRet := aRet[1]
	   oTSS := aRet[2]
		If lRet 
			cRet := If(nNeoCom=1,oTss:OWSTOTVSCOLABREMESSADOCRESULT:OWSREMESSADOCRET:OWSDOCUMENTORET[1]:NSTATUS,oTss)
			If Valtype(cRet) = 'N' .and. cRet = 0
				If Right(cPesqChave,1) = ','		//Retiro a vírgula
					cPesqChave := Substr(cPesqChave,1,Len(cPesqChave)-1)
				EndIf
				cPesq2Chave := "'"+StrTran(cPesqChave,",","','")+"'"		//Para update em SQL
				cQry :=""
				cQry+= " UPDATE "+ RetSqlName("SC7") 
				cQry+= " SET C7_DRPEXP = '" +DtoS(dData1) +"' " 
				cQry+= " WHERE D_E_L_E_T_ = ' ' "
				cQry+= " AND C7_QUJE < C7_QUANT "
				cQry+= " AND (NOT C7_ORIGEM = 'LOJA7033') AND C7_DRPEXP = '' "
				cQry+= " AND (C7_EMISSAO = '"+ Dtos(dData1) + "') "
				cQry+= " AND C7_NUM+C7_ITEM+C7_PRODUTO IN (" + cPesq2Chave + ") "
		   			   
				TCSqlExec(cQry)
				TCSqlExec("COMMIT")
	      Endif        	   
	   Endif
	Else
	   lRet := .F.
	Endif
Else
	lRet := .f.
Endif

cXml := ""		//Limpa o campo XML
cPesqChave := ""
		
Return lRet


//----------------------------------------------------------
/*	 Gravação modelo 13 - Fornecedores
@author  	
@version 	P11                                                                              
@build		
@since 		19/07/2017
@return 	lRet										  */
//----------------------------------------------------------
Static Function Lj7030Gr13(oTss,cXml,cUrl,dData1,;
							nNeoCom,lItXml,lFimXML,nContador,;
							nValidador)
						
Local lRet := .T.		//Retorno
Local cRet := ""
Local aRet := nil
Local cChaveAnt := ""

Default oTss := nil
Default cXml := ""
Default cUrl := ""
Default dData1 := Date()
Default nNeoCom := 2
Default lItXml := .T.
Default lFimXml := .F.
Default nContador := 0
Default nValidador := 0

If lFimXml
	cXML+=' </FORNEC>'+CRLF
	cXML+='</CADFOR>'+CRLF
Endif 
// Verificação se o XML tem item
If lItXMl
	// Envio do XMl para o TSS   
	aRet :=  LOJA7030A(oTss,13,cXML,cURL,dData1,lFimXML,.T.)
	If Len(aRet) > 0
		lRet := aRet[1]
		oTSS := aRet[2]
	Else
		lRet := .F.
	Endif
Else
	lRet := .f.
Endif
If Select("TMPDRP") > 0
	If lRet 
		cRet := If(nNeoCom=1,oTss:OWSTOTVSCOLABREMESSADOCRESULT:OWSREMESSADOCRET:OWSDOCUMENTORET[1]:NSTATUS,oTss)
		If Valtype(cRet) = 'N' .and. cRet = 0	
			cChaveAnt := TmpDrp->(A2_FILIAL+A2_COD+A2_LOJA)	
			TmpDrp->(Dbgotop())
    	    While !(TmpDrp->(Eof()))            
				If nValidador < nContador
					IF SA2->(DbSeek(TmpDrp->(A2_FILIAL+A2_COD+A2_LOJA)))
						RecLock("SA2",.F.)
						SA2->A2_DRPEXP := DtoS(dData1)
						SA2->(MSUnlock())
					Endif
					If (nValidador % 1000 = 0) .OR. (nValidador <= 3)	//Acima de 3, mando no LogLoja a cada 1000 leituras
						LjGrvLog(STR0017," Modelo 13: Fornecedores "+"  SYS  Produto:  "+ alltrim (TMPDRP->A2_COD)+ "  Contador:  " + cValToChar(nValidador))
					EndIf
					nValidador := nValidador + 1
				EndIf
				TmpDrp->(Dbskip())
		    End
		Endif 

	    //Voltar posição do A2_FILIAL+A2_COD+A2_LOJA
	    //DbGoto para Query não funciona, deverá ser aplicado a pesquisa do ponto onde parou em Do/While
		TmpDrp->(Dbgotop())
	    While !(TmpDrp->(Eof()))
	    	If TmpDrp->(A2_FILIAL+A2_COD+A2_LOJA) = cChaveAnt
	    		Exit
	    	EndIf
	    	TmpDrp->(DbSkip())
	    EndDo 
	    
	Endif
EndIf

cXml := ""		//Limpa o campo XML
		
Return lRet
										

//----------------------------------------------------------
/*	 Validação do XML do Ponto de Entrada - 
@param		nt1   		: Num. Posição inicial do XML
@param		cTagIni		: Nome da Tag inicial
@param		nt2			: Num. Posição Final do XML
@param		cTagFim		: Nome da Tag Final
@param		ntAnt1 		: Num. Posição inicial da tag anterior do XML
@param		cTagIni		: Nome da Tag anterior inicial
@param		ntAnt2		: Num. Posição Final da tag anterior do XML
@param		cTagFim		: Nome da Tag anterior Final
@author  	
@version 	P11                                                                              
@build		
@since 		06/09/2017
@return 	cRet										  */
//----------------------------------------------------------
Static Function Lj7030VlP(nt1,cTagIni,nt2,cTagFim,;
						   ntAnt1,cTagAntIni,ntAnt2,cTagAntFim)

Local cRet := ""

If !(nt1 > 0)
	cRet += STR0033 + cTagIni + STR0034 + CRLF		//"Tag"###" nao encontrado"
EndIf
If !(nt2 > 0)
	cRet += STR0033 + cTagFim + STR0034 + CRLF		//"Tag"###" nao encontrado"
EndIf
If !(nt2 > nt1)
	cRet += STR0033 + cTagFim + STR0035 + cTagIni + CRLF	//"Tag"###" devera vir depois da tag "
EndIf
If !Empty(cTagIni) .AND. !Empty(cTagFim)
	If !(nt1 > ntAnt1)
		cRet += STR0033 + cTagIni + STR0035 + cTagAntIni + CRLF		//"Tag"###" devera vir depois da tag "
	EndIf
	If !(nt2 > ntAnt2)
		cRet += STR0033 + cTagFim + STR0035 + cTagAntFim + CRLF		//"Tag"###" devera vir depois da tag "
	EndIf
EndIf

Return cRet
