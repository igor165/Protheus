#INCLUDE "LOJA303.ch"
#INCLUDE "Protheus.ch"

#DEFINE PACOTE_PRODUTO 		"0000001"  //Codigo do pacote de PRODUTOS
#DEFINE PACOTE_PRECO   		"0000002"  //Codigo do pacote de PRECOS
#DEFINE PACOTE_DESCONTO		"0000003"  //Codigo do pacote de REGRA DE DESCONTOS

#DEFINE ACAO_ATUALIZADADOS	"0000001"  //Codigo da acao de atualizacao de dados
#DEFINE ACAO_IMPETIQUETAS	"0000002"  //Codigo da acao de impressao de etiquetas
#DEFINE ACAO_GERACARGA		"0000003"  //Codigo da acao de geracao de cargas
#DEFINE ACAO_GERTEC			"0000004"  //Codigo da acao de geracao dos arquivos GERTEC

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse ณPainelPrecificacaoบ Autor ณ  Vendas Clientes   บ Data ณ  12/10/10   บฑฑ
ฑฑฬอออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.  ณClasse de acesso aos lotes do painel de precificacao de produtos    บฑฑ
ฑฑศอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class PainelPrecificacao

	Data cNroLote                                //Variavel que armazena o Numero do Lote
	Data dDataLote                               //Variavel que armazena a Data do Lote
	Data cTipoPacote							 //Variavel que armazena o Tipo do Pacote(Produto, Manutencao de Precos ou Regra de Desconto)
	Data cAcaoPacote                             //Variavel que armazena a Acao do Pacote
	Data aPacotes                                //Array que armazena os pacotes a serem criados
	Data aAcoes                                  //Array que armazena as acoes dos pacotes
		
	Method New() Constructor					//Instacia o OBJETO com o lote da data informada

	Method Lj3Lote()							//Cria ou Retorna o lote da data informada
	Method Lj3PacPrec()							//Adiciona um pacote do tipo ATUALIZACAO DE PRECOS ao lote da data
	Method Lj3ExcPrec()                         //Exclui uma acao/pacote/lote referente a ATUALIZACAO DE PRECOS
	Method Lj3PacProd()							//Adiciona um pacote do tipo ATUALIZACAO DE PRODUTOS ao lote da data
	Method Lj3ExcProd()							//Exclui uma acao/pacote/lote referente ATUALIZACAO DE PRODUTOS 
	Method Lj3PacRDes()							//Adiciona um pacote do tipo ATUALIZACAO DE REGRA DE DESCONTOS ao lote da data
	Method Lj3ExcRDes()							//Exclui uma acao/pacote/lote do tipo ATUALIZACAO DE REGRA DE DESCONTOS
	Method Lj3AcaoxPacote()						//Adiciona as ACOES relacionadas ao tipo do pacote
	Method Lj3LibLote()							//Libera um LOTE para que JOB via Schedulle processe suas acoes
	Method Lj3RetPacotes()						//Metodo que retorna vetor com os pacotes, tipos do pacote e status do lote
	Method Lj3RetAcoes()						//Metodo que retorna vetor com as acoes e seus respectivos status de um pacote	
	Method Lj3LibAcao()							//Libera uma acao especifica de um pacote do lote           
	Method Lj3ExecAcao()						//Flega uma ACAO como executada
	Method Lj3PacStatus()						//Metodo INTERNO que libera um lote conforme acao em EXECUCAO
	Method NovoPacote()							//Metodo INTERNO que grava os registros na tabela de PACOTES
	Method GetNroLote()							//Metodo de retorno do numero do lote do objeto
	Method AcaoPendente()						//Metodo INTERNO que retorna .T. se existe uma acao de do tipo informado como parametro pendente para execucao
	Method ExecutaAcao()						//Metodo INTERNO que atualiza o FLAG de status de um tipo de acao dos lotes pendentes
	Method Lj3AtuDados()						//Metodo que retorna .T. se houver acoes do tipo ATUALIZACAO DE DADOS (pacote manutencao de preco) liberadas para processar
	Method Lj3ImpEtiquetas()					//Metodo que retorna .T. se houver acoes do tipo IMPRESSAO DE ETIQUETAS (pacotes manutencao de preco, produto e regra de desconto) liberadas para processar
	Method Lj3GerarCarga()						//Metodo que retorna .T. se houver acoes do tipo GERAR CARGA (pacotes manutencao de preco, produto e regra de desconto) liberadas para processar
	Method Lj3Gertec()							//Metodo que retorna .T. se houver acoes do tipo GERAR ARQUIVO GERTEC  (pacotes manutencao de preco, produto e regra de desconto) liberadas para processar
	Method Lj3ExecCarga()						//Metodo que atualiza o status das acoes do tipo GERACAO DE CARGA como executados (.T.) ou falha (.F.)
	Method Lj3ExecEtiquetas()					//Metodo que atualiza o status das acoes do tipo IMPRESSAO DE ETIQUETAS como executados (.T.) ou falha (.F.)
	Method Lj3ExecGertec()						//Metodo que atualiza o status das acoes do tipo GERAR ARQUIVO GERTEC como executados (.T.) ou falha (.F.)
	Method Lj3ExecAtuDados()					//Metodo que atualiza o status das acoes do tipo ATUALIZACAO DE DADOS como executados (.T.) ou falha (.F.)

	Method Lj3CatRegDesc()						//Metodo que retorna a categoria do produto na regra de desconto
	Method Lj3CancImpEtiquetas()                //Metodo que efetua o cancelamento da impressใo antecipada
	Method Lj3ChecaProduto()             	    //Metodo que checa se o pacote de produtos pode ou nao ser criado
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodoณNew บAutor  ณVendas Clientes     บ Data ณ  20/09/10   บฑฑ
ฑฑฬออออออุออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. ณMetodo construtor, que instacia o objeto para acesso  บฑฑ
ฑฑบ      ณaos pacotes                                           บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(_dDataLote) Class PainelPrecificacao

	Default _dDataLote := dDataBase               //Variavel que armazena a data do dia para a criacao do Lote
	
	Self:cNroLote    := ""
	Self:cTipoPacote := ""
	Self:cAcaoPacote := ""
	Self:dDataLote   := _dDataLote
	Self:aPacotes    := {}
	Self:aAcoes      := {}
	
Return Self
                                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ  Lj3Lote  บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que adiciona um lote a data informada                    บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    
Method Lj3Lote(_dDataLote) Class PainelPrecificacao

	Default _dDataLote := dDataBase				  //Variavel que armazena a data do dia para a criacao do Lote
	Self:dDataLote     := _dDataLote
	
	DbSelectArea("MBE")
	MBE->(DbSetOrder(2))
	If !MBE->(DbSeek(xFilial("MBE")+DTOS(Self:dDataLote) ))
		MBE->(DbSetOrder(1))
		
		While .T.
			Self:cNroLote := GetSXENum("MBE","MBE_CODIGO") //Gera numero sequencial para o lote
			
			If MBE->(DbSeek(xFilial("MBE")+Self:cNroLote ))
				ConfirmSX8()
				Loop
			Else
				ConfirmSX8()
				Exit
			EndIf
		End
		
		//Cria o Lote para a data
		MBE->(RecLock("MBE",.T.))
		MBE->MBE_FILIAL	:= xFilial("MBE")
		MBE->MBE_CODIGO	:= Self:cNroLote
		MBE->MBE_DATA	:= Self:dDataLote
		MBE->MBE_STATUS	:= "1" 	//Lote em Aberto
		MBE->(MsUnlock())
	Else
		Self:cNroLote := MBE->MBE_CODIGO
	EndIf
	
