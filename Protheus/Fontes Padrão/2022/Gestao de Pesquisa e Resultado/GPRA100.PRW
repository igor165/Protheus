#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPRA100.CH"
#INCLUDE "GPRDEF.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPRA100    �Autor  � Henry Fila           � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extracao de resultados da pesquisa                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K.�09/08/04�710   �Revisao do fonte:Sintaxe,Documentacao,Logica���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GPRA100(aRotAuto,nOpc)

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local aCores        := {}

Private cCadastro 	:= STR0001 //"Extracao de Resultados"
Private cString   	:= "SKC"      	// Alias de Trabalho

Private aRotina 	:= 	MenuDef()

Aadd(aCores,{"SKC->KC_STATUS == '2'","BR_VERMELHO"}) //Pesquisa desativada 
Aadd(aCores,{"SKC->KC_STATUS == '1'","BR_VERDE"}) //Pesquisa ativa 

mBrowse( 6,1,22,75,"SKC",,,,,,aCores)

Return( .T. )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 12.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0002,"AxPesqui"  ,0,1} ,;	//"Pesquisar"
						{STR0003,"Gpr010Man"  ,0,2} ,;	//"Visualizar"
						{STR0004,"Gpr100Exp" ,0,4},;   //Exportacao XLS
						{STR0012,"Gpr100Leg" ,0,4}}	    //"Legenda"
Return(aRotina)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr100Exp  �Autor  � Henry Fila           � Data � 07/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extracao de resultados                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//������������������������������Ŀ
//�Se criou o arquivo de trabalho�
//��������������������������������
If nRegAux > 0

	//���������������������������������������������������������������������Ŀ
	//� Verifica o caminho a ser gravado o arquivo                          �
	//�����������������������������������������������������������������������
	cPath 		:= cGetFile("",STR0007,1,,.F.,GETF_LOCALHARD + GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ) //"Local para grava��o..."
	cArqPesq	:= cPath + "PQ" + cPesq + ".xls"	// Exemplo: PQ123456.xls
		
	//���������������������������������������������������������������������Ŀ
	//� Cria um arquivo do tipo *.xls                                       �
	//�����������������������������������������������������������������������
	nHandle := FCREATE(cArqPesq, 0)
	
	//�������������������������������������������������������������������������������������Ŀ
	//� Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido        �
	//���������������������������������������������������������������������������������������
	If FERROR() <> 0
		Alert(STR0009 + cPesq + ".xls") //"N�o foi poss�vel abrir ou criar o arquivo: "
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

		//�������������������������������������������������������������������������������������Ŀ
		//� Posiciona no inicio do arquivo                                                      �
		//���������������������������������������������������������������������������������������

		DbGoTop()
		
		ProcRegua(nRegAux)
		
		While !TRB->(EOF())
		
			cTexto := ""
	
			If !Empty(TRB->DISSERT)
			
				DbselectArea("SYP")
				DbSetOrder(1)
				If DbSeek(xFilial("SYP")+TRB->DISSERT)
				
				While 	(!Eof()) .AND. (SYP->YP_FILIAL == xFilial("SYP")) .AND. (SYP->YP_CHAVE == TRB->DISSERT)
					
					//�������������������������������������������������������������������������������������Ŀ
					//� Caso seja nao seja a primeira vez q o texto e concatenado, utiliza o TRIM(),        �
					//� caso contrario ALLTRIM()  						                                    �
					//���������������������������������������������������������������������������������������
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
		
		//�������������������������������������������������������������������������������������Ŀ
		//� Verifica se foi possivel gravar o arquivo, caso nao seja possivel um mensagem de 	�
		//� alerta ser� exibida na tela                  	                                    �
		//���������������������������������������������������������������������������������������
		
		If(FWRITE(nHandle, cTabela) == 0) 
			Alert(STR0010)	 //"N�o foi poss�vel gravar o arquivo!"
		EndIf
	
		//�������������������������������������������������������������������������������������Ŀ
		//� Fecha o arquivo gravado                                                          	�
		//���������������������������������������������������������������������������������������
		FCLOSE(nHandle)
	
		If MsgYesNo(STR0008+cArqPesq+". "+STR0015) //"O arquivo foi gerado no diret�rio "
			//�������������������������������������������������������������������������������������Ŀ
			//� Abre Excel                                                                       	�
			//���������������������������������������������������������������������������������������
	
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
	MsgStop(STR0011)//"N�o h� dados para a pesquisa selecionada"
Endif

RestArea( aArea )
	
Return( .T. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr100Leg  �Autora � Henry Fila           � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a Legenda das Pesquisas                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr100Leg()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K.�09/08/04�710   �-Revisao do fonte:Sintaxe, documentacao     ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr100Leg()

/*
  ��������������������������������������������������Ŀ
  �VERMELHO  - Ativa                                 �
  �VERDE     - Inativa                               �
  �PRETO     - Vencida                               �
  ����������������������������������������������������
*/

Local aLegenda := {	{"BR_VERMELHO",	STR0007},; 	// "Pesquisa desativada"
					{"BR_VERDE"  ,STR0008 }}  //"Pesquisa ativa"

BrwLegenda(STR0006,STR0005,aLegenda)  //Legenda##Status da pesquisa

Return( .T. )



