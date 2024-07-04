#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPRA100.CH"
#INCLUDE "GPRDEF.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPRA100    ³Autor  ³ Henry Fila           ³ Data ³ 20/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extracao de resultados da pesquisa                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K.³09/08/04³710   ³Revisao do fonte:Sintaxe,Documentacao,Logica³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPRA100(aRotAuto,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aCores        := {}

Private cCadastro 	:= STR0001 //"Extracao de Resultados"
Private cString   	:= "SKC"      	// Alias de Trabalho

Private aRotina 	:= 	MenuDef()

Aadd(aCores,{"SKC->KC_STATUS == '2'","BR_VERMELHO"}) //Pesquisa desativada 
Aadd(aCores,{"SKC->KC_STATUS == '1'","BR_VERDE"}) //Pesquisa ativa 

mBrowse( 6,1,22,75,"SKC",,,,,,aCores)

Return( .T. )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 12.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0002,"AxPesqui"  ,0,1} ,;	//"Pesquisar"
						{STR0003,"Gpr010Man"  ,0,2} ,;	//"Visualizar"
						{STR0004,"Gpr100Exp" ,0,4},;   //Exportacao XLS
						{STR0012,"Gpr100Leg" ,0,4}}	    //"Legenda"
Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gpr100Exp  ³Autor  ³ Henry Fila           ³ Data ³ 07/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extracao de resultados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Gpr100Exp( aAlias, nReg, nOpc ) 

Local aCampos   := {}                              //Campos do arquivo de trabalho
Local aArea     := GetArea()

Local cPesq   	:= SKC->KC_CODPQ					// Codigo da Pesquisa escolhida - posicao no Browse
Local cQuery  	:= ""								// Sintaxe da Query
Local cPath   	:= ""

Local cArqPesq 	:= ""								// Nome do arquivo que foi gerado
Local cIndex 	:= ""								// Chave do arquivo de trabalho
Local cTexto	:= ""								// exportacao do campo MEMO	
Local cTabela	:= ""								// Tabela dos resultados da pesquisa a ser exportada
Local cDescAlt  := ""                              // Descricao da alternativa 
Local cDescCol  := ""                              // Descricao da coluna 
Local cDescQues := ""                              // Descricao da questao 

Local nHandle	:= 0								// Indicador de arquivo de exportacao aberto
Local nContTxt	:= 0
Local nRadio	:= 1								// Opcoes do radio button
Local nOpca     := 0                                // Variavel de controle de tela
Local nRegAux	:= 0								// handle do arquivo de trabalho

Local oDlgDef										// Objeto da caixa de dialogo
Local oRadio										// Objeto do Radio Button da Caixa de dialogo


cQuery := "SELECT "
cQuery += "SKU.KU_CODPESQ PESQUISA, SKU.KU_CODRESP RESPOND, SKU.KU_CODQUES CODQUES, SKG.KG_DESC QUESTAO,"
cQuery += "SKU.KU_CODALT  ALTERNAT, SKH.KH_DESC    DESCALT, SKU.KU_CODCOL  COLUNA,"
cQuery += "SKI.KI_DESC    ESCOLHA,SKU.KU_CODDISS DISSERT, '" + SPACE(400) + "' TEXTO "
cQuery += " FROM "
cQuery += RetSqlName( "SKU" )+ " SKU LEFT JOIN "    
cQuery += RetSqlName( "SKI" )+ " SKI ON( "		

cQuery += " SKI.KI_FILIAL = '" + xFilial( "SKI" ) + "' AND "
cQuery += " SKI.KI_CODQST = SKU.KU_CODQUES AND "
cQuery += " SKI.KI_CODCOL = SKU.KU_CODCOL AND "
cQuery += " SKI.D_E_L_E_T_ = ' ' ) LEFT JOIN "		
									
cQuery += RetSqlName( "SKH" )+ " SKH ON("		

cQuery += " SKH.KH_FILIAL = '" + xFilial( "SKH" ) + "' AND "
cQuery += " SKH.KH_CODQST = SKU.KU_CODQUES AND "
cQuery += " SKH.KH_CODALT = SKU.KU_CODALT AND "
cQuery += " SKH.D_E_L_E_T_ = ' ' ),"

cQuery += RetSqlName( "SKG" )+ " SKG "		

cQuery += " WHERE "
cQuery += " KU_FILIAL = '"+ xFilial( "SKU" ) + "' AND "
cQuery += " KU_CODPESQ = '"+ cPesq+"' AND "
cQuery += " SKU.D_E_L_E_T_ = ' ' AND "

cQuery += " KG_FILIAL = '"+ xFilial( "SKG" ) + "' AND "
cQuery += " KG_CODQST = KU_CODQUES AND "
cQuery += " SKG.D_E_L_E_T_ = ' ' "

cQuery += "ORDER BY 1, 2, 3

cQuery := ChangeQuery(cQuery)

MsgRun(STR0006, SKC->KC_CODPQ, {|| dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .F.)}) //"Lendo arquivo de pesquisas, Aguarde..."

