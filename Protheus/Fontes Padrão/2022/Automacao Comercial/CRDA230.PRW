#INCLUDE "CRDA230.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWizard.ch"

//Pula Linha
#Define CTRL Chr(13)+Chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRDA230   ³ Autor ³Marcos R. Andrade      ³ Data ³30.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de pontos manual dos clientes                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±      
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³16/01/06  ³Machima B.91206³Incluida a opcao para zerar o saldo dos pon-³±±
±±³			 ³				 ³tos dos clientes							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Function CRDA230()                   

Private aRotina := MenuDef()

Private cCadastro := STR0006                           //"Cadastro de Pontos do Cliente"

DbSelectArea("MAX")                                                    

dbSetOrder(1) 
DbSeek(xFilial("MAX"),.T.)

mBrowse( 06, 01, 15, 75, "MAX" )

Return 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 13.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CRDA230                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0001	,"AxPesqui"		,0	,1	,0	,.F.	}	,; 	//"Pesquisar"
						{STR0002	,"AxVisual"		,0	,2	,0	,.T.	}	,; 	//"Visualizar"
						{STR0004	,"AxAltera"		,0	,4	,0	,.T.	}	,; 	//"Alterar"
						{STR0007	,"Crd230Zera"	,0	,4	,0	,.T.	}	} 	//"Inic. Ptos."
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd230Zera  ³ Autor ³Fernando Machima     ³ Data ³13/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem da interface do wizard para inicializar o saldo    ³±±
±±³			 ³de pontos 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd230Zera()		                                          ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Cadastro de pontos             					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Function Crd230Zera()

Local nTamCliente  := TamSX3("A1_COD")[1]        // Tamanho do campo A1_COD
Local nTamLoja     := TamSX3("A1_LOJA")[1]       // Tamanho do campo A1_LOJA
Local lRet         := .T.                        // Retorno da funcao
Local lMA7_PONTOS  := MA7->(FieldPos("MA7_PONTOS") > 0)  // Controla se o campo MA7_PONTOS foi criado no dicionario
Local oWizard                                     // Objeto do wizard
Local oPanel                                      // Objeto do panel
Local oGetCliIni                                  // Objeto do codigo do cliente
Local oGetLojIni                                  // Objeto da loja 
Local oGetCliFim                                  // Objeto do codigo do cliente
Local oGetLojFim                                  // Objeto da loja 
Local cCodCliIni   := Space(nTamCliente)         // Codigo do cliente inicial
Local cCodCliFim   := Space(nTamCliente)         // Codigo do cliente final
Local cLojCliIni   := Space(nTamLoja)            // Loja do cliente inicial
Local cLojCliFim   := Space(nTamLoja)            // Loja do cliente final
Local cText        := STR0008 + ;               //"Este programa inicializará o saldo de pontos dos clientes de acordo com os "
					  STR0009 + ;               //"parâmetros selecionados. O saldo atual será armazenado no campo Pontos(MA7_PONTOS) "
					  STR0010 + CTRL + CTRL + ; //"para consulta futura. "
					  STR0011 + CTRL + CTRL + ; //"ATENÇÃO! Se já houver um saldo gravado, este será sobreposto pelo novo saldo calculado."
	  			      STR0012                   //"Para continuar clique em Avançar."	  			      
	  			      
Local bValid                                      // Bloco de codigo com validacao


