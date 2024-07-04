#INCLUDE "CRDA070.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRDA070   ³ Autor ³Viviane M. Fernandes   ³ Data ³05.07.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³CLASSIFICACAO DO CLIENTE                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Rotina de Classificação do cliente, apontará se o cliente   ³±±
±±³          ³atingiu a pontuacao, se baseando no cadastro de MAG e no    ³±±
±±³          ³e no perfil do cliente  								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DATA    ³BOPS ³Programador³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³04/07/05³81261³Machima    ³Considerar a analise de perfil para a classi³±±
±±³        ³     ³           ³ficacao do cliente                          ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function CRDA070

Private aRotina := MenuDef()
					
Private cCadastro := STR0006	 //"Classificação de clientes

DbSelectArea("SA1")     
dbSetOrder(1)

DbSeek(xFilial("SA1"))

mBrowse( 06, 01, 15, 75, "SA1" )

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
±±³ Uso      ³ CRDA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{ STR0001 ,"AxPesqui"   ,0 ,1 ,0 ,.F.},; 	//"Pesquisar"
						{ STR0002 ,"CRC070_001" ,0 ,2 ,0 ,.T.}}	//"Visualizar"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³CRDA070_001  ºAutor³Viviane M. Fernandesº Data ³  05/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Classificação do Cliente, base de scripts de Perfil e créditoº±±
±±º         ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPC1: Alias proveniente da MBrowse                          º±±
±±º         ³EXPN2: Registro posicionado na MBrowse                       º±±
±±º         ³EXPN3: Opcao de Menu Selecionada.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP7-Telecobrança-Cadastro de Questionário Socio Ecom. socialº±±
±±ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DATA    ³Versa³Programador³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/02/07³912  ³Fernando   ³Bops115955 Alteração feita para utilizar    ³±±
±±³        ³     ³           ³Walk Trhu                                   ³±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRC070_001(cAlias, nReg, nOpc)

Local oEnchoice   						// Objeto para Enchoice
Local oDlg 								// Objeto da Dialog
Local oBar								// ToolBar superior
Local aButtons   := {}  				// Array de botoes para a toolBar superior (EnchoiceBar)
Local aAC        := {STR0007,STR0008} 	// "Abandona"###"Confirma"

//Size da Dialog
Local aSize      := {}					// Size da Dialog - Funcao de calculo para coordenadas de tela.
Local aObjects   := {}					// Array de controle utilizado nos calculos de didmensao da Dialog
Local aInfo      := {}					// Array de controle utilizado nos calculos de didmensao da Dialog
Local aPosObj    := {}					// Array de controle utilizado nos calculos de didmensao da Dialog

Local bOk        := Nil					// Bloco para Ok
Local bCancel    := Nil					// Bloco para Cancela
Local nSele      := 0					// Verifica o botao selecionado. 
Local nItem      := 0
Local nTipo      := 1 		            //  1 - consulta de classificacao do cliente, chamada do menu
                      	 	            //  2 - Classificação -  consulta geral (calcula a análise)- Ficha cadastral
                      		            //  3 - Classificação -  Liberação para efetivação- Ficha cadastral
Local oBmp
Local aAnalise   :={}
Local lR5        := GetRpoRelease("R5") //Verifica caso seja release 11.5
Local nTamTela1  := 0                   //Adiciona posicoes aos objetos setados, Versao11.5

Private aHeader  := {} 					// Referencias trabalhos
Private aCols    := {} 

//bloco de código para os botões

bOk     := {||(nSele := 1,oDlg:End())}
bCancel := {||(nSele := 2,oDlg:End())}

					    	//cAlias, cSkip,OnlyFields,lWalkThru
aHeader   := A610CriaHeader("MAG", "MAG_CODCLI, MAG_LOJA, MAG_EMPRES, MAG_FILEMP, MAG_REGRA",,.T.)

aAnalise:= CRC070_002(nTipo)