Return(Self:cNroLote)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3PacPrec บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que adiciona um novo pacote de ATUALIZACAO PRECOS ao LOTEบฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3PacPrec(dDataPacote,cFilPacote,cTabPacote) Class PainelPrecificacao

	Local cIDPacote := ""           // Variaval que armazena o ID do pacote 
	
	Default dDataPacote		:= dDataBase
	Default cFilPacote		:= ""  
	Default cTabPacote		:= ""

	//Cria o Lote ou recupera o ja existente para a data do pacote
	If Self:cNroLote == Nil .OR. EMPTY(Self:cNroLote)
		Self:Lj3Lote(dDataPacote)
		
		If Self:cNroLote == Nil
			Return(.F.)
		EndIf
	EndIf
	
	//Adiciona um pacote
	cIDPacote := Self:NovoPacote(PACOTE_PRECO,dDataPacote,cFilPacote,cTabPacote)

	//Cria as Acoes associadas ao tipo do Pacote ATUALIZACAO DE PRECOS
	If  !EMPTY(cIDPacote)
		Self:Lj3AcaoxPacote(PACOTE_PRECO,cFilPacote,cTabPacote,cIDPacote,dDataPacote)
		
		//Adiciona na propriedade aPacotes
		AAdd(Self:aPacotes,{cIDPacote,PACOTE_PRECO,"1"})
	EndIf
	
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3PacProd บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que adiciona um novo pacote de ATUALIZACAO DE PRODUTOS   บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/        
Method Lj3PacProd(dDataPacote,cFilPacote,cProdPacote) Class PainelPrecificacao

	Local cIDPacote := ""			// Variaval que armazena o ID do pacote
    Local aCriaPac  := {}   
    
   	Default dDataPacote		:= dDataBase
	Default cFilPacote		:= ""  
	Default cProdPacote		:= ""
	
	aCriaPac  := {,DTOS(dDataPacote),.T.}                                   
    
    While aCriaPac[3] 
		dDataPacote := STOD(aCriaPac[2])
    	aCriaPac := {}
    	aCriaPac := aClone(Self:Lj3ChecaProduto(dDataPacote,cFilPacote,cProdPacote))
    End
    
    dDataPacote := STOD(aCriaPac[2])
    
    If aCriaPac[1]

		//Cria o Lote ou recupera o ja existente para a data do pacote
		If Self:cNroLote == Nil .OR. EMPTY(Self:cNroLote)
			
			Self:Lj3Lote(dDataPacote)
			
			If Self:cNroLote == Nil
				Return(.F.)
			EndIf

		EndIf
		
		//Adiciona um pacote
		cIDPacote := Self:NovoPacote(PACOTE_PRODUTO,dDataPacote,cFilPacote,cProdPacote)
		
		//Cria as Acoes associadas ao tipo do Pacote ATUALIZACAO DE PRODUTOS (DADOS CADASTRAIS)
		If  !EMPTY(cIDPacote)
			Self:Lj3AcaoxPacote(PACOTE_PRODUTO,cFilPacote,cProdPacote,cIDPacote,dDataPacote)
			
			//Adiciona na propriedade aPacotes
			AAdd(Self:aPacotes,{cIDPacote,PACOTE_PRODUTO,"1"})
		EndIf
		
	EndIf
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3PacRDes บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que adiciona um novo pacote de ATUALIZACAO DE DESCONTOS  บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3PacRDes(dDataIniPac,dDataFimPac,cFilPacote,cRegraPacote) Class PainelPrecificacao

	Local cIDPacote   := ""                             // Variaval que armazena o ID do pacote
	Local dDataPacote := ""                             // Variaval que armazena a data do pacote
	Local aPacote     := {}						        // Array que armazena as duas datas dos lotes a serem criados
	Local nCount      := 0                              // Variavel contador do For         
	
   	Default dDataIniPac		:= dDataBase
  	Default dDataFimPac		:= dDataBase
	Default cFilPacote		:= ""  
	Default cRegraPacote	:= "" 
	
	aPacote := {dDataIniPac,dDataFimPac}
	
	For nCount := 1 to Len(aPacote)
		
		dDataPacote := aPacote[nCount]
		
		//Cria o Lote ou recupera o ja existente para a data do pacote
		If Self:cNroLote == Nil .OR. EMPTY(Self:cNroLote)
			Self:Lj3Lote(dDataPacote)
			
			If Self:cNroLote == Nil
				Return(.F.)
			EndIf
		EndIf
		
		//Adiciona um pacote
		cIDPacote := Self:NovoPacote(PACOTE_DESCONTO,dDataPacote,cFilPacote,cRegraPacote)
		
		//Cria as Acoes associadas ao tipo do Pacote ATUALIZACAO DE REGRAS DE DESCONTOS
		If  !EMPTY(cIDPacote)
			Self:Lj3AcaoxPacote(PACOTE_DESCONTO,cFilPacote,cRegraPacote,cIDPacote,dDataPacote)
			
			//Adiciona na propriedade aPacotes
			AAdd(Self:aPacotes,{cIDPacote,PACOTE_DESCONTO,"1"})
		EndIf
		
		dDataPacote := ""
		Self:cNroLote := ""

	Next nCount
		
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณNovoPacote บAutor  ณ  Vendas Clientes   บ Data ณ  20/11/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que adiciona um pacote ao LOTE                           บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method NovoPacote(cTipoPacote,dDataPacote,cFilPacote,cProdPacote) Class PainelPrecificacao

	Local cIDPacote := ""		// Variaval que armazena o ID do pacote
	
   	Default dDataPacote		:= dDataBase
  	Default cTipoPacote		:= ""
	Default cFilPacote		:= ""  
	Default cProdPacote		:= "" 
	
	// Checa se ja existe o pacote do produto criado para a data especifica
	If cTipoPacote == PACOTE_PRODUTO
		DbSelectArea("MBA")
		DbSetOrder(4)
		If MBA->(DbSeek(xFilial("MBA")+Self:cNroLote+cTipoPacote+cFilPacote+cProdPacote))
			MsgAlert(STR0001,STR0002) //"Pacote de produtos jแ existe no Painel de Gestใo para esta data."###"Painel nใo atualizado."
			Return(cIDPacote)
		EndIf
	EndIf
	
	// Checa se ja existe o pacote de manutencao de precos(publicacao) criado para a data especifica
	If cTipoPacote == PACOTE_PRECO
		DbSelectArea("MBA")
		DbSetOrder(5)
		If MBA->(DbSeek(xFilial("MBA")+Self:cNroLote+cTipoPacote+cFilPacote+cProdPacote))
			MsgAlert(STR0003,STR0002) //"Pacote de manuten็ใo de pre็os jแ existe no Painel de Gestใo para esta data."###"Painel nใo atualizado."
			Return(cIDPacote)
		EndIf
	EndIf
	
	// Checa se ja existe a regra de desconto criada para a data especifica
	If cTipoPacote == PACOTE_DESCONTO
		DbSelectArea("MBA")
		DbSetOrder(6)
		If MBA->(DbSeek(xFilial("MBA")+Self:cNroLote+cTipoPacote+cFilPacote+cProdPacote))
			MsgAlert(STR0004,STR0002) //"Pacote de regra de desconto jแ existe no Painel de Gestใo para esta data."###"Painel nใo atualizado."
			Return(cIDPacote)
		EndIf
	EndIf
	
	// Gera numero sequencial para amarrar pacotes x acoes do lote
	DbSelectArea("MB9")
	cIDPacote := GetSXENum("MB9","MB9_ID")
	ConfirmSX8()
	
	//Adiciona um novo pacote ao LOTE
	DbSelectArea("MB9")
	MB9->(DbSetOrder(1))
	MB9->(RecLock("MB9",.T.))
	MB9->MB9_FILIAL	:= xFilial("MB9")
	MB9->MB9_BECOD	:= Self:cNroLote
	MB9->MB9_BBCOD	:= cTipoPacote
	MB9->MB9_DATA	:= dDataPacote
	MB9->MB9_STATUS	:= "1"        //Em Liberacao
	MB9->MB9_ID		:= cIDPacote
	MB9->(MsUnlock())
		
Return(cIDPacote)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3AcaoxPacoteบAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que adiciona as acoes correspondentes ao tipo do pacote     บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3AcaoxPacote(cAcaoPacote,cFilPacote,cComplemento,cIDPacote,dDataPacote) Class PainelPrecificacao

	Local nSeqMBA := 0         // Variavel que armazena o sequencial na tabela MBA
	
	Default cAcaoPacote 	:= ""  			// Variavel que armazena a acao do pacote
   	Default dDataPacote		:= dDataBase
  	Default cFilPacote		:= ""
	Default cComplemento	:= ""  
	Default cIDPacote		:= "" 
	
	//Gera as Acoes previstas para o tipo do pacote conforme amarracao na interface Cadastro de Pacotes x Acoes (LOJA077)
	DbSelectArea("MBC")
	MBC->(DbSetOrder(1))
	MBC->(DbSeek(xFilial("MBC")+cAcaoPacote ))
	While MBC->(!Eof()) .AND. MBC->MBC_FILIAL + MBC->MBC_BBCOD == xFilial("MBC")+cAcaoPacote
		nSeqMBA++
		
		DbSelectArea("MBA")
		MBA->(RecLock("MBA",.T.))
		MBA->MBA_FILIAL	:= xFilial("MBA")
		MBA->MBA_BECOD	:= Self:cNroLote
		MBA->MBA_BBCOD	:= cAcaoPacote
		MBA->MBA_BDCOD	:= MBC->MBC_BDCOD
		MBA->MBA_CODIGO	:= StrZero(nSeqMBA,18)
		MBA->MBA_DTPAC	:= dDataPacote
		MBA->MBA_DATA	:= DATE()
		MBA->MBA_HORA	:= TIME()
		MBA->MBA_USBAIX	:= CUSERNAME
		
		If cAcaoPacote == PACOTE_PRECO //Manutencao de Preco
			MBA->MBA_FILTAB	:= cFilPacote
			MBA->MBA_CODTAB	:= cComplemento
		ElseIf cAcaoPacote == PACOTE_PRODUTO //Manutencao Cadastro de Produto
			MBA->MBA_CODPRO	:= cComplemento
			MBA->MBA_FILPRO	:= cFilPacote
		ElseIf cAcaoPacote == PACOTE_DESCONTO //Regra de Desconto
			MBA->MBA_FILREG	:= cFilPacote
			MBA->MBA_CODREG	:= cComplemento
		EndIf
		
		MBA->MBA_STATUS	:= "1"  	//Status em aberto
		MBA->MBA_ID		:= cIDPacote
		MBA->(MsUnlock())
		
		MBC->(dbSkip())
	End
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ  Lj3LibLote  บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que libera um LOTE para ser processado pelo SCHEDULLE       บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3LibLote() Class PainelPrecificacao

	Local lRetorno := .F.             // Variavel logica de retorno da funcao
	
	//Objeto nao instanciado ou nao existe LOTE para a data informada
	If Self:cNroLote == Nil .OR. EMPTY(Self:cNroLote)
		Return(lRetorno)
	EndIf
	
	DbSelectArea("MBE")
	MBE->(DbSetOrder(1))
	MBE->(DbSeek(xFilial("MBE")+Self:cNroLote ))
	If MBE->MBE_STATUS == "1"
		MBE->(RecLock("MBE",.F.))
		MBE->MBE_STATUS := "3"
		MBE->(MsUnlock())
		lRetorno := .T.
	EndIf
	
