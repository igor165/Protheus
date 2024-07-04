#INCLUDE "CRDA210.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWizard.ch"
         
//Pula Linha
#Define CTRL Chr(13)+Chr(10)
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRDA210   ³ Autor ³Marcos R. Andrade      ³ Data ³29.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de vale compra                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³12/01/06  ³Machima 91206  ³Melhoria para geracao automatica de Vale Com³±±
±±³			 ³				 ³pras									      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          

Function CRDA210                   

Private aRotina := MenuDef()

Private cCadastro := STR0006                           //Motivo de Liberacao

DbSelectArea("MAV")   
dbSetOrder(1) 
DbSeek(xFilial("MAV"),.T.) 

mBrowse( 06, 01, 15, 75, "MAV" )

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
±±³ Uso      ³ CRDA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{ STR0001	,"AxPesqui" 	,0	,1	,0	,.F.	}	,; 	//"Pesquisar"
						{ STR0002	,"AxVisual" 	,0	,2	,0	,.T.	}	,; 	//"Visualizar"
						{ STR0003	,"AxInclui" 	,0	,3	,0	,.T.	}	,; 	//"Incluir"
						{ STR0004	,"AxAltera" 	,0	,4	,0	,.T.	}	,; 	//"Alterar"
						{ STR0005	,"Crd210Del"	,0	,0	,0	,.T.	}	,; 	//"Excluir"
						{ STR0007	,"Crd210Aut"	,0	,3	,0	,.T.	}	}  	//"Ger. Automática"					
Return(aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRD210Del ³ Autor ³Marcos R. Andrade      ³ Data ³29.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exclusao do vale compra                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Function Crd210Del(cAlias,nReg,nOpc)

If Crd210CanDel()
	AxDeleta(cAlias,nReg,nOpc,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL)
Else
	Help(" ",1,"NODELETA")	
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRD210CanDel³ Autor ³Marcos R. Andrade    ³ Data ³29.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da exclusao do motivo da liberacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³31/03/07  ³ Danilo Calil  ³Correcao do campo MAY_CODPRD                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          

Function Crd210CanDel()

Local lRet 		:= .T.              // Controla se foram encontrados registros no arquivo MAY com o codigo da Vale Compra
Local cAliasMAY	:= ""               // Alias da query ou do proprio arquivo MAY

#IFDEF TOP
	Local cQuery	:= ""           // Expressao da query
	Local lQuery	:= .F.          // Controla se trata com query
#ENDIF	

#IFDEF TOP

    lQuery := .T.
    
    cAliasMAY := "QRYMAY"
    
    cQuery := "SELECT COUNT(*) QTDMAY "
    cQuery += " FROM "
    cQuery += RetSqlName("MAY")+ " MAY "
    cQuery += " WHERE "
    
    cQuery += "MAY_FILIAL = '" + xFilial( "MAY" ) +"' AND "
    cQuery += "MAY_CODPRD = '" + MAV->MAV_CODIGO +"' AND "    
    cQuery += "MAY.D_E_L_E_T_ = ' ' "
    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAY,.F.,.T.)

	If (cAliasMAY)->QTDMAY > 0
		lRet := .F.
	EndIf	

	dbCloseArea()
	
	dbSelectArea("MAY")
	
#ELSE
    
    cAliasMAY	:= "MAY"                             
    
	dbSelectArea( "MAY" )
	dbSetOrder( 1 )
	
    If DbSeek(xFilial("MAY")+ MAV->MAV_CODIGO)
		lRet := .F.
	EndIf	
 
	dbSelectArea("MAY")
	                      
#ENDIF

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd210Aut   ³ Autor ³Fernando Machima     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao automatica do vale compras						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd210Aut(ExpC1, ExpN2, ExpN3)							  ³±±
±±³          ³ExpC1 - Alias do arquivo									  ³±±
±±³          ³ExpN2 - Recno do registro									  ³±±
±±³          ³ExpN3 - Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Function Crd210Aut(cAlias,nReg,nOpc)

Local nTamMAV_COD  := TamSX3("MAV_CODIGO")[1]     // Tamanho do campo MAV_CODIGO
Local nValor       := 0                           // Valor do Vale Compras
Local oWizard                                     // Objeto do wizard
Local oPanel                                      // Objeto do panel
Local oGetNumIni                                  // Objeto do codigo inicial
Local oGetNumFim                                  // Objeto do codigo final
Local oGetValor                                   // Objeto do valor 
Local oGetCodLoja                                 // Objeto do codigo da loja origem
Local cNumIni      := Space(nTamMAV_COD)         // Codigo inicial informado pelo usuario
Local cNumFim      := Space(nTamMAV_COD)		 // Codigo final informado pelo usuario
Local cCodLoja     := Space(TamSX3("LJ_CODIGO")[1])  // Loja origem de geracao
Local cText        := STR0021 +;                 //"Este programa processará a geração automática de Vale Compras de acordo com os "
					  STR0022 + CTRL + CTRL + ;  //"parâmetros selecionados."
	  			      STR0023                     //"Para continuar clique em Avançar."