// fazer um tratamento para verificar se há regraas no cadastro de críticas
If Len(aAnalise) > 0

	// Calcula as dimensoes dos objetos
	aSize  := MsAdvSize( .T. , .T.)
	
	aObjects	:= {}
	AAdd( aObjects, { 50,15,.T.,.T. } )							// Horizontal superior.
	AAdd( aObjects, { 50,60,.T.,.T. } )							// Horizontal Inferior.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³LR5 = Verifica se utiliza versão 11.5                            ³	
	//³Caso Utilize 11.5 retira -15 Posicoes no (quarto) 4ºParametro.³
	//³ Realiza ajuste da posicao do Objeto na tela                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lR5
		nTamTela1 := 15 
    EndIf
    aInfo := { aSize[1],aSize[2],aSize[3],aSize[4]-nTamTela1, 0, 0 }
	aPosObj	:= MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5];
	TITLE STR0006 PIXEL 
	
	RegToMemory("SA1",IIf(nOpc == 3,.T.,.F.))
	
	@aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3],(aPosObj[1,4] - 30) LABEL "" PIXEL 
	@aPosObj[1,1] + 7, aPosObj[1,2] + 5  SAY STR0015	SIZE 50,8 of ODLG PIXEL  //"Cliente"
	@aPosObj[1,1] + 7, aPosObj[1,2] + 25  SAY M->A1_NOME SIZE 100,8 of ODLG PIXEL //Nome do cliente
		
	@aPosObj[1,1] + 7, aPosObj[1,2] + 180 SAY STR0009 SIZE 50,10 of ODLG PIXEL 
	@aPosObj[1,1] + 7, aPosObj[1,2] + 210 SAY STR0010 SIZE 50,10 of ODLG PIXEL
	@aPosObj[1,1] + 7, aPosObj[1,2] + 240 SAY aAnalise[1] SIZE 40,8 of ODLG PIXEL //pontos acumulados
		
	@aPosObj[1,1] + 17, aPosObj[1,2] + 180 SAY STR0009  SIZE 50,10  of ODLG PIXEL
	@aPosObj[1,1] + 17, aPosObj[1,2] + 210 SAY STR0011 SIZE 50,10  of ODLG PIXEL 
	@aPosObj[1,1] + 17, aPosObj[1,2] + 240 SAY aAnalise[2] SIZE 40,8 of ODLG PIXEL // parametro MAXPONT
	
	@aPosObj[1,1] + 17, aPosObj[1,2] + 5  SAY aAnalise[3] SIZE 150,8 of ODLG PIXEL //Mensagem de classificacao do cliente
	
	//conforme a classificação do cliente é exibido a imagem do semaforo 
	@aPosObj[1,1] + 5, aPosObj[1,2] + 290   BITMAP oBmp RESOURCE aAnalise[4] Of oDlg NOBORDER SIZE 50,20 PIXEL
		                                                                        
	@aPosObj[2,1], aPosObj[2,2] TO aPosObj[2,3],aPosObj[2,4] LABEL "" PIXEL 
	oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"","","",.T.)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))

Else                    

	//Não há regras no cadastro de de críticas de crédito
	MsgStop( STR0012,  STR0013 )

EndIf

Return .T.                                                 

               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³CRC070_002   ºAutor³Viviane M. Fernandesº Data ³  05/07/03    º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Retorna um array com os dados necessários para a visualizacaoº±±
±±º         ³da tela                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPN1: Tipo da Consulta que será chamando	                  º±±
±±º         ³       1 - Classificacao/consulta a tabela de pontos         º±±
±±º         ³       2 - Consulta sem permissao para liberar               º±±
±±º         ³       3 - Consulta com permissão para liberar               º±±
±±º         ³EXPN2: Cliente da mBrowse                                    º±±
±±º         ³EXPN3: Loja do Cliente                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³EXPN1: Total de pontos obtido pela cosulta do cliente        º±±
±±º         ³EXPN2: Total Máximo de pontos que o cliente pode obter - ver º±±
±±º 		³	    parametro MV_MAXPONT                                  º±±
±±º         ³EXPC3: Mensagem de classificação da análise de crédito       º±± 
±±º         ³EXPC4: Bitmap que deverá ser visualizado                     º±± 
±±º         ³EXPC5: Resultado da análise de Crédito                       º±± 
±±º         ³EXPC6: REsultado da análise pessoal                          º±± 
±±º         ³EXPN7: Numero de regras que foi respondida pelo cliente      º±± 
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP7-Telecobrança-Cadastro de Questionário Socio Ecom. socialº±±
±±ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DATA    ³Versa³Programador³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/02/07³912  ³Fernando   ³Bops115955 Alteração feita para tratar aCols³±±
±±³        ³     ³           ³com os campos do Walk trhu                  ³±±
±±³03/10/07³133686³Nunzio     ³Considera so os scrits da filial corrente,  ³±±
±±³        ³      ³           ³se o arquivo for compartilhado e MAG_FILEMP ³±±
±±³        ³      ³           ³estiver vazio							   ³±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRC070_002(nTipo,cCliente,cLoja) // selecionando as criticas a serem executadas			