Return(lRetorno) 
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3RetPacotes บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que retorna os pacotes de um determinado lote               บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3RetPacotes() Class PainelPrecificacao

	Local nCount := 0      // Variavel utilizada no For
	
	//Varre os pacotes atuais do lote e atualiza seus status
	DbSelectArea("MB9")
	MB9->(DbSetOrder(2))
	
	If Len(Self:aPacotes) > 0
		For nCount := 1 To Len(Self:aPacotes)
			If MB9->(DbSeek(xFilial("MB9")+Self:cNroLote+Self:aPacotes[nCount,1] ))
				Self:aPacotes[nCount,3] := MB9->MB9_STATUS
			EndIf
		Next nCount
	Else
		MB9->(DbSeek(xFilial("MB9")+Self:cNroLote ))
		While MB9->(!Eof()) .AND. MB9->MB9_FILIAL + MB9->MB9_BECOD == xFilial("MB9")+Self:cNroLote
			AAdd(Self:aPacotes,{MB9->MB9_ID,MB9->MB9_BBCOD,MB9->MB9_STATUS})
			MB9->(dbSkip())
		End
	EndIf
	
Return(Self:aPacotes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ  Lj3RetAcoes บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que retorna as acoes de um pacote com seus status           บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3RetAcoes(cIDPacote) Class PainelPrecificacao
	
	Default cIDPacote := "" 	// Variaval que armazena o ID do pacote
	
	//Zera o vetor, pois sempre tera apenas as informacoes do ultimo ID solicitado
	Self:aAcoes := {}
	
	DbSelectArea("MBA")
	MBA->(DbSetOrder(2))
	MBA->(DbSeek(xFilial("MBA")+Self:cNroLote+cIDPacote ))
	While MBA->(!Eof()) .AND. MBA->MBA_FILIAL + MBA->MBA_BECOD + MBA->MBA_ID == xFilial("MBA")+Self:cNroLote+cIDPacote
		AAdd(Self:aAcoes,{	MBA->MBA_BDCOD,;
		Posicione("MBD",1,xFilial("MBD")+MBA->MBA_BDCOD,"MBD->MBD_DESC"),;
		MBA->MBA_STATUS,;
		"","" })
		
		//Retorna os campos CHAVES de cada acao
		If MBA->MBA_BBCOD == PACOTE_PRODUTO
			Self:aAcoes[Len(Self:aAcoes)][4] := MBA->MBA_CODPRO
			Self:aAcoes[Len(Self:aAcoes)][5] := MBA->MBA_FILPRO
		ElseIf MBA->MBA_BBCOD == PACOTE_PRECO
			Self:aAcoes[Len(Self:aAcoes)][4] := MBA->MBA_CODTAB
			Self:aAcoes[Len(Self:aAcoes)][5] := MBA->MBA_FILTAB
		ElseIf MBA->MBA_BBCOD == PACOTE_DESCONTO
			Self:aAcoes[Len(Self:aAcoes)][4] := MBA->MBA_CODREG
			Self:aAcoes[Len(Self:aAcoes)][5] := MBA->MBA_FILREG
		EndIf
		
		MBA->(dbSkip())
	End
		
Return(Nil)
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ  Lj3LibAcao  บ Autor ณ  Vendas Clientes   บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que libera uma ACAO de um pacote do  LOTE                   บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3LibAcao(cIDPacote,cTipoAcao) Class PainelPrecificacao

	Local lRetorno := .F.    // Variavel logica utilizada no retorno da funcao
	
	Default cIDPacote		:= ""  
	Default cTipoAcao		:= "" 
	
	DbSelectArea("MBA")
	MBA->(DbSetOrder(2))
	If MBA->(DbSeek(xFilial("MBA")+Self:cNroLote+cIDPacote+cTipoAcao ))
		//Flega a acao do pacote como AGUARDANDO EXECUCAO
		If MBA->MBA_STATUS == "1"
			MBA->(RecLock("MBA",.F.))
			MBA->MBA_STATUS := "2"
			MBA->(MsUnlock())
			
			//Atualiza o status do pacote
			Self:Lj3PacStatus(cIDPacote)
			
			lRetorno := .T.
		EndIf
	EndIf
	
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ Lj3PacStatus บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que avalia a situacao de todas as ACOES do pacote e atualizaบฑฑ
ฑฑบ      ณo status do mesmo com a posicao atual                              บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3PacStatus(cIDPacote,cNumLote,cTipoAcao) Class PainelPrecificacao

	Local cStatusAtual := ""   // Variavel que armazena o status atual da acao
	Local lExecutado   := .F.  // Variavel que checa se a acao foi executada
	Local cMB9While    := ""   // Variavel que armazena o While da tabela MB9
	Local lMBAAberto   := .F.  // Variavel que armazena se o alguma acao esta atualmente com status em aberto ou em liberacao
	Local lMB9Execut   := .T.  // Variavel que armazena se o status do pacote foi alterado para executado
	Local lMB9Falhou   := .F.  // Variavel que armazena se o resultado do pacote falhou 
	
	Default cNumLote   := ""   // Varriavel que armazena o numero do lote 
	Default cIDPacote  := ""  
	Default cTipoAcao  := "" 
	
	//Busca o status do pacote, varrendo as acoes e analisando as ordens de precedencia dos status de cada uma
	DbSelectArea("MBA")
	MBA->(DbSetOrder(2))
	If MBA->(DbSeek(xFilial("MBA")+cNumLote+cIDPacote))
		While MBA->(!Eof()) .AND. MBA->MBA_FILIAL + MBA->MBA_BECOD + MBA->MBA_ID == xFilial("MBA")+cNumLote+cIDPacote
			If MBA->MBA_STATUS == "1" .AND. !EMPTY(cStatusAtual)		//Acao em liberacao
			   lMBAAberto   := .T.
			ElseIf MBA->MBA_STATUS == "2" 		//Acao aguardando execucao
				cStatusAtual := MBA->MBA_STATUS
				lMBAAberto   := .T.
			ElseIf MBA->MBA_STATUS == "1" .AND. EMPTY(cStatusAtual) //Acao em liberacao, eh o 1o. nivel, prevalece apenas se estiver sem historico de status
				cStatusAtual := MBA->MBA_STATUS
			ElseIf MBA->MBA_STATUS == "3"
				If (EMPTY(cStatusAtual) .OR. cStatusAtual <> "4") //Acao executada, e o historico atual nao eh do tipo FALHA que prevalece
					cStatusAtual := MBA->MBA_STATUS
				EndIf
				lExecutado   := .T.
			ElseIf MBA->MBA_STATUS == "4" .AND. (EMPTY(cStatusAtual) .OR. cStatusAtual <> "2") //Acao com FALHA, e o historico autla nao eh do tipo AGUARDANDO EXECUCAO que prevalece
				cStatusAtual := MBA->MBA_STATUS
			EndIf
			
			MBA->(dbSkip())
		End
	EndIf
	
	//Atualiza o status do pacote
	DbSelectArea("MB9")
	MB9->(DbSetOrder(2))
	If MB9->(DbSeek(xFilial("MB9")+cNumLote+cIDPacote ))
		MB9->(RecLock("MB9",.F.))
		If cStatusAtual <= "2" .AND. !lExecutado
			MB9->MB9_STATUS := cStatusAtual
		ElseIf (lExecutado .AND. cStatusAtual <> "3") .OR. (lExecutado .AND. lMBAAberto)
			MB9->MB9_STATUS := "3"
		Else
			MB9->MB9_STATUS := AllTrim(Str(Val(cStatusAtual)+1))
		EndIf
		MB9->(MsUnlock())
	EndIf
	
	// Checa se houve algum pacote com falha ou se todos estao com status de executado
	DbSelectArea("MB9")
	MB9->(DbSetOrder(1))
	If MB9->(DbSeek(xFilial("MB9")+cNumLote))
		cMB9While := xFilial("MB9")+cNumLote
		While rtrim(cMB9While) == rtrim(MB9->MB9_FILIAL+MB9->MB9_BECOD)
			
			If MB9->MB9_STATUS <> "4"
				lMB9Execut := .F.
			EndIf
			
			If MB9->MB9_STATUS == "5"
				lMB9Falhou   := .T.
			EndIf
			
			MB9->(dbskip())
		End
		
		//	Atualiza o status do Lote para Executado(caso todos os pacotes estejam finalizados) ou Falha
		If lMB9Execut .OR. lMB9Falhou
			DbSelectArea("MBE")
			DbSetOrder(1)
			If DbSeek(xFilial("MBE")+cNumLote)
				MBE->(RecLock("MBE",.F.))
				MBE->MBE_STATUS := Iif(lMB9Falhou,"5","4")
				MBE->(MsUnlock())
			EndIf
		EndIf
		
	EndIf
	
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ Lj3PacStatus บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que avalia a situacao de todas as ACOES do pacote e atualizaบฑฑ
ฑฑบ      ณo status do mesmo com a posicao atual                              บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ExecAcao(cIDPacote,cTipoAcao) Class PainelPrecificacao

	Local lRetorno := .F. 
	
	Default cIDPacote  := ""  
	Default cTipoAcao  := "" 
	
	DbSelectArea("MBA")
	MBA->(DbSetOrder(2))
	If MBA->(DbSeek(xFilial("MBA")+Self:cNroLote+cIDPacote+cTipoAcao ))
		//Flega a acao do pacote como AGUARDANDO EXECUCAO
		If MBA->MBA_STATUS $ "1|2|3"
			MBA->(RecLock("MBA",.F.))
			MBA->MBA_STATUS := "3"
			MBA->(MsUnlock())
			
			//Atualiza o status do pacote
			Self:Lj3PacStatus(cIDPacote)
			
			lRetorno := .T.
		EndIf
	EndIf
	
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณGetNroLote บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณRetorna o numero do lote SETADO                                 บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNroLote() Class PainelPrecificacao     

Return(Self:cNroLote)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณAcaoPendenteบAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณRetorna .T. se houver uma acao pendente do tipo informado        บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AcaoPendente(cTipoAcao) Class PainelPrecificacao

	Local lRetorno 		:= .F.    //Variavel logica de retorno da funcao" 
	 
	Default cTipoAcao  	:= "" 
	
	DbSelectArea("MBA")
	MBA->(DbSetOrder(3))
	If MBA->(DbSeek(xFilial("MBA")+cTipoAcao+"2" ))
		lRetorno := .T.
	EndIf
		
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณExecutaAcao บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณAtualiza o FLAG das acoes dos pacotes do tipo informado          บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ExecutaAcao(cTipoAcao,lComSucesso) Class PainelPrecificacao

	Local lRetorno := .F.  //Variavel logica de retorno da funcao
	Local cNumLote := ""   //Variavel que armazena o numero do lote
	
	Default lComSucesso  := .F.  
	Default cTipoAcao    := "" 

	//Atualiza o status das acoes
	DbSelectArea("MBA")
	MBA->(DbSetOrder(3))
	If MBA->(DbSeek(xFilial("MBA")+cTipoAcao+"2" ))
		While MBA->(!Eof()) .AND. MBA->(MBA_FILIAL+MBA_BDCOD+MBA_STATUS) == xFilial("MBA")+cTipoAcao+"2"
			MBA->(RecLock("MBA",.F.))
			MBA->MBA_STATUS := Iif(lComSucesso,"3","4")
			MBA->(MsUnlock())
			cNumLote := MBA->MBA_BECOD
			
			//Atualiza o status do pacote da acao
			Self:Lj3PacStatus(MBA->MBA_ID, cNumLote,cTipoAcao) 
			
			// Efetua novo seek na MBA para checar se existe alguma acao aguardando execucao
			MBA->(DbSetOrder(3))
			MBA->(DbSeek(xFilial("MBA")+cTipoAcao+"2" ))

			lRetorno := .T.
		End
	EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ   Lj3ImpEtiquetas   บAutor  ณVendas Clientes     บ Data ณ  20/12/10      บฑฑ
ฑฑฬออออออุอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณRetorna .T. se houver uma ou mais acao do tipo ETIQUETAS liberada para    บฑฑ
ฑฑบ      ณEXECUCAO (pacote ATUALIZACAO DE PRECOS)                                   บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ImpEtiquetas(cNumLote,cTipoImp) Class PainelPrecificacao

	Local cMB9While := ""                               // Variavel utilizada no While efetuado na MB9
	Local cMBAWhile := ""								// Variavel utilizada no While efetuado na MBA
	Local cSAYWhile := ""								// Variavel utilizada no While efetuado na SAY
	Local cDA0While := ""								// Variavel utilizada no While efetuado na DA0
	Local cMB9Status:= "1"								// Variavel utilizada para armazenar o maior status do lote
	Local nCount 	:= 0								// Variavel utilizada no laco For
	Local lStatLote := .F.								// Variavel utilizada para atualizacao de status do lote
	Local lRegDesc  := .T.                              // Variavel para executar uma unica vez a checagem da regra de desconto
	Local lImpAnt   := .F.								// Variavel que checa o tipo de impressao se eh Antecipada ou Nao
	Local lRetorno	:= .T.                              // Variavel de retorno da funcao
	Local lMBGGrava	:= .T.                              // Variavel de retorno da funcao
	Local lAtuPub	:= .F.                              // Variavel de retorno da funcao de atualizacao de publicacao
	Local nValorDe  := 0                                // Variavel que armazena o conteudo do valor inicial da tabela de precos ou cadastro de produtos
	Local aProdutos := {}                               // Array que armazena os produtos   
	Local nDescPer	:= 0								// percentual de desconto do produto conforme as regras de desconto.
	
	Default cNumLote  := ""                             // Variavel que armazena o numero do lote
	Default cTipoImp  := ""                             // Variavel que armazena o tipo de impressao    
	
	lImpAnt := IIf(cTipoImp == "A",.T.,.F.)
	
	DbSelectArea("MB9")
	DbSetOrder(2)
	If DbSeek(xFilial("MB9")+alltrim(cNumLote))         // Posiciona no pacote do lote
		cMB9While := (xFilial("MB9")+alltrim(cNumLote))
		While rtrim(cMB9While) == rtrim(MB9->MB9_FILIAL+MB9->MB9_BECOD)
			
			DbSelectArea("MBA")
			DbSetOrder(2)
			If DbSeek(xFilial("MBA")+alltrim(cNumLote)+MB9->MB9_ID)  // Posiciona na acao do lote
				cMBAWhile := (xFilial("MB9")+alltrim(cNumLote)+MB9->MB9_ID)
				While rtrim(cMBAWhile) == rtrim(MBA->MBA_FILIAL+MBA->MBA_BECOD+MBA->MBA_ID)
					If MBA->MBA_STATUS == "1"    // Somente se o Status for em aberto
						
						// Tratamento para nao atualizar pacote caso exista impressao antecipada com status executada e depois seja feita a liberacao do lote
						If MB9->MB9_STATUS > cMB9Status
							cMB9Status := MB9->MB9_STATUS
						EndIf
						
						If MBA->MBA_BBCOD == PACOTE_PRODUTO
							If MBA->MBA_BDCOD == ACAO_IMPETIQUETAS

								// Gera MBG se baseando na tabela de precos
								DbSelectArea("MBG")
								DbSetOrder(1)
								If !DbSeek(xFilial("MBG")+alltrim(cNumLote)+DTOS(MBA->MBA_DTPAC)+MBA->MBA_FILPRO+MBA->MBA_CODPRO)
									DbSelectArea("DA0")
									DbSetOrder(1)
									If DbSeek(xFilial("DA0"))
										cDA0While := DA0->DA0_FILIAL
										While cDA0While == DA0->DA0_FILIAL
											If Date() >= DA0->DA0_DATDE .AND. (Date() <= DA0->DA0_DATATE .OR. EMPTY(DA0->DA0_DATATE))
												DbSelectArea("DA1")
												DbSetOrder(1)
												If DbSeek(DA0->DA0_FILIAL+DA0->DA0_CODTAB+MBA->MBA_CODPRO)
													nValorDe := DA1->DA1_PRCVEN
													Exit
												EndIf
											EndIf
											DA0->(dbskip())
										End
									EndIf
									
									// Gera MBG se baseando no valor do cadastro de produtos
									If nValorDe <= 0
										DbSelectArea("SB1")
										DbSetOrder(1)
										If DbSeek(MBA->MBA_FILPRO+MBA->MBA_CODPRO)
											nValorDe := SB1->B1_PRV1
										EndIf
									EndIf
									
									MBG->(RecLock("MBG",.T.))
									MBG->MBG_FILIAL  := xFilial("MBG")
									MBG->MBG_CODIGO  := alltrim(cNumLote)
									MBG->MBG_FILPROD := MBA->MBA_FILPRO //filial
									MBG->MBG_CODPROD := MBA->MBA_CODPRO //cod. produto 
									                
									If FindFunction("RGDesIte") //Loja 3025  
										nDescPer := RGDesIte(MBA->MBA_CODPRO,"","","",MBA->MBA_DATA,1,.T.)
									Endif	
									
									MBG->MBG_VLRDE   := nValorDe
									MBG->MBG_VLRPOR  := nValorDe  - ((nValorDe * nDescPer)/100) // Efetuar calculo de desconto quando houver o metodo
									MBG->MBG_STATUS  := 2
									MBG->MBG_DTVIG   := MBA->MBA_DTPAC
									MBG->MBG_TIPO 	 := cTipoImp   // A = Antecipada, N = Normal ou J = Normal via Job
									MBG->(MsUnlock())
									nValorDe := 0
								EndIf
							EndIf
						EndIf
						
						
						If MBA->MBA_BBCOD == PACOTE_PRECO
							If MBA->MBA_BDCOD == ACAO_IMPETIQUETAS

								// Gera MBG se baseando na Pre-Tabela (Publicacoes)
								DbSelectArea("SAY")
								DbSetOrder(1)
								If DbSeek(xFilial("SAY")+MBA->MBA_CODTAB)
									cSAYWhile := xFilial("SAY")+MBA->MBA_CODTAB
									While rtrim(cSAYWhile) == rtrim(SAY->AY_FILIAL+SAY->AY_CODIGO)
										DbSelectArea("MBG")
										DbSetOrder(1)
										If !DbSeek(xFilial("MBG")+alltrim(cNumLote)+DTOS(MBA->MBA_DTPAC)+SAY->AY_FILIAL+ltrim(SAY->AY_PRODUTO))
											MBG->(RecLock("MBG",.T.))
											lMBGGrava := .T.
										ElseIf 	MBG->MBG_STATUS == 2
											MBG->(RecLock("MBG",.F.))
											lMBGGrava := .F.
										EndIf
										If lMBGGrava          
                                            
											If FindFunction("RGDesIte")   // LOJA3025
												nDescPer := RGDesIte(MBA->MBA_CODPRO,"","","",MBA->MBA_DATA,1,.T.)
										    Endif
										    
											MBG->MBG_FILIAL  := xFilial("MBG")
											MBG->MBG_CODIGO  := alltrim(cNumLote)
											MBG->MBG_FILPROD := SAY->AY_FILIAL
											MBG->MBG_CODPROD := SAY->AY_PRODUTO
											MBG->MBG_VLRDE   := SAY->AY_PRCSUG  //SAY->AY_PRCATU
											MBG->MBG_VLRPOR  := SAY->AY_PRCSUG  - ((SAY->AY_PRCSUG * nDescPer)/100) // Efetuar calculo da regra de desconto quando houver o metodo
											MBG->MBG_STATUS  := 2
											MBG->MBG_DTVIG   := MBA->MBA_DTPAC
											MBG->MBG_TIPO 	 := cTipoImp   // A = Antecipada, N = Normal ou J = Normal via Job
											MBG->(MsUnlock())
										EndIf
										lMBGGrava := .F.
										SAY->(dbskip())
									End
									
								EndIf
							EndIf
							
						EndIf
						
						// Gera MBG se baseando na regra de desconto e categoria de produtos
						If lRegDesc
							
							lRegDesc := .F.
							/*
							array aprodutos
							[1][1] = filial          c  ""
							[1][2] = cod. produto    c  "000004"
							[1][3] = % de desconto   N  10
							*/
							
							aProdutos := Self:Lj3CatRegDesc(MBA->MBA_FILREG,MBA->MBA_CODREG,MBA->MBA_DTPAC)   ///// ALTEREI A DATA MBA_DATA   PARA MBA_DTPAC - flavio.
							
							If !EMPTY(aProdutos)
								For nCount := 1 to Len(aProdutos)
									DbSelectArea("MBG")
									DbSetOrder(1)
									If !DbSeek(xFilial("MBG")+alltrim(cNumLote)+DTOS(MBA->MBA_DTPAC)+aProdutos[nCount][1]+ltrim(aProdutos[nCount][2]))
										DbSelectArea("DA0")
										DbSetOrder(1)
										If DbSeek(xFilial("DA0"))
											cDA0While := xFilial("DA0")
											While DA0->( ! Eof()) .and. cDA0While == DA0->DA0_FILIAL
												If Date() >= DA0->DA0_DATDE .AND. (Date() <= DA0->DA0_DATATE .OR. EMPTY(DA0->DA0_DATATE))
													DbSelectArea("DA1")
													DbSetOrder(1)
													If DbSeek(DA0->DA0_FILIAL+DA0->DA0_CODTAB+alltrim(aprodutos[nCount][2])+space(Len(DA1->DA1_CODPRO)-Len(alltrim(aprodutos[nCount][2]))))
														nValorDe := DA1->DA1_PRCVEN
														Exit
													EndIf
												EndIf
												DA0->(dbskip())
											End
										EndIf
										If nValorDe <= 0
											DbSelectArea("SB1")
											DbSetOrder(1)
											If DbSeek(aprodutos[nCount][1]+ltrim(aprodutos[nCount][2]))
												nValorDe := SB1->B1_PRV1
											EndIf
										EndIf
										MBG->(RecLock("MBG",.T.))
										MBG->MBG_FILIAL  := xFilial("MBG")
										MBG->MBG_CODIGO  := alltrim(cNumLote)
										MBG->MBG_FILPROD := aprodutos[nCount][1] //filial
										MBG->MBG_CODPROD := ltrim(aprodutos[nCount][2]) //cod. produto
										MBG->MBG_VLRDE   := nValorDe
										MBG->MBG_VLRPOR  := nValorDe - ((nValorDe*aprodutos[nCount][3])/100) // ***efetuar calculo de desconto quando houver o metodo
										MBG->MBG_STATUS  := 2
										MBG->MBG_DTVIG   := MBA->MBA_DTPAC
										MBG->MBG_TIPO 	 := cTipoImp   // A = Antecipada, N = Normal ou J = Normal via Job
										MBG->(MsUnlock())
										nValorDe := 0
									EndIf
								Next nCount
							EndIf
						EndIf
						
						// Sendo impressao antecipada e acao de etiquetas ou impressao normal ou impressa via job atualiza status da acao e do pacote
						If (lImpAnt .AND. MBA->MBA_BDCOD == ACAO_IMPETIQUETAS) .OR. cTipoImp == "N" .OR. cTipoImp == "J"
                                
								MBA->(RecLock("MBA",.F.))
								MBA->MBA_STATUS := "2"
								MBA->(MsUnlock())
						
								If cMB9Status <= "2"
									MB9->(RecLock("MB9",.F.))
									MB9->MB9_STATUS := "2"
									MB9->(MsUnlock())
								EndIf
								lStatLote := .T.
						EndIf
						
					EndIf
					
					//Efetua a atualizacao do pacote de publicacoes para a efetivacao em tabela de precos
					If !lImpAnt
						If MBA->MBA_BBCOD == PACOTE_PRECO
							If MBA->MBA_BDCOD == ACAO_ATUALIZADADOS
								lAtuPub := A325ESAX(,,,alltrim(cNumLote),MBA->MBA_FILTAB)
						        If lAtuPub
								
									MBA->(RecLock("MBA",.F.))
									MBA->MBA_STATUS := "3"
									MBA->(MsUnlock())
									
									If cMB9Status <= "2"
										MB9->(RecLock("MB9",.F.))
										MB9->MB9_STATUS := "3"
										MB9->(MsUnlock())
									EndIf
						        
						        Else
								
									MBA->(RecLock("MBA",.F.))
									MBA->MBA_STATUS := "4"
									MBA->(MsUnlock())
									
									If cMB9Status <= "2"
										MB9->(RecLock("MB9",.F.))
										MB9->MB9_STATUS := "5"
										MB9->(MsUnlock())
									EndIf
						        
						        EndIf 
						    EndIf
						EndIf
                    EndIf
                    
					MBA->(dbskip())
				End
			EndIf
			
			cMB9Status := "1"
			MB9->(dbskip())
			
		End
		
		//Altera Status do lote
		If lStatLote
			MBE->(RecLock("MBE",.F.))
			If cTipoImp == "A" .AND. MBE->MBE_STATUS == "1"
				MBE->MBE_STATUS := "2"
			Else
				MBE->MBE_STATUS := "3"
			EndIf
			MBE->(MsUnlock())
		EndIf
		
	Else
		MsgInfo(STR0005) //"Lote inexistente."
	EndIf
		
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj3CancImpEtiquetasบ Autor ณ Vendas Clientes    บ Data ณ  30/12/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo utilizado para efetuar o cancelamento da impressao antecipada.บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method Lj3CancImpEtiquetas(cNumLote) Class PainelPrecificacao

	Local cMB9While := ""          // Variavel utilizada no laco while para MB9
	Local cMBAWhile := ""          // Variavel utilizada no laco while para MBA
	Local cMBGWhile := ""          // Variavel utilizada no laco while para MBG
	Local lCancLote := .F.         // Variavel logica que confirma o cancelamento do lote
	Local lStatusImp:= .F.         // Variavel logica que confirma se a etiqueta jah foi ou nao impressa
	Local lRetorno	:= .T.         // Variavel logica do retorno da funcao
	
	Default cNumLote  := ""        // Variavel que armazena o numero do lote
	
	// Checa se alguma etiqueta do lote jแ foi impressa
	DbSelectArea("MBG")
	DbSetOrder(1)
	If DbSeek(xFilial("MBG")+alltrim(cNumLote))
		cMBGWhile := xFilial("MBG")+alltrim(cNumLote)
		While cMBGWhile == MBG->MBG_FILIAL+MBG->MBG_CODIGO
			If MBG->MBG_STATUS == 1
				lStatusImp := .T.
				Exit
			EndIf
			MBG->(dbskip())
		End
		
	EndIf
	
	//Efetua a delecao das etiquetas caso nao tenha ocorrido nenhuma impressao
	If !lStatusImp
		DbSelectArea("MBG")
		DbSetOrder(1)
		If DbSeek(xFilial("MBG")+alltrim(cNumLote))
			cMBGWhile := xFilial("MBG")+alltrim(cNumLote)
			While cMBGWhile == MBG->MBG_FILIAL+MBG->MBG_CODIGO
				
				RecLock("MBG",.F.)
				MBG->(dbDelete())
				MBG->(MsUnLock())
				
				MBG->(dbskip())
			End
			
		EndIf
		
		//Efetua a alteracao dos status das acoes e pacotes para "em aberto"
		DbSelectArea("MB9")
		DbSetOrder(2)
		If DbSeek(xFilial("MB9")+alltrim(cNumLote))
			cMB9While := (xFilial("MB9")+alltrim(cNumLote))
			While rtrim(cMB9While) == rtrim(MB9->MB9_FILIAL+MB9->MB9_BECOD)
				
				DbSelectArea("MBA")
				DbSetOrder(2)
				If DbSeek(xFilial("MBA")+alltrim(cNumLote))
					cMBAWhile := (xFilial("MB9")+alltrim(cNumLote))
					While rtrim(cMBAWhile) == rtrim(MBA->MBA_FILIAL+MBA->MBA_BECOD)
						If MBA->MBA_STATUS == "2"
							
							If MBA->MBA_BDCOD == ACAO_IMPETIQUETAS
								
								MBA->(RecLock("MBA",.F.))
								MBA->MBA_STATUS := "1"
								MBA->(MsUnlock())
								
								MB9->(RecLock("MB9",.F.))
								MB9->MB9_STATUS := "1"
								MB9->(MsUnlock())
								
								lCancLote := .T.
								
							EndIf
							
						EndIf
						
						MBA->(dbskip())
					End
				EndIf
				
				MB9->(dbskip())
				
			End
			
			//Efetua a alteracao do status do lote
			If lCancLote
				MBE->(RecLock("MBE",.F.))
				MBE->MBE_STATUS := "1"
				MBE->(MsUnlock())
			EndIf
			
		Else
			MsgInfo(STR0005) //"Lote inexistente."
		EndIf
		
	Else
		MsgInfo(STR0006) //"Cancelamento nใo pode ser efetuado devido jแ ter ocorrido impressใo de produto(s)."
	EndIf
	
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ    Lj3GerarCarga    บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณRetorna .T. se houver uma ou mais acao do tipo GERAR CARGA          libe- บฑฑ
ฑฑบ      ณrada para EXECUCAO (pacote ATUALIZACAO DE PRECOS)                         บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3GerarCarga() Class PainelPrecificacao

	Local lRetorno := .F.		// Variavel logica do retorno da funcao
	
	//Metodo que testa se existe acao pendente do tipo informado
	lRetorno := Self:AcaoPendente(ACAO_IMPETIQUETAS)
	If !lRetorno
		lRetorno := Self:AcaoPendente(ACAO_GERACARGA)
		If !lRetorno
			lRetorno := Self:AcaoPendente(ACAO_GERTEC)
		EndIf
	EndIf
	
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ      Lj3Gertec      บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณRetorna .T. se houver uma ou mais acao do tipo ARQUIVOS GERTEC liberada   บฑฑ
ฑฑบ      ณ     para EXECUCAO (pacote ATUALIZACAO DE PRECOS)                         บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3Gertec() Class PainelPrecificacao

	Local lRetorno := .F.		// Variavel logica do retorno da funcao
	
	//Metodo que testa se existe acao pendente do tipo informado
	lRetorno := Self:AcaoPendente(ACAO_IMPETIQUETAS)
	If !lRetorno
		lRetorno := Self:AcaoPendente(ACAO_GERACARGA)
		If !lRetorno
			lRetorno := Self:AcaoPendente(ACAO_GERTEC)
		EndIf
	EndIf
	
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3ExecAtuDados บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณAltera o status das acoes PENDENTES do tipo ATUALIZACAO DE DADOS     บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ExecAtuDados(lComSucesso) Class PainelPrecificacao

	Default lComSucesso := .F.		// Variavel logica do retorno da funcao de atualizacao de dados informando se foi ou nao gerado com sucesso o arquivo
	
	//Metodo que retorna para o painel a execucao com sucesso ou nao da Atualizacao de dados
	lRetorno := Self:ExecutaAcao(ACAO_ATUALIZADADOS,lComSucesso)
	
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3ExecEtiquetasบAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณAltera o status das acoes PENDENTES do tipo IMPRESSAO ETIQUETAS      บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ExecEtiquetas(lComSucesso) Class PainelPrecificacao

	Default lComSucesso := .F.  // Variavel logica do retorno da funcao de etiquetas informando se foi ou nao gerado com sucesso a impressao
	
	//Metodo que testa se existe acao pendente do pacote e tipo informado
	lRetorno := Self:ExecutaAcao(ACAO_IMPETIQUETAS,lComSucesso)
	
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ Lj3ExecGertec  บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณAltera o status das acoes PENDENTES do tipo ARQUIVOS GERTEC          บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ExecGertec(lComSucesso) Class PainelPrecificacao

	Default lComSucesso := .F.		// Variavel logica do retorno da funcao de atualizacao GERTEC informando se foi ou nao gerado com sucesso o arquivo
	
	//Metodo que testa se existe acao pendente do pacote e tipo informado
	lRetorno := Self:ExecutaAcao(ACAO_GERTEC,lComSucesso)
	
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณ Lj3ExecCarga บAutor  ณVendas Clientes     บ Data ณ  20/09/10      บฑฑ
ฑฑฬออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณAltera o status das acoes PENDENTES do tipo CARGA DE DADOS         บฑฑ
ฑฑศออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ExecCarga(lComSucesso) Class PainelPrecificacao

	Default lComSucesso := .F.   // Variavel logica do retorno da funcao de carga informando se foi ou nao gerado com sucesso o arquivo
	
	//Metodo que testa se existe acao pendente do pacote e tipo informado
	lRetorno := Self:ExecutaAcao(ACAO_GERACARGA,lComSucesso)
	
Return(lRetorno)
                                                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3ExcPrec บAutor  ณVendas Clientes     บ Data ณ  14/12/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que exclui pacote/acao/lote de MANUTENCAO DE PRECOS.     บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method Lj3ExcPrec(dDataPacote,cFilPacote,cTabPacote) Class PainelPrecificacao
	
	Local cNumLote   := ""		// Variavel que armazena o numero do lote
	Local cNumPacote := ""      // Variavel que armazena o numero do pacote
	Local cNumID     := ""      // Variavel que armazena o numero ID que amarra pacote x acao
	Local cWhileMBA  := ""		// Variavel que utilizada no laco While MBA
	Local lLoteStat  := .T.		// Variavel que checa se o pacote podera ou nao ser excluido  
	
	Default dDataPacote		:= dDataBase
	Default cFilPacote		:= ""
	Default cTabPacote		:= ""

	// Checa se alguma acao do pacote de publicacao esta aguardando liberacao ou ja foi executado
	DbSelectArea("MBA")
	DbSetOrder(7)
	If MBA->(DbSeek(xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cTabPacote))
		cNumLote   := MBA->MBA_BECOD
		cNumPacote := MBA->MBA_BBCOD
		cNumID	   := MBA->MBA_ID
		cWhileMBA  := (xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cTabPacote)
		
		// Checa status das acoes
		While rtrim(cWhileMBA) == rtrim(MBA->MBA_FILIAL+DTOS(MBA->MBA_DTPAC)+MBA->MBA_FILTAB+MBA->MBA_CODTAB)
			If MBA->MBA_STATUS > "1"
				lLoteStat := .F.
			EndIf
			MBA->(DbSkip())
		End
		
		//Checa status do pacote e do lote
		If lLoteStat
			DbSelectArea("MB9")
			MB9->(DbSetOrder(2))
			If MB9->(DbSeek(xFilial("MB9")+cNumLote+cNumID))
				If MB9->MB9_STATUS > "1"
					lLoteStat := .F.
				Else
					DbSelectArea("MBE")
					MBE->(DbSetOrder(1))
					If MBE->(DbSeek(xFilial("MBE")+cNumLote))
						If MBE->MBE_STATUS > "2"
							lLoteStat := .F.
						Else
							lLoteStat := .T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		
	Else
		MsgInfo(STR0017+alltrim(cTabPacote)+STR0018+alltrim(cFilPacote)+STR0019+substr(DTOS(dDataPacote),7,2 )+"/"+substr(DTOS(dDataPacote),5,2 )+"/"+substr(DTOS(dDataPacote),1,4 )+".") //"Nใo ้ possํvel efetuar a exclusใo devido nใo existir a็ใo/pacote para a publica็ใo "###" da filial "###" na data de "
		Return .T.
	EndIf
	
	If lLoteStat
		
		DbSelectArea("MBA")
		DbSetOrder(7)
		If MBA->(DbSeek(xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cTabPacote))
			cNumLote   := MBA->MBA_BECOD
			cNumPacote := MBA->MBA_BBCOD
			cNumID	   := MBA->MBA_ID
			cWhileMBA  := (xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cTabPacote)
			
			//Efetua exclusao das acoes
			While rtrim(cWhileMBA) == rtrim(MBA->MBA_FILIAL+DTOS(MBA->MBA_DTPAC)+MBA->MBA_FILTAB+MBA->MBA_CODTAB)
				RecLock( "MBA", .F. )
				MBA->( dbDelete() )
				MBA->( msUnlock() )
				MBA->(dbskip())
			End
			
			//Efetua exclusao dos pacotes
			DbSelectArea("MB9")
			MB9->(DbSetOrder(2))
			If MB9->(DbSeek(xFilial("MB9")+cNumLote+cNumID))
				RecLock( "MB9", .F. )
				MB9->( dbDelete() )
				MB9->( msUnlock() )
				MsgInfo(STR0007+alltrim(cFilPacote)+STR0008+alltrim(cTabPacote)+".") //"Exclusใo efetuada na Manuten็ใo de Pre็o da Filial - "###", Cod.Tabela - "
			EndIf
			
			//Efetua a exclusao do lote
			If MB9->(!DbSeek(xFilial("MB9")+cNumLote))
				DbSelectArea("MBE")
				MBE->(DbSetOrder(1))
				If MBE->(DbSeek(xFilial("MBE")+cNumLote))
					RecLock( "MBE", .F. )
					MBE->( dbDelete() )
					MBE->( msUnlock() )
					MsgInfo(STR0009+alltrim(cNumLote)+STR0010+alltrim(cFilPacote)+STR0008+alltrim(cTabPacote)+".") //"Exclusใo do Lote - "###" efetuada pela dele็ao do pacote de Manuten็ใo de Pre็o da Filial - "###", Cod.Tabela - "
				EndIf
			EndIf
			
		EndIf
	Else
		MsgInfo(STR0020+alltrim(cTabPacote)+STR0021+alltrim(cFilPacote)+STR0022+substr(DTOS(dDataPacote),7,2 )+"/"+substr(DTOS(dDataPacote),5,2 )+"/"+substr(DTOS(dDataPacote),1,4 )+".",STR0023) //"Status do Lote/Pacote/A็๕es nใo permite a exclusใo do pacote que cont้m a publica็ใo "###", filial "###" e na data de "###"Painel de Gestใo - Precifica็ใo"
	EndIf
		
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3ExcProd บAutor  ณVendas Clientes     บ Data ณ  14/12/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que exclui a acao/pacote/lote de Produtos.				  บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ExcProd(dDataPacote,cFilPacote,cProdPacote) Class PainelPrecificacao

	Local cNumLote   := ""		// Variavel que armazena o numero do lote
	Local cNumPacote := ""      // Variavel que armazena o numero do pacote
	Local cNumID     := ""      // Variavel que armazena o numero ID que amarra pacote x acao
	Local cWhileMBA  := ""		// Variavel que utilizada no laco While MBA
	Local lLoteStat  := .T.		// Variavel que checa se o pacote podera ou nao ser excluido 
	
	Default dDataPacote		:= dDataBase
	Default cFilPacote		:= ""
	Default cProdPacote		:= ""
	
	// Checa se alguma acao do pacote de publicacao esta aguardando liberacao ou ja foi executado
	DbSelectArea("MBA")
	DbSetOrder(8)
	If MBA->(DbSeek(xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cProdPacote))
		cNumLote   := MBA->MBA_BECOD
		cNumPacote := MBA->MBA_BBCOD
		cNumID	   := MBA->MBA_ID
		cWhileMBA  := (xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cProdPacote)
		
		// Checa status das acoes
		While rtrim(cWhileMBA) == rtrim(MBA->MBA_FILIAL+DTOS(MBA->MBA_DTPAC)+MBA->MBA_FILPRO+MBA->MBA_CODPRO)
			If MBA->MBA_STATUS > "1"
				lLoteStat := .F.
			EndIf
			MBA->(DbSkip())
		End

		// Checa status das acoes
		If lLoteStat
			DbSelectArea("MB9")
			MB9->(DbSetOrder(2))
			If MB9->(DbSeek(xFilial("MB9")+cNumLote+cNumID))
				If MB9->MB9_STATUS > "1"
					lLoteStat := .F.
				Else
					DbSelectArea("MBE")
					MBE->(DbSetOrder(1))
					If MBE->(DbSeek(xFilial("MBE")+cNumLote))
						If MBE->MBE_STATUS > "2"
							lLoteStat := .F.
						Else
							lLoteStat := .T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		
	Else
		MsgInfo(STR0024+alltrim(cProdPacote)+STR0018+alltrim(cFilPacote)+STR0019+substr(DTOS(dDataPacote),7,2 )+"/"+substr(DTOS(dDataPacote),5,2 )+"/"+substr(DTOS(dDataPacote),1,4 )+".") //"Nใo ้ possํvel efetuar a exclusใo devido nใo existir a็ใo/pacote para o produto "###" da filial "###" na data de "
		Return .T.
	EndIf
	
	If lLoteStat   
	
		DbSelectArea("MBA")
		DbSetOrder(8)
		If MBA->(DbSeek(xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cProdPacote))
			cNumLote   := MBA->MBA_BECOD
			cNumPacote := MBA->MBA_BBCOD
			cNumID	   := MBA->MBA_ID
			cWhileMBA  := (xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cProdPacote)
			
			//Efetua a exclusao das acoes
			While rtrim(cWhileMBA) == rtrim(MBA->MBA_FILIAL+DTOS(MBA->MBA_DTPAC)+MBA->MBA_FILPRO+MBA->MBA_CODPRO)
				RecLock( "MBA", .F. )
				MBA->( dbDelete() )
				MBA->( msUnlock() )
				MBA->(dbskip())
			End
			
			//Efetua a exclusao do pacote
			DbSelectArea("MB9")
			MB9->(DbSetOrder(2))
			If MB9->(DbSeek(xFilial("MB9")+cNumLote+cNumID))
				RecLock( "MB9", .F. )
				MB9->( dbDelete() )
				MB9->( msUnlock() )
				MsgInfo(STR0011+alltrim(cFilPacote)+STR0012+alltrim(cProdPacote)+".",STR0023) //"Exclusใo efetuada do Cadastro de Produto da Filial - "###", Produto - " //"Painel de Gestใo - Precifica็ใo"
			EndIf
			
			//Efetua a exclusao do lote
			If MB9->(!DbSeek(xFilial("MB9")+cNumLote))
				DbSelectArea("MBE")
				MBE->(DbSetOrder(1))
				If MBE->(DbSeek(xFilial("MBE")+cNumLote))
					RecLock( "MBE", .F. )
					MBE->( dbDelete() )
					MBE->( msUnlock() )
					MsgInfo(STR0009+alltrim(cNumLote)+STR0013+alltrim(cFilPacote)+STR0012+alltrim(cProdPacote)+".") //"Exclusใo do Lote - "###" efetuada pela dele็ao do pacote de Cadastro de Produto da Filial - "###", Produto - "
				EndIf
			EndIf
			
		EndIf
	Else
		MsgInfo(STR0025+alltrim(cProdPacote)+STR0021+alltrim(cFilPacote)+STR0022+substr(DTOS(dDataPacote),7,2 )+"/"+substr(DTOS(dDataPacote),5,2 )+"/"+substr(DTOS(dDataPacote),1,4 )+".",STR0023) //"Status do Lote/Pacote/A็๕es nใo permite a exclusใo do pacote que cont้m o produto "###", filial "###" e na data de "###"Painel de Gestใo - Precifica็ใo"
	EndIf
	
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3ExcRDes บAutor  ณVendas Clientes     บ Data ณ  15/12/10      บฑฑ
ฑฑฬออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que exclui acao/pacote/lote de Regra de Desconto.		  บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ExcRDes(dDataPacote,cFilPacote,cRegraPacote) Class PainelPrecificacao

	Local cNumLote   := ""		// Variavel que armazena o numero do lote
	Local cNumPacote := ""      // Variavel que armazena o numero do pacote
	Local cNumID     := ""      // Variavel que armazena o numero ID que amarra pacote x acao
	Local cWhileMBA  := ""		// Variavel que utilizada no laco While MBA
	Local lLoteStat  := .T.		// Variavel que checa se o pacote podera ou nao ser excluido  
	
	Default dDataPacote		:= dDataBase
	Default cFilPacote		:= ""
	Default cRegraPacote	:= ""
	
	// Checa se alguma acao do pacote de publicacao esta aguardando liberacao ou ja foi executado
	DbSelectArea("MBA")
	DbSetOrder(9)
	If MBA->(DbSeek(xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cRegraPacote))
		cNumLote   := MBA->MBA_BECOD
		cNumPacote := MBA->MBA_BBCOD
		cNumID	   := MBA->MBA_ID
		cWhileMBA  := (xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cRegraPacote)
		
		// Checa status das acoes
		While rtrim(cWhileMBA) == rtrim(MBA->MBA_FILIAL+DTOS(MBA->MBA_DTPAC)+MBA->MBA_FILREG+MBA->MBA_CODREG)
			If MBA->MBA_STATUS > "1"
				lLoteStat := .F.
			EndIf
			MBA->(DbSkip())
		End
		
		//Checa status do pacote e do lote
		If lLoteStat
			DbSelectArea("MB9")
			MB9->(DbSetOrder(2))
			If MB9->(DbSeek(xFilial("MB9")+cNumLote+cNumID))
				If MB9->MB9_STATUS > "1"
					lLoteStat := .F.
				Else
					DbSelectArea("MBE")
					MBE->(DbSetOrder(1))
					If MBE->(DbSeek(xFilial("MBE")+cNumLote))
						If MBE->MBE_STATUS > "2"
							lLoteStat := .F.
						Else
							lLoteStat := .T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		
	Else
		MsgInfo(STR0026+alltrim(cRegraPacote)+STR0018+alltrim(cFilPacote)+STR0019+substr(DTOS(dDataPacote),7,2 )+"/"+substr(DTOS(dDataPacote),5,2 )+"/"+substr(DTOS(dDataPacote),1,4 )+".") //"Nใo ้ possํvel efetuar a exclusใo devido nใo existir a็ใo/pacote para a regra de desconto "###" da filial "###" na data de "
		Return .F.
	EndIf
	
	If lLoteStat
		
		DbSelectArea("MBA")
		DbSetOrder(9)
		If MBA->(DbSeek(xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cRegraPacote))
			cNumLote   := MBA->MBA_BECOD
			cNumPacote := MBA->MBA_BBCOD
			cNumID	   := MBA->MBA_ID
			cWhileMBA  := (xFilial("MBA")+DTOS(dDataPacote)+cFilPacote+cRegraPacote)
			
			//Efetua a exclusao da acao
			While rtrim(cWhileMBA) == rtrim(MBA->MBA_FILIAL+DTOS(MBA->MBA_DTPAC)+MBA->MBA_FILREG+MBA->MBA_CODREG)
				RecLock( "MBA", .F. )
				MBA->( dbDelete() )
				MBA->( msUnlock() )
				MBA->(dbskip())
			End
			
			//Efetua a exclusao do pacote
			DbSelectArea("MB9")
			MB9->(DbSetOrder(2))
			If MB9->(DbSeek(xFilial("MB9")+cNumLote+cNumID))
				RecLock( "MB9", .F. )
				MB9->( dbDelete() )
				MB9->( msUnlock() )
				MsgInfo(STR0014+alltrim(cFilPacote)+STR0015+alltrim(cRegraPacote)+".") //"Exclusใo efetuada da Regra de Desconto da Filial - "###", Regra - "
			EndIf
			
			//Efetua a exclusao do lote
			If MB9->(!DbSeek(xFilial("MB9")+cNumLote))
				DbSelectArea("MBE")
				MBE->(DbSetOrder(1))
				If MBE->(DbSeek(xFilial("MBE")+cNumLote))
					RecLock( "MBE", .F. )
					MBE->( dbDelete() )
					MBE->( msUnlock() )
					MsgInfo(STR0009+alltrim(cNumLote)+STR0016+alltrim(cFilPacote)+STR0015+alltrim(cRegraPacote)+".") //"Exclusใo do Lote - "###" efetuada pela dele็ao do pacote de Regra de Desconto da Filial - "###", Regra - "
				EndIf
			EndIf
			
		EndIf
		
	Else
		MsgInfo(STR0027+alltrim(cRegraPacote)+STR0021+alltrim(cFilPacote)+STR0022+substr(DTOS(dDataPacote),7,2 )+"/"+substr(DTOS(dDataPacote),5,2 )+"/"+substr(DTOS(dDataPacote),1,4 )+".",STR0023) //"Status do Lote/Pacote/A็๕es nใo permite a exclusใo do pacote que cont้m a regra de desconto "###", filial "###" e na data de "###"Painel de Gestใo - Precifica็ใo"
	EndIf
		
Return(lLoteStat)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบMetodoณLj3CatRegDescบ Autor ณ  Vendas Clientes   บ Data ณ  15/12/10      บฑฑ
ฑฑฬออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc. ณMetodo que exclui acao/pacote/lote de Regra de Desconto.		    บฑฑ
ฑฑศออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3CatRegDesc(cFilRegra,cCodRegra,dDtRegDesc) Class PainelPrecificacao 

	Local aProdutos := {}      //Array para armazenar os produtos da Categoria  
	
	Default dDtRegDesc		:= dDataBase
	Default cFilRegra		:= ""
	Default cCodRegra  		:= ""
                                                       
	aProdutos := Loja3027(cFilRegra,cCodRegra,dDtRegDesc)
	
Return aProdutos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LJ302JOB บ Autor ณ  Vendas Clientes   บ Data ณ  29/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a liberacao dos lotes via job.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LJ302JOB( aParam )

	Local lRet  	 := .T.  // Variavel logica para retorno da funcao
	Local cEmp		 := ""   // Variavel que armazena a empresa
	Local cFil		 := ""   // Variavel que armazena a filial
	Local cQry		 := ""   // Variavel que armazena a query utilizada
	Local cNumLote   := ""   // Variavel que armazena o numero do lote
	Local cTipoImp   := ""   // Variavel que armazena o tipo de impressao
	Local oPainel    := Nil  // Declaracao do objeto que instaciara a classe
	Local cAliasQry1 := ""   // Variavel que armazena o alias da area utilizada pela query
	
	If Valtype(aParam) != "A"
		cEmp := cEmpAnt
		cFil := cFilant
	Else
		cEmp := aParam[1][1]
		cFil := aParam[1][2]
	EndIf
	
	//----------------------
	// Teste Carlos Queiroz
	//cEmp := "99"
	//cFil := "01"
	// Teste Carlos Queiroz
	//----------------------
	
	RpcSetType(3)
	RpcSetEnv(cEmp, cFil) 	// Seta Ambiente
	
	BEGIN TRANSACTION
	
	oPainel := PainelPrecificacao():New()
	
	aArea := GetArea()
	
	// query que filtra lotes com status 'em aberto' e com status 'impressao antecipada'
	
	cAliasQry1:= GetNextAlias()
	
	cQry := " 	SELECT MBE.MBE_FILIAL, MBE.MBE_CODIGO, "
	cQry += " 	MBE.MBE_DATA, MBE.MBE_STATUS FROM "+RetSqlName("MBE")+" MBE "
	cQry += " 	WHERE MBE.D_E_L_E_T_ = ' ' AND MBE.MBE_STATUS < '3' AND MBE.MBE_DATA <= '"+DTOS(DATE()+1)+"'"
	
	cQry := Changequery(cQry)
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), cAliasQry1, .F., .T.)
	
	(cAliasQry1)->(dbgotop())
	
	While (cAliasQry1)->(!EOF())
		
		DbSelectArea("MBE")
		DbSetOrder(1)
		If DbSeek((cAliasQry1)->MBE_FILIAL+(cAliasQry1)->MBE_CODIGO)
			
			cNumLote := MBE->MBE_CODIGO
			cTipoImp := "J"
			
			begin transaction
			oPainel:Lj3ImpEtiquetas(cNumLote,cTipoImp)   //metodo que gera impressao de etiqueta do lote liberado
			end transaction
			
		EndIf
		
		(cAliasQry1)->(dbskip())
		
	End
	
	RestArea(aArea)
	
	END TRANSACTION
	
	RpcClearEnv()
	
Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj3ChecaProdutoบ Autor ณ   Vendas Clientes  บ Data ณ  13/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo que checa se o produto podera ser incluido em um lote    บฑฑ
ฑฑบ          ณ existente no mesmo dia ou em dias posteriores.                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Lj3ChecaProduto(dDataPacote,cFilPacote,cProdPacote) Class PainelPrecificacao

	Local cDataPac    	  := ""                                  // Variavel que armazena a data do pacote
	Local cPacProduto     := PACOTE_PRODUTO+space(11)            // Variavel que armazena o conteudo do pacote de produto
	Local lGeraPacote 	  := .T.                                 // Variavel logica que permite ou nao a geracao do pacote para a data sugerida
	Local lChecaNovamente := .F.                                 // Variavel que determina se devera ser checado outro lote para a data sugerida
	Local aLoteProd   	  := {}							         // Array que contem os detalhes que determinam a criacao do pacote na data aprovada
	
	Default dDataPacote		:= dDataBase
	Default cFilPacote		:= ""
	Default cProdPacote		:= ""
	
	aLoteProd   := {.T.,DTOS(dDataPacote),.F.}
	cDataPac 	:= DTOS(dDataPacote)     

	
	// Seleciona o lote
	DbSelectArea("MBE")
	DbSetOrder(2)
	If DbSeek(XFilial("MBE")+cDataPac)
		cNumLote := MBE->MBE_CODIGO
		
		If MBE->MBE_STATUS >= "2"

			// Posiciona no pacote do lote
			DbSelectArea("MB9")
			DbSetOrder(1)
			If DbSeek(xFilial("MB9")+cNumLote+cPacProduto+cDataPac)  
				cMB9While := (xFilial("MB9")+cNumLote+cPacProduto+cDataPac)
				While rtrim(cMB9While) == rtrim(MB9->MB9_FILIAL+MB9->MB9_BECOD+MB9->MB9_BBCOD+DTOS(MB9->MB9_DATA))
					
					// Posiciona na acao do pacote
					DbSelectArea("MBA")
					DbSetOrder(2)
					If DbSeek(xFilial("MBA")+cNumLote+MB9->MB9_ID)  
						cMBAWhile := (xFilial("MB9")+cNumLote+MB9->MB9_ID)
						While rtrim(cMBAWhile) == rtrim(MBA->MBA_FILIAL+MBA->MBA_BECOD+MBA->MBA_ID)
							
							If MBA->MBA_BBCOD == PACOTE_PRODUTO
								If (MBA->MBA_BDCOD == ACAO_IMPETIQUETAS .AND. MBA->MBA_STATUS == "2") .OR. (MBA->MBA_STATUS >= "3")
									If alltrim(MBA->MBA_FILPRO) == alltrim(cFilPacote) .AND. alltrim(MBA->MBA_CODPRO) == alltrim(cProdPacote)
										If MBA->MBA_STATUS == "2"
											lGeraPacote := .F.
											lChecaNovamente := .F.
											Exit
										ElseIf MBA->MBA_STATUS >= "3"
											lGeraPacote := .F.
											lChecaNovamente := .T.
											cDataPac := Dtos(Stod(cDataPac)+1)
											Exit
										EndIf
									EndIf
								EndIf
							EndIf
							
							MBA->(Dbskip())
						End
					EndIf
					
					MB9->(Dbskip())
				End
				
			Elseif MBE->MBE_STATUS == "2"
				lGeraPacote := .T.
			Elseif MBE->MBE_STATUS >= "3"
				lGeraPacote := .F.
				cDataPac := Dtos(stod(cDataPac)+1)
				lChecaNovamente := .T.
			EndIf
			
		Else
			lGeraPacote := .T.
			lChecaNovamente := .F.
		EndIf
		
		//Array que armazena os dados do pacote a ser gerado
		aLoteProd := {lGeraPacote, cDataPac, lChecaNovamente}
		
	EndIf
	
Return aLoteProd