Local bValid                                      // Bloco de codigo com validacao
Local dValidade		:= CtoD("  /  /  ")			  //variavel para armazenar a data de validade
Local lRet         := .T.                        // Controle do retorno da senha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Permissao apenas com senha de Administrador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !CRDXVLDUSU(3)
   lRet  := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	DEFINE WIZARD oWizard TITLE STR0024 ;   //"Processamento de geração de Vale Compras"
	HEADER STR0025 ;  						//"Wizard de geração automática de Vale Compras"
	MESSAGE STR0026 TEXT cText ;            //"Processamento automático."
	NEXT {|| .T.} FINISH {|| .T.} PANEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Segundo Panel - Perguntas da geracao       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard HEADER STR0027 ;   //"Parâmetros para geração automática"
	MESSAGE STR0028 ; 						//"Informe os parâmetros abaixo para a geração automática de Vale Compras."
	BACK {|| .T. } FINISH {|| IIf(Crd210VlPar( cNumIni  ,cNumFim  ,nValor  ,cCodLoja	,dValidade ),;
	                               Crd210Gera( cNumIni  ,cNumFim  ,nValor  ,cCodLoja	,dValidade ),.F.) } PANEL         
	oPanel := oWizard:GetPanel(2)
	
	bValid   := {|| Crd210VlNum( cNumIni ,cNumFim )}
	TSay():New(15,05,{|| STR0008},oPanel,,,,,,.T.) //"Código inicial:"
	oGetNumIni := TGet():New(14,70,bSETGET(cNumIni),oPanel,55,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	bValid   := {|| Crd210VlNum( cNumIni ,cNumFim )}
	TSay():New(35,05,{|| STR0009},oPanel,,,,,,.T.) //"Código final:"
	oGetNumFim := TGet():New(34,70,bSETGET(cNumFim),oPanel,55,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	bValid   := {|| nValor > 0 }
	TSay():New(55,05,{|| STR0010},oPanel,,,,,,.T.) //"Valor:"
	oGetValor := TGet():New(54,70,bSETGET(nValor),oPanel,45,10,PesqPict("MAV","MAV_VALOR"),bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	bValid   := {|| ExistCpo("SLJ",cCodLoja)}
	TSay():New(75,05,{|| STR0011},oPanel,,,,,,.T.) //"Loja:"
	oGetCodLoja := TGet():New(74,70,bSETGET(cCodLoja),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SLJ",)

	bValid   := {|| dValidade >= dDatabase }
	TSay():New(95,05,{|| STR0029},oPanel,,,,,,.T.) //"Validade:"
	oGetValidade := TGet():New(94,70,bSETGET(dValidade),oPanel,55,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)	
	ACTIVATE WIZARD oWizard CENTER
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd210VlPar ³ Autor ³Fernando Machima     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se todos os parametros foram informados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd210VlPar(ExpC1, ExpC2, ExpN3, ExpC4)					  ³±±
±±³          ³ExpC1 - Codigo inicial do Vale Compras					  ³±±
±±³          ³ExpC2 - Codigo final do Vale Compras					      ³±±
±±³          ³ExpN3 - Valor do Vale Compras					  			  ³±±
±±³          ³ExpC4 - Loja de origem do Vale Compras					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function Crd210VlPar( cNumIni  ,cNumFim  ,nValor  ,cCodLoja	,dValidade)

Local lRet    := .T.               //Retorno da validacao

lRet  := !(Empty(cNumIni) .OR. Empty(cNumFim) .OR. nValor == 0 .OR. Empty(cCodLoja) .OR. Empty(dValidade) )

If !lRet
   MsgStop(STR0012) //"Favor preencher todos os parâmetros para o início do processamento."
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd210Gera  ³ Autor ³Fernando Machima     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do processamento de Vale Compras			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd210Gera(ExpC1, ExpC2, ExpN3, ExpC4)					  ³±±
±±³          ³ExpC1 - Codigo inicial do Vale Compras					  ³±±
±±³          ³ExpC2 - Codigo final do Vale Compras					      ³±±
±±³          ³ExpN3 - Valor do Vale Compras					  			  ³±±
±±³          ³ExpC4 - Loja de origem do Vale Compras					  ³±±
±±³          ³ExpC5 - Validade do vale compra                 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function Crd210Gera( cNumIni  ,cNumFim  ,nValor  ,cCodLoja	,dValidade )

Local lRet       := .T.                                   // Retorno da geracao
Local nQtde      := (VAL(cNumFim) - VAL(cNumIni)) + 1    // Intervalo entre os codigos inicial e final digitados pelo usuario
Local nCount     := 0                                     // Contador de Vale Compras gerados
Local cNewNum                                             // Codigo onicial e controle dos codigos sequenciais de Vale Compras

//"ATENÇÃO! Certifique que os códigos de Vale Compras dentro do intervalo digitado correspondem ao valor especificado."
//"Confirma a geração automática de Vale Compras com os parâmetros informados?"
If lRet := MsgYesNo(STR0013 + CTRL + STR0014)              
	DbSelectArea("MAV")
	DbSetOrder(1)
	cNewNum  := ALLTRIM(cNumIni)
	
	Processa({|lEnd| Crd210Processa(@nCount  ,nQtde  ,cNewNum  ,cCodLoja  ,;
	                                nValor	,dValidade    )},,STR0015)	                    //"Gerando Vale Compras..."
	
	If nCount > 0
	   MsgStop(STR0016+ALLTRIM(STR(nCount))+STR0017)  //"Foram gerados "###" Vale Compras."
	Else 
	   lRet  := .F.
	   MsgStop(STR0018)  //"Não foi gerado nenhum Vale Compras. Verifique se o intervalo de códigos informado já não existe na base de dados."
	EndIf   
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd210VlNum ³ Autor ³Fernando Machima     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Vaçida os codigos de Vale Compras inicial e final		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd210VlNum(ExpC1, ExpC2)									  ³±±
±±³          ³ExpC1 - Codigo inicial do Vale Compras					  ³±±
±±³          ³ExpC2 - Codigo final do Vale Compras					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function Crd210VlNum( cNumIni  ,cNumFim )

Local lRet  := .T.                         // Retorno da validacao

If !Empty(cNumIni) .AND. !Empty(cNumFim)
	lRet  := (VAL(cNumFim) >= VAL(cNumIni))
	
	If !lRet
	   MsgStop(STR0019) //"O código final deve ser maior ou igual ao código inicial."
	EndIf
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Crd210Proces³ Autor ³Fernando Machima     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa a geracao de Vale Compras                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Crd210Processa(ExpN1, ExpN2, ExpC3, ExpC4, ExpN5)		      ³±±
±±³			 ³ExpN1 - contador de Vale Compras gerados 					  ³±±
±±³			 ³ExpN2 - intervalo entre os codigos inicial e final seleciona³±±
±±³			 ³dos 														  ³±±
±±³			 ³ExpC3 - codigo inicial e sequenciais de Vale Compras		  ³±±
±±³          ³ExpC4 - Loja de origem do Vale Compras					  ³±±
±±³          ³ExpN5 - Valor do Vale Compras					  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function Crd210Processa(	nCount	, nQtde		, cNewNum	, cCodLoja	,;
								nValor	, dValidade	)

Local nX							// Controle do loop
Local nNewNum	:= 0				// Codigo do Vale Compras numerico
Local nTamCod	:= LEN( cNewNum )	// Tamanho do codigo inicial, referencia para a geracao dos sequenciais
Local aVale		:= {}				// Dados para a gravação do log do vale compras

BEGIN TRANSACTION
	For nX := 1 to nQtde
		If !DbSeek( xFilial( "MAV" ) + cNewNum )
			RecLock( "MAV", .T. )
			REPLACE MAV_FILIAL     WITH xFilial("MAV")
			REPLACE MAV_CODIGO     WITH cNewNum
			REPLACE MAV_LOJA       WITH cCodLoja
			REPLACE MAV_VALOR      WITH nValor
			REPLACE MAV_STATUS     WITH  "1"				//Ativo
			If MAV->( FieldPos( "MAV_DTVALI" ) ) > 0
				REPLACE MAV_DTVALI WITH dValidade
			EndIf
			MsUnlock()
			
			aAdd( aVale, xFilial("MAV") )
			aAdd( aVale, cNewNum )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a MB1 esta no dicionario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AliasIndic( "MB1" )
				CRDA270Log( aVale, "1" )
			EndIf
			aVale := {}
			
			nCount++
		EndIf
		
		nNewNum := VAL( cNewNum ) + 1
		cNewNum := ALLTRIM( STR( nNewNum ) )
		If nTamCod > LEN( cNewNum )
			cNewNum := StrZero( nNewNum, nTamCod )
		EndIf
	Next nX
	FkCommit()
END TRANSACTION

Return .T.	