Local aCritica 		:= {}                  	//Array com os scripts de avaliacao
Local cMsg     		:= ""                  	//Retorna a mensagem da funcao
Local nTotPont 		:= 0                   	//Total de pontos
Local cSemaf   		:= ""					//Nao devera aparecer o semaforo
Local cSitCr   		:= ""					//Nao devera aparecer o botaozinho vermelho
Local cSitPer  		:= ""					//Define a cor do semafaro
Local nTotCrit 		:= 0 					//total de criticas para serem executadas 
Local nTotPer  		:= 0                    //Total de perguntas
Local cValorMacro 	:= ""					//Utilizada para executar uma macro
Local nPontos  		:= 0                   	//Total de pontos
Local nItem			:= 0                   	//Varialvel de controle contador

Private nMaxPont 	:= SuperGetMv("MV_MAXPONT")

If nMaxPont = 0                                                       
   cMsg     := STR0014 //"O valor de pontuacäo näo foi informado corretamente"
   nTotPont := 0  
   cSitCr:= ""   // não deverá aparecer o botaozinho vermelho
	nTotCrit := 0        
   cSemaf:= ""  // não deverá aparecer o semáforo
   Return({nTotpont,nMaxPont,cMsg, cSemaf, cSitCr ,cSitPer ,nTotcrit})

EndIf

dbSelectArea("MAG")
dbSetOrder(2)

//selecionando as criticas que forem da Empresa atual
MAG->(DbSeek(xFilial("MAG"), .T.))


While !Eof() // MAG->MAG_EMPRES == cEmpAnt .and. ( MAG->MAG_FILEMP == cFilAnt .or. Empty(MAG->MAG_FILEMP ) )  .and. !eof()

	If !Empty(MAG->MAG_EMPRES) .and. MAG->MAG_EMPRES <> cEmpAnt
		dbSkip()
		Loop
	EndIf
	
	If !Empty(MAG->MAG_FILIAL) .and. MAG->MAG_FILIAL <> cFilAnt
		dbSkip()
		Loop
	EndIF

    //Considera so os registros da filial corrente, se o arquivo for compartilhado e MAG_FILEMP estiver vazio
	If 	Empty(MAG->MAG_FILIAL) .AND. !Empty(MAG->MAG_FILEMP) .AND. MAG->MAG_FILEMP <> cFilAnt
		dbSkip()
		Loop
	EndIf  
	If !Empty(MAG->MAG_CRITIC) .and. !Empty(MAG->MAG_REGRA) // se existe o execblock (regra) a ser executada

  		AADD(aCritica, {MAG->MAG_CRITIC,MAG->MAG_REGRA,MAG->(Recno())})

  	EndIf
    	
  	MAG->(dbSkip())	    
    
End

//Verifica se o Perfil do cliente será analisado
	
nTotCrit := Len(aCritica) //Totalizador de perguntas para fazer a regra
								// de cálculo com base no parâmetro.
If nTotCrit > 0 

	For nItem:=1 to len(aCritica)

        dbSelectArea("MAG")
        dbGoto(aCritica[nItem,3])
		
		cValorMacro := ExecMacroInServer( aCritica[nItem,2] )

		If SubStr( cValorMacro,1,1) == "N"

			nPontos := Val( SubStr( cValorMacro,2 ))

		Else 

		   MsgStop( STR0016 + Chr(10) + Chr(10) + SubStr( cValorMacro, 2 ), STR0017 ) // "Houve problemas na execução da regra." ### "Atenção"
			nPontos := 0

		EndIf		
		
		If nTipo == 1 

		   Aadd(aCols,Array(Len(aHeader) + 1))	
	       aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_CRITIC"})]:= aCritica[nItem,1]
       	   aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_PESO"}) ]:= nPontos
		   aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_ALI_WT"}) ]:= "MAG"
		   aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_REC_WT"}) ]:= aCritica[nItem,3]		       
	       aCols[nItem,Len(aHeader) + 1]:= .F.                         	       
       	   nTotPont:= nTotPont + aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_PESO"})]
     	Else
       	   nTotPont:= nTotPont + nPontos
     	EndIf   
	Next