If !lMA7_PONTOS        
   //"Favor criar o campo MA7_PONTOS para armazenar o valor atual de pontos do cliente."
   //"Entre em contato com o Administrador do Sistema."
   MsgStop(STR0013 + STR0014) 
   lRet  := .F.        
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Permissao apenas com senha de Administrador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. !CrdSenhaAdm()
   lRet  := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	DEFINE WIZARD oWizard TITLE STR0015 ;    //"Inicialização do Saldo de Pontos"
	HEADER STR0016 ;                         //"Wizard de inicialização do saldo de pontos dos clientes"
	MESSAGE STR0017 TEXT cText ;             //"Processamento automático."
	NEXT {|| .T.} FINISH {|| .T.} PANEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Segundo Panel - Perguntas da inicializacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard HEADER STR0018 ; //"Parâmetros para inicialização automática"
	MESSAGE STR0019 ;                     //"Informe os parâmetros abaixo para a inicialização automática do saldo de pontos dos clientes."
	BACK {|| .T. } FINISH {|| Crd230Inic( cCodCliIni   ,cLojCliIni  ,cCodCliFim  ,cLojCliFim ) } PANEL         
	oPanel := oWizard:GetPanel(2)
	
	bValid   := {|| Crd230VldCli( cCodCliIni  ,cLojCliIni ) .AND. ;
	                Crd230VlSeqCli( cCodCliIni ,cLojCliIni, cCodCliFim, cLojCliFim ) }
	TSay():New(15,05,{|| STR0020},oPanel,,,,,,.T.)  //"Cliente inicial:"
	oGetCliIni := TGet():New(14,70,bSETGET(cCodCliIni),oPanel,35,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA1",)
	
	bValid   := {|| Crd230VldCli( cCodCliIni  ,cLojCliIni ) .AND. ;
	                Crd230VlSeqCli( cCodCliIni ,cLojCliIni, cCodCliFim, cLojCliFim ) }
	TSay():New(35,05,{|| STR0021},oPanel,,,,,,.T.)  //"Loja inicial:"
	oGetLojIni := TGet():New(34,70,bSETGET(cLojCliIni),oPanel,15,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	bValid   := {|| Crd230VldCli( cCodCliFim  ,cLojCliFim ) .AND. ;
	                Crd230VlSeqCli( cCodCliIni ,cLojCliIni, cCodCliFim, cLojCliFim ) }	
	TSay():New(55,05,{|| STR0022},oPanel,,,,,,.T.)  //"Cliente final:"
	oGetCliFim := TGet():New(54,70,bSETGET(cCodCliFim),oPanel,35,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA1",)
	
	bValid   := {|| Crd230VldCli( cCodCliFim  ,cLojCliFim ) .AND. ;
	                Crd230VlSeqCli( cCodCliIni ,cLojCliIni, cCodCliFim, cLojCliFim ) }
	TSay():New(75,05,{|| STR0023},oPanel,,,,,,.T.)  //"Loja final:"
	oGetLojFim := TGet():New(74,70,bSETGET(cLojCliFim),oPanel,15,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	ACTIVATE WIZARD oWizard CENTER
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd230VldCli³ Autor ³Fernando Machima     ³ Data ³13/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se o cliente esta cadastrado na base de dados		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd230VldCli(ExpC1, ExpC2)		                          ³±±
±±³			 ³ExpC1 - codigo do cliente								      ³±±
±±³			 ³ExpC2 - loja do cliente								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Cadastro de pontos             					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function Crd230VldCli( cCodCli  ,cLojCli )

Local lRet    := .T.                                                //Retorno da funcao, controla se cliente esta cadastrado
Local cChave  := IIf(Empty(cLojCli),cCodCli,cCodCli+cLojCli)       // Chave de pesquisa

lRet  := ExistCpo("SA1",cChave)

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd230VlSeqC³ Autor ³Fernando Machima     ³ Data ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Vaçida os codigos de Cliente inicial e final		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd230VlSeqC(ExpC1, ExpC2, ExpC3, ExpC4 )		              ³±±
±±³          ³ExpC1 - cliente inicial								      ³±±
±±³          ³ExpC2 - loja do cliente inicial							  ³±±
±±³          ³ExpC3 - cliente final								          ³±±
±±³          ³ExpC4 - loja do cliente final							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Cadastro de Pontos             					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function Crd230VlSeqCli( cCodIni  ,cLojIni, cCodFim, cLojFim )

Local lRet  := .T.                         // Retorno da validacao

If !Empty(cCodIni+cLojIni) .AND. !Empty(cCodFim+cLojFim)
	lRet  := (cCodFim+cLojFim >= cCodIni+cLojIni)
	
	If !lRet
	   MsgStop(STR0024) //"O código final deve ser maior ou igual ao código inicial."
	EndIf
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd230Inic  ³ Autor ³Fernando Machima     ³ Data ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa a inicializacao do saldo de pontos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd230Inic(ExpC1, ExpC2, ExpC3, ExpC4)        		      ³±±
±±³			 ³ExpC1 - cliente inicial 								      ³±±
±±³			 ³ExpC2 - loja do cliente inicial 							  ³±±
±±³			 ³ExpC3 - cliente final 								      ³±±
±±³			 ³ExpC4 - loja do cliente final  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Cadastro de Pontos             					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function Crd230Inic( cCodCliIni   ,cLojCliIni  ,cCodCliFim  ,cLojCliFim )

Local lRet      := .T.           // Retorno da funcao, controla se foram excluidos os pontos de algum cliente
Local nQtde     := 0             // Quantidade de clientes atualizados

If lRet := MsgYesNo(STR0025)    //"Confirma a inicialização do saldo de pontos dos clientes informados?"
   DbSelectArea("MA7")
   DbSetOrder(1)
   DbSeek(xFilial("MA7")+cCodCliIni+cLojCliIni,.T.)

   Processa({|lEnd| Crd230Processa(cCodCliIni  ,cLojCliIni  ,cCodCliFim ,cLojCliFim ,;
                                    @nQtde )},,STR0026)	     //"Inicializando saldo de pontos..."

   If nQtde > 0
      MsgStop(STR0027+ALLTRIM(STR(nQtde))+STR0028)   //"Foi realizada a inicialização do saldo de pontos de "###" clientes."
   Else 
      lRet  := .F.
	  MsgStop(STR0029) //"Não foi inicializado o saldo de pontos de nenhum cliente. Verifique se o intervalo de códigos foi corretamente informado."
   EndIf      
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd230Proces³ Autor ³Fernando Machima     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa a inicializacao do saldo de pontos				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd230Processa(ExpC1, ExpC2, ExpC3, ExpC4, ExpN5)		      ³±±
±±³			 ³ExpC1 - cliente inicial               					  ³±±
±±³			 ³ExpC2 - loja do cliente inicial               		      ³±±
±±³			 ³ExpC3 - cliente final                					      ³±±
±±³			 ³ExpC4 - loja do cliente final            					  ³±±
±±³			 ³ExpN5 - quantidade de registros inicializados      		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Cadastro de pontos             					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function Crd230Processa(cCodCliIni  ,cLojCliIni  ,cCodCliFim ,cLojCliFim ,;
							   nQtde )

Local nTotPontos:= 0            // Somatoria de pontos acumulados do cliente
Local nX                        // Controle de loop
Local aRecnoMAX := {}          // Array com os recnos dos clientes(MAX) a serem excluidos 

BEGIN TRANSACTION
	While !Eof() .AND. xFilial("MA7")+cCodCliFim+cLojCliFim >= MA7->MA7_FILIAL+MA7->MA7_CODCLI+MA7->MA7_LOJA
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Soma o total de pontos acumulados ate o momento³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   DbSelectArea("MAX")
	   DbSetOrder(1)
	   nTotPontos  := 0
	   aRecnoMAX   := {}
	   If DbSeek(xFilial("MAX")+MA7->MA7_CODCLI+MA7->MA7_LOJA)
	      While !Eof() .AND. xFilial("MAX")+MA7->MA7_CODCLI+MA7->MA7_LOJA == MAX->MAX_FILIAL+MAX->MAX_CODCLI+MAX->MAX_LOJA            
	         nTotPontos  += MAX->MAX_PONTOS
	            
	         AADD(aRecnoMAX,Recno())
	            
	         DbSkip()      
	      End         
	      
	      If nTotPontos > 0
	         nQtde++   
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Armazena no campo MA7_PONTOS do cliente o total acumulado caso queira recuperar posteriomente ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 RecLock("MA7",.F.)     
			 MA7->MA7_PONTOS  := nTotPontos
			 MsUnlock()      
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Exclui os registros de pontos do arquivo MAX³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 For nX := 1 to LEN(aRecnoMAX)
			    MAX->(DbGoto(aRecnoMAX[nX]))   
			    
				RecLock("MAX",.F.)     
				DbDelete()
				MsUnlock()      	        
			 Next nX
		  EndIf	 
	   EndIf   
		  
	   DbSelectArea("MA7")
	   DbSkip()
	End
	FkCommit()
END TRANSACTION

Return (.T.)