nRegAux := Select("TRB")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se criou o arquivo de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRegAux > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o caminho a ser gravado o arquivo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPath 		:= cGetFile("",STR0007,1,,.F.,GETF_LOCALHARD + GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ) //"Local para gravação..."
	cArqPesq	:= cPath + "PQ" + cPesq + ".xls"	// Exemplo: PQ123456.xls
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria um arquivo do tipo *.xls                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHandle := FCREATE(cArqPesq, 0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FERROR() <> 0
		Alert(STR0009 + cPesq + ".xls") //"Não foi possível abrir ou criar o arquivo: "
	Else
		cTabela := "<table border=1>"	
		cTabela += "<tr><td>RESPONDENTE</td>"
		cTabela += "<td>PESQUISA</td>"
		cTabela += "<td>CODIGO DA QUESTAO</td>"				    
		cTabela	+= "<td>QUESTAO</td>"
		cTabela	+= "<td>CODIGO ALTERNATIVA</td>"
		cTabela	+= "<td>ALTERNATIVA</td>"
		cTabela	+= "<td>COLUNA</td>"
		cTabela	+= "<td>ESCOLHA</td>"
		cTabela	+= "<td>DISSERTATIVA</td>"
		cTabela	+= "<td>TEXTO</td></tr>"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no inicio do arquivo                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		DbGoTop()
		
		ProcRegua(nRegAux)
		
		While !TRB->(EOF())
		
			cTexto := ""
	
			If !Empty(TRB->DISSERT)
			
				DbselectArea("SYP")
				DbSetOrder(1)
				If DbSeek(xFilial("SYP")+TRB->DISSERT)
				
				While 	(!Eof()) .AND. (SYP->YP_FILIAL == xFilial("SYP")) .AND. (SYP->YP_CHAVE == TRB->DISSERT)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso seja nao seja a primeira vez q o texto e concatenado, utiliza o TRIM(),        ³
					//³ caso contrario ALLTRIM()  						                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nContTxt > 0
						cTexto += TRIM(SYP->YP_TEXTO)	// SYP_TEXTO = 80 Caracteres
					Else
						cTexto += ALLTRIM(SYP->YP_TEXTO)	// SYP_TEXTO = 80 Caracteres
					EndIf
					
					nContTxt++
					SYP->(DbSkip())
					End
				Endif	 
			Endif 

			DbSelectArea("TRB")
			cTabela			+=	"<tr><td>" + ALLTRIM(TRB->RESPOND) + "</td>"
			cTabela			+=	"<td>" + ALLTRIM(TRB->PESQUISA) + "</td>"
			cTabela			+=	"<td>" + ALLTRIM(TRB->CODQUES) + "</td>"				       
			cTabela			+=	"<td>" + ALLTRIM(TRB->QUESTAO) + "</td>"
			cTabela			+=	"<td>" + ALLTRIM(TRB->ALTERNAT) + "</td>"
			cTabela			+=	"<td>" + ALLTRIM(TRB->DESCALT) + "</td>"
			cTabela			+=	"<td>" + ALLTRIM(TRB->COLUNA) + "</td>"
			cTabela			+=	"<td>" + ALLTRIM(TRB->ESCOLHA) + "</td>"
			cTabela			+=	"<td>" + ALLTRIM(TRB->DISSERT) + "</td>"
			cTabela			+=	"<td>" + cTexto + "</td></tr>"
			TRB->(DbSkip())
		End
		
		cTabela += "</table>"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foi possivel gravar o arquivo, caso nao seja possivel um mensagem de 	³
		//³ alerta será exibida na tela                  	                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If(FWRITE(nHandle, cTabela) == 0) 
			Alert(STR0010)	 //"Não foi possível gravar o arquivo!"
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha o arquivo gravado                                                          	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FCLOSE(nHandle)
	
		If MsgYesNo(STR0008+cArqPesq+". "+STR0015) //"O arquivo foi gerado no diretório "
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abre Excel                                                                       	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			If ApOleClient( 'MsExcel' ) 
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cArqPesq ) // Abre uma planilha
				oExcelApp:SetVisible(.T.)
			Else
				Alert( STR0014 )	 //"Microsoft Excel nao encontrado !"
			EndIf
		Endif
			
	Endif
	
	TRB->( dbCloseArea() )	            
	
Else
	MsgStop(STR0011)//"Não há dados para a pesquisa selecionada"
Endif

RestArea( aArea )
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gpr100Leg  ³Autora ³ Henry Fila           ³ Data ³ 20/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a Legenda das Pesquisas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gpr100Leg()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K.³09/08/04³710   ³-Revisao do fonte:Sintaxe, documentacao     ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gpr100Leg()

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³VERMELHO  - Ativa                                 ³
  ³VERDE     - Inativa                               ³
  ³PRETO     - Vencida                               ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

Local aLegenda := {	{"BR_VERMELHO",	STR0007},; 	// "Pesquisa desativada"
					{"BR_VERDE"  ,STR0008 }}  //"Pesquisa ativa"

BrwLegenda(STR0006,STR0005,aLegenda)  //Legenda##Status da pesquisa

Return( .T. )



