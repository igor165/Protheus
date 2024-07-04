#include "Protheus.ch"
#include "LOJA7000.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA7000  ºAutor  ³VENDAS CRM          º Data ³  10/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Motivo de desconto                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA7000

	AxCadastro( "MDT", STR0001, Nil, Nil, 	;
				 Nil, Nil, Nil, Nil, 	 	;
				 {|| LJ7000Integ() }  	    ) // "MOTIVO DE DESCONTO"

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LJ7000Integ ³ Autor ³ Vendas cliente      ³ Data ³ 21/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responsavel em enviar os dados do cadastro de Motivo de     ³±±
±±³			 ³ desconto para integracao								       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de Motivo de desconto                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function LJ7000Integ()

	Local cTipo 		:= ""											//Como os dados serao integrados no processo offline    
	Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
	Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
	
	//Verifica se o ambiente esta em off-line
	If lAmbOffLn   
	
		//Instancia o objeto LJCProcessoOffLine
		oProcessOff := LJCProcessoOffLine():New("034")
		
		//Determina o tipo de operacao 
		If INCLUI
			cTipo := "INSERT"
		ElseIf ALTERA
			cTipo := "UPDATE"
		Else
			cTipo := "DELETE"
			
			//Considera os registros deletados
			SET DELETED OFF
		EndIf
			    
		If !Empty(cTipo)
			//Insere os dados do processo (registro da tabela)
			oProcessOff:Inserir("MDT", xFilial("MDT") + MDT_CODIGO, 1, cTipo)	
				
			//Processa os dados 
			oProcessOff:Processar()	
		EndIf
		
		//Desconsidera os registros deletados
		SET DELETED ON
	EndIf
	
Return (Nil)         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ J7MovInt    ³ Autor ³ Vendas cliente      ³ Data ³ 21/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responsavel em enviar os dados da movimentacao do motivo    ³±±
±±³			 ³ de desconto integracao								       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Movimento de Motivo de desconto                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function LJ7MovInt()

Local cTipo 		:= ""											//Como os dados serao integrados no processo offline    
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
Local lEnviaDado	:= .F.                                          // Verifica se existe o Indice 4 e só envia se houver este indice
Local cContIndice	:= ""	//Conteudo do Índice Selecionado
Local nIndice		:= 0	//Índice encontrado
	
	//Verifica se o ambiente esta em off-line
	If lAmbOffLn     
	
		SIX->(DbSetOrder(1))
		If SIX->(DbSeek("MDU4"))  // Verifica se o UPDLOJ89 foi aplicado, pesquisa o Indice 4 da Tabela MDU
			If AllTrim( SIX->CHAVE )  == "MDU_FILIAL+MDU_DOC+MDU_SERIE+MDU_PRODUT"
				cContIndice := xFilial("MDU") + MDU_DOC + MDU_SERIE + MDU_PRODUT
				nIndice		:= 4
				lEnviaDado	:= .T.
			EndIf
		EndIf        
		
		If !lEnviaDado           //Se UPDLOJ89 não foi aplicado, deve-se seguir com um índice que já vem cadastrado qdo o UPDLOJ41 é aplicado
			cContIndice	:= xFilial("MDU") + MDU_DOC + MDU_SERIE
			nIndice		:= 2
		EndIf
			
		//Instancia o objeto LJCProcessoOffLine
		oProcessOff := LJCProcessoOffLine():New("035")
		
		//Determina o tipo de operacao 
		cTipo := "INSERT"
			    
		If !Empty(cTipo)
			//Insere os dados do processo (registro da tabela)
			oProcessOff:Inserir("MDU", cContIndice , nIndice , cTipo)	
				
			//Processa os dados 
			oProcessOff:Processar()	
		EndIf
		
	EndIf
	
Return (Nil)  

