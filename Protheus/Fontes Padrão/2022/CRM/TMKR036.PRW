#INCLUDE "TMKR036.CH"
#INCLUDE "PROTHEUS.CH"      
#INCLUDE "REPORT.CH"

/*
  旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
  � aScripts[X][1] - Codigo do Script                    �
  � aScripts[X][2] - Array com as perguntas deste Scripts�
  � aScripts[X][3] - Array com as respostas deste Scripts�
  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

  旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  쿌PERGUNTA                                                                �
  �1- UP_CODCAMP	-	Codigo do Script                                    �
  �2- UP_CARGO	    -	Codigo do Item                                      �
  �3- UP_IDTREE	    -	Cargo Pai deste Item. (em que ele esta amarrado)    �
  �4- UP_DESC		-   Descricao da resposta.                              �
  �5- UP_CODOBS	    -   Codigo da Observacao da pergunta                    �
  �6- UP_SCORE	    -   Pontuacao da resposta no cadastro de Scripts        �
  �7- UP_TIPOOBJ	-   Tipo da Resposta ('1','2' ou '3')                   �
  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  쿌RESPOSTA                                                                �
  �1- UP_CODCAMP	-	Codigo do Script                                    �
  �2- UP_CARGO	    -	Codigo do Item                                      �
  �3- UP_IDTREE	    -	Cargo Pai deste Item. (em que ele esta amarrado)    �
  �4- UP_DESC		-   Descricao da resposta.                              �
  �5- UP_CODOBS	    -   Codigo da Observacao da resposta                    �
  �6- UP_SCORE	    -   Pontuacao da resposta no cadastro de Scripts        �
  �7- UP_TIPOOBJ	-   Tipo da Resposta ('1','2' ou '3')                   �
  �8- 0             -  	Pontuacao de cada resposta.                         �
  �9- Array         -  	Array com os textos referentes a resposta.          �
  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TMKR036  � Autor � Rafael M. Quadrotti   � Data � 16/05/03 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Resultado de Scripts Din�micos.                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Call Center - Gerencia de Campanhas                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K.�75670   �7.10  쿎orrecao do SELECT para INFORMIX 	          낢�
굇쿘ichel W. �99206   �8.11  쿌tualizacao relatorios release 4.	          낢�
굇쿘ichel W. �21/08/06�8.11  쿝evisao do fonte.                           낢�
굇쿎onrado Q.�22/02/07�9.12  �-Bops 119542: Retirado fun豫o de ajuste de  낢�
굇�          �        �      쿭icion�rio.                                 낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/  
Function TMKR036()
Local oReport	//Objeto relatorio TReport (Release 4)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte("TMK036",.F.)

/*旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	� Variaveis utilizadas para parametros                          �
	� Mv_Par01           // Campanha                                �
	� Mv_Par02           // Do Script                               �
	� Mv_Par03           // Ate Script                              �
	� Mv_Par04           // Da data                                 �
	� Mv_Par05           // Ate a Data                              �
/*읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/


//旼컴컴컴컴컴컴컴컴컴컴커
//쿔nterface de impressao�
//읕컴컴컴컴컴컴컴컴컴컴켸
oReport := ReportDef()
oReport:PrintDialog() 

Return Nil            



/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟KR036VlSc튍utor  쿝afael M. Quadrotti � Data �  06/03/03   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿣alidacao dos scripts informados com relacao a campanha     볍�
굇�          쿭efinida no MV_PAR01                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP7                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function TKR036VlSc(nScripts,aScripts,cScripts)
Local lRet 		:= .F.			//	Retorno da Funcao
Local aSArea	:= GetArea()	//	Grava o alias anterior

DbSelectArea("SUW")
DbSetOrder(1)
If MsSeek(xFilial("SUW")+AllTrim(Mv_Par01))
	While	(!Eof())							.AND.;
			(xFilial("SUW")==SUW->UW_FILIAL)	.AND.;
			(SUW->UW_CODCAMP ==	 Mv_Par01   )
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿌rmazena todos os Scripts relacionados a campanha.�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		// aScripts[X][1] - Codigo do Script
		// aScripts[X][2] - Array com as perguntas deste Scripts
		// aScripts[X][3] - Array com as respostas deste Scripts
		Aadd(aScripts,{SUW->UW_CODSCRI,{},{}})
		SUW->(DbSkip())
	End
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌rmazena os Scripts selecionados nos parametos.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
For nScripts := 1 To Len(aScripts)
	If (aScripts[nScripts][1] >= MV_PAR02) .AND. (aScripts[nScripts][1] <= MV_PAR03)
		cScripts+= "'" + aScripts[nScripts][1]+ "',"
	Endif
Next nScripts

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿟ratamento para retirada da ', ' para a clausula IN do SQL.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cScripts := SubStr(cScripts,1, Len(cScripts)-1)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e esta variavel estiver vazia os scripts definidos nos parametros        �
//쿮stao incorretos. O sistema so permitira a impressao dos relatorios se os �
//퀂cripts informados estiverem corretos.                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If Empty(cScripts)
	lRet := .F.
Else
	lRet := .T.	
EndIf

RestArea(aSArea)
Return (lRet)
                                   

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    ReportDef � Autor 쿘ichel W. Mosca     � Data �01/08/2007낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿝otina que define os itens que serao apresentados no relato-낢�
굇�          퀁io de Resultado de Scripts Din�micos no release 4.         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � ReportDef(ExpN1, ExpA2, ExpC3)                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿐xpN1 = Numero de scripts da campanha selecionada           낢�
굇�          쿐xpN2 = Array contendo dados dos scripts                    낢�
굇�          쿐xpC3 = codigos dos scripts para consulta ao DB.            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Generico                                                   낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/                       
Static Function ReportDef()
Local oReport			//Objeto relatorio TReport (Release 4)
Local oSection1 		//Objeto secao 1 do relatorio (Dados do script da campanha)
Local oSection2 		//Objeto secao 2 do relatorio (Perguntas associadas ao script)
Local oSection3 		//Objeto secao 3 do relatorio (Repostas as perguntas)
Local cACI := GetNextAlias() 	// Gerencia o alias entre top e dbf
Local cSUK := cACI 	// Gerencia o alias entre top e dbf
Local nScripts	:= 0	// Contador do For.
Local aScripts	:= {}	// Array com os scripts que estao definidos no item da Campanha selecionada.
Local cScripts	:= ""	// String com os codigos dos Scripts selecionados.


// "Resultado de Scripts Dinamicos" # // "Este programa ira emitir uma relacao dos Scripts dinamicos"
// "totalizando todas das respostas dadas de acordo com o" # // "periodo e Campanhas definidas. "
DEFINE REPORT oReport NAME "TMKR036" TITLE STR0001 PARAMETER "TMK036" ACTION {|oReport| Tkr036PrtRpt( oReport, @nScripts,@aScripts,@cScripts, cACI, cSUK)} DESCRIPTION STR0002 + STR0003 + STR0004


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏efine a secao1 do relatorio, informando que o arquivo principal � 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
DEFINE SECTION oSection1 OF oReport TITLE STR0032  		//"Dados do script da campanha"
DEFINE SECTION oSection2 OF oSection1 TITLE STR0033 	//"Perguntas associadas ao script"
DEFINE SECTION oSection3 OF oSection2 TITLE STR0034 	//"Repostas as perguntas"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏efine as celulas que irao aparecer na secao1�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
DEFINE CELL NAME "S1_SCRIPT"	OF oSection1 TITLE STR0010 SIZE 70

DEFINE CELL NAME "S2_PERGUNT"	OF oSection2 TITLE STR0013 SIZE 70 LINE BREAK

DEFINE CELL NAME "S3_RESP"		OF oSection3 TITLE STR0014 SIZE 70 LINE BREAK
DEFINE CELL NAME "S3_SCORE"		OF oSection3 TITLE STR0011 SIZE 10
DEFINE CELL NAME "S3_TOT"		OF oSection3 TITLE STR0012 SIZE 10
DEFINE CELL NAME "S3_OBS"		OF oSection3 TITLE STR0031 SIZE 70 LINE BREAK 

Return(oReport)   

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿟kr036PrtRpt � Autor 쿘ichel W. Mosca     � Data �01/08/2007낢�
굇�          �             �       �                    �      �          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿝otina responsavel pela impressao do relatorio de Resultados낢�
굇�          쿭e Scripts Dinamicos  no release 4.                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � Tkr036PrtRept(ExpO1,ExpN1,ExpN2,ExpC3,ExpC4,ExpC5)         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpO1 = objeto relatorio                                   낢�
굇�          � ExpN1 = Numero de scripts da campanha selecionada          낢�
굇�          � ExpN2 = Array contendo dados dos scripts                   낢�
굇�          � ExpC3 = codigos dos scripts para consulta ao DB.           낢�
굇�          � ExpC4 = alias da query atual ACI                           낢�
굇�          � ExpC5 = alias da query atual SUK                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Generico                                                   낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function Tkr036PrtRpt(oReport, nScripts, aScripts, cScripts, cACI, cSUK)
Local oSection1 := oReport:Section(1) 		//Objeto secao 1 do relatorio (Dados do script da campanha)
Local oSection2 := oSection1:Section(1)		//Objeto secao 2 do relatorio (Perguntas associadas ao script)
Local oSection3 := oSection2:Section(1)    //Objeto secao 3 do relatorio (Repostas as perguntas)


Local cFiltro	:= ""   					//String contendo o filtro de busca a ser utilizado com DBF   

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏eclaracao de variaveis especificas para este relatorio�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local nI		   := 0			// Contador
Local aLinhas	   := {}		// Recebe as linhas do memo
Local dDatIniCamp  :=CtoD("//")	// Data Inicial da vigencia da Campanha
Local dDatFimCamp  :=CtoD("//")	// Data Final de vigencia da Campanha
Local aPergunta    := {}		// Array auxiliar para as perguntas
Local aResposta    := {}		// Array auxiliar para as Respostas
Local nPosResp	   := 0			// Retorno de AsCan
Local nPosScript   := 0			// Retorno do AsCan
Local aRespTemp    := {}		// Array temporario de respostas para utilizacao do contador.
Local lDado        := .F.		// Flag para identificar se existem dados para impressao.
Local cCodPerg     := ""		// Codigo da pergunta relacionada a resposta
Local nPosPerg     := 0			// Posicao da pergunta.
Local nW           := 0			// Controle de for para impressao de Memo.
Local nLenAux	   := 0 		// Contador auxilar para o FOR
Local cAuxObs					//Armazena o conteudo da resposta informada pelo usu�rio
Local cStringAux    := ""		//Var auxiliar para tirar aspas simples da string


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿗aco para verificacao dos parametros digitados.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !TKR036VlSc(@nScripts,@aScripts,@cScripts)
		Aviso(STR0029,STR0030,{"OK"}) //"Pergunte"###"Os Par�metros de Scripts nao pertencem a campanha definida."
		oReport:PrintText(STR0035+STR0029+" "+STR0030+" "+STR0036) //"Falha: "    /"Verifique os par�metros para a impress�o do relat�rio."
Else
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	//쿣erifica se a Campanha foi preenchida para pesquisa dos Scripts que estao no itens. �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	
	If !Empty(Mv_Par01)
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿌rmazena as datas de vigencia da campanha para validacao do periodo para impressao.�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		DbSelectArea("SUO")
		DbSetOrder(1)
		If MsSeek(xFilial("SUO")+AllTrim(Mv_Par01))
			dDatIniCamp:= SUO-> UO_DTINI
			dDatFimCamp:= SUO-> UO_DTFIM
		Endif
	Endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿣alidacao da data inical para selecao dos resultados.          �
	//쿌s datas de inicio e fim devem respeitar as datas definidas na �
	//쿬ampanha.                                                      �
	//쿞e Data Inicial da Campanha  > que data do Parametro Dt Inicial�
	//�     Data Inicial valida = Data Inicial da Campanha            �
	//쿞enao                                                          �
	//�     Data Inicial valida = Data do Parametro Dt Inicial        �
	//쿑imSe                                                          �
	//�                                                               �
	//쿞e Data Final da Campanha  < que data do Parametro Dt Final    �
	//�     Data Final valida = Data Final da Campanha                �
	//쿞enao                                                          �
	//�     Data Final valida = Data do Parametro Dt Final            �
	//쿑imSe                                                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	
	If (dDatIniCamp < MV_PAR04) .OR. Empty(dDatIniCamp)
		dDatIniCamp := MV_PAR04
	Endif
	
	If (dDatFimCamp > MV_PAR05)	.OR. Empty(dDatFimCamp)
		dDatFimCamp := MV_PAR05
	Endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿛ara cada Script serao armazenadas as Perguntas e Respostas�
	//쿽nde serao tambem totalizadas as respostas.                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	//쿎arrega as perguntas e repostas.�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	DbSelectArea("SUP")
	DbSetOrder(1)               
	nLenAux := Len(aScripts)
	For nScripts := 1 To nLenAux
		
		If MsSeek(xFilial("SUP") + aScripts[nScripts][1])
			
			While (!Eof()) 							 		.AND.;
				 (xFilial("SUP") == SUP->UP_FILIAL) 		.AND.; 
				 (aScripts[nScripts,1] == SUP->UP_CODCAMP)
				
				If !Empty(SUP->UP_TIPOOBJ)
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//쿌PERGUNTA                                                                �
					//�1- UP_CODCAMP	-	Codigo do Script                                    �
					//�2- UP_CARGO	    -	Codigo do Item                                      �
					//�3- UP_IDTREE	    -	Cargo Pai deste Item. (em que ele esta amarrado)    �
					//�4- UP_DESC		-   Descricao da resposta.                              �
					//�5- UP_CODOBS	    -   Codigo da Observacao da pergunta                    �
					//�6- UP_SCORE	    -   Pontuacao da resposta no cadastro de Scripts        �
					//�7- UP_TIPOOBJ	-   Tipo da Resposta ('1','2' ou '3')                   �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					
					Aadd(aPergunta,{UP_CODCAMP	,;	//	 Codigo do Script
									UP_CARGO	,;	//	 Cargo do Item.
									UP_IDTREE	,;	//	 Cargo Pai deste item. (em quem ele esta amarrado)
									UP_DESC		,;
									UP_CODOBS	,;
									UP_SCORE	,;
									UP_TIPOOBJ})      
	
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//쿞e o tipo de resposta for dissertativa nao ha uma referencia �
					//쿻a base de dados para a resposta pois a informacao fica      �
					//쿪rmazenada na pergunta. Neste caso crio uma posicao          �
					//쿾ara resposta dissetativa para armazenamento das informacoes �
					//쿭igitadas.                                                   �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					If SUP->UP_TIPOOBJ == "3" 
						Aadd(aResposta,{	UP_CODCAMP	,; //	Codigo do Script
											"00000000"	,; //	Codigo do Item
											UP_CARGO	,; //	Cargo Pai deste Item. (em que ele esta amarrado) - utilizado o cargo da pergunta
											""			,;
											""			,;
											0			,; //	Score
											""			,;
											0			,; //	Pontuacao de cada resposta.
											{}			})
					Endif								
					
				Else
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//쿌RESPOSTA                                                                �
					//�1- UP_CODCAMP	-	Codigo do Script                                    �
					//�2- UP_CARGO	    -	Codigo do Item                                      �
					//�3- UP_IDTREE	    -	Cargo Pai deste Item. (em que ele esta amarrado)    �
					//�4- UP_DESC		-   Descricao da resposta.                              �
					//�5- UP_CODOBS	    -   Codigo da Observacao da resposta                    �
					//�6- UP_SCORE	    -   Pontuacao da resposta no cadastro de Scripts        �
					//�7- UP_TIPOOBJ	-   Tipo da Resposta ('1','2' ou '3')                   �
					//�8- 0             -  	Pontuacao de cada resposta.                         �
					//�9- Array         -  	Array com os textos referentes a resposta.          �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					
					Aadd(aResposta,{	UP_CODCAMP	,; //	Codigo do Script
										UP_CARGO	,; //	Codigo do Item
										UP_IDTREE	,; //	Cargo Pai deste Item. (em que ele esta amarrado)
										UP_DESC		,;
										UP_CODOBS	,;
										UP_SCORE	,;
										UP_TIPOOBJ	,;
										0			,; //	Pontuacao de cada resposta.
										{}			})
				Endif
				
				DbSkip()
			End
			
		Endif
	
		aScripts[nScripts][2] := aPergunta
		aScripts[nScripts][3] := aResposta
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿗impa as informacoes para o proximo script.�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		aPergunta := {}
		aResposta := {}
		
	Next nScripts
		
	MakeSqlExpr("TMKR006")      
	
	cScriptsAux :=SubStr(cScripts,2, Len(cScripts)-2)

	BEGIN REPORT QUERY oSection1
	BeginSQL alias cACI                          	
			SELECT ACI_FILIAL,		ACI_CODCAM,		ACI_CODSCR,		ACI_CODSCR,
					ACI_DATA,			ACI_CODIGO,		UK_FILIAL,		UK_CODIGO,
					UK_CODPERG,		UK_CODRESP,		UK_CODMEMO		           
			FROM %table:ACI% ACI,	%table:SUK% SUK 

			WHERE	ACI.ACI_FILIAL = %xFilial:ACI% 		AND
					ACI.ACI_CODCAM = %exp:Mv_Par01%    	AND
					ACI.ACI_CODSCR IN(%exp:cScriptsAux%) 	AND
					ACI.ACI_DATA BETWEEN %exp:DtoS(dDatIniCamp)%	AND %exp:DtoS(dDatFimCamp)%		AND
					ACI.%notDel%						 AND
					SUK.UK_FILIAL = %xFilial:SUK% 		 AND
					SUK.UK_CODIGO = ACI.ACI_CODIGO 		 AND
					SUK.%notDel%				
			ORDER BY %order:ACI%
	EndSql    
	END REPORT QUERY oSection1      
	
	While	(!Eof())								.AND.;
			(cACI)->ACI_FILIAL == xFilial("ACI")	.AND.;
			(cACI)->ACI_CODCAM == Mv_Par01			.AND.;
			(cACI)->ACI_CODSCR >= Mv_PAR02			.AND.;
			(cACI)->ACI_CODSCR <= Mv_PAR03
		
	    oReport:IncMeter()
		
		If oReport:Cancel()
			Exit
		EndIf
					
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿣erifico a posico do Script que esta sendo trabalhado no �
		//쿪rray de Scripts que serao emitidos.                     �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		nPosScript := Ascan(aScripts,{|aVal| aVal[1] = (cACI)->ACI_CODSCR})
		
		aRespTemp := aScripts[nPosScript][3]
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿛esquisa em todo o array de respostas (aResposta) a resposta gravada no SUK		�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿌RESPOSTA                                                                �
		//�1- UP_CODCAMP	-	Codigo do Script                                    �
		//�2- UP_CARGO	    -	Codigo do Item                                      �
		//�3- UP_IDTREE	    -	Cargo Pai deste Item. (em que ele esta amarrado)    �
		//�4- UP_DESC		-   Descricao da resposta.                              �
		//�5- UP_CODOBS	    -   Codigo da Observacao da resposta                    �
		//�6- UP_SCORE	    -   Pontuacao da resposta no cadastro de Scripts        �
		//�7- UP_TIPOOBJ	-   Tipo da Resposta ('1','2' ou '3')                   �
		//�8- 0             -  	Pontuacao de cada resposta.                         �
		//�9- Array         -  	Array com os textos referentes a resposta.          �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		cCodPerg := (cSUK)->UK_CODPERG
		nPosResp := Ascan(aRespTemp,{|aVal| aVal[2] = (cSUK)->UK_CODRESP})
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿎aso a resposta seja encontrada sera contabilizada.�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If nPosResp > 0
			lDado := .T.
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿣erifica se o tipo de objeto da resposta eh memo.                       �
			//쿛ara saber se esta resposta utiliza memo (respostas dissertativas)      �
			//퀂era verificada a pergunta a ela relacionada que contem esta informacao.�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿌PERGUNTA                                                                �
			//�1- UP_CODCAMP	-	Codigo do Script                                    �
			//�2- UP_CARGO	    -	Codigo do Item                                      �
			//�3- UP_IDTREE	    -	Cargo Pai deste Item. (em que ele esta amarrado)    �
			//�4- UP_DESC		-   Descricao da resposta.                              �
			//�5- UP_CODOBS	    -   Codigo da Observacao da pergunta                    �
			//�6- UP_SCORE	    -   Pontuacao da resposta no cadastro de Scripts        �
			//�7- UP_TIPOOBJ	-   Tipo da Resposta ('1','2' ou '3')                   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
								
			nPosPerg := Ascan(aScripts[nPosScript][2],{|aVal| aVal[2] = cCodPerg})
			If aScripts[nPosScript][2][nPosPerg][7] <> '3' // Diferente de Memo 
				
				aScripts[nPosScript][3][nPosResp][8]+= 1
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//쿟ratamento para impressao do memo de resposta aberta.�
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				If Alltrim(aScripts[nPosScript][3][nPosResp][4]) == STR0008 //"RESPOSTA ABERTA"
					Aadd(aScripts[nPosScript][3][nPosResp][9],(cSUK)->UK_CODMEMO)
				Endif
			
			Else
				nPosResp := Ascan(aRespTemp,{|aVal| aVal[3] = cCodPerg})
				If nPosResp > 0
					If (aScripts[nPosScript][3][nPosResp][3] = cCodPerg)
						Aadd(aScripts[nPosScript][3][nPosResp][9],(cSUK)->UK_CODMEMO)
					Endif	
				Endif	
			Endif
		
		Endif
		
		// Limpa variaveis auxiliares
		nPosResp := 0
		aRespTemp:= {}
	
		DbSelectArea(cACI)
		DbSkip()
	End
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿜uebra a linha, caso existam muitas colunas�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	oSection1:SetLineBreak()
	oSection2:SetLineBreak()
		
	
	If lDado
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿔mpressao dos dados da campanha�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		oReport:FatLine()
		oReport:PrintText(STR0009 + MV_PAR01+ "-"+ Posicione("SUO",1,xFilial("SUO") + MV_PAR01,"UO_DESC"))		
		oReport:FatLine()		
		
		For nScripts := 1 To Len(aScripts)
					
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Verifico se o script faz parte dos scripts selecionados  �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If !( aScripts[nScripts][1] $ cScripts)
				Loop
			Endif
		
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Impressao do Titulo do Script Dinamico                   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		
		//S1_SCRIPT	
			oSection1:Init()
			oSection1:Cell("S1_SCRIPT"):SetValue(aScripts[nScripts][1]+ "-"+ Posicione("SUZ",1,xFilial("SUZ") + aScripts[nScripts][1],"UZ_DESC"))
			oSection1:PrintLine()	
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Laco para impressao das perguntas.                       �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			// aScripts[x][1] - Codigo do Script
			// aScripts[x][2] - Array com as perguntas deste Scripts
			// aScripts[x][3] - Array com as respostas deste Scripts
		                                       
		
			For nPosPerg := 1 To Len(aScripts[nScripts][2]) // Perguntas
		
		//S2_PERGUNT
				oSection2:Init()
				oSection2:Cell("S2_PERGUNT"):SetValue(aScripts[nScripts][2][nPosPerg][4])
				oSection2:PrintLine()
				
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//� Inicio da impressao das respostas.                       �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//� Laco para impressao das respostas.                       �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				oSection3:Init()                
				For nPosResp:= 1 To Len(aScripts[nScripts][3])
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//� Se a resposta for relacionada com a pergunta             �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			 		
					If aScripts[nScripts][3][nPosResp][3] == aScripts[nScripts][2][nPosPerg][2]
						
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
						//� Se o tipo de dados for diferente de Memo                 �
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
						If aScripts[nScripts][2][nPosPerg][7] <> '3' // Memo        
							
							oSection3:Cell("S3_RESP" ):Enable()
							oSection3:Cell("S3_SCORE"):Enable()
							oSection3:Cell("S3_TOT"  ):Enable()
							oSection3:Cell("S3_OBS"  ):Disable()
								
							oSection3:Cell("S3_RESP" ):SetValue(aScripts[nScripts][3][nPosResp][4])
							oSection3:Cell("S3_SCORE"):SetValue(Transform(aScripts[nScripts][3][nPosResp][6],"99999"))
							oSection3:Cell("S3_TOT"  ):SetValue(Transform(aScripts[nScripts][3][nPosResp][8],"99999"))							
							
						Else
							//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
							//� Se existirem dados para serem impressos sera executado um laco	 �
							//� para todos estes dados e a funcao TkMemo que retorna esta		 � 
							//� informacao.												 		 �
							//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
							If Len(aScripts[nScripts][3][nPosResp][9]) > 0								

								oSection3:Cell("S3_RESP" ):Disable()
								oSection3:Cell("S3_SCORE"):Disable()
								oSection3:Cell("S3_TOT"  ):Disable()					
								oSection3:Cell("S3_OBS"  ):Enable()
								
								cAuxObs := ""
								For nW := 1 To Len(aScripts[nScripts][3][nPosResp][9])
									aLinhas := TkMemo(aScripts[nScripts][3][nPosResp][9][nW],999)
									For nI := 1 to Len(aLinhas)
										cAuxObs += aLinhas[nI] + " " + CRLF
									Next nI
								Next nW

								oSection3:Cell("S3_OBS"):SetValue(cAuxObs)															

							EndIf
						Endif
						oSection3:PrintLine()	
					Endif
					
				Next nPosResp
				oSection3:Finish()					
				oSection2:Finish()		
			Next nPosPerg
			
			oSection1:Finish()		
		Next nScripts
	Else
		oReport:PrintText(STR0015)	//"Nao Existem dados a serem impressos para este relatorio com os parametros informados"
	EndIf	
EndIf

Return(.T.)