Else    

	// nao há regras para classificar o cliente
   cMsg := STR0013	              
   nTotPont := 0  
   cSitCr:= ""   // não deverá aparecer o botaozinho vermelho
	nTotCrit := 0        
   cSemaf:= ""  // não deverá aparecer o semáforo
   Return({nTotpont,nMaxPont,cMsg, cSemaf, cSitCr ,cSitPer ,nTotcrit}) 

EndIf

// calculo das resposta do questionario socio economico cultural
If nTipo == 3 .or. nTipo == 2

	nTotPer := CRC070_003(cCliente, cLoja)

EndIf				

// pra utilizar os dois quadrados eu tenho que ver se este parametro está ativo
If SuperGetMv("MV_PERFIL") 

	If nTotPer >= nMaxPont

		cSitPer:= "VERDE"

	Elseif nTotPer >= (nMaxPont / 2)	

	    cSitPer:= "AMARELO"

	Else              

	    cSitPer:= "VERMELHO"

	EndIf          	

EndIf

// se o valor total de analise credito - MAG
//
If nTotPont >= nMaxPont

	cMsg:= STR0018	// "Cliente padrão excelente."
	cSemaf:= "SVD"
	cSitCr := "VERDE"                    //só analiso o crédito

Elseif nTotPont >= (nMaxPont / 2)	

   cMsg:= STR0019 	// "Cliente com potencial de classificação."
   cSemaf:= "SAM"  
   cSitCr:= "AMARELO"

Else              

	cMsg:= STR0020 	// "Fora da faixa de pontuação."
	cSemaf:= "SVM"   
	cSitCr:= "VERMELHO"

EndIf                                   
	
// pergunto se o perfil é analisado e verifico a classifição do cliente com base neste parametro
If SuperGetMv("MV_PERFIL") 

	If cSitCr == "VERDE" .AND. (cSitPer == "VERDE" .OR. !SuperGetMv("MV_PERFIL") .OR. nTipo == 1 )// pra ser verde tenho que ter as duas análises 

		cMsg:= STR0018	// "Cliente padrão excelente."
		cSemaf:= "SVD"

	ElseIf cSitCr == "VERMELHO" .AND. (cSitPer == "VERMELHO" .OR. !SuperGetMv("MV_PERFIL") .OR. nTipo == 1 )

		cMsg:= STR0020	// "Fora da faixa de pontuação."
	    cSemaf:= "SVM"                                                               

	ELSE
	   
	   cMsg:= STR0019	// "Cliente com potencial de Classificação."
	   cSemaf:= "SAM"  

	ENDIF    

EndIf

Return({nTotpont,nMaxPont,cMsg, cSemaf, cSitCr ,cSitPer ,nTotcrit}) 


               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³CRDA070_003  ºAutor³Viviane M. Fernandesº Data ³  05/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Retorna a pontuacao obtida ao responder o questinario socio- º±±
±±          ³economico-social											  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPC1: Codigo do cliente  									  º±±
±±º         ³EXPC2: Loja do cliente 									  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³EXPN1: Total de pontos obtido no questionário                º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP7-Telecobrança-Cadastro de Questionário Socio Ecom. socialº±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION CRC070_003(cCliente,cLoja)
Local cValorMacro 	:= ""
Local nTotPontos		:= 0
Local nPontos			:= 0

dbSelectArea("MAI")
dbSetOrder(1)

If dbseek(xFilial("SA1")+cCliente+cLoja )
	
	While !eof() .and. MAI->MAI_CODCLI == cCliente
		
		nTotPontos:= nTotPontos +   MAI->MAI_PONTO
		dbSkip()
		
	End
	
EndIf

If SuperGetMv("MV_PERFIL") .and. !empty(SuperGetMv("MV_PEROT"))
	
	cValorMacro := ExecMacroInServer( SuperGetMv("MV_PEROT") )
	
	If SubStr( cValorMacro,1,1) == "N"
		
		nPontos := Val( SubStr( cValorMacro,2 ))
		
	Else
		
		MsgStop( STR0016 + Chr(10) + Chr(10) + SubStr( cValorMacro, 2 ), STR0017 )	// "Houve problemas na execução da regra." ### "Atenção"
		nPontos := 0
		
	EndIf
	
	nTotPontos += nPontos
	
EndIf

Return(nTotPontos